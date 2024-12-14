import 'package:flutter/material.dart';
import 'package:googleapis/adsense/v2.dart' as adsense;
import 'package:http/http.dart' as http;
import '../widgets/earning_card.dart';
import '../services/auth_client.dart';

class DashboardScreen extends StatefulWidget {
  final String accessToken;

  const DashboardScreen({super.key, required this.accessToken});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final Map<String, double> earnings = {
    'today': 0.0,
    'yesterday': 0.0,
    'lastWeek': 0.0,
    'lastWeekSameDay': 0.0,
    'thisMonth': 0.0,
    'previous7Days': 0.0
  };
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEarnings();
  }

  Future<void> _loadEarnings() async {
    setState(() => isLoading = true);
    try {
      final client = http.Client();
      final authClient = AuthClient(widget.accessToken, client);
      final adsenseApi = adsense.AdsenseApi(authClient);

      final accounts = await adsenseApi.accounts.list();
      if (accounts.accounts?.isEmpty ?? true) {
        throw Exception('AdSense 계정을 찾을 수 없습니다.');
      }

      final accountName = accounts.accounts!.first.name!;
      print(accounts.accounts);
      print('Account Name: $accountName');

      final now = DateTime.now();
      final startDate = now.subtract(const Duration(days: 31));

      final report = await adsenseApi.accounts.reports.generate(
        accountName,
        dateRange: 'CUSTOM',
        startDate_year: startDate.year,
        startDate_month: startDate.month,
        startDate_day: startDate.day,
        endDate_year: now.year,
        endDate_month: now.month,
        endDate_day: now.day,
        metrics: [
          'AD_REQUESTS',
          'PAGE_VIEWS',
          'IMPRESSIONS',
          'CLICKS',
          'MATCHED_AD_REQUESTS_CTR',
          'MATCHED_AD_REQUESTS_RPM',
          'ESTIMATED_EARNINGS',
        ],
        dimensions: ['DATE'],
      );

      print('=== AdSense Report ===');
      print('Headers: ${report.headers}');
      print('Warnings: ${report.warnings}');

      if (report.rows != null && report.rows!.isNotEmpty) {
        final earningsIndex = report.headers
                ?.indexWhere((header) => header.name == 'ESTIMATED_EARNINGS') ??
            6;

        final dailyEarnings = <String, double>{};

        for (var row in report.rows!) {
          final date = row.cells![0].value!;
          final earning =
              double.tryParse(row.cells![earningsIndex].value ?? '0') ?? 0.0;
          dailyEarnings[date] = earning;
          print('Date: $date, Earnings: $earning');
        }

        setState(() {
          earnings['today'] = dailyEarnings.values.lastOrNull ?? 0.0;
          earnings['yesterday'] =
              dailyEarnings.values.elementAtOrNull(dailyEarnings.length - 2) ??
                  0.0;

          final lastWeekSameDayEarning =
              dailyEarnings.values.elementAtOrNull(dailyEarnings.length - 9) ??
                  0.0;
          earnings['lastWeekSameDay'] = lastWeekSameDayEarning;

          // 최근 7일 수입
          final last7Days =
              dailyEarnings.values.toList().reversed.skip(1).take(7);
          earnings['lastWeek'] =
              last7Days.fold(0.0, (sum, value) => sum + value);

          // 이전 7일 수입 (7-14일 전)
          final previous7Days =
              dailyEarnings.values.toList().reversed.skip(7).take(7);
          earnings['previous7Days'] =
              previous7Days.fold(0.0, (sum, value) => sum + value);

          final thisMonthEarnings = dailyEarnings.entries
              .where((entry) {
                final date =
                    DateTime.parse(entry.key); // DATE 형식의 문자열을 DateTime으로 변환
                return date.year == now.year &&
                    date.month == DateTime.now().month;
              })
              .map((e) => e.value)
              .fold(0.0, (sum, earning) => sum + earning);

          earnings['thisMonth'] = thisMonthEarnings;
        });
      }
    } catch (e) {
      print('Error loading earnings: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('데이터 로딩 실패: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('예상 수입'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadEarnings,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                EarningCard(
                    title: '오늘 현재까지',
                    amount: earnings['today'] ?? 0,
                    comparison: null,
                    changeAmount: null),
                const SizedBox(height: 16),
                EarningCard(
                  title: '어제',
                  amount: earnings['yesterday'] ?? 0,
                  comparison: '지난주 같은 요일',
                  changeAmount: (earnings['yesterday'] ?? 0) -
                      (earnings['lastWeekSameDay'] ?? 0),
                  percentageChange: ((earnings['yesterday'] ?? 0) -
                          (earnings['lastWeekSameDay'] ?? 0)) /
                      (earnings['lastWeekSameDay'] ?? 1) *
                      100, // 0으로 나누는 것 방지를 위해 1로 설정
                ),
                const SizedBox(height: 16),
                EarningCard(
                  title: '지난 7일',
                  amount: earnings['lastWeek'] ?? 0,
                  comparison: '이전 7일',
                  changeAmount: (earnings['lastWeek'] ?? 0) -
                      (earnings['previous7Days'] ?? 0),
                  percentageChange: ((earnings['lastWeek'] ?? 0) -
                          (earnings['previous7Days'] ?? 0)) /
                      (earnings['previous7Days'] ?? 1) *
                      100,
                ),
                const SizedBox(height: 16),
                EarningCard(
                  title: '이번 달',
                  amount: earnings['thisMonth'] ?? 0,
                  comparison: '지난 동기',
                  changeAmount: (earnings['thisMonth'] ?? 0),
                ),
              ],
            ),
    );
  }
}

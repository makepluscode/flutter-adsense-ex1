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
    'lastMonth': 0.0,
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

      final report = await adsenseApi.accounts.reports.generate(
        accountName,
        dateRange: 'CUSTOM',
        startDate_year: 2024,
        startDate_month: 12,
        startDate_day: 1,
        endDate_year: 2024,
        endDate_month: 12,
        endDate_day: 31,
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

          final last7Days = dailyEarnings.values.toList().reversed.take(7);
          earnings['lastWeek'] =
              last7Days.fold(0.0, (sum, value) => sum + value);

          earnings['lastMonth'] =
              dailyEarnings.values.fold(0.0, (sum, value) => sum + value);
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
                  comparison: '어제',
                  changeAmount:
                      (earnings['today'] ?? 0) - (earnings['yesterday'] ?? 0),
                ),
                const SizedBox(height: 16),
                EarningCard(
                  title: '어제',
                  amount: earnings['yesterday'] ?? 0,
                  comparison: '지난 7일',
                  changeAmount: (earnings['yesterday'] ?? 0) -
                      ((earnings['lastWeek'] ?? 0) / 7),
                ),
                const SizedBox(height: 16),
                EarningCard(
                  title: '지난 7일',
                  amount: earnings['lastWeek'] ?? 0,
                  comparison: '이번 달',
                  changeAmount: (earnings['lastWeek'] ?? 0),
                ),
                const SizedBox(height: 16),
                EarningCard(
                  title: '이번 달',
                  amount: earnings['lastMonth'] ?? 0,
                  comparison: '지난 동기',
                  changeAmount: (earnings['lastMonth'] ?? 0),
                ),
              ],
            ),
    );
  }
}

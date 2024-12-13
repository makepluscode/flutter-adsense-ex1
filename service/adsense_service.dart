// services/adsense_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';

class AdSenseService {
  final String accessToken;

  AdSenseService(this.accessToken);

  Future<String?> getAccountId() async {
    try {
      final response = await http.get(
        Uri.parse('https://adsense.googleapis.com/v2/accounts'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['accounts']?.isNotEmpty) {
          return data['accounts'][0]['name'];
        }
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get AdSense account: $e');
    }
  }

  Future<Map<String, dynamic>> getDailyReport(String accountId) async {
    try {
      final now = DateTime.now();
      final response = await http.post(
        Uri.parse(
            'https://adsense.googleapis.com/v2/$accountId/reports:generate'),
        headers: _getHeaders(),
        body: json.encode({
          'reportingTimeZone': 'UTC',
          'dateRanges': [
            {'startDate': _formatDate(now), 'endDate': _formatDate(now)}
          ],
          'metrics': ['ESTIMATED_EARNINGS', 'PAGE_VIEWS', 'CLICKS']
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      throw Exception('API returned ${response.statusCode}: ${response.body}');
    } on http.ClientException catch (e) {
      throw Exception('네트워크 오류: $e');
    } on FormatException catch (e) {
      throw Exception('응답 데이터 파싱 오류: $e');
    } catch (e) {
      throw Exception('AdSense 리포트 조회 실패: $e');
    }
  }

  Map<String, String> _getHeaders() => {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

import 'package:dio/dio.dart';
import 'analytics_model.dart';

class AnalyticsService {
  final Dio _dio = Dio();
  final String baseUrl =
      'https://xo7bxp4hwrfw4x6mpvcixnr3xm0bqhlp.lambda-url.ap-south-1.on.aws/';

  Future<AnalyticsData> fetchAnalyticsData(
      {required int month, required int year}) async {
    try {
      final response = await _dio.get(
        baseUrl,
        queryParameters: {
          'table_name': 'onDutyModel-2jskpek75veajd4yfnqjmkppmu-NONE',
          'index_name': '__typename-createdAt-index',
          'partition_key_value': 'onDutyModel',
          'partition_key': '__typename',
          'limit': 100,
          'month': month,
          'year': year,
        },
      );

      if (response.statusCode == 200) {
        return AnalyticsData.fromJson(response.data);
      } else {
        throw Exception(
            'Failed to load analytics data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching analytics data: $e');
    }
  }
}

import '../models/exam_scorebook.dart';
import 'api_client.dart';

class PdfExportService {
  PdfExportService._();

  static final PdfExportService instance = PdfExportService._();

  final ApiClient _api = ApiClient.instance;

  Future<void> generateSummary() async {
    await _api.post('/scores/export');
  }

  Future<List<ExamScorebook>> fetchScores() async {
    final response = await _api.get('/scores') as Map<String, dynamic>;
    final list = response['exams'] as List<dynamic>? ?? [];
    return list
        .whereType<Map<String, dynamic>>()
        .map(ExamScorebook.fromJson)
        .toList(growable: false);
  }
}

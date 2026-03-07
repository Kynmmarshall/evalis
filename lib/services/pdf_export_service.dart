import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/exam_scorebook.dart';
import 'api_client.dart';

class PdfExportService {
  PdfExportService._();

  static final PdfExportService instance = PdfExportService._();

  final ApiClient _api = ApiClient.instance;

  Future<List<ExamScorebook>> fetchScores() async {
    final response = await _api.get('/scores') as Map<String, dynamic>;
    final list = response['exams'] as List<dynamic>? ?? [];
    return list
        .whereType<Map<String, dynamic>>()
        .map(ExamScorebook.fromJson)
        .toList(growable: false);
  }

  Future<ExamScorebook> fetchScorebook(String examId) async {
    final response = await _api.get('/scores/$examId') as Map<String, dynamic>;
    final exam = response['exam'];
    if (exam is Map<String, dynamic>) {
      return ExamScorebook.fromJson(exam);
    }
    throw const ApiException('Scorebook unavailable');
  }

  Future<String> downloadExamPdf(String examId) async {
    final response = await _api.getRaw('/scores/$examId/pdf');
    final fileName = _resolveFileName(response.headers['content-disposition'], examId);
    final directory = await _ensureScorebookDirectory();
    final file = File('${directory.path}/$fileName');
    await file.writeAsBytes(response.bodyBytes, flush: true);
    return file.path;
  }

  Future<Directory> _ensureScorebookDirectory() async {
    final baseDir = await getApplicationDocumentsDirectory();
    final scorebookDir = Directory('${baseDir.path}/scorebooks');
    if (!await scorebookDir.exists()) {
      await scorebookDir.create(recursive: true);
    }
    return scorebookDir;
  }

  String _resolveFileName(String? disposition, String examId) {
    if (disposition != null) {
      final match = RegExp("filename\\*=UTF-8''([^;]+)").firstMatch(disposition);
      if (match != null) {
        return match.group(1)!;
      }
      final simpleMatch = RegExp('filename="?([^";]+)"?').firstMatch(disposition);
      if (simpleMatch != null) {
        return simpleMatch.group(1)!;
      }
    }
    final sanitized = examId.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '-');
    return 'scorebook-$sanitized.pdf';
  }
}

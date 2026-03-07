import '../models/exam_brief.dart';
import '../models/mock_question.dart';
import 'api_client.dart';

class AssessmentService {
  AssessmentService._();

  static final AssessmentService instance = AssessmentService._();

  final ApiClient _api = ApiClient.instance;

  Future<List<ExamBrief>> fetchExams({String? state}) async {
    final response = await _api.get('/exams', query: state == null ? null : {'state': state})
        as Map<String, dynamic>;
    final list = response['exams'] as List<dynamic>? ?? [];
    return list.whereType<Map<String, dynamic>>().map(ExamBrief.fromJson).toList(growable: false);
  }

  Future<List<ExamBrief>> fetchClosedExams() => fetchExams(state: 'closed');

  Future<ExamBrief> createExam({
    required String title,
    required String courseCode,
    required String examWindow,
  }) async {
    final response = await _api.post('/exams', body: {
      'title': title,
      'courseCode': courseCode,
      'examWindow': examWindow,
    }) as Map<String, dynamic>;
    return ExamBrief.fromJson(response['exam'] as Map<String, dynamic>);
  }

  Future<ExamBrief> updateExamSchedule({
    required String examId,
    required String examWindow,
    required DateTime startAt,
    required DateTime endAt,
    required bool launched,
  }) async {
    final response = await _api.patch('/exams/$examId/schedule', body: {
      'examWindow': examWindow,
      'startAt': startAt.toUtc().toIso8601String(),
      'endAt': endAt.toUtc().toIso8601String(),
      'launched': launched,
    }) as Map<String, dynamic>;
    return ExamBrief.fromJson(response['exam'] as Map<String, dynamic>);
  }

  Future<void> deleteExam(String id) async {
    await _api.post('/exams/$id/delete');
  }

  Future<List<MockQuestion>> fetchQuestions(String examId) async {
    final response = await _api.get('/exams/$examId/questions') as Map<String, dynamic>;
    final list = response['questions'] as List<dynamic>? ?? [];
    return list.whereType<Map<String, dynamic>>().map(MockQuestion.fromJson).toList(growable: false);
  }

  Future<void> addQuestion({
    required String examId,
    required String prompt,
    required List<String> options,
    required int correctIndex,
    String? tip,
  }) async {
    await _api.post('/exams/$examId/questions', body: {
      'prompt': prompt,
      'options': options,
      'correctIndex': correctIndex,
      'tip': tip ?? '',
    });
  }

  Future<void> submitResponse({
    required String examId,
    required String questionId,
    required int optionIndex,
  }) async {
    await _api.post('/exams/$examId/questions/$questionId/response', body: {
      'optionIndex': optionIndex,
    });
  }

  Future<List<MockQuestion>> fetchPracticeQuestions() async {
    final exams = await fetchExams(state: 'live');
    if (exams.isEmpty) {
      return const [];
    }
    return fetchQuestions(exams.first.id);
  }
}

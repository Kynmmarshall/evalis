import '../models/learning_resource.dart';
import '../models/past_material.dart';
import 'api_client.dart';

class ResourceService {
  ResourceService._();

  static final ResourceService instance = ResourceService._();

  final ApiClient _api = ApiClient.instance;

  Future<List<LearningResource>> fetchResources() async {
    final response = await _api.get('/resources') as Map<String, dynamic>;
    final list = response['resources'] as List<dynamic>? ?? [];
    return list.whereType<Map<String, dynamic>>().map(LearningResource.fromJson).toList(growable: false);
  }

  Future<List<PastMaterial>> fetchPastMaterials() async {
    final response = await _api.get('/materials') as Map<String, dynamic>;
    final list = response['materials'] as List<dynamic>? ?? [];
    return list.whereType<Map<String, dynamic>>().map(PastMaterial.fromJson).toList(growable: false);
  }

  Future<void> addResource({
    required String title,
    required String description,
    required String format,
    required String eta,
  }) async {
    await _api.post('/resources', body: {
      'title': title,
      'description': description,
      'format': format,
      'eta': eta,
    });
  }

  Future<void> addMaterial({
    required String title,
    required String topic,
    required String duration,
    required String difficulty,
  }) async {
    await _api.post('/materials', body: {
      'title': title,
      'topic': topic,
      'duration': duration,
      'difficulty': difficulty,
    });
  }
}

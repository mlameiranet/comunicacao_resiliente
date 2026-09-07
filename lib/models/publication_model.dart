import 'scene_model.dart';

class Publication {
  final String id;
  final String title;
  final String description;
  final String category;
  final String version;
  final List<SceneModel> scenes;

  const Publication({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.version,
    required this.scenes,
  });
}

enum SceneType {
  textOnly,
  imageText,
  audioText,
  videoText,
}

class SceneModel {
  final String id;
  final String title;
  final String content;
  final String? assetPath;
  final SceneType type;

  const SceneModel({
    required this.id,
    required this.title,
    required this.content,
    this.assetPath,
    required this.type,
  });
}

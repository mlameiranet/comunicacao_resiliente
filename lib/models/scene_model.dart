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
  final String? caption; // Novo campo opcional
  final SceneType type;

  const SceneModel({
    required this.id,
    required this.title,
    required this.content,
    this.assetPath,
    this.caption,
    required this.type,
  });
}

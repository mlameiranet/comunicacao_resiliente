enum SceneType {
  textOnly,
  imageText,
  audioText,
  videoText,
  intro, // Novo tipo
}

class SceneModel {
  final String id;
  final String title;
  final String content;
  final String? assetPath;
  final String? imageUrl; // Novo campo para fotos externas
  final String? mediaUrl; // Novo campo para vídeos externos
  final String? caption;
  final SceneType type;

  const SceneModel({
    required this.id,
    required this.title,
    required this.content,
    this.assetPath,
    this.imageUrl,
    this.mediaUrl,
    this.caption,
    required this.type,
  });
}

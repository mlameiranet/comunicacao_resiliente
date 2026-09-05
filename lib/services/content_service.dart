import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/scene_model.dart';

class ContentService {
  /// Carrega as cenas a partir do arquivo JSON nos assets.
  Future<List<SceneModel>> getScenes() async {
    try {
      final String response = await rootBundle.loadString('assets/scenes.json');
      final List<dynamic> data = json.decode(response);
      
      return data.map((jsonItem) {
        return SceneModel(
          id: jsonItem['id'],
          title: jsonItem['title'],
          content: jsonItem['content'],
          assetPath: jsonItem['assetPath'],
          type: _parseSceneType(jsonItem['type']),
        );
      }).toList();
    } catch (e) {
      // Fallback em caso de erro ao carregar o JSON
      return [
        const SceneModel(
          id: 'error',
          title: 'Erro ao carregar',
          content: 'Não foi possível carregar o conteúdo das cenas.',
          type: SceneType.textOnly,
        ),
      ];
    }
  }

  SceneType _parseSceneType(String type) {
    switch (type) {
      case 'imageText':
        return SceneType.imageText;
      case 'audioText':
        return SceneType.audioText;
      case 'videoText':
        return SceneType.videoText;
      default:
        return SceneType.textOnly;
    }
  }
}

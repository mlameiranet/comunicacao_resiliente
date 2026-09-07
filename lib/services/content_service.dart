import 'dart:convert';
import 'package:flutter/services.dart';
// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;
import '../models/scene_model.dart';
import '../models/publication_model.dart';

class ContentService {
  /// Carrega uma publicação a partir do arquivo JSON dinâmico baseado na URL.
  Future<Publication> getPublication() async {
    try {
      // 1. Tenta obter o ID da URL (?id=001)
      final uri = Uri.parse(html.window.location.href);
      final pubId = uri.queryParameters['id'] ?? '001'; // Fallback para 001
      
      // 2. Tenta carregar o arquivo específico da biblioteca
      String jsonPath = 'assets/publications/$pubId.json';
      
      String response;
      try {
        response = await rootBundle.loadString(jsonPath);
      } catch (e) {
        // Se não achar na pasta nova, tenta o arquivo principal antigo
        response = await rootBundle.loadString('assets/scenes.json');
      }

      final Map<String, dynamic> data = json.decode(response);
      
      final List<dynamic> scenesData = data['scenes'];
      final List<SceneModel> scenes = scenesData.map((jsonItem) {
        // Suporte para os campos manuais que você inseriu
        String? mediaUrl;
        if (jsonItem['media'] != null && jsonItem['media']['url'] != null) {
          mediaUrl = jsonItem['media']['url'];
        }

        return SceneModel(
          id: jsonItem['id'],
          title: jsonItem['title'],
          content: jsonItem['content'],
          assetPath: jsonItem['assetPath'],
          imageUrl: jsonItem['image_url'], // Mapeia image_url do seu JSON
          mediaUrl: mediaUrl,              // Mapeia o vídeo externo
          caption: jsonItem['caption'] ?? (jsonItem['media'] != null ? jsonItem['media']['caption'] : null),
          type: _parseSceneType(jsonItem['type']),
        );
      }).toList();

      return Publication(
        id: data['id'],
        title: data['title'],
        description: data['description'],
        category: data['category'],
        version: data['version'],
        scenes: scenes,
      );
    } catch (e) {
      // Fallback em caso de erro ao carregar o JSON
      return const Publication(
        id: 'error',
        title: 'Erro',
        description: 'Erro ao carregar',
        category: 'Erro',
        version: '0.0',
        scenes: [
          SceneModel(
            id: 'error',
            title: 'Erro ao carregar',
            content: 'Não foi possível carregar o conteúdo da publicação.',
            type: SceneType.textOnly,
          ),
        ],
      );
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
      case 'intro':
        return SceneType.intro;
      default:
        return SceneType.textOnly;
    }
  }
}

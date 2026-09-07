// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:js' as js;

class AnalyticsService {
  /// Registra a visualização de uma cena específica.
  /// Isso ajuda a saber até onde os usuários estão lendo.
  static void logSceneView(String sceneId, String title) {
    try {
      // Chama a função global do Google Analytics se ela existir no index.html
      js.context.callMethod('gtag', [
        'event',
        'scene_view',
        {
          'scene_id': sceneId,
          'scene_title': title,
        }
      ]);
    } catch (e) {
      // Falha silenciosa para não atrapalhar o usuário
    }
  }

  /// Registra quando o usuário clica em compartilhar.
  static void logShare() {
    try {
      js.context.callMethod('gtag', ['event', 'share_clicked']);
    } catch (e) {}
  }

  /// Registra o início da apresentação (clique no Splash).
  static void logStart() {
    try {
      js.context.callMethod('gtag', ['event', 'presentation_started']);
    } catch (e) {}
  }
}

// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

class BrowserService {
  html.AudioElement? _audioElement;

  /// Tenta fechar a aba ou janela do navegador.
  void closeWindow() {
    html.window.close();
    if (html.window.closed == false) {
      html.window.location.href = "about:blank";
    }
  }

  /// Ativa o modo de tela cheia.
  void toggleFullScreen() {
    if (html.document.fullscreenElement == null) {
      html.document.documentElement?.requestFullscreen();
    } else {
      html.document.exitFullscreen();
    }
  }

  /// Toca um áudio a partir de um caminho de asset.
  void playAudio(String assetPath, {Function? onEnded}) {
    stopAudio();
    // No Flutter Web, assets ficam em 'assets/assets/...' em alguns builds, 
    // mas o caminho relativo padrão geralmente funciona.
    _audioElement = html.AudioElement(assetPath);
    _audioElement?.onEnded.listen((_) {
      if (onEnded != null) onEnded();
    });
    _audioElement?.play();
  }

  /// Pausa o áudio atual.
  void pauseAudio() {
    _audioElement?.pause();
  }

  /// Retoma o áudio atual.
  void resumeAudio() {
    _audioElement?.play();
  }

  /// Para e remove o áudio.
  void stopAudio() {
    _audioElement?.pause();
    _audioElement?.src = "";
    _audioElement = null;
  }
}

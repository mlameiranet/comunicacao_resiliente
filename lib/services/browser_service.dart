// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
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
    
    // Técnica de Resiliência de Caminho para Flutter Web / GitHub Pages
    // Tenta o caminho original e o caminho com o prefixo duplo do Flutter Web
    String path1 = assetPath;
    if (!path1.startsWith('assets/')) path1 = 'assets/$path1';
    
    String path2 = 'assets/$path1'; // Resulta em assets/assets/...

    _audioElement = html.AudioElement();
    
    // Tenta o caminho 1, se der erro, tenta o caminho 2
    _audioElement?.onError.listen((_) {
      if (_audioElement?.src != path2) {
        _audioElement?.src = path2;
        _audioElement?.play();
      }
    });

    _audioElement?.src = path1;
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

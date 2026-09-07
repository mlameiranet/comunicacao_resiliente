import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'dart:ui_web' as ui_web;
// ignore: deprecated_member_use, avoid_web_libraries_in_flutter
import 'dart:html' as html;
import '../models/scene_model.dart';
import '../models/publication_model.dart';
import '../services/content_service.dart';
import '../services/browser_service.dart';
import '../services/analytics_service.dart';
import '../widgets/marajoara_pattern_painter.dart';

class PresentationScreen extends StatefulWidget {
  const PresentationScreen({super.key});

  @override
  State<PresentationScreen> createState() => _PresentationScreenState();
}

class _PresentationScreenState extends State<PresentationScreen> {
  final ContentService _contentService = ContentService();
  final BrowserService _browserService = BrowserService();
  Publication? _publication;
  int _currentIndex = 0;
  bool _isFinished = false;
  bool _isAudioPlaying = false;
  bool _isLoading = true;
  bool _hasStarted = false;

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  Future<void> _loadContent() async {
    final publication = await _contentService.getPublication();
    setState(() {
      _publication = publication;
      _isLoading = false;
    });
  }

  void _startPresentation() {
    _browserService.toggleFullScreen(); // Ativa tela cheia no clique
    AnalyticsService.logStart(); // Auditoria: Início
    setState(() {
      _hasStarted = true;
    });
    // Log da primeira cena
    if (_publication != null && _publication!.scenes.isNotEmpty) {
      final firstScene = _publication!.scenes[0];
      AnalyticsService.logSceneView(firstScene.id, firstScene.title);
    }
  }

  void _nextScene() {
    _browserService.stopAudio();
    setState(() => _isAudioPlaying = false);
    
    if (_publication != null) {
      if (_currentIndex < _publication!.scenes.length - 1) {
        setState(() {
          _currentIndex++;
        });
        // Auditoria: Visualização da nova cena
        final currentScene = _publication!.scenes[_currentIndex];
        AnalyticsService.logSceneView(
          currentScene.id, 
          currentScene.title
        );
      } else {
        // Se já está na última cena e clicou em Próximo/Concluir
        setState(() {
          _isFinished = true;
        });
      }
    }
  }

  void _previousScene() {
    _browserService.stopAudio();
    setState(() => _isAudioPlaying = false);
    
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _isFinished = false;
      });
    }
  }

  void _toggleAudio(String? assetPath) {
    if (assetPath == null) return;

    if (_isAudioPlaying) {
      _browserService.pauseAudio();
      setState(() => _isAudioPlaying = false);
    } else {
      _browserService.playAudio(assetPath, onEnded: () {
        setState(() => _isAudioPlaying = false);
      });
      setState(() => _isAudioPlaying = true);
    }
  }

  void _onConcluir() {
    _browserService.closeWindow();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (!_hasStarted) {
      return _buildStartScreen();
    }

    if (_isFinished) {
      return _buildFinishScreen();
    }

    final currentScene = _publication!.scenes[_currentIndex];
    final progress = (_currentIndex + 1) / _publication!.scenes.length;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Transparente para mostrar o padrão
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            onPressed: () => _browserService.toggleFullScreen(),
            icon: const Icon(Icons.fullscreen, color: Color(0xFF2D5A27)),
          )
        ],
      ),
      extendBodyBehindAppBar: true, // Faz o padrão subir até o topo
      body: Stack(
        children: [
          // Camada 1: Padrão Marajoara de Fundo
          Positioned.fill(
            child: CustomPaint(
              painter: MarajoaraPatternPainter(
                color: const Color(0xFF2D5A27).withValues(alpha: 0.04), // Muito sutil
              ),
            ),
          ),
          
          // Camada 2: Conteúdo da Aplicação
          SafeArea(
            child: Column(
              children: [
                // Barra de Progresso Superior
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey[300]?.withValues(alpha: 0.5) ?? Colors.grey.withValues(alpha: 0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                      minHeight: 6,
                    ),
                  ),
                ),
                
                // Área de Conteúdo
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.05, 0),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: SingleChildScrollView(
                      key: ValueKey<int>(_currentIndex),
                      padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentScene.title,
                            style: Theme.of(context).textTheme.headlineLarge,
                          ),
                          const SizedBox(height: 24),
                          MarkdownBody(
                            data: currentScene.content,
                            styleSheet: MarkdownStyleSheet(
                              p: Theme.of(context).textTheme.bodyLarge,
                              strong: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF2D5A27),
                              ),
                              listBullet: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                          const SizedBox(height: 40),
                          
                          // Placeholder ou Mídia Real (Melhorado para links externos)
                          if (currentScene.type != SceneType.textOnly || 
                              currentScene.imageUrl != null || 
                              currentScene.mediaUrl != null)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: double.infinity,
                                  height: 240,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.05),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                    border: Border.all(color: const Color(0xFFE0E0E0)),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: _buildMediaContent(currentScene),
                                  ),
                                ),
                                if (currentScene.caption != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 12, left: 8),
                                    child: Text(
                                      currentScene.caption!,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontStyle: FontStyle.italic,
                                        color: Colors.black45,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Controles Inferiores
                Container(
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Botão Voltar
                      IconButton(
                        onPressed: _currentIndex > 0 ? _previousScene : null,
                        icon: const Icon(Icons.arrow_back_ios_new),
                        color: Theme.of(context).primaryColor,
                        iconSize: 28,
                      ),
                      
                      // Indicador Numérico
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${_currentIndex + 1} / ${_publication!.scenes.length}',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black54),
                        ),
                      ),
                      
                      // Botão Próximo ou Finalizar
                      ElevatedButton(
                        onPressed: _nextScene, // Sempre chama _nextScene, que agora decide se avança ou finaliza
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          _currentIndex == _publication!.scenes.length - 1 ? 'Concluir' : 'Próximo',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinishScreen() {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: MarajoaraPatternPainter(
                color: const Color(0xFF2D5A27).withValues(alpha: 0.04),
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.verified_user, size: 100, color: Color(0xFF2D5A27)),
                  const SizedBox(height: 24),
                  Text(
                    'Missão Cumprida!',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Você finalizou esta orientação. Que tal compartilhar este conhecimento com um vizinho ou parente?',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, color: Colors.black54),
                  ),
                  const SizedBox(height: 48),
                  
                  // Botão Compartilhar
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Lógica de compartilhar via WhatsApp
                        final url = "https://wa.me/?text=Olha que interessante esse guia do Marajó Resiliente: https://mlameiranet.github.io/comunicacao_resiliente/";
                        html.window.open(url, "_blank");
                      },
                      icon: const Icon(Icons.share, color: Colors.white),
                      label: const Text('COMPARTILHAR NO WHATSAPP', 
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0066CC), // Azul para diferenciar do concluir
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Botão Concluir
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _onConcluir,
                      icon: const Icon(Icons.close, color: Color(0xFF25D366)),
                      label: const Text('ENCERRAR E VOLTAR', 
                        style: TextStyle(color: Color(0xFF2D5A27), fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF25D366), width: 2),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStartScreen() {
    return Scaffold(
      body: GestureDetector(
        onTap: _startPresentation, // Inicia a apresentação ao tocar em qualquer lugar
        behavior: HitTestBehavior.opaque, // Garante que o toque funcione em toda a área
        child: Stack(
          children: [
            // Camada 1: Sua Imagem de Fundo (splash_bg.jpg)
            // Agora você pode desenhar o botão diretamente nesta imagem
            Positioned.fill(
              child: Image.asset(
                'assets/images/splash_bg.jpg',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: const Color(0xFF2D5A27),
                    child: const Center(
                      child: Text(
                        'Toque para iniciar',
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaContent(SceneModel scene) {
    // 1. Suporte para Fotos Externas (Links)
    if (scene.imageUrl != null) {
      return GestureDetector(
        onTap: () => _showFullScreenImage(context, scene.imageUrl!, isNetwork: true),
        child: Image.network(
          scene.imageUrl!,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => _buildMediaPlaceholder(scene.type),
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const Center(child: CircularProgressIndicator());
          },
        ),
      );
    }

    // 2. Suporte para Vídeos Externos (YouTube)
    if (scene.mediaUrl != null && scene.mediaUrl!.contains('youtube')) {
      final viewId = 'youtube-${scene.id}';
      final videoId = _extractYoutubeId(scene.mediaUrl!);
      
      // ignore: undefined_prefixed_name
      ui_web.platformViewRegistry.registerViewFactory(viewId, (int viewId) {
        final iframe = html.IFrameElement()
          ..src = 'https://www.youtube.com/embed/$videoId'
          ..style.border = 'none'
          ..style.width = '100%'
          ..style.height = '100%'
          ..allowFullscreen = true;
        return iframe;
      });

      return HtmlElementView(viewType: viewId);
    }

    // 3. Suporte original para Assets Locais
    if (scene.type == SceneType.imageText && scene.assetPath != null) {
      final paths = scene.assetPath!.split(',');
      
      if (paths.length > 1) {
        return PageView.builder(
          itemCount: paths.length,
          itemBuilder: (context, index) {
            final imagePath = paths[index].trim();
            return GestureDetector(
              onTap: () => _showFullScreenImage(context, imagePath),
              child: Image.asset(
                imagePath,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => _buildMediaPlaceholder(scene.type),
              ),
            );
          },
        );
      }

      return GestureDetector(
        onTap: () => _showFullScreenImage(context, scene.assetPath!),
        child: Image.asset(
          scene.assetPath!,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => _buildMediaPlaceholder(scene.type),
        ),
      );
    }

    if (scene.type == SceneType.audioText) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: () => _toggleAudio(scene.assetPath),
              icon: Icon(
                _isAudioPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                size: 80,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _isAudioPlaying ? 'Ouvindo orientação...' : 'Tocar orientação',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    if (scene.type == SceneType.videoText && scene.assetPath != null) {
      final viewId = 'video-player-${scene.id}';
      String videoPath = scene.assetPath!;
      if (!videoPath.startsWith('assets/')) {
        videoPath = 'assets/$videoPath';
      }
      final String finalVideoPath = 'assets/$videoPath';
      
      // ignore: undefined_prefixed_name
      ui_web.platformViewRegistry.registerViewFactory(viewId, (int viewId) {
        final videoElement = html.VideoElement()
          ..src = finalVideoPath
          ..controls = true
          ..style.border = 'none'
          ..style.width = '100%'
          ..style.height = '100%'
          ..style.objectFit = 'contain'
          ..style.borderRadius = '20px';
        return videoElement;
      });

      return HtmlElementView(viewType: viewId);
    }
    
    return _buildMediaPlaceholder(scene.type);
  }

  String _extractYoutubeId(String url) {
    // Shorts: youtube.com/shorts/ID
    if (url.contains('shorts/')) {
      return url.split('shorts/').last.split('?').first;
    }
    // Mobile/Short: youtu.be/ID
    if (url.contains('youtu.be/')) {
      return url.split('youtu.be/').last.split('?').first;
    }
    // Standard: youtube.com/watch?v=ID
    if (url.contains('v=')) {
      return url.split('v=').last.split('&').first;
    }
    return '';
  }

  void _showFullScreenImage(BuildContext context, String imagePath, {bool isNetwork = false}) {
    showDialog(
      context: context,
      builder: (context) => Dialog.fullscreen(
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            Positioned.fill(
              child: InteractiveViewer(
                panEnabled: true,
                minScale: 0.5,
                maxScale: 4.0,
                child: isNetwork 
                  ? Image.network(imagePath, fit: BoxFit.contain)
                  : Image.asset(imagePath, fit: BoxFit.contain),
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: CircleAvatar(
                backgroundColor: Colors.black54,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaPlaceholder(SceneType type) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getIconForType(type),
            size: 64,
            color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 12),
          Text(
            'Mídia em breve',
            style: TextStyle(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.4),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showFullScreenImage(BuildContext context, String imagePath) {
    showDialog(
      context: context,
      builder: (context) => Dialog.fullscreen(
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            Positioned.fill(
              child: InteractiveViewer(
                panEnabled: true,
                minScale: 0.5,
                maxScale: 4.0,
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: CircleAvatar(
                backgroundColor: Colors.black54,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForType(SceneType type) {
    switch (type) {
      case SceneType.imageText:
        return Icons.image;
      case SceneType.audioText:
        return Icons.audiotrack;
      case SceneType.videoText:
        return Icons.videocam;
      case SceneType.intro:
        return Icons.info_outline;
      default:
        return Icons.text_fields;
    }
  }
}

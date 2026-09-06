import 'package:flutter/material.dart';

class MarajoaraPatternPainter extends CustomPainter {
  final Color color;

  MarajoaraPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    const double spacing = 60.0;
    
    // Desenha triângulos e linhas em padrão de grade sutil
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        final path = Path();
        // Desenho geométrico básico inspirado em padrões Marajoara
        path.moveTo(x, y + 20);
        path.lineTo(x + 20, y);
        path.lineTo(x + 40, y + 20);
        path.lineTo(x + 20, y + 40);
        path.close();
        
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

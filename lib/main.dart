import 'package:flutter/material.dart';
import 'screens/presentation_screen.dart';

void main() {
  runApp(const ResilientCommunicationApp());
}

class ResilientCommunicationApp extends StatelessWidget {
  const ResilientCommunicationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Marajó Resiliente',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2D5A27),
          primary: const Color(0xFF2D5A27),
          secondary: const Color(0xFF8B4513),
          surface: const Color(0xFFFDFCF5),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            fontSize: 28, // Reduzi um pouco para telas menores
            fontWeight: FontWeight.w900,
            color: Color(0xFF1B3318),
            letterSpacing: -0.5,
          ),
          bodyLarge: TextStyle(
            fontSize: 18, // Tamanho ideal para leitura mobile
            height: 1.6,
            color: Color(0xFF333333),
          ),
        ),
      ),
      builder: (context, child) {
        // Isso garante que em telas grandes a aplicação fique centralizada como um celular
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: child,
          ),
        );
      },
      home: const PresentationScreen(),
    );
  }
}

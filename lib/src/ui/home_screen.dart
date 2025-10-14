import 'package:flutter/material.dart';
import '../../main.dart' show kAppTitle;

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(kAppTitle)), // <- sin const
      body: const Center(
        child: Text(
          'VidSnap Reader — Fase 1\n(Build de prueba OK)',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'presentation/pages/home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SoundScribeApp());
}

class SoundScribeApp extends StatelessWidget {
  const SoundScribeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SoundScribe',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const HomePage(),
    );
  }
}

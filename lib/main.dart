// File: /storage/emulated/0/Download/Tester/lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/login_screen.dart';
import 'utils/constants.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Lock orientation to portrait
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  
  // Set system UI style
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF0A0E21),
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  
  runApp(const TesterApp());
}

class TesterApp extends StatelessWidget {
  const TesterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'System Security Scanner',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'ShareTechMono',
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFF0A0E21),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1A1F38),
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontFamily: 'ShareTechMono',
            fontSize: 18,
            color: Colors.white,
            letterSpacing: 2,
          ),
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontFamily: 'ShareTechMono',
            fontSize: 32,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          bodyLarge: TextStyle(
            fontFamily: 'ShareTechMono',
            fontSize: 16,
            color: Color(0xFF8A8DAA),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF1A1F38),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color(0xFF2196F3),
              width: 2,
            ),
          ),
          contentPadding: const EdgeInsets.all(20),
          hintStyle: const TextStyle(
            fontFamily: 'ShareTechMono',
            color: Color(0xFF5A5D7A),
          ),
          labelStyle: const TextStyle(
            fontFamily: 'ShareTechMono',
            color: Color(0xFF8A8DAA),
            letterSpacing: 1.5,
          ),
        ),
      ),
      home: const LoginScreen(),
    );
  }
}

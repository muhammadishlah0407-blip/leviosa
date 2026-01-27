import 'package:leviosa/pages/dashboard.dart';
import 'package:leviosa/pages/login_screen.dart';
import 'package:leviosa/pages/register_screen.dart';
import 'package:leviosa/pages/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://vgfpiqzjsozomsvrnrtb.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZnZnBpcXpqc296b21zdnJucnRiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDk4NjQ4NzEsImV4cCI6MjA2NTQ0MDg3MX0.y-Wx10YB00jyZ-ttOmEKdCjMfreUPJNVmKl9RwDrYLg',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Leviosa',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        primaryColor: const Color(0xFF3B82F6),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3B82F6),
          brightness: Brightness.dark,
          background: const Color(0xFF0F172A),
        ),
        fontFamily: 'Montserrat',
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 28,
            color: Colors.white,
            letterSpacing: 1.5,
            shadows: [
              Shadow(
                color: Color(0xFF3B82F6),
                blurRadius: 12,
                offset: Offset(0, 0),
              ),
            ],
          ),
          bodyLarge: TextStyle(fontSize: 16, color: Colors.white70),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0D1B2A),
          foregroundColor: Colors.white,
          elevation: 0,
          titleTextStyle: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
            letterSpacing: 1.2,
            shadows: [
              Shadow(
                color: Color(0xFF3B82F6),
                blurRadius: 8,
                offset: Offset(0, 0),
              ),
            ],
          ),
        ),
      ),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/dashboard': (context) => const Dashboard(),
        '/splash': (context) => const SplashScreen(),
      },
      home: const SplashScreen(),
    );
  }
}

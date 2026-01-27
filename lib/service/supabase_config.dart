import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String url = 'https://vgfpiqzjsozomsvrnrtb.supabase.co';
  static const String anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZnZnBpcXpqc296b21zdnJucnRiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDk4NjQ4NzEsImV4cCI6MjA2NTQ0MDg3MX0.y-Wx10YB00jyZ-ttOmEKdCjMfreUPJNVmKl9RwDrYLg';

  static Future<void> initialize() async {
    try {
      await Supabase.initialize(
        url: url,
        anonKey: anonKey,
      );
    } catch (e) {
      rethrow;
    }
  }

  static SupabaseClient get client {
    try {
      return Supabase.instance.client;
    } catch (e) {
      throw Exception('Supabase client not initialized');
    }
  }

  static bool get isInitialized {
    try {
      Supabase.instance.client;
      return true;
    } catch (e) {
      return false;
    }
  }
} 
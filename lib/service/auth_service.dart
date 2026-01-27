import 'package:leviosa/pages/dashboard.dart';
import 'package:leviosa/pages/splash_screen.dart';
// import 'package:leviosa/service/supabase_config.dart'; // unused import dihapus
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';

class AuthService {
  final supabase = Supabase.instance.client;

  Future<void> login(
    String? email,
    String password,
    BuildContext context,
  ) async {
    try {
      final AuthResponse res = await supabase.auth.signInWithPassword(
        email: email!,
        password: password,
      );
      final User? user = res.user;
      if (!context.mounted) return;
      if (user != null) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const Dashboard()),
          (route) => false,
        );
      }
    } on AuthException catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(e.message, style: const TextStyle(color: Colors.white)),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            e.toString(),
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
    }
  }

  Future<void> register(
    String? email,
    String password,
    BuildContext context,
  ) async {
    try {
      final AuthResponse res = await supabase.auth.signUp(
        email: email!,
        password: password,
      );
      
      final User? user = res.user;
      
      if (!context.mounted) return;
      if (user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Text('Registration successful! Please check your email.', 
              style: TextStyle(color: Colors.white)),
          ),
        );
      }
    } on AuthException catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(e.message, style: const TextStyle(color: Colors.white)),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            e.toString(),
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
    }
  }

  Future<void> logout(BuildContext context) async {
    try {
      await supabase.auth.signOut();
      
      if (!context.mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const SplashScreen()),
        (route) => false,
      );
    } catch (e) {
      // print('***** Error during logout: $e');
    }
  }

  // Update profil user (display_name, avatar_url)
  Future<void> updateProfile({
    required String userId,
    String? displayName,
    String? avatarUrl,
  }) async {
    final updates = <String, dynamic>{};
    if (displayName != null) updates['display_name'] = displayName;
    if (avatarUrl != null) updates['avatar_url'] = avatarUrl;
    if (updates.isEmpty) return;
    await supabase.from('profiles').update(updates).eq('id', userId);
  }
}

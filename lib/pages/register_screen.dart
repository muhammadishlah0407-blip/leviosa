import 'package:flutter/material.dart';
import 'package:leviosa/pages/login_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with TickerProviderStateMixin {
  final emailController = TextEditingController();
  final passController = TextEditingController();
  final nameController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    emailController.dispose();
    passController.dispose();
    nameController.dispose();
    super.dispose();
  }

  Future<void> register() async {
    final email = emailController.text.trim();
    final password = passController.text.trim();
    final name = nameController.text.trim();

    if (email.isEmpty || password.isEmpty || name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.orange,
          content: Text('Nama, email, dan password harus diisi!'),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final res = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {'display_name': name},
      );

      if (res.user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Text('Registrasi berhasil! Silakan login.'),
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    } on AuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: Colors.red, content: Text(e.message)),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value,
                  child: Transform.translate(
                    offset: Offset(0, 40 * (1 - _fadeAnimation.value)),
                    child: child,
                  ),
                );
              },
              child: Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                elevation: 10,
                shadowColor: Colors.blue.withOpacity(0.08),
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 10),
                      Center(
                        child: Image.asset('assets/images/logo.png', height: 64),
                      ),
                      const SizedBox(height: 10),
                      const Text('Buat Akun Baru', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF008FE5), fontWeight: FontWeight.bold, fontSize: 24, letterSpacing: 1.2)),
                      const SizedBox(height: 4),
                      const Text('Daftar untuk mulai menggunakan Leviosa', textAlign: TextAlign.center, style: TextStyle(color: Colors.black54, fontSize: 15)),
                      const SizedBox(height: 18),
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: 'Nama Lengkap',
                          labelStyle: const TextStyle(color: Color(0xFF008FE5)),
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                        ),
                        style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          labelStyle: const TextStyle(color: Color(0xFF008FE5)),
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                        ),
                        style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: passController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: const TextStyle(color: Color(0xFF008FE5)),
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                        style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : register,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF008FE5),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                            elevation: 2,
                          ),
                          child: _isLoading
                              ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Text('Daftar'),
                        ),
                      ),
                      const SizedBox(height: 18),
                      TextButton(
                        onPressed: _isLoading ? null : () => Navigator.pop(context),
                        child: const Text('Sudah punya akun? Masuk', style: TextStyle(color: Color(0xFF008FE5), fontWeight: FontWeight.w600, fontSize: 15, decoration: TextDecoration.underline)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

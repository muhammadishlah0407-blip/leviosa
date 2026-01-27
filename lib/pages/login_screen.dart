import 'package:flutter/material.dart';
import 'package:leviosa/pages/register_screen.dart';
import 'package:leviosa/service/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final emailController = TextEditingController();
  final passController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    emailController.dispose();
    passController.dispose();
    super.dispose();
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
                  opacity: _animationController.value,
                  child: Transform.translate(
                    offset: Offset(0, 40 * (1 - _animationController.value)),
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
                      const Text('Selamat Datang!', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF008FE5), fontWeight: FontWeight.bold, fontSize: 24, letterSpacing: 1.2)),
                      const SizedBox(height: 4),
                      const Text('Masuk ke akun Leviosa Anda', textAlign: TextAlign.center, style: TextStyle(color: Colors.black54, fontSize: 15)),
                      const SizedBox(height: 18),
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
                          onPressed: _isLoading ? null : _login,
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
                              : const Text('Masuk'),
                        ),
                      ),
                      const SizedBox(height: 18),
                      TextButton(
                        onPressed: _isLoading ? null : () => Navigator.pushNamed(context, '/register'),
                        child: const Text('Belum punya akun? Daftar', style: TextStyle(color: Color(0xFF008FE5), fontWeight: FontWeight.w600, fontSize: 15, decoration: TextDecoration.underline)),
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

  void _login() async {
    setState(() {
      _isLoading = true;
    });
    await AuthService().login(
      emailController.text,
      passController.text,
      context,
    );
    setState(() {
      _isLoading = false;
    });
  }
}

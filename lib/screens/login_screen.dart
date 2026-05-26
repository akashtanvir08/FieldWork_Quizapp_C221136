import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/storage_service.dart';
import '../widgets/custom_button.dart';
import 'signup_screen.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    final user = await StorageService.instance.loginUser(username, password);

    setState(() {
      _isLoading = false;
    });

    if (user != null) {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } else {
      setState(() {
        _errorMessage = 'Invalid username or password';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F172A), Color(0xFF1E293B)], // Dark sleek slate
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28.0),
            child: SizedBox(
              height: size.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Spacer(flex: 2),
                    // Title
                    Text(
                      'Welcome Back',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 36.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      'Sign in to test your knowledge offline!',
                      style: GoogleFonts.inter(
                        color: Colors.white70,
                        fontSize: 16.0,
                      ),
                    ),
                    const Spacer(flex: 1),

                    // Inputs card
                    Container(
                      padding: const EdgeInsets.all(24.0),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(24.0),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_errorMessage != null) ...[
                            Container(
                              padding: const EdgeInsets.all(12.0),
                              decoration: BoxDecoration(
                                color: Colors.redAccent.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12.0),
                                border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 20.0),
                                  const SizedBox(width: 10.0),
                                  Expanded(
                                    child: Text(
                                      _errorMessage!,
                                      style: const TextStyle(color: Colors.redAccent, fontSize: 14.0),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16.0),
                          ],

                          // Username Field
                          Text(
                            'Username',
                            style: GoogleFonts.inter(
                              color: Colors.white70,
                              fontSize: 14.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          TextFormField(
                            controller: _usernameController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Enter your username',
                              hintStyle: const TextStyle(color: Colors.white30),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.05),
                              prefixIcon: const Icon(Icons.person_outline_rounded, color: Colors.white54),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16.0),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16.0),
                                borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16.0),
                                borderSide: const BorderSide(color: Color(0xFF6366F1), width: 1.5),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter your username';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20.0),

                          // Password Field
                          Text(
                            'Password',
                            style: GoogleFonts.inter(
                              color: Colors.white70,
                              fontSize: 14.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Enter your password',
                              hintStyle: const TextStyle(color: Colors.white30),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.05),
                              prefixIcon: const Icon(Icons.lock_outline_rounded, color: Colors.white54),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16.0),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16.0),
                                borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16.0),
                                borderSide: const BorderSide(color: Color(0xFF6366F1), width: 1.5),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24.0),

                          CustomButton(
                            text: 'Sign In',
                            onPressed: _login,
                            isLoading: _isLoading,
                          ),
                        ],
                      ),
                    ),

                    const Spacer(flex: 1),

                    // Signup navigate
                    Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const SignupScreen()),
                          );
                        },
                        child: RichText(
                          text: TextSpan(
                            text: "Don't have an account? ",
                            style: GoogleFonts.inter(color: Colors.white54, fontSize: 14.0),
                            children: [
                              TextSpan(
                                text: 'Sign Up',
                                style: GoogleFonts.inter(
                                  color: const Color(0xFF6366F1),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const Spacer(flex: 2),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

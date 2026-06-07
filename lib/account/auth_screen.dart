import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../account//auth_service.dart';
import '../homescreen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoginMode = true; // Swaps between true (Login) and false (Create Account)
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleAuthAction() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    // Background internal mapping to support native Firebase Auth email requirements
    final internalEmail = "${username.toLowerCase().replaceAll(' ', '')}@smartsensetutor.internal";

    dynamic user;

    if (_isLoginMode) {
      // 1. LOGIN PROCESS
      user = await _authService.loginWithEmail(internalEmail, password);
    } else {
      // 2. CREATE ACCOUNT PROCESS
      user = await _authService.signUpWithEmail(internalEmail, password);

      if (user != null) {
        await FirebaseAuth.instance.currentUser?.updateDisplayName(username);
      }
    }

    setState(() => _isLoading = false);

    if (user != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isLoginMode ? "Welcome back, $username!" : "Account created successfully!"),
            backgroundColor: const Color(0xFF62D275),
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isLoginMode
                ? "Invalid username or password. Please try again."
                : "Registration failed. This username might already be in use."),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // App Branding Logo
                  Center(
                    child: Image.asset(
                      'asset/logo.png',
                      width: 240,
                      fit: BoxFit.contain,
                      errorBuilder: (c, e, s) => const Icon(Icons.menu_book, size: 70, color: Color(0xFF70D3F4)),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // DYNAMIC HEADER BLOCK (Provides explicit context to the user)
                  Column(
                    children: [
                      Text(
                        _isLoginMode ? "Log In" : "Create Account",
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C4379),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _isLoginMode
                            ? "Enter your credentials to return to your lessons."
                            : "Choose a brand new username and password to get started.",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // USERNAME FIELD
                  const Text(
                    "Username",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _usernameController,
                    keyboardType: TextInputType.text,
                    style: const TextStyle(fontSize: 16),
                    decoration: _buildInputDecoration(_isLoginMode ? "Your username" : "Create a username"),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return "Username cannot be empty";
                      }
                      if (!_isLoginMode && val.trim().length < 3) {
                        return "Username must be at least 3 characters";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // PASSWORD FIELD
                  const Text(
                    "Password",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    style: const TextStyle(fontSize: 16),
                    decoration: _buildInputDecoration(_isLoginMode ? "Your password" : "Create a strong password").copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                          color: Colors.grey,
                        ),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return "Password cannot be empty";
                      }
                      if (val.length < 6) {
                        return "Password must be at least 6 characters";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 28),

                  // DYNAMIC MAIN ACTION BUTTON
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleAuthAction,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF70D3F4),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: Color(0xFF2C4379), width: 1),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                          : Text(
                        _isLoginMode ? "Login" : "Register Account",
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Decorative Divider Component
                  const Row(
                    children: [
                      Expanded(child: Divider(color: Color(0xFFE2E8F0), thickness: 1)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.0),
                        child: Text("or", style: TextStyle(color: Colors.grey, fontSize: 14)),
                      ),
                      Expanded(child: Divider(color: Color(0xFFE2E8F0), thickness: 1)),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Alternative Identity Access Links
                  _buildSocialButton(label: "Continue with Apple", icon: Icons.apple, iconColor: Colors.black, onPressed: () {}),
                  const SizedBox(height: 12),
                  _buildSocialButton(label: "Continue with Google", icon: Icons.g_mobiledata_rounded, iconColor: Colors.redAccent, onPressed: () {}),
                  const SizedBox(height: 12),
                  _buildSocialButton(label: "Continue with Facebook", icon: Icons.facebook, iconColor: const Color(0xFF1877F2), onPressed: () {}),

                  const SizedBox(height: 28),

                  // FOOTER SWITCH
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _isLoginMode ? "Don't have an account? " : "Already have an account? ",
                        style: const TextStyle(color: Colors.grey, fontSize: 15),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isLoginMode = !_isLoginMode;
                            _formKey.currentState?.reset();
                            _usernameController.clear();
                            _passwordController.clear();
                          });
                        },
                        child: Text(
                          _isLoginMode ? "Sign Up" : "Log In",
                          style: const TextStyle(
                            color: Color(0xFF70D3F4),
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.black26, fontSize: 15),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      filled: true,
      fillColor: Colors.white,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF70D3F4), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 2),
      ),
    );
  }

  Widget _buildSocialButton({
    required String label,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 50,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: const Color(0xFFF1F5F9),
          side: BorderSide.none,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: 26),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
            ),
          ],
        ),
      ),
    );
  }
}
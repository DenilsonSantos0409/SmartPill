import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isSignIn = true; // Track current tab

  void _login() async {
    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 1)); // Simulasi loading

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isNotEmpty && password.isNotEmpty) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email dan Password tidak boleh kosong.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        height: screenHeight,
        width: screenWidth,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE1F5FE),
              Color(0xFFB3E5FC),
              Color(0xFF81D4FA),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
              child: Column(
                children: [
                  SizedBox(height: screenHeight * 0.08),

                  // Logo Section
                  Container(
                    width: 120,
                    height: 120,
                    child: Image.asset(
                      'assets/Logo.png',
                      width: 120,
                      height: 120,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 120,
                          height: 120,
                          decoration: const BoxDecoration(
                            color: Colors.lightBlueAccent,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.medical_services,
                            size: 60,
                            color: Colors.white,
                          ),
                        );
                      },
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.06),

                  // Tab Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isSignIn = true;
                          });
                        },
                        child: Column(
                          children: [
                            Text(
                              'SIGN IN',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: _isSignIn
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: _isSignIn
                                    ? const Color(0xFF4C5CE6)
                                    : Colors.grey,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: 80,
                              height: 2,
                              color: _isSignIn
                                  ? const Color(0xFF4C5CE6)
                                  : Colors.transparent,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 60),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/register');
                        },
                        child: Column(
                          children: [
                            Text(
                              'SIGN UP',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: !_isSignIn
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: !_isSignIn
                                    ? const Color(0xFF4C5CE6)
                                    : Colors.grey,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: 80,
                              height: 2,
                              color: !_isSignIn
                                  ? const Color(0xFF4C5CE6)
                                  : Colors.transparent,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Horizontal line
                  Container(
                    margin: const EdgeInsets.only(top: 0),
                    height: 1,
                    color: Colors.grey.withOpacity(0.3),
                  ),

                  SizedBox(height: screenHeight * 0.04),

                  // Email Field
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        hintText: 'User name',
                        hintStyle: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 16,
                        ),
                        prefixIcon: Icon(
                          Icons.person_outline,
                          color: Colors.grey.shade400,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.025),

                  // Password Field
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      decoration: InputDecoration(
                        hintText: 'Password',
                        hintStyle: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 16,
                        ),
                        prefixIcon: Icon(
                          Icons.lock_outline,
                          color: Colors.grey.shade400,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.grey.shade400,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.06),

                  // Sign In Button
                  GestureDetector(
                    onTap: _isLoading ? null : _login,
                    child: Column(
                      children: [
                        Text(
                          'SIGN IN',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _isLoading
                                ? Colors.grey
                                : const Color(0xFF4C5CE6),
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 80,
                          height: 3,
                          decoration: BoxDecoration(
                            color: _isLoading
                                ? Colors.grey
                                : const Color(0xFF4C5CE6),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.04),

                  // Loading indicator
                  if (_isLoading)
                    const CircularProgressIndicator(
                      color: Color(0xFF4C5CE6),
                    ),

                  SizedBox(height: screenHeight * 0.03),

                  // Forgot Password
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Forget your password?',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

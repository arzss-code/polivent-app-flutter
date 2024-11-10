import 'dart:convert';
import 'package:polivent_app/models/ui_colors.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:polivent_app/screens/forgot_password.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uicons_pro/uicons_pro.dart';
import 'home.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final FocusNode emailFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();
  bool rememberMe = false;
  bool securePassword = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  String? _emailError;
  String? _passwordError;

  @override
  void initState() {
    super.initState();
    _loadUserPreferences();
    _setupAnimations();
    emailFocusNode.addListener(() {
      if (emailFocusNode.hasFocus) setState(() => _emailError = null);
    });
    passwordFocusNode.addListener(() {
      if (passwordFocusNode.hasFocus) setState(() => _passwordError = null);
    });
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  bool _validateEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  bool _validatePassword(String password) {
    return password.length >= 6;
  }

  Future<void> _login() async {
    setState(() {
      _emailError = null;
      _passwordError = null;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    // Validasi input
    bool hasError = false;
    if (!_validateEmail(email)) {
      setState(() {
        _emailError = 'Please enter a valid email address';
      });
      hasError = true;
    }
    if (!_validatePassword(password)) {
      setState(() {
        _passwordError = 'Password must be at least 6 characters';
      });
      hasError = true;
    }

    if (hasError) return;

    // Show loading animation
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: Container(
            width: 250, // Fixed width
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: Offset(0, 4), // Shadow position
                ),
              ],
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize:
                  MainAxisSize.min, // Ensure the column takes minimum space
              children: [
                CircularProgressIndicator(
                  color: UIColor.primaryColor,
                ),
                // SizedBox(height: 16),
                // Text(
                //   'Logging in...',
                //   textAlign: TextAlign.center, // Center the text
                //   style: TextStyle(
                //     fontSize: 16, // Increased font size for better visibility
                //     fontFamily: "Inter",
                //     fontWeight: FontWeight.bold,
                //     color: Colors.black,
                //   ),
                // ),
              ],
            ),
          ),
        );
      },
    );

    try {
      const url = 'https://polivent.my.id/api/auth';
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
      }

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['status'] == 'success') {
          await _saveUserPreferences(email, password);

          if (mounted) {
            // Success animation and transition
            _showSuccessDialog(() {
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      const Home(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    const begin = Offset(1.0, 0.0);
                    const end = Offset.zero;
                    const curve = Curves.easeInOutCubic;
                    var tween = Tween(begin: begin, end: end)
                        .chain(CurveTween(curve: curve));
                    var offsetAnimation = animation.drive(tween);
                    return SlideTransition(
                        position: offsetAnimation, child: child);
                  },
                  transitionDuration: const Duration(milliseconds: 800),
                ),
              );
            });
          }
        } else {
          if (mounted) {
            _showError(jsonData['message']);
          }
        }
      } else {
        if (mounted) {
          _showError('Error: ${response.statusCode}');
        }
      }
    } catch (error) {
      if (mounted) {
        Navigator.of(context).pop();
        _showError('Login failed. Please check your connection and try again.');
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessDialog(VoidCallback onComplete) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 100,
                ),
                SizedBox(height: 16),
                Text(
                  'Login Successful',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        // Check if the widget is still mounted
        Navigator.of(context).pop();
        onComplete();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background with blur
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    'assets/images/background.png'), // Add a background image
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Content
          Center(
            child: SingleChildScrollView(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/logo-polivent.png',
                          alignment: Alignment.center,
                          width: 150,
                          height: 150,
                        ),

                        const SizedBox(height: 36),
                        // Sign in text with animation
                        const Row(
                          children: [
                            Text(
                              "Login",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: UIColor.typoBlack,
                                fontSize: 28,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Email field
                        TextFormField(
                          controller: _emailController,
                          focusNode: emailFocusNode,
                          cursorColor: UIColor.primary,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: UIColor.solidWhite,
                            labelText: 'Email',
                            errorText: _emailError,
                            floatingLabelStyle:
                                const TextStyle(color: UIColor.primary),
                            focusedBorder: OutlineInputBorder(
                              borderSide:
                                  const BorderSide(color: UIColor.primary),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide:
                                  const BorderSide(color: UIColor.typoGray),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.red),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.red),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: Icon(
                              UIconsPro.regularRounded.envelope,
                              color: _emailError != null
                                  ? Colors.red
                                  : emailFocusNode.hasFocus
                                      ? UIColor.primary
                                      : UIColor.typoGray,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Password field
                        TextFormField(
                          controller: _passwordController,
                          focusNode: passwordFocusNode,
                          obscureText: securePassword,
                          cursorColor: UIColor.primary,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: UIColor.solidWhite,
                            labelText: 'Password',
                            errorText: _passwordError,
                            floatingLabelStyle:
                                const TextStyle(color: UIColor.primary),
                            focusedBorder: OutlineInputBorder(
                              borderSide:
                                  const BorderSide(color: UIColor.primary),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide:
                                  const BorderSide(color: UIColor.typoGray),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.red),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.red),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: Icon(
                              UIconsPro.regularRounded.lock,
                              color: _passwordError != null
                                  ? Colors.red
                                  : passwordFocusNode.hasFocus
                                      ? UIColor.primary
                                      : UIColor.typoGray,
                            ),
                            suffixIcon: IconButton(
                              color: passwordFocusNode.hasFocus
                                  ? UIColor.primary
                                  : UIColor.typoGray,
                              onPressed: () => setState(
                                  () => securePassword = !securePassword),
                              icon: Icon(securePassword
                                  ? UIconsPro.solidRounded.eye_crossed
                                  : UIconsPro.solidRounded.eye),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Remember me switch
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Remember Me",
                                style: TextStyle(
                                  color: UIColor.typoBlack,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Switch(
                                value: rememberMe,
                                onChanged: (value) =>
                                    setState(() => rememberMe = value),
                                activeColor: UIColor.primary,
                              ),
                            ],
                          ),
                        ),
                        // Forgot password button
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ForgotPasswordScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            "Forgot Password?",
                            style: TextStyle(
                              color: UIColor.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        // Login button with animation
                        ElevatedButton(
                          onPressed: _login,
                          style: ElevatedButton.styleFrom(
                            fixedSize: Size(
                              MediaQuery.of(context).size.width * 1,
                              52,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            backgroundColor: UIColor.primary,
                            elevation: 3,
                          ),
                          child: const Text(
                            "Login",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveUserPreferences(String email, String password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (rememberMe) {
      await prefs.setString('email', email);
      await prefs.setString('password', password);
      await prefs.setBool('rememberMe', true);
    } else {
      await prefs.remove('email');
      await prefs.remove('password');
      await prefs.setBool('rememberMe', false);
    }
  }

  Future<void> _loadUserPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _emailController.text = prefs.getString('email') ?? '';
      _passwordController.text = prefs.getString('password') ?? '';
      rememberMe = prefs.getBool('rememberMe') ?? false;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    super.dispose();
  }
}

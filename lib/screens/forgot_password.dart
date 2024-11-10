import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:polivent_app/models/ui_colors.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ForgotPasswordScreenState createState() => ForgotPasswordScreenState();
}

class ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  String? _emailError;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _emailFocusNode.addListener(() {
      if (_emailFocusNode.hasFocus) setState(() => _emailError = null);
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

  Future<void> _resetPassword() async {
    if (_isLoading) return;

    final email = _emailController.text.trim();

    if (!_validateEmail(email)) {
      setState(() {
        _emailError = 'Please enter a valid email address';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _emailError = null;
    });

    try {
      const url = 'https://polivent.my.id/api/forgot-password';
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (response.statusCode == 200) {
          final jsonData = jsonDecode(response.body);
          if (jsonData['status'] == 'success') {
            _showSuccessDialog();
          } else {
            _showError(jsonData['message'] ?? 'Password reset request failed');
          }
        } else {
          _showError('Error: ${response.statusCode}');
        }
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showError('Failed to send reset request. Please check your connection.');
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 60,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Reset Link Sent',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Please check your email for password reset instructions',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                    Navigator.of(context).pop(); // Return to login screen
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: UIColor.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text('Back to Login'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: UIColor.typoBlack),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Forgot Password",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: UIColor.typoBlack,
                            fontSize: 28,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "Enter your email address and we'll send you instructions to reset your password.",
                          style: TextStyle(
                            color: UIColor.typoGray,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 32),
                        TextFormField(
                          controller: _emailController,
                          focusNode: _emailFocusNode,
                          cursorColor: UIColor.primary,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: UIColor.solidWhite,
                            labelText: 'Email',
                            errorText: _emailError,
                            floatingLabelStyle: const TextStyle(color: UIColor.primary),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: UIColor.primary),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: UIColor.typoGray),
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
                              Icons.email,
                              color: _emailError != null
                                  ? Colors.red
                                  : _emailFocusNode.hasFocus
                                      ? UIColor.primary
                                      : UIColor.typoGray,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _resetPassword,
                          style: ElevatedButton.styleFrom(
                            fixedSize: Size(MediaQuery.of(context).size.width * 1, 52),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            backgroundColor: UIColor.primary,
                            elevation: 3,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  "Send Reset Link",
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

  @override
  void dispose() {
    _animationController.dispose();
    _emailFocusNode.dispose();
    _emailController.dispose();
    super.dispose();
  }
}
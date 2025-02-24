// ignore_for_file: deprecated_member_use

import 'package:flutter/services.dart';
import 'package:polivent_app/config/ui_colors.dart';
import 'package:flutter/material.dart';
import 'package:polivent_app/services/auth_services.dart';
import 'package:polivent_app/services/token_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uicons_pro/uicons_pro.dart';
import '../home/home.dart';

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
    _checkForToken();
    _setupAnimations();
    emailFocusNode.addListener(() {
      if (emailFocusNode.hasFocus) setState(() => _emailError = null);
    });
    passwordFocusNode.addListener(() {
      if (passwordFocusNode.hasFocus) setState(() => _passwordError = null);
    });
  }

  Future<void> _checkForToken() async {
    try {
      // Gunakan TokenService untuk mengecek token
      final isValid = await TokenService.checkTokenValidity();

      if (isValid) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Home()),
        );
      }
    } catch (e) {
      debugPrint('Token check error: $e');
    }
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
    FocusScope.of(context).unfocus(); // Menutup keyboard
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
        _emailError = 'Masukkan alamat email yang valid';
      });
      hasError = true;
    }
    if (!_validatePassword(password)) {
      setState(() {
        _passwordError = 'Kata sandi harus minimal 6 karakter';
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
            width: 100, // Fixed width
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
              ],
            ),
          ),
        );
      },
    );

    try {
      // Gunakan AuthService untuk login
      final loginSuccess = await AuthService().login(email, password);

      if (loginSuccess) {
        // Simpan preferensi pengguna sesuai remember me
        await _saveUserPreferences(email, password);

        // Tutup loading dialog
        if (mounted) {
          Navigator.of(context).pop();
        }

        // Tampilkan dialog sukses
        _showSuccessDialog(() {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => Home(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                const begin = Offset(1.0, 0.0);
                const end = Offset.zero;
                const curve = Curves.easeInOutCubic;
                var tween = Tween(begin: begin, end: end)
                    .chain(CurveTween(curve: curve));
                var offsetAnimation = animation.drive(tween);
                return SlideTransition(position: offsetAnimation, child: child);
              },
              transitionDuration: const Duration(milliseconds: 800),
            ),
          );
        });
      } else {
        // Tangani login gagal
        if (mounted) {
          Navigator.of(context).pop();
          _showError('Login gagal. Silakan periksa kredensial Anda.');
        }
      }
    } catch (error) {
      if (mounted) {
        Navigator.of(context).pop();
        _showError('Login gagal. Silakan periksa koneksi dan coba lagi.');
      }
    }
  }

  void _showError(String message) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    // Tutup snackbar yang sedang aktif
    scaffoldMessenger.hideCurrentSnackBar();

    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.redAccent.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          left: 16,
          right: 16,
        ),
        padding: const EdgeInsets.all(16),
        elevation: 6,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccessDialog(VoidCallback onComplete) {
    // Nonaktifkan semua fokus
    FocusManager.instance.primaryFocus?.unfocus();

    // Metode untuk menyembunyikan keyboard
    SystemChannels.textInput.invokeMethod('TextInput.hide');

    // Tunggu sebentar untuk memastikan input method stabil
    Future.delayed(const Duration(milliseconds: 100), () {
      // Pastikan tidak ada input aktif
      FocusScope.of(context).requestFocus(FocusNode());

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return PopScope(
            canPop: false,
            child: Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: WillPopScope(
                onWillPop: () async => false,
                child: const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 100,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Login Berhasil!',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );

      // Tutup dialog dan jalankan callback
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          Navigator.of(context).pop(); // Tutup dialog
          onComplete(); // Jalankan callback
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // Pastikan ini diatur
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context)
              .unfocus(); // Menutup keyboard saat tap di luar input
        },
        child: Stack(
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
                physics: const AlwaysScrollableScrollPhysics(),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag, // Tambahkan ini
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
                              prefixIconConstraints: const BoxConstraints(
                                minWidth: 50, // Lebar minimum untuk icon
                                minHeight: 50, // Tinggi minimum untuk icon
                              ),
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
                                size: 22,
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
                              prefixIconConstraints: const BoxConstraints(
                                minWidth: 50, // Lebar minimum untuk icon
                                minHeight: 50, // Tinggi minimum untuk icon
                              ),
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
                                size: 22,
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
                                icon: Icon(
                                  securePassword
                                      ? UIconsPro.solidRounded.eye_crossed
                                      : UIconsPro.solidRounded.eye,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Remember me switch
                          Padding(
                            padding: const EdgeInsets.all(4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Remember Me",
                                  style: TextStyle(
                                    color: UIColor.typoBlack,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
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
                          // TextButton(
                          //   onPressed: () {
                          //     Navigator.push(
                          //       context,
                          //       MaterialPageRoute(
                          //         builder: (context) =>
                          //             const ForgotPasswordScreen(),
                          //       ),
                          //     );
                          //   },
                          //   child: const Text(
                          //     "Forgot Password?",
                          //     style: TextStyle(
                          //       color: UIColor.primary,
                          //       fontWeight: FontWeight.w500,
                          //       fontSize: 14,
                          //     ),
                          //   ),
                          // ),
                          const SizedBox(height: 18),
                          // Login button with animation
                          ElevatedButton(
                            onPressed: () {
                              // Pastikan keyboard ditutup sebelum login
                              FocusScope.of(context).unfocus();
                              _login();
                            },
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
                          // const SizedBox(height: 24),
                          // TextButton(
                          //   onPressed: () {
                          //     Navigator.push(
                          //       context,
                          //       MaterialPageRoute(
                          //         builder: (context) =>
                          //             const ForgotPasswordScreen(),
                          //       ),
                          //     );
                          //   },
                          //   child: const Text(
                          //     "Forgot Password?",
                          //     style: TextStyle(
                          //       color: UIColor.primary,
                          //       fontWeight: FontWeight.w500,
                          //       fontSize: 14,
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
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

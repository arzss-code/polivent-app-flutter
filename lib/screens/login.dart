import 'dart:convert';
import 'package:polivent_app/models/ui_colors.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:polivent_app/screens/select_interest.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences untuk "Remember Me"
import 'package:uicons_pro/uicons_pro.dart';
import 'home.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool rememberMe = false;
  final FocusNode emailFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();
  bool securePassword = true;

  @override
  void initState() {
    super.initState();
    _loadUserPreferences(); // Memuat email/password jika Remember Me diaktifkan sebelumnya
    emailFocusNode.addListener(() {
      setState(() {}); // Memperbarui tampilan saat fokus berubah
    });
    passwordFocusNode.addListener(() {
      setState(() {}); // Memperbarui tampilan saat fokus berubah
    });
  }

  Future<void> _loadUserPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      rememberMe = prefs.getBool('rememberMe') ?? false;
      if (rememberMe) {
        _emailController.text = prefs.getString('email') ?? '';
        _passwordController.text = prefs.getString('password') ?? '';
      }
    });
  }

  Future<void> _saveUserPreferences(String email, String password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (rememberMe) {
      await prefs.setBool('rememberMe', true);
      await prefs.setString('email', email);
      await prefs.setString('password', password);
    } else {
      await prefs.remove('rememberMe');
      await prefs.remove('email');
      await prefs.remove('password');
    }
  }

  Future<void> _login() async {
    final email = _emailController.text;
    final password = _passwordController.text;

    // Menampilkan loading spinner saat proses login
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    try {
      const url =
          'http://localhost/api-polyvent/auth'; // Ubah URL dengan yang sesuai
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      if (mounted) {
        Navigator.of(context).pop(); // Menutup loading spinner
      }

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['status'] == 'success') {
          // Simpan email/password jika Remember Me diaktifkan
          await _saveUserPreferences(email, password);

          // Berhasil login, arahkan ke home screen
          if (mounted) {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const Home(),
                transitionDuration: const Duration(
                    milliseconds: 500), // adjust the duration as needed
              ),
            );
          }
        } else {
          // Tampilkan pesan kesalahan dari response API
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
        Navigator.of(context).pop(); // Menutup loading spinner
        _showError('Login failed. Please try again.');
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  showhide() {
    setState(() {
      securePassword = !securePassword;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 130),
                  Image.asset(
                    'assets/images/logo-polivent.png',
                    width: 150,
                    height: 150,
                  ),
                  const SizedBox(height: 36),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Sign in",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: UIColor.typoBlack,
                        fontSize: 24,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _emailController,
                    focusNode: emailFocusNode,
                    cursorColor: UIColor.primary,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: UIColor.solidWhite,
                      labelText: 'Email',
                      floatingLabelStyle:
                          const TextStyle(color: UIColor.primary),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: UIColor.primary),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: UIColor.typoGray),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: Icon(
                        UIconsPro.regularRounded.envelope,
                        color: emailFocusNode.hasFocus
                            ? UIColor.primary
                            : UIColor.typoGray,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  TextField(
                    controller: _passwordController,
                    focusNode: passwordFocusNode,
                    obscureText: securePassword,
                    cursorColor: UIColor.primary,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: UIColor.solidWhite,
                      labelText: 'Password',
                      floatingLabelStyle:
                          const TextStyle(color: UIColor.primary),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: UIColor.primary),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: UIColor.typoGray),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: Icon(
                        UIconsPro.regularRounded.lock,
                        color: passwordFocusNode.hasFocus
                            ? UIColor.primary
                            : UIColor.typoGray,
                      ),
                      suffixIcon: IconButton(
                          color: passwordFocusNode.hasFocus
                              ? UIColor.primary
                              : UIColor.typoGray,
                          onPressed: () {
                            showhide();
                          },
                          icon: Icon(securePassword
                              ? UIconsPro.solidRounded.eye_crossed
                              : UIconsPro.solidRounded.eye)),
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Checkbox(value: rememberMe, onChanged: (value) {}),
                      const Text("Remember Me"),
                      // Checkbox(value: rememberMe, onChanged: (value) {}),
                      Switch(
                        value: rememberMe,
                        onChanged: (value) {
                          setState(() {
                            rememberMe = value;
                          });
                        },
                        activeColor: UIColor.primary,
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text("Forgot Password?"),
                            content: const Text(
                                "Reset password functionality goes here."),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text("OK"),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: const Text(
                      "Forgot Password?",
                      style: TextStyle(color: Color(0xff1886EA)),
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SelectInterestScreen()),
                      );
                    },
                    // ElevatedButton(
                    //   onPressed:
                    //       _login, //! Untuk membuat  fungsi login email& password melalui API
                    style: ElevatedButton.styleFrom(
                      // fixedSize: const Size(350, 50),
                      padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      backgroundColor: const Color(0xff1886EA),
                    ),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 1,
                      child: const Text(
                        "Sign in",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16.0, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 130),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

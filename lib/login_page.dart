import 'package:firebase_core/firebase_core.dart';
import 'package:kitasihat/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kitasihat/home_page.dart';
import 'package:kitasihat/bottom_nav_bar.dart';
import 'package:kitasihat/registration_page.dart';
import 'package:kitasihat/admin_dashboard_page.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback? onTap;
  const LoginPage({super.key, this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _errorMessage = '';
  bool _obscureText = true;

  void signUserIn() async {
    setState(() {
      _errorMessage = '';
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userRoleSnapshot = await FirebaseFirestore.instance
            .collection('registration')
            .doc(user.uid)
            .get();

        if (userRoleSnapshot.exists && userRoleSnapshot.data() != null) {
          Map<String, dynamic> data =
              userRoleSnapshot.data() as Map<String, dynamic>;
          String role = data['user_role'] ?? 'user';

          if (role == 'admin') {
            navigateToAdminDashboard(context);
          } else {
            navigateToHomePage(context);
          }
        } else {
          navigateToHomePage(context);
        }
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = e.message ?? 'An error occurred';
      });
    }
  }

  void navigateToRegistrationPage(BuildContext context) {
    widget.onTap?.call();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegistrationPage()),
    );
  }

  void navigateToAdminDashboard(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const AdminDashboardPage()),
    );
  }

  void navigateToHomePage(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const MyBottomNavigationBar()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00FFCA),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.brightness_2,
                  size: 150,
                  color: Color(0xFFFFFFFF),
                ),
                const SizedBox(height: 25),
                const Text(
                  'KitaSihatMY!',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      fontFamily: 'Outfit'),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Hello Again!',
                  style: TextStyle(fontSize: 20, fontFamily: 'Outfit'),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFFFF),
                      border:
                          Border.all(color: const Color(0xFFD1D1D6), width: 1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: TextField(
                        controller: _emailController,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            fontFamily: 'Outfit',
                            color: Color(0xFF000000)),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Email',
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFFFF),
                      border:
                          Border.all(color: const Color(0xFFD1D1D6), width: 1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: TextField(
                        controller: _passwordController,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            fontFamily: 'Outfit',
                            color: Color(0xFF000000)),
                        obscureText: _obscureText,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Password',
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureText
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureText = !_obscureText;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                if (_errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 25.0, vertical: 8.0),
                    child: Text(
                      _errorMessage,
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: GestureDetector(
                    onTap: signUserIn,
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                          color: const Color(0XFF190152),
                          border: Border.all(
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(12)),
                      child: const Center(
                        child: Text(
                          'Sign in',
                          style: TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 18,
                              color: Color(0xFFFFFFFF)),
                        ),
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Not a member?',
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 14,
                        )),
                    const Text(
                      'Register ',
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 14,
                      ),
                    ),
                    GestureDetector(
                      child: const Text(
                        'here',
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                          fontFamily: 'Outfit',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onTap: () {
                        navigateToRegistrationPage(context);
                      },
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

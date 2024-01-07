import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kitasihat/bottom_nav_bar.dart'; // Adjust this import as necessary

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<StatefulWidget> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _nameController = TextEditingController();
  final _icNumberController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String _errorMessage = '';
  bool _obscureText = true;
  bool _obscureConfirmText = true;

  String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<void> signUserUp() async {
    setState(() {
      _errorMessage = '';
    });

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorMessage = 'Passwords do not match';
      });
      return;
    }

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // Storing user details without setting user_role initially
      await FirebaseFirestore.instance
          .collection('registration')
          .doc(userCredential.user!.uid)
          .set({
        'name': _nameController.text,
        'ic_number': _icNumberController.text,
        'email': _emailController.text,
        'phone_number': _phoneController.text,
        'password': _hashPassword(_passwordController.text),
      });

      navigateToHomePage(context);
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = e.message ?? 'An error occurred';
      });
    }
  }

  void navigateToHomePage(BuildContext context) {
    Navigator.push(
      context,
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
                  Icons.health_and_safety,
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
                  'Register Now!',
                  style: TextStyle(fontSize: 20, fontFamily: 'Outfit'),
                ),
                const SizedBox(height: 20),
                _buildTextField(_nameController, 'Name'),
                _buildTextField(_icNumberController, 'IC Number'),
                _buildTextField(_emailController, 'Email'),
                _buildTextField(_phoneController, 'Phone Number'),
                _buildPasswordField(
                    _passwordController, 'Password', _obscureText, () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                }),
                _buildPasswordField(_confirmPasswordController,
                    'Confirm Password', _obscureConfirmText, () {
                  setState(() {
                    _obscureConfirmText = !_obscureConfirmText;
                  });
                }),
                const SizedBox(height: 25),
                if (_errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      _errorMessage,
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: GestureDetector(
                    onTap: signUserUp,
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                          color: const Color(0XFF190152),
                          border: Border.all(width: 1),
                          borderRadius: BorderRadius.circular(12)),
                      child: const Center(
                        child: Text(
                          'Sign Up',
                          style: TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 18,
                              color: Color(0xFFFFFFFF)),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          border: Border.all(color: const Color(0xFFD1D1D6), width: 1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: label,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField(TextEditingController controller, String label,
      bool obscureText, VoidCallback toggleVisibility) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          border: Border.all(color: const Color(0xFFD1D1D6), width: 1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: label,
              suffixIcon: IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: toggleVisibility,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _icNumberController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}

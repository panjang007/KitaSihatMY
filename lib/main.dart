import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:kitasihat/appointment_page.dart';
import 'package:kitasihat/auth_service_page.dart';
import 'package:kitasihat/bottom_nav_bar.dart';
import 'package:kitasihat/home_page.dart';
import 'firebase_options.dart';

import 'package:flutter/material.dart';

import 'package:kitasihat/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StreamBuilder<User?>(
        stream: AuthService().user,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            if (snapshot.data == null) {
              return const LoginPage(); // Redirect to login page if not authenticated
            }
            return const MyBottomNavigationBar(); // Go to home page if authenticated
          }
          return const CircularProgressIndicator(); // Show loading indicator while waiting for auth state
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kitasihat/auth_service_page.dart'; 
import 'package:kitasihat/appointment_page.dart';
import 'package:kitasihat/home_page.dart';
import 'package:kitasihat/login_page.dart';
import 'package:kitasihat/medical_history_page.dart';
import 'package:kitasihat/medication_reminder_page.dart';
import 'package:kitasihat/settings_page.dart';

class MyBottomNavigationBar extends StatefulWidget {
  const MyBottomNavigationBar({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MyBottomNavigationBarState createState() => _MyBottomNavigationBarState();
}

class _MyBottomNavigationBarState extends State<MyBottomNavigationBar> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService().user,
      builder: (context, snapshot) {
        if (snapshot.data == null) {
          return const LoginPage(); // Redirect to login page if not authenticated
        }
        return Scaffold(
          // Add 'return' here
          body: IndexedStack(
            index: _currentIndex,
            children: const [
              HomePage(),
              MedicalHistory(),
              AppointmentPage(),
              MedicationPage(),
              SettingsPage(),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.shifting,
            backgroundColor: const Color(0xFFFFFFFF),
            showUnselectedLabels: true,
            selectedItemColor: const Color(0xFF190152),
            unselectedItemColor: const Color(0xFF000000),
            selectedLabelStyle: const TextStyle(
                color: Color(0xFF190152),
                fontFamily: 'Outfit',
                fontWeight: FontWeight.w900),
            unselectedLabelStyle: const TextStyle(
              color: Color(0xFF190152),
            ),
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.house_outlined),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.history_outlined),
                label: 'History',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.add_circle_outline_outlined),
                label: 'Appointment',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.medical_services_outlined),
                label: 'Medication',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                label: 'Settings',
              ),
            ],
          ),
        );
      },
    );
  }
}

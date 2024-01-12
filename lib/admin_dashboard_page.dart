import 'package:flutter/material.dart';
import 'package:kitasihat/medical_record_update_page.dart';
import 'emergency_requests_page.dart';
import 'package:kitasihat/appointment_approval_page.dart';
import 'package:kitasihat/admin_settings_page.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  _AdminDashboardPageState createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    EmergencyRequestsPage(),
    MedicalRecordUpdatePage(),
    AppointmentApprovalPage(),
    AdminSettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Colors.deepPurple, // Selected item color
        unselectedItemColor: Colors.grey, // Unselected item color
        backgroundColor: Colors.white, // Background color of the navbar
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Emergency Requests',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.medical_services),
            label: 'Medical Record',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.approval),
            label: 'Appointment',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

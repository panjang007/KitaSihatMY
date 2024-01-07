import 'package:flutter/material.dart';

import 'package:kitasihat/medical_record_update_page.dart';
import 'emergency_requests_page.dart';
import 'package:kitasihat/appointment_approval_page.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  _AdminDashboardPageState createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  int _currentIndex = 0; // To keep track of the active tab

  // List of pages to display
  final List<Widget> _pages = [
    EmergencyRequestsPage(),
    MedicalRecordUpdatePage(), // Replace with your actual page
    AppointmentApprovalPage(), // Replace with your actual page
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex], // Display the selected page
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Emergency Requests',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.medical_services),
            label: 'Medical Record Update',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.approval),
            label: 'Appointment Approval',
          ),
        ],
      ),
    );
  }
}

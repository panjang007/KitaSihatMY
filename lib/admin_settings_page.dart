import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kitasihat/login_page.dart'; // Adjust this import as necessary

class AdminSettingsPage extends StatefulWidget {
  const AdminSettingsPage({super.key});

  @override
  _AdminSettingsPageState createState() => _AdminSettingsPageState();
}

class _AdminSettingsPageState extends State<AdminSettingsPage> {
  late User user;
  Map<String, dynamic> adminData = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser!;
    _fetchAdminData();
  }

  Future<void> _fetchAdminData() async {
    try {
      DocumentSnapshot adminDoc = await FirebaseFirestore.instance
          .collection('registration')
          .doc(user.uid)
          .get();
      if (adminDoc.exists) {
        setState(() {
          adminData = adminDoc.data() as Map<String, dynamic>;
        });
      } else {
        print('Admin document does not exist.');
      }
    } catch (e) {
      print('Error fetching admin data: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (Route<dynamic> route) => false,
    );
  }

  Future<void> _editAdminDetail(String field) async {
    String? newValue =
        await _asyncInputDialog(context, field, adminData[field]);
    if (newValue != null) {
      setState(() {
        adminData[field] = newValue;
      });
      FirebaseFirestore.instance
          .collection('registration')
          .doc(user.uid)
          .set({field: newValue}, SetOptions(merge: true));
    }
  }

  Future<String?> _asyncInputDialog(
      BuildContext context, String field, String? currentValue) async {
    String? newValue;
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit $field'),
          content: Row(
            children: <Widget>[
              Expanded(
                  child: TextField(
                autofocus: true,
                decoration: InputDecoration(
                    labelText: '$field', hintText: 'Enter your $field'),
                onChanged: (value) {
                  newValue = value;
                },
              ))
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop(newValue);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Settings', style: TextStyle(color: Colors.black)),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      backgroundColor: Colors.white,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildDetailCard('Name', adminData['name']),
                  _buildDetailCard('IC Number', adminData['ic_number']),
                  _buildDetailCard('Email', adminData['email']),
                  _buildDetailCard('Phone', adminData['phone_number']),
                  Spacer(),
                  ElevatedButton(
                    onPressed: _signOut,
                    child: const Text('Log Out'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      padding:
                          EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildDetailCard(String title, String? value) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        title: Text(title),
        subtitle: Text(value ?? 'Not available'),
        trailing: IconButton(
          icon: Icon(Icons.edit, color: Colors.blue),
          onPressed: () =>
              _editAdminDetail(title.toLowerCase().replaceAll(' ', '_')),
        ),
      ),
    );
  }
}

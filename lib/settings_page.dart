import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kitasihat/login_page.dart'; // Adjust this import as necessary

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late User user;
  Map<String, dynamic> userData = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser!;
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('registration')
          .doc(user.uid)
          .get();
      if (userDoc.exists) {
        setState(() {
          userData = userDoc.data() as Map<String, dynamic>;
        });
      } else {
        print('User document does not exist.');
      }
    } catch (e) {
      print('Error fetching user data: $e');
    } finally {
      setState(() {
        isLoading = false; // Set isLoading to false regardless of outcome
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

  Future<void> _editUserDetail(String field) async {
    String? newValue = await _asyncInputDialog(context, field, userData[field]);
    if (newValue != null) {
      setState(() {
        userData[field] = newValue;
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
                  _buildDetailCard('Name', userData['name']),
                  _buildDetailCard('IC Number', userData['ic_number']),
                  _buildDetailCard('Email', userData['email']),
                  _buildDetailCard('Phone', userData['phone']),
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
              _editUserDetail(title.toLowerCase().replaceAll(' ', '_')),
        ),
      ),
    );
  }
}

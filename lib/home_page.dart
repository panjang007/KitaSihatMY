import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kitasihat/chat_page.dart'; // Ensure this import is correct

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Timer? _timer;
  int _start = 10;
  bool _isEmergencyActive = false;
  bool _isChatEnabled = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late String userId;
  String sessionId = '';

  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser?.uid ?? '';
  }

  Future<Map<String, dynamic>> getUserRegistrationData() async {
    var userDoc = await FirebaseFirestore.instance
        .collection('registration')
        .doc(userId)
        .get();
    return userDoc.data() ?? {};
  }

  void startTimer() {
    setState(() {
      _isEmergencyActive = true;
      _start = 10;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Emergency Alert'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setDialogState) {
              if (_timer != null) {
                _timer!.cancel();
              }

              _timer =
                  Timer.periodic(const Duration(seconds: 1), (Timer timer) {
                if (_start == 0) {
                  timer.cancel();
                  Navigator.of(context).pop(); // Close the dialog
                  sendEmergencyRequest();
                } else {
                  setDialogState(() {
                    _start--;
                  });
                }
              });

              return Text('Sending emergency alert in $_start seconds');
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel Alert'),
              onPressed: () {
                _timer?.cancel();
                Navigator.of(context).pop();
                setState(() {
                  _isEmergencyActive = false;
                });
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> sendEmergencyRequest() async {
    var userData = await getUserRegistrationData();

    sessionId = Random().nextInt(100000).toString();

    await FirebaseFirestore.instance
        .collection('emergency_request')
        .doc(userId)
        .set({
      'user_id': userId,
      'date': DateTime.now(),
      'name': userData['name'],
      'ic_number': userData['ic_number'],
      'phone': userData['phone_number'],
      'email': userData['email'],
      'request_status': 'Pending',
      'session_id': sessionId,
    }, SetOptions(merge: true));

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Emergency Request"),
          content: const Text("Your emergency request has been sent."),
          actions: <Widget>[
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _isChatEnabled = true;
                });
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Color purpleColor = const Color(0xFF800080); // Bright strong purple color

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Home Page'),
      ),
      backgroundColor: const Color(0xFF00FFCA),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black,
                backgroundColor: Colors.yellow,
                shape: CircleBorder(),
                padding: EdgeInsets.all(64), // Adjusted padding
              ),
              onPressed: !_isEmergencyActive ? () => startTimer() : null,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.warning_amber_rounded,
                      size: 120), // Adjusted icon size
                  SizedBox(height: 12), // Adjusted spacing
                  Text(
                    'S.O.S',
                    style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.black), // Adjusted text size
                  ),
                ],
              ),
            ),
            SizedBox(height: 30), // Adjusted spacing
            ElevatedButton(
              onPressed: _isChatEnabled
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatPage(sessionId: sessionId),
                        ),
                      );
                    }
                  : null,
              child: Text(
                'Chat with Admin',
                style: TextStyle(
                    fontSize: 15,
                    color: _isChatEnabled
                        ? purpleColor
                        : Colors.black), // Adjusted text size
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    _isChatEnabled ? Colors.white : Colors.grey.shade800,
                padding: EdgeInsets.symmetric(
                    horizontal: 45, vertical: 22.5), // Adjusted padding
              ),
            ),
          ],
        ),
      ),
    );
  }
}

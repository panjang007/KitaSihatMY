import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'admin_chat_page.dart'; // Admin chat page

class EmergencyRequestsPage extends StatefulWidget {
  const EmergencyRequestsPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _EmergencyRequestsPageState createState() => _EmergencyRequestsPageState();
}

class _EmergencyRequestsPageState extends State<EmergencyRequestsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _formatDate(Timestamp timestamp) {
    DateTime utcDate = timestamp.toDate();
    DateTime localDate = utcDate.add(Duration(hours: 8)); // Adjusting for UTC+8
    return DateFormat.yMMMd().add_jm().format(localDate); // Format date
  }

  void _showDetailsDialog(Map<String, dynamic> requestData) {
    String formattedDate =
        _formatDate(requestData['date']); // Use formatted date

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(requestData['name']),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('IC Number: ${requestData['ic_number']}'),
                Text('Date: $formattedDate'),
              ],
            ),
          ),
          actions: <Widget>[
            Center(
              child: TextButton(
                child: const Text('Chat with User',
                    style: TextStyle(color: Color(0xFF800080))),
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          AdminChatPage(sessionId: requestData['session_id']),
                    ),
                  );
                },
                style: TextButton.styleFrom(
                  backgroundColor: Colors.grey.shade300,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  child: const Text('Approve',
                      style: TextStyle(color: Colors.white)),
                  onPressed: () {
                    _updateRequestStatus(requestData['user_id'], 'Approved');
                    Navigator.of(context).pop();
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                ),
                TextButton(
                  child:
                      const Text('Deny', style: TextStyle(color: Colors.white)),
                  onPressed: () {
                    _updateRequestStatus(requestData['user_id'], 'Denied');
                    Navigator.of(context).pop();
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                ),
              ],
            ),
            Center(
              child: TextButton(
                child: const Text('Close',
                    style: TextStyle(color: Color(0xFF800080))),
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.grey.shade300,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _updateRequestStatus(String userId, String status) {
    _firestore
        .collection('emergency_request')
        .doc(userId)
        .update({'request_status': status}).then((_) {
      if (mounted) setState(() {}); // Refresh the UI after status update
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Emergency Requests'),
      ),
      body: StreamBuilder(
        stream: _firestore.collection('emergency_request').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return CircularProgressIndicator();

          return ListView(
            children: snapshot.data!.docs.map((doc) {
              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
              if (data['request_status'] == 'Denied')
                return Container(); // Hide denied requests

              return Card(
                color: data['request_status'] == 'Approved'
                    ? Colors.lightGreenAccent
                    : null, // Light green if approved
                margin: const EdgeInsets.all(10),
                elevation: 5,
                child: ListTile(
                  title: Text(data['name'],
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                      'IC: ${data['ic_number']} - Date: ${_formatDate(data['date'])}'),
                  trailing: ElevatedButton(
                    child: Text('View'),
                    onPressed: () => _showDetailsDialog(data),
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // For date formatting

class AppointmentApprovalPage extends StatefulWidget {
  const AppointmentApprovalPage({Key? key}) : super(key: key);

  @override
  _AppointmentApprovalPageState createState() =>
      _AppointmentApprovalPageState();
}

class _AppointmentApprovalPageState extends State<AppointmentApprovalPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _showDetailsDialog(Map<String, dynamic> requestData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(requestData['type'] ?? 'Unknown Type'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Date: ${requestData['date'] ?? 'Unknown'}'),
                Text('Time: ${requestData['time'] ?? 'Unknown'}'),
                Text('Location: ${requestData['location'] ?? 'Unknown'}'),
              ],
            ),
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  child: const Text('Approve',
                      style: TextStyle(color: Colors.white)),
                  onPressed: () {
                    _updateRequestStatus(requestData['id'], 'Approved');
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
                    _updateRequestStatus(requestData['id'], 'Denied');
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
            TextButton(
              child: const Text('Close'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  void _updateRequestStatus(String requestId, String status) {
    _firestore
        .collection('appointment_request')
        .doc(requestId)
        .update({'request_status': status}).then((_) {
      if (mounted) setState(() {}); // Refresh the UI after status update
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointment Approvals'),
      ),
      body: StreamBuilder(
        stream: _firestore.collection('appointment_request').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return const CircularProgressIndicator();

          return ListView(
            children: snapshot.data!.docs.map((doc) {
              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
              data['id'] = doc.id; // Store document ID for later use

              if (data['request_status'] == 'Denied')
                return Container(); // Hide denied requests

              return Card(
                color: data['request_status'] == 'Approved'
                    ? Colors.lightGreenAccent
                    : null, // Light green if approved
                margin: const EdgeInsets.all(10),
                elevation: 5,
                child: ListTile(
                  title: Text(data['type'] ?? 'Unknown Type',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                      'Date: ${data['date'] ?? 'Unknown'} - Time: ${data['time'] ?? 'Unknown'}'),
                  trailing: ElevatedButton(
                    child: const Text('View'),
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

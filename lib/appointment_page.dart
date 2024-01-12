import 'package:firebase_core/firebase_core.dart';
import 'package:kitasihat/firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppointmentPage extends StatefulWidget {
  const AppointmentPage({super.key});

  @override
  _AppointmentPageState createState() => _AppointmentPageState();
}

class _AppointmentPageState extends State<AppointmentPage> {
  String selectedAppointmentType = 'Normal Appointment';
  DateTime selectedDateTime = DateTime.now();
  String selectedLocation = '';
  String userId = FirebaseAuth.instance.currentUser?.uid ?? '';

  Future<void> _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != selectedDateTime) {
      setState(() {
        selectedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          selectedDateTime.hour,
          selectedDateTime.minute,
        );
      });
    }
  }

  Future<void> _pickTime() async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(selectedDateTime),
    );
    if (pickedTime != null) {
      setState(() {
        selectedDateTime = DateTime(
          selectedDateTime.year,
          selectedDateTime.month,
          selectedDateTime.day,
          pickedTime.hour,
          pickedTime.minute,
        );
      });
    }
  }

  Future<void> _submitAppointment() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    await firestore.collection('appointment_request').add({
      'user_id': userId,
      'type': selectedAppointmentType,
      'date': '${selectedDateTime.toLocal().toString().split(' ')[0]}',
      'time':
          '${selectedDateTime.toLocal().hour}:${selectedDateTime.toLocal().minute}',
      'location': selectedLocation,
      'request_status': 'Pending',
      'notification_shown': false,
    }).then((value) {
      _showSubmissionPopup(context, "Appointment Submitted",
          "Your appointment has been submitted for review.");
    }).catchError((error) {
      _showSubmissionPopup(
          context, "Submission Failed", "Failed to submit your appointment.");
    });
  }

  void _showSubmissionPopup(
      BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showStatusUpdatePopup(BuildContext context, String status) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Appointment Status Update'),
          content: Text('Your appointment has been $status.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _checkAndShowNotification(QuerySnapshot snapshot) {
    for (var doc in snapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;
      if (data['request_status'] != 'Pending' &&
          data['notification_shown'] != true) {
        _showStatusUpdatePopup(context, data['request_status']);
        FirebaseFirestore.instance
            .collection('appointment_request')
            .doc(doc.id)
            .update({'notification_shown': true});
      }
    }
  }

  Widget buildAppointmentForm() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Book Here',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ),
            ),
            ExpansionTile(
              title: const Text('Type of Appointment'),
              children: [
                DropdownButtonFormField<String>(
                  value: selectedAppointmentType,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedAppointmentType = newValue!;
                    });
                  },
                  items: <String>[
                    'Vaccine',
                    'Booster',
                    'Normal Appointment',
                  ].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(value),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
            Row(
              children: [
                const Icon(Icons.calendar_today),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                      'Date: ${selectedDateTime.toLocal().toString().split(' ')[0]}'),
                ),
                ElevatedButton(
                  onPressed: _pickDate,
                  child: const Text('Choose Date'),
                ),
              ],
            ),
            Row(
              children: [
                const Icon(Icons.access_time),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                      'Time: ${selectedDateTime.toLocal().hour}:${selectedDateTime.toLocal().minute}'),
                ),
                ElevatedButton(
                  onPressed: _pickTime,
                  child: const Text('Choose Time'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ExpansionTile(
              title: const Text('Location'),
              children: [
                TextField(
                  onChanged: (value) {
                    setState(() {
                      selectedLocation = value;
                    });
                  },
                  decoration: const InputDecoration(
                    hintText: 'Enter Location',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitAppointment,
              style: ElevatedButton.styleFrom(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: const Text('Submit Appointment'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentDetailCard(Map<String, dynamic> data) {
    return Card(
      child: ListTile(
        title: Text(data['type'] ?? 'Unknown Type'),
        subtitle: Text(
          'Date: ${data['date'] ?? 'Unknown'} - Time: ${data['time'] ?? 'Unknown'} - Location: ${data['location'] ?? 'Unknown'}',
        ),
        trailing: ElevatedButton(
          child: const Text('View'),
          onPressed: () => _showAppointmentDetailPopup(context, data),
        ),
      ),
    );
  }

  void _showAppointmentDetailPopup(
      BuildContext context, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Appointment Details'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Type: ${data['type'] ?? 'Unknown'}'),
                Text('Date: ${data['date'] ?? 'Unknown'}'),
                Text('Time: ${data['time'] ?? 'Unknown'}'),
                Text('Location: ${data['location'] ?? 'Unknown'}'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00FFCA),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Appointment Booking'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('appointment_request')
            .where('user_id', isEqualTo: userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const CircularProgressIndicator();

          if (snapshot.hasData) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _checkAndShowNotification(snapshot.data!);
            });
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                buildAppointmentForm(),
                const SizedBox(height: 20),
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('Upcoming Appointments',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18)),
                        ),
                        StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('appointment_request')
                              .where('user_id', isEqualTo: userId)
                              .where('request_status', isEqualTo: 'Pending')
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData)
                              return const CircularProgressIndicator();
                            return ListView(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              children: snapshot.data!.docs.map((doc) {
                                var data = doc.data() as Map<String, dynamic>;
                                return _buildAppointmentDetailCard(data);
                              }).toList(),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

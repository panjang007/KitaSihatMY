import 'package:firebase_core/firebase_core.dart';
import 'package:kitasihat/firebase_options.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';

class AppointmentPage extends StatefulWidget {
  const AppointmentPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AppointmentPageState createState() => _AppointmentPageState();
}

class _AppointmentPageState extends State<AppointmentPage> {
  String selectedAppointmentType = 'Normal Appointment';
  DateTime selectedDateTime = DateTime.now();
  String selectedLocation = '';

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
      'type': selectedAppointmentType,
      'date': '${selectedDateTime.toLocal().toString().split(' ')[0]}',
      'time':
          '${selectedDateTime.toLocal().hour}:${selectedDateTime.toLocal().minute}',
      'location': selectedLocation,
    }).then((value) {
      print("Appointment Request Added");
      _showSubmissionPopup(context, "Appointment Submitted",
          "Your appointment has been submitted for review.");
    }).catchError((error) {
      print("Failed to add appointment request: $error");
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00FFCA),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Appointment Booking'),
      ),
      body: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
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
      ),
    );
  }
}

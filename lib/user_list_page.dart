import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserListPage extends StatelessWidget {
  final String userId;

  const UserListPage({super.key, required this.userId});

  void _addMedicalRecord(BuildContext context) {
    final TextEditingController _doctorNameController = TextEditingController();
    final TextEditingController _doctorRemarksController =
        TextEditingController();
    final TextEditingController _dateOfVisitController =
        TextEditingController();
    final TextEditingController _treatmentFacilityController =
        TextEditingController();
    final TextEditingController _timeOfVisitController =
        TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Medical Record'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: _doctorNameController,
                  decoration: const InputDecoration(hintText: 'Doctor Name'),
                ),
                TextField(
                  controller: _doctorRemarksController,
                  decoration: const InputDecoration(hintText: 'Doctor Remarks'),
                ),
                TextField(
                  controller: _dateOfVisitController,
                  decoration: const InputDecoration(
                      hintText: 'Date of Visit (yyyy-mm-dd)'),
                ),
                TextField(
                  controller: _treatmentFacilityController,
                  decoration:
                      const InputDecoration(hintText: 'Treatment Facility'),
                ),
                TextField(
                  controller: _timeOfVisitController,
                  decoration: const InputDecoration(hintText: 'Time of Visit'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Add'),
              onPressed: () {
                FirebaseFirestore.instance
                    .collection('medical_treatment_history')
                    .add({
                  'doctor_name': _doctorNameController.text,
                  'doctor_remarks': _doctorRemarksController.text,
                  'date_of_visit': _dateOfVisitController.text,
                  'treatment_facility': _treatmentFacilityController.text,
                  'time_of_visit': _timeOfVisitController.text,
                  'user_id': userId,
                });
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  void _addMedicationRecord(BuildContext context) {
    final TextEditingController _medicineNameController =
        TextEditingController();
    final TextEditingController _doctorNameController = TextEditingController();
    final TextEditingController _doctorInstructionsController =
        TextEditingController();
    final TextEditingController _doctorRemarksController =
        TextEditingController();
    final TextEditingController _startDateController = TextEditingController();
    final TextEditingController _endDateController = TextEditingController();
    final TextEditingController _facilityController = TextEditingController();
    final TextEditingController _timeOfVisitController =
        TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Medication Record'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: _medicineNameController,
                  decoration: const InputDecoration(hintText: 'Medicine Name'),
                ),
                TextField(
                  controller: _doctorNameController,
                  decoration: const InputDecoration(hintText: 'Doctor Name'),
                ),
                TextField(
                  controller: _doctorInstructionsController,
                  decoration:
                      const InputDecoration(hintText: 'Doctor Instructions'),
                ),
                TextField(
                  controller: _doctorRemarksController,
                  decoration: const InputDecoration(hintText: 'Doctor Remarks'),
                ),
                TextField(
                  controller: _startDateController,
                  decoration: const InputDecoration(
                      hintText: 'Start Date (yyyy-mm-dd)'),
                ),
                TextField(
                  controller: _endDateController,
                  decoration:
                      const InputDecoration(hintText: 'End Date (yyyy-mm-dd)'),
                ),
                TextField(
                  controller: _facilityController,
                  decoration: const InputDecoration(hintText: 'Facility'),
                ),
                TextField(
                  controller: _timeOfVisitController,
                  decoration: const InputDecoration(hintText: 'Time of Visit'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Add'),
              onPressed: () {
                FirebaseFirestore.instance
                    .collection('medication_history')
                    .add({
                  'medicine_name': _medicineNameController.text,
                  'doctor_name': _doctorNameController.text,
                  'doctor_instructions': _doctorInstructionsController.text,
                  'doctor_remarks': _doctorRemarksController.text,
                  'start_date': _startDateController.text,
                  'end_date': _endDateController.text,
                  'facility': _facilityController.text,
                  'time_of_visit': _timeOfVisitController.text,
                  'user_id': userId,
                });
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Cancel'),
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
      appBar: AppBar(
        title: const Text('User Medical History'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ListTile(
              title: const Text('Medical Treatment Record'),
              trailing: IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => _addMedicalRecord(context),
              ),
            ),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('medical_treatment_history')
                  .where('user_id', isEqualTo: userId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const ListTile(
                      title: Text('No Medical Treatment Records'));
                }
                return ExpansionTile(
                  title: const Text('Medical Treatment Record'),
                  children: snapshot.data!.docs.map((doc) {
                    var data = doc.data() as Map<String, dynamic>;
                    return ListTile(
                      title: Text(data['doctor_name'] ?? 'N/A'),
                      subtitle: Text(
                          'Date of Visit: ${data['date_of_visit'] ?? 'N/A'}'),
                    );
                  }).toList(),
                );
              },
            ),
            ListTile(
              title: const Text('Medication History'),
              trailing: IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => _addMedicationRecord(context),
              ),
            ),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('medication_history')
                  .where('user_id', isEqualTo: userId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const ListTile(
                      title: Text('No Medication History Records'));
                }
                return ExpansionTile(
                  title: const Text('Medication History'),
                  children: snapshot.data!.docs.map((doc) {
                    var data = doc.data() as Map<String, dynamic>;
                    return ListTile(
                      title: Text(data['medicine_name'] ?? 'N/A'),
                      subtitle:
                          Text('Start Date: ${data['start_date'] ?? 'N/A'}'),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

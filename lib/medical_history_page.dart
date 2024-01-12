import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MedicalHistory extends StatefulWidget {
  const MedicalHistory({super.key});

  @override
  State<MedicalHistory> createState() => _MedicalHistoryState();
}

class _MedicalHistoryState extends State<MedicalHistory> {
  late String userId;

  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    initializeCollections();
  }

  void initializeCollections() async {
    // Initializing default data for 'patient_data'
    await initializeCollectionWithDefaultData('patient_data', {
      'name': 'N/A',
      'age': 'N/A',
      'blood_type': 'N/A',
      'allergies': 'N/A',
    });
  }

  Future<void> initializeCollectionWithDefaultData(
      String collectionName, Map<String, dynamic> defaultData) async {
    var collectionRef = FirebaseFirestore.instance.collection(collectionName);
    var docRef = collectionRef.doc(userId);
    var docSnapshot = await docRef.get();

    if (!docSnapshot.exists) {
      await docRef.set({...defaultData, 'user_id': userId});
    }
  }

  void _showEditDialog(Map<String, dynamic> patientData) {
    final _nameController = TextEditingController(text: patientData['name']);
    final _ageController =
        TextEditingController(text: patientData['age']?.toString() ?? '');
    final _bloodTypeController =
        TextEditingController(text: patientData['blood_type']);
    final _allergiesController =
        TextEditingController(text: patientData['allergies']);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Patient Information'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Name')),
                TextField(
                    controller: _ageController,
                    decoration: const InputDecoration(labelText: 'Age'),
                    keyboardType: TextInputType.number),
                TextField(
                    controller: _bloodTypeController,
                    decoration: const InputDecoration(labelText: 'Blood Type')),
                TextField(
                    controller: _allergiesController,
                    decoration: const InputDecoration(labelText: 'Allergies')),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                FirebaseFirestore.instance
                    .collection('patient_data')
                    .doc(userId)
                    .set({
                  'name': _nameController.text,
                  'age': int.tryParse(_ageController.text) ?? 0,
                  'blood_type': _bloodTypeController.text,
                  'allergies': _allergiesController.text,
                }, SetOptions(merge: true)).then((_) {
                  Navigator.of(context).pop();
                  setState(() {});
                });
              },
            ),
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showDetailsDialog(Map<String, dynamic> recordData, String title) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: ListBody(
              children: recordData.entries
                  .map((entry) => Text('${entry.key}: ${entry.value}'))
                  .toList(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget buildPatientDataSection() {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('patient_data')
          .doc(userId)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        if (!snapshot.hasData ||
            snapshot.hasError ||
            snapshot.data?.data() == null) {
          return ElevatedButton(
              onPressed: () => _showEditDialog({}),
              child: const Text('Enter Patient Information'));
        }
        var patientData = snapshot.data!.data() as Map<String, dynamic>;
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 4.0,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Patient Information',
                      style: TextStyle(
                          fontSize: 24.0, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text(
                      'Name: ${patientData['name']}\nAge: ${patientData['age']}\nBlood Type: ${patientData['blood_type']}\nAllergies: ${patientData['allergies']}',
                      style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 20),
                  ElevatedButton(
                      onPressed: () => _showEditDialog(patientData),
                      child: const Text('Edit')),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildHistorySection(String title, String collection,
      List<String> displayFields, Map<String, String> fieldLabels) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection(collection)
          .where('user_id', isEqualTo: userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        if (!snapshot.hasData || snapshot.hasError) {
          return ElevatedButton(
              onPressed: () {},
              child: Text('Enter $title')); // Adjust as needed
        }

        List<DocumentSnapshot> documents = snapshot.data!.docs;
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 4.0,
            child: ExpansionTile(
              title: Text(title,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              children: documents.map((doc) {
                Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                return ListTile(
                  title: Text(title == 'Medication History'
                      ? 'Medicine: ${data['medicine_name'] ?? 'N/A'}\nStart Date: ${data['start_date'] ?? 'N/A'}'
                      : displayFields
                          .map((field) =>
                              '${fieldLabels[field]}: ${data[field]}')
                          .join('\n')),
                  trailing: ElevatedButton(
                    child: const Text('View'),
                    onPressed: () => _showDetailsDialog(data, title),
                  ),
                );
              }).toList(),
            ),
          ),
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
        title: const Text('Medical History'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 80),
              buildPatientDataSection(),
              buildHistorySection(
                  'Medical Treatment Record', 'medical_treatment_history', [
                'treatment_facility',
                'date_of_visit',
                'doctor_name'
              ], {
                'treatment_facility': 'Hospital/Clinic',
                'date_of_visit': 'Date of Visit',
                'doctor_name': "Doctor's Name"
              }),
              buildHistorySection(
                  'Medication History',
                  'medication_history',
                  ['medicine_name', 'start_date'],
                  {'medicine_name': 'Medicine', 'start_date': 'Start Date'}),
            ],
          ),
        ),
      ),
    );
  }
}

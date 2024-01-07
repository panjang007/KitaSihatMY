import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Add this for Firebase Authentication

class MedicationPage extends StatefulWidget {
  const MedicationPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MedicationPageState createState() => _MedicationPageState();
}

class _MedicationPageState extends State<MedicationPage> {
  final List<String> days = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday"
  ];
  int _selectedDayIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Medication Reminder'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: days.length,
                itemBuilder: (context, index) {
                  return buildDayWidget(index);
                },
              ),
            ),
          ),
          Expanded(
            child: buildSelectedDayContent(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AddReminderPage()),
          );
        },
        child: const Icon(Icons.add),
        tooltip: 'Add Medication Reminder',
      ),
    );
  }

  Widget buildDayWidget(int index) {
    final String day = days[index];
    final bool isSelected = index == _selectedDayIndex;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedDayIndex = index;
        });
      },
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color.fromARGB(255, 99, 45, 106)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Text(
          day,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  Widget buildSelectedDayContent() {
    final String selectedDay = days[_selectedDayIndex];
    final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('medication_reminder')
          .where('day', isEqualTo: selectedDay)
          .where('user_id', isEqualTo: currentUserId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        List<DocumentSnapshot> documents = snapshot.data!.docs;
        return ListView(
          children: documents
              .map((doc) => MedicationReminderCard(document: doc))
              .toList(),
        );
      },
    );
  }
}

class MedicationReminderCard extends StatelessWidget {
  final DocumentSnapshot document;

  const MedicationReminderCard({super.key, required this.document});

  @override
  Widget build(BuildContext context) {
    bool isDone = document['is_done'] ?? false;
    Color cardColor = isDone ? Colors.lightGreen : Colors.white;

    return Card(
      color: cardColor,
      child: ListTile(
        title: Text(document['medicine_name']),
        subtitle: Text('Time: ${document['time']}'),
        onTap: () => showMedicineDetails(context, document),
        trailing: Wrap(
          spacing: 12,
          children: <Widget>[
            ElevatedButton(
              child: const Text('Done'),
              onPressed: () {
                if (!isDone) {
                  document.reference.update({'is_done': true});
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteReminder(document, context),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteReminder(DocumentSnapshot document, BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Reminder'),
          content: const Text('Are you sure you want to delete this reminder?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                document.reference.delete().then((_) {
                  Navigator.of(context).pop();
                });
              },
            ),
          ],
        );
      },
    );
  }

  void showMedicineDetails(BuildContext context, DocumentSnapshot document) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(document['medicine_name']),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Type: ${document['medicine_type']}'),
                Text('Day: ${document['day']}'),
                Text('Time: ${document['time']}'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Done'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

class AddReminderPage extends StatefulWidget {
  const AddReminderPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AddReminderPageState createState() => _AddReminderPageState();
}

class _AddReminderPageState extends State<AddReminderPage> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _iconType = 'Pill';
  final List<String> _selectedDays = [];
  TimeOfDay _time = TimeOfDay.now();

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _time,
    );
    if (picked != null && picked != _time) {
      setState(() {
        _time = picked;
      });
    }
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      String currentUserId = FirebaseAuth.instance.currentUser!.uid;

      for (String day in _selectedDays) {
        FirebaseFirestore.instance.collection('medication_reminder').add({
          'medicine_name': _name,
          'medicine_type': _iconType,
          'day': day,
          'time': _time.format(context),
          'is_done': false,
          'user_id': currentUserId,
        });
      }

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Medication Reminder'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: <Widget>[
            TextFormField(
              decoration: const InputDecoration(labelText: 'Medicine Name'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter medicine name';
                }
                return null;
              },
              onSaved: (value) => _name = value ?? '',
            ),
            DropdownButtonFormField<String>(
              value: _iconType,
              decoration: const InputDecoration(labelText: 'Medicine Type'),
              items: <String>['Pill', 'Syringe', 'Liquid', 'Inhaler']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _iconType = newValue!;
                });
              },
            ),
            ...buildDayCheckboxes(),
            ListTile(
              title: Text("Time: ${_time.format(context)}"),
              trailing: const Icon(Icons.access_time),
              onTap: () => _selectTime(context),
            ),
            ElevatedButton(
              onPressed: _saveForm,
              child: const Text('Add Reminder'),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> buildDayCheckboxes() {
    List<String> days = [
      "Monday",
      "Tuesday",
      "Wednesday",
      "Thursday",
      "Friday",
      "Saturday",
      "Sunday"
    ];

    return days.map((day) {
      return CheckboxListTile(
        title: Text(day),
        value: _selectedDays.contains(day),
        onChanged: (bool? value) {
          setState(() {
            if (value ?? false) {
              if (!_selectedDays.contains(day)) {
                _selectedDays.add(day);
              }
            } else {
              _selectedDays.remove(day);
            }
          });
        },
      );
    }).toList();
  }
}

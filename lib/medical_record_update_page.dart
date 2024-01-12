import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kitasihat/user_list_page.dart';

class MedicalRecordUpdatePage extends StatefulWidget {
  const MedicalRecordUpdatePage({Key? key}) : super(key: key);

  @override
  _MedicalRecordUpdatePageState createState() =>
      _MedicalRecordUpdatePageState();
}

class _MedicalRecordUpdatePageState extends State<MedicalRecordUpdatePage> {
  List<Map<String, dynamic>> _allUsers = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    var querySnapshot =
        await FirebaseFirestore.instance.collection('registration').get();
    setState(() {
      _allUsers = querySnapshot.docs.map((doc) {
        var userData = doc.data();
        return {...userData, 'userId': doc.id};
      }).toList();
    });
  }

  List<Map<String, dynamic>> _getFilteredUsers() {
    if (_searchQuery.isEmpty) {
      return _allUsers;
    } else {
      return _allUsers.where((user) {
        var name = user['name']?.toLowerCase() ?? '';
        var icNumber = user['ic_number'] ?? '';
        var email = user['email']?.toLowerCase() ?? '';
        var phone = user['phone'] ?? '';

        return name.contains(_searchQuery.toLowerCase()) ||
            icNumber.contains(_searchQuery) ||
            email.contains(_searchQuery.toLowerCase()) ||
            phone.contains(_searchQuery);
      }).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    var filteredUsers = _getFilteredUsers();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Medical Record Update'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                labelText: 'Search',
                suffixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: filteredUsers.isEmpty
                ? const Center(child: Text("No search results found"))
                : ListView.builder(
                    itemCount: filteredUsers.length,
                    itemBuilder: (context, index) {
                      var user = filteredUsers[index];
                      return Card(
                        child: ListTile(
                          title: Text(user['name'] ?? 'Unknown Name'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('IC: ${user['ic_number'] ?? 'N/A'}'),
                              Text('Email: ${user['email'] ?? 'N/A'}'),
                              Text('Phone: ${user['phone'] ?? 'N/A'}'),
                            ],
                          ),
                          isThreeLine: true,
                          trailing: ElevatedButton(
                            child: const Text('View'),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      UserListPage(userId: user['userId']),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

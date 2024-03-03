import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:env_assignment/services/firebase_auth_services.dart';
import 'package:flutter/material.dart';

import '../assign.dart';
import '../auth/login.dart';

class ComplaintsScreen extends StatefulWidget {
  static const routeName = '/complaintsscreen';

  @override
  State<ComplaintsScreen> createState() => _ComplaintsScreenState();
}

class _ComplaintsScreenState extends State<ComplaintsScreen> {
  final FirebaseAuthService _authService = FirebaseAuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> complaints = [];

  @override
  void initState() {
    super.initState();
    fetchComplaints();
  }

  Future<void> fetchComplaints() async {
    try {
      // Fetch all complaints from Firestore
      QuerySnapshot complaintsSnapshot =
          await _firestore.collection('complaints').get();

      // Convert QuerySnapshot to List<Map<String, dynamic>>
      complaints = complaintsSnapshot.docs.map((DocumentSnapshot document) {
        return {
          ...document.data() as Map<String, dynamic>,
          'id': document.id,
        };
      }).toList();
      print("compd $complaints");
      // Update the state to trigger a rebuild with the fetched data
      setState(() {});
    } catch (e) {
      print("Error fetching complaints: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text('Complaints'),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert),
            onSelected: (value) async {
              if (value == 'logout') {
                await _authService.signOut();
                Navigator.pushReplacementNamed(context, '/');
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'logout',
                child: Text('Logout'),
              ),
              // Add more menu items if needed
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Number of Complaints: ${complaints.length}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
            SizedBox(height: 16.0),
            Container(
              height: height * 0.8,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: complaints.length,
                scrollDirection: Axis.vertical,
                itemBuilder: (context, index) {
                  // Replace with actual complaint data
                  String complaintNumber = 'C${index + 1}';
                  String description = complaints[index]['description'];
                  String title = complaints[index]['title'];
                  String complaintID = complaints[index]['id'];
                  bool isAssigned =
                      complaints[index]['assignedType'] != "" ? true : false;
                  bool? isSolved = complaints[index]['status'] == 'Solved' &&
                          complaints[index]['status'] != 'Rejected'
                      ? true
                      : (complaints[index]['status'] == 'In Progress' &&
                              complaints[index]['status'] != 'Rejected'
                          ? false
                          : null);
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      title: Text('Complaint: $complaintNumber - $title'),
                      subtitle: Text(description),
                      trailing: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            primary: isAssigned && isSolved == false
                                ? Colors.blue[700]
                                : (isAssigned && isSolved == true
                                    ? Colors.green
                                    : (isSolved == null
                                        ? Colors.red
                                        : Colors.blue)) // Background color
                            ),
                        onPressed: () {
                          ((!isAssigned && isSolved != true) ||
                                  (!isAssigned && isSolved == true))
                              ? Navigator.pushNamed(
                                  context,
                                  AssignScreen.routeName,
                                  arguments: {
                                    'complaintNumber': complaintNumber,
                                    'title': complaints[index]['title'],
                                    'description': complaints[index]
                                        ['description'],
                                    'province': complaints[index]['province'],
                                    'evidenceURL': complaints[index]
                                        ['evidenceURL'],
                                    'complaintID': complaintID,
                                  },
                                )
                              : null;
                        },
                        child: isAssigned && isSolved == false
                            ? Text('Assigned')
                            : (isAssigned && isSolved == true
                                ? Text('Solved')
                                : (isSolved == null
                                    ? Text('Rejected')
                                    : Text('Assign'))),
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

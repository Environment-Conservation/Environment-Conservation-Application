import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:env_assignment/screens/submit_action.dart';
import 'package:env_assignment/services/firebase_auth_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../auth/login.dart';

class ComplaintsBeat extends StatefulWidget {
  static const routeName = '/complaintsbeatscreen';

  @override
  State<ComplaintsBeat> createState() => _ComplaintsBeatState();
}

class _ComplaintsBeatState extends State<ComplaintsBeat> {
  List<Map<String, dynamic>> complaints = [];
  int progressCount = 0;

  @override
  void initState() {
    super.initState();
    fetchComplaints().then((_) {
      setState(() {});
    });
  }

  Future<void> fetchComplaints() async {
    try {
      String currentUserID = FirebaseAuth.instance.currentUser?.uid ?? "";

      QuerySnapshot complaintsSnapshot = await FirebaseFirestore.instance
          .collection('complaints')
          .where('assignedTo', isEqualTo: currentUserID)
          .get();

      QuerySnapshot complaintsOnProgress = await FirebaseFirestore.instance
          .collection('complaints')
          .where('assignedTo', isEqualTo: currentUserID)
          .where('status', isEqualTo: 'In Progress')
          .get();

      // Convert QuerySnapshot to List<Map<String, dynamic>>
      complaints = complaintsSnapshot.docs.map((DocumentSnapshot document) {
        return {
          ...document.data() as Map<String, dynamic>,
          'id': document.id,
        };
      }).toList();

      progressCount = complaintsOnProgress.docs
          .map((DocumentSnapshot document) {
            return document.data() as Map<String, dynamic>;
          })
          .toList()
          .length;
      setState(() {});
    } catch (e) {
      print("Error fetching user details: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final FirebaseAuthService _authService = FirebaseAuthService();
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    Widget _buildStatusBox(String title, int number) {
      return Container(
        margin: EdgeInsets.all(8.0),
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12.0,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              number.toString(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
                color: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

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
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              children: [
                _buildStatusBox('Total \nComplaints', complaints.length),
                _buildStatusBox('Complaints \nin Progress', progressCount),
                _buildStatusBox(
                    'Complaints \nSolved', complaints.length - progressCount),
              ],
            ),
            Container(
              height: height * 0.8,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: complaints.length,
                scrollDirection: Axis.vertical,
                itemBuilder: (context, index) {
                  // Replace with actual complaint data
                  String complaintNumber = 'C$index';
                  String description = complaints[index]['description'];
                  String title = complaints[index]['title'];
                  String complaintID = complaints[index]['id'];
                  double? progress = complaints[index]['progress'] == null
                      ? 0.0
                      : (complaints[index]['progress'] as num).toDouble();
                  String? action = complaints[index]['action'];
                  String? status = complaints[index]['status'];

                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      title: Text('Complaint: $complaintNumber - $title'),
                      subtitle: Text(description),
                      trailing: GestureDetector(
                        onTap: () {
                          action != 'Solved'
                              ? Navigator.pushNamed(
                                  context,
                                  SubmitAction.routeName,
                                  arguments: {
                                    'complaintNumber': complaintNumber,
                                    'title': complaints[index]['title'],
                                    'description': complaints[index]
                                        ['description'],
                                    'complaintID': complaintID,
                                    'progress': progress,
                                    'action': complaints[index]['action'],
                                    'evidenceURL': complaints[index]
                                        ['evidenceURL'],
                                  },
                                )
                              : null;
                        },
                        child: Container(
                          padding: EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: action != '' && status == 'Solved'
                                ? Colors.green
                                : (action != '' && status == 'In Progress'
                                    ? Colors.orange
                                    : Theme.of(context).primaryColor),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Text(
                            action != '' && status == 'Solved'
                                ? 'Solved'
                                : (action != '' && status == 'In Progress'
                                    ? 'In Progress'
                                    : 'New'),
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

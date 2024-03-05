import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:env_assignment/screens/complaints_public_add.dart';
import 'package:env_assignment/services/complaintServices.dart';
import 'package:env_assignment/services/firebase_auth_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../assign.dart';
import '../auth/login.dart';

class ComplaintsPublic extends StatefulWidget {
  static const routeName = '/complaintspublicscreen';

  @override
  State<ComplaintsPublic> createState() => _ComplaintsPublicState();
}

class _ComplaintsPublicState extends State<ComplaintsPublic> {
  List<Map<String, dynamic>> complaints = [];
  int progressCount = 0;

  @override
  void initState() {
    super.initState();
    fetchComplaints();
  }

  Future<void> fetchComplaints() async {
    try {
      String currentUserID = FirebaseAuth.instance.currentUser?.uid ?? "";

      // Fetch complaints based on the current user's ID
      QuerySnapshot complaintsSnapshot = await FirebaseFirestore.instance
          .collection('complaints')
          .where('createdBy', isEqualTo: currentUserID)
          .get();

      QuerySnapshot complaintsOnProgress = await FirebaseFirestore.instance
          .collection('complaints')
          .where('createdBy', isEqualTo: currentUserID)
          .where('status', isEqualTo: 'In Progress')
          .get();

      // Convert QuerySnapshot to List<Map<String, dynamic>>
      complaints = complaintsSnapshot.docs.map((DocumentSnapshot document) {
        return document.data() as Map<String, dynamic>;
      }).toList();

      progressCount = complaintsOnProgress.docs
          .map((DocumentSnapshot document) {
            return document.data() as Map<String, dynamic>;
          })
          .toList()
          .length;

      print("comp: ${complaints}");
      // Update the state to trigger a rebuild with the fetched data
      setState(() {});
    } catch (e) {
      print("Error fetching complaints: $e");
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
              textAlign: TextAlign.center,
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
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, ComplaintsPublicAdd.routeName);
            },
            child: Row(
              children: [
                Icon(
                  Icons.add,
                  color: Colors.white,
                ),
                Text(
                  'Add New',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                  ),
                ),
              ],
            ),
          ),
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
                reverse: true,
                itemBuilder: (context, index) {
                  // Replace with actual complaint data
                  String complaintNumber = 'C$index';
                  String description = complaints[index]['description'];
                  String title = complaints[index]['title'];
                  double? progress = complaints[index]['progress'] == null
                      ? 0.0
                      : (complaints[index]['progress'] as num).toDouble();
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
                      title: Text('Complaint: $complaintNumber  - $title'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(description),
                          Text('progress - ${progress} %'),
                        ],
                      ),
                      trailing: Container(
                        padding: EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: isSolved == true
                              ? Colors.green
                              : (isSolved == false
                                  ? Colors.orange
                                  : Colors.red),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Text(
                          isSolved == true
                              ? 'Solved'
                              : (isSolved == false
                                  ? 'In Progress'
                                  : 'Rejected'),
                          style: TextStyle(color: Colors.white),
                        ),
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

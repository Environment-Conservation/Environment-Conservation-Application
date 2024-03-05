import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:env_assignment/screens/assign_dept.dart';
import 'package:env_assignment/services/firebase_auth_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../auth/login.dart';

class ComplaintsDept extends StatefulWidget {
  static const routeName = '/complaintsdeptscreen';

  @override
  State<ComplaintsDept> createState() => _ComplaintsDeptState();
}

class _ComplaintsDeptState extends State<ComplaintsDept> {
  List<Map<String, dynamic>> complaints = [];
  String appBar = '';
  String userType = '';
  int progressCount = 0;

  @override
  void initState() {
    super.initState();
    checkUserType().then((_) {
      setState(() {});
    });
  }

  Future<void> checkUserType() async {
    try {
      String currentUserID = FirebaseAuth.instance.currentUser?.uid ?? "";

      // Fetch user type based on the current user's ID
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserID)
          .get();

      if (userSnapshot.exists) {
        String userType = userSnapshot['type'];

        QuerySnapshot complaintsSnapshot = await FirebaseFirestore.instance
            .collection('complaints')
            .where('assignedType', isEqualTo: userType)
            .get();

        QuerySnapshot complaintsOnProgress = await FirebaseFirestore.instance
            .collection('complaints')
            .where('assignedType', isEqualTo: userType)
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
        print("compd $complaints");
        // Update the state to trigger a rebuild with the fetched data
        setState(() {});

        String appBarTitle = userType == 'wild'
            ? 'Department of Wildlife Conservation'
            : (userType == 'forest'
                ? 'Department of Forest Conservation'
                : 'Complaints Department');

        appBar = appBarTitle;
        print("appbar $appBarTitle");

        // You can perform additional actions based on the user type here

      } else {
        print("User document does not exist");
      }
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
          title: Text(appBar),
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
                    String? action = complaints[index]['action'];
                    double? progress = complaints[index]['progress'] == null
                        ? 0.0
                        : (complaints[index]['progress'] as num).toDouble();
                    bool isSolved = complaints[index]['status'] != 'In Progress'
                        ? true
                        : false;
                    bool isAssigned =
                        complaints[index]['assignedTo'] != "" ? true : false;

                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8.0),
                      child: ListTile(
                        title: Text('Complaint: $complaintNumber - $title'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(description),
                            Text('progress - ${progress} %'),
                          ],
                        ),
                        trailing: GestureDetector(
                          onTap: () {
                            (!isAssigned || isSolved != true)
                                ? Navigator.pushNamed(
                                    context,
                                    AssignDept.routeName,
                                    arguments: {
                                      'complaintNumber': 'C$index',
                                      'title': complaints[index]['title'],
                                      'description': complaints[index]
                                          ['description'],
                                      'complaintID': complaintID,
                                      'province': complaints[index]['province'],
                                      'evidenceURL': complaints[index]
                                          ['evidenceURL'],
                                      'action': complaints[index]['action'],
                                      'progress': complaints[index]['progress'],
                                      'assignedTo': complaints[index]
                                          ['assignedTo']
                                    },
                                  )
                                : null;
                          },
                          child: Container(
                            padding: EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color: !isAssigned
                                  ? Theme.of(context).primaryColor
                                  : (isSolved ? Colors.green : Colors.orange),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Text(
                              !isAssigned
                                  ? 'Assign'
                                  : (isSolved ? 'Solved' : 'In Progress'),
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              )
            ],
          ),
        ));
  }
}

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:env_assignment/screens/home/complaints_dept.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class AssignDept extends StatefulWidget {
  static const routeName = '/assigndeptscreen';

  @override
  State<AssignDept> createState() => _AssignDeptState();
}

class _AssignDeptState extends State<AssignDept> {
  firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;
  String currentUserID = FirebaseAuth.instance.currentUser?.uid ?? "";
  List<Map<String, dynamic>> officers = [];

  TextEditingController _complaintNoController = TextEditingController();
  TextEditingController _titleController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _actionController = TextEditingController();
  TextEditingController _provinceController = TextEditingController();
  TextEditingController _deptController = TextEditingController();
  TextEditingController _fileSubmitController = TextEditingController();

  String? _selectedBeatOfficer;
  String? _beatOfficer;
  String? _complaintId;
  String? _provinceValue;
  String? _progress;
  int? _selectedDept;
  String _imageURL = '';
  String _evidenceURL = '';

  String _filePath = '';

  List<String> _provinceOptions = [
    'Western',
    'Central',
    'Southern',
    'Northern',
    'Eastern',
    'North Western',
    'North Central',
    'Uva',
    'Sabaragamuwa',
  ];

  @override
  void initState() {
    super.initState();
    checkUserType().then((_) {
      setState(() {
        if (_beatOfficer != '') {
          _selectedBeatOfficer = _beatOfficer;
        }
      });
    });
  }

  Future<void> checkUserType() async {
    try {
      String currentUserID = FirebaseAuth.instance.currentUser?.uid ?? "";

      // Fetch user type based on the current user's ID
      QuerySnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('type', isEqualTo: 'beat')
          .get();

      officers = userSnapshot.docs.map((DocumentSnapshot documentSnapshot) {
        return {
          ...documentSnapshot.data() as Map<String, dynamic>,
          'id': documentSnapshot.id,
        };
      }).toList();
      print("offce $officers");
    } catch (e) {
      print("Error fetching user details: $e");
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Retrieve arguments here
    Map<String, dynamic>? arguments =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    // Update controllers with the passed data
    _complaintNoController.text = arguments?['complaintNumber'] ?? '';
    _titleController.text = arguments?['title'] ?? '';
    _descriptionController.text = arguments?['description'] ?? '';
    _actionController.text = arguments?['action'] ?? '';
    _provinceController.text = arguments?['province'] ?? '';
    _complaintId = arguments?['complaintID'] ?? '';
    _evidenceURL = arguments?['evidenceURL'] ?? '';
    _beatOfficer = arguments?['assignedTo'] ?? '';
    _progress = arguments?['progress']?.toString() ?? '0';

    print("prov ${_beatOfficer}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text('Assign complaint'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Complaint Number',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.0),
                TextField(
                  controller: _complaintNoController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  enabled: false,
                ),
              ],
            ),
            SizedBox(height: 16.0),

            // Title field
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Title',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.0),
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  enabled: false,
                ),
              ],
            ),
            SizedBox(height: 16.0),

            // Description field
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Description',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.0),
                TextField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.0),

            // Province field
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Province',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.0),
                DropdownButtonFormField<String>(
                  value: _provinceController.text,
                  onChanged: (value) {
                    setState(() {
                      _provinceValue = value;
                    });
                  },
                  items: _provinceOptions.map((String department) {
                    return DropdownMenuItem<String>(
                      value: department,
                      child: Text(department),
                    );
                  }).toList(),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.0),

            // Assign Department Dropdown
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Assign Beat Officer',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.0),
                DropdownButtonFormField<String>(
                  value: _selectedBeatOfficer,
                  onChanged: (value) {
                    setState(() {
                      _selectedBeatOfficer = value;
                    });
                  },
                  items: officers.map((Map<String, dynamic> officer) {
                    return DropdownMenuItem<String>(
                      value: officer['id'],
                      child: Text(officer['fullName']),
                    );
                  }).toList(),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.0),

            if (_beatOfficer != '')
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Action Taken',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  TextField(
                    controller: _actionController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            SizedBox(height: 16.0),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Progress - ${_progress}%',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.0),

            // File Submission option
            // Column(
            //   crossAxisAlignment: CrossAxisAlignment.start,
            //   children: [
            //     Text(
            //       'Evidence',
            //       style: TextStyle(
            //         fontWeight: FontWeight.bold,
            //       ),
            //     ),
            //     SizedBox(height: 8.0),
            //     ElevatedButton(
            //       onPressed: () async {
            //         // Open file picker when the button is pressed
            //         FilePickerResult? result =
            //             await FilePicker.platform.pickFiles(
            //           type: FileType.custom,
            //           allowedExtensions: ['jpg', 'jpeg', 'png'],
            //         );

            //         if (result != null) {
            //           String filePath = result.files.single.path!;
            //           setState(() {
            //             _filePath = filePath;
            //           });
            //           firebase_storage.Reference ref = storage
            //               .ref()
            //               .child('complaint_images/${DateTime.now()}.jpg');
            //           await ref.putFile(File(filePath));

            //           _imageURL = await ref.getDownloadURL();
            //           print('Image URL: $_imageURL');
            //         }
            //       },
            //       child: Text('Upload Evidence'),
            //     ),
            //     SizedBox(height: 8.0),
            //     if (_filePath.isNotEmpty) Text('Selected File: $_filePath'),
            //   ],
            // ),
            SizedBox(height: 24.0),
            if (_evidenceURL != '')
              Image.network(
                _evidenceURL,
                height: 200,
                width: 200,
                fit: BoxFit.cover,
              ),

            // Submit button
            ElevatedButton(
              onPressed: () async {
                Map<String, dynamic> updatedData = {
                  'title': _titleController.text,
                  'description': _descriptionController.text,
                  'status': 'In Progress',
                  'assignedTo': _selectedBeatOfficer,
                  'assignedBy': currentUserID,
                  'action': _actionController.text,
                };

                if (_filePath.isNotEmpty) {
                  File file = File(_filePath);
                  String fileName =
                      DateTime.now().millisecondsSinceEpoch.toString();
                  firebase_storage.Reference ref = firebase_storage
                      .FirebaseStorage.instance
                      .ref()
                      .child('evidence_images')
                      .child(fileName);

                  await ref.putFile(file);

                  // Get the download URL of the uploaded image
                  String downloadURL = await ref.getDownloadURL();

                  // Save the download URL in Firestore along with other data
                  updatedData['evidenceURL'] = downloadURL;
                }

                try {
                  await FirebaseFirestore.instance
                      .collection('complaints')
                      .doc(_complaintId)
                      .update(updatedData);

                  // If the update is successful, you can perform additional actions here
                } catch (e) {
                  print("Error updating complaint: $e");
                }
                Navigator.pushReplacementNamed(
                    context, ComplaintsDept.routeName);
              },
              child: Container(
                width: double.infinity,
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(vertical: 15.0),
                child: Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

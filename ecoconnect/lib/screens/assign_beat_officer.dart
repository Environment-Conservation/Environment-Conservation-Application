import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:env_assignment/screens/home/complaints.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class AssignScreen extends StatefulWidget {
  static const routeName = '/assignscreen';

  @override
  State<AssignScreen> createState() => _AssignScreenState();
}

class _AssignScreenState extends State<AssignScreen> {
  TextEditingController _complaintNoController = TextEditingController();
  TextEditingController _titleController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _provinceController = TextEditingController();
  TextEditingController _fileSubmitController = TextEditingController();

  String? _selectedDepartment;
  String? _provinceValue;
  String? _complaintId;
  String _evidenceURL = '';
  int? _selectedDept;

  String currentUserID = FirebaseAuth.instance.currentUser?.uid ?? "";

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

  List<String> _departmentOptions = [
    'Department of Forest Conservation',
    'Department of Wildlife Conservation',
  ];

  String _filePath = '';

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
    _provinceController.text = arguments?['province'] ?? '';
    _complaintId = arguments?['complaintID'] ?? '';
    _evidenceURL = arguments?['evidenceURL'] ?? '';

    print("_provinceController.text: ${_provinceController.text}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          title: Text('Assign Complaint')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
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
                  'Assign Department',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.0),
                DropdownButtonFormField<String>(
                  value: _selectedDepartment,
                  onChanged: (value) {
                    setState(() {
                      _selectedDepartment = value;
                      _selectedDept = _departmentOptions.indexOf(value!);
                      print("val $value");
                    });
                  },
                  items: _departmentOptions.map((String department) {
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
                  'assignedType': _selectedDept == 0 ? 'forest' : 'wild',
                  'assignedTo': '',
                  'assignedBy': currentUserID,
                  // Add other fields as needed
                };

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
                    context, ComplaintsScreen.routeName);
              },
              child: Container(
                width: double.infinity,
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(vertical: 15.0),
                child: Text('Assign'),
              ),
            ),
            SizedBox(height: 8.0),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.red, // Background color
              ),
              onPressed: () async {
                Map<String, dynamic> updatedData = {
                  'title': _titleController.text,
                  'description': _descriptionController.text,
                  'status': 'Rejected',
                  'assignedBy': currentUserID,
                };
                try {
                  await FirebaseFirestore.instance
                      .collection('complaints')
                      .doc(_complaintId)
                      .update(updatedData);

                  // If the update is successful, you can perform additional actions here
                } catch (e) {
                  print("Error updating complaint: $e");
                }
                Navigator.pop(context);
              },
              child: Container(
                width: double.infinity,
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(vertical: 15.0),
                child: Text('Reject'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

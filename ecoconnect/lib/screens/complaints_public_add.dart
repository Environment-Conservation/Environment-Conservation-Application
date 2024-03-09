import 'dart:io';

import 'package:env_assignment/screens/home/complaints_public.dart';
import 'package:env_assignment/services/complaintServices.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class ComplaintsPublicAdd extends StatefulWidget {
  static const routeName = '/publicomplaintaddscreen';

  @override
  State<ComplaintsPublicAdd> createState() => _ComplaintsPublicAddState();
}

class _ComplaintsPublicAddState extends State<ComplaintsPublicAdd> {
  firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;
  TextEditingController _titleController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  String? _provinceValue;
  String? _districtValue;
  String _filePath = '';
  String _imageURL = '';

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

  Map<String, List<String>> _districtsByProvince = {
    'Western': ['Colombo', 'Gampaha', 'Kalutara'],
    'Central': ['Kandy', 'Nuwara Eliya', 'Matale'],
    'Southern': ['Galle', 'Matara', 'Hambantota'],
    'Northern': ['Jaffna', 'Kilinochchi', 'Mannar'],
    'Eastern': ['Trincomalee', 'Batticaloa', 'Ampara'],
    'North Western': ['Kurunegala', 'Puttalam'],
    'North Central': ['Anuradhapura', 'Polonnaruwa'],
    'Uva': ['Badulla', 'Monaragala'],
    'Sabaragamuwa': ['Ratnapura', 'Kegalle'],
  };

  List<String> _districtOptions = [];

  void _updateDistrictOptions(String selectedProvince) {
    setState(() {
      _districtOptions = _districtsByProvince[selectedProvince] ?? [];
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: Theme.of(context).primaryColor,
            title: Text('Add new complaint')),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Title',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),

              // Description Field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  TextField(
                    controller: _descriptionController,
                    maxLines: null, // Allows multiple lines for the description
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),

              // Province Dropdown
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
                    value: _provinceValue,
                    onChanged: (value) {
                      setState(() {
                        _provinceValue = value;
                        _updateDistrictOptions(_provinceValue!);
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
              SizedBox(height: 16),
              // // District Dropdown
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'District',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  DropdownButtonFormField<String>(
                    value: _districtValue,
                    onChanged: (value) {
                      setState(() {
                        _districtValue = value!;
                      });
                    },
                    items: _districtOptions.map((String department) {
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
              SizedBox(height: 16),

              // File Upload Field
              ElevatedButton(
                onPressed: () async {
                  // Open file picker when the button is pressed
                  FilePickerResult? result =
                      await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['jpg', 'jpeg', 'png'],
                  );

                  if (result != null) {
                    String filePath = result.files.single.path!;
                    setState(() {
                      _filePath = filePath;
                    });
                    firebase_storage.Reference ref = storage
                        .ref()
                        .child('complaint_images/${DateTime.now()}.jpg');
                    await ref.putFile(File(filePath));

                    _imageURL = await ref.getDownloadURL();
                    print('Image URL: $_imageURL');
                  }
                },
                child: Text('Upload Evidence'),
              ),

              SizedBox(height: 32),

              if (_filePath.isNotEmpty)
                Image.file(
                  File(_filePath),
                  height: 200,
                  width: 200,
                  fit: BoxFit.cover,
                ),

              // Submit Button
              ElevatedButton(
                onPressed: () async {
                  String createdBy = FirebaseAuth.instance.currentUser!.uid;
                  Map<String, dynamic> complaintData = {
                    'title': _titleController.text,
                    'description': _descriptionController.text,
                    'status': 'In Progress',
                    'assignedTo': '',
                    'assignedBy': '',
                    'assignedType': '',
                    'province': _provinceValue,
                    'district': _districtValue,
                    'action': '',
                    'createdBy': createdBy,
                    'evidenceURL': _imageURL
                  };

                  ComplaintServices complaintService = ComplaintServices();
                  await complaintService.addComplaint(complaintData);
                  Navigator.pushReplacementNamed(
                      context, ComplaintsPublic.routeName);
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
        ));
  }
}

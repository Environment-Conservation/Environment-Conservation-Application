import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:env_assignment/screens/home/complaints_beat.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class SubmitAction extends StatefulWidget {
  static const routeName = '/submitactionscreen';

  @override
  State<SubmitAction> createState() => _SubmitActionState();
}

class _SubmitActionState extends State<SubmitAction> {
  firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;
  TextEditingController _complaintNoController = TextEditingController();
  TextEditingController _titleController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _actionController = TextEditingController();
  TextEditingController _fileSubmitController = TextEditingController();
  DateTime? _selectedDate = DateTime.now();

  String _filePath = '';
  String? _complaintId;
  String _imageURL = '';

  double _percentage = 0.0;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
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
    _complaintId = arguments?['complaintID'] ?? '';
    _percentage = arguments?['progress'] ?? '';
    _actionController.text = arguments?['action'] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text('Submit'),
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Action taken',
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
                  'Date',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.0),
                InkWell(
                  onTap: () {
                    _selectDate(context);
                  },
                  child: Container(
                    padding: EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      border: Border.all(),
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selectedDate != null
                              ? "${_selectedDate!.toLocal()}".split(' ')[0]
                              : 'Select Date',
                          style: TextStyle(fontSize: 16),
                        ),
                        Icon(Icons.calendar_today),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Progress',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '($_percentage%)',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.0),
                Slider(
                  value: _percentage,
                  onChanged: (double value) {
                    setState(() {
                      _percentage = value;
                    });
                  },
                  min: 0.0,
                  max: 100.0,
                  divisions: 100,
                  label: '$_percentage%',
                ),
              ],
            ),
            SizedBox(height: 16.0),
            // File Upload Field
            ElevatedButton(
              onPressed: () async {
                // Open file picker when the button is pressed
                FilePickerResult? result = await FilePicker.platform.pickFiles(
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

            SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: () async {
                Map<String, dynamic> updatedData = {
                  'title': _titleController.text,
                  'status': _percentage == 100.0 ? 'Solved' : 'In Progress',
                  'remark': _descriptionController.text,
                  'date': _selectedDate,
                  'progress': _percentage,
                  'action': _actionController.text,
                  'evidenceURL2': _imageURL
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
                    context, ComplaintsBeat.routeName);
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

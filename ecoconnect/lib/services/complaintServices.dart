import 'package:cloud_firestore/cloud_firestore.dart';

class ComplaintServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addComplaint(Map<String, dynamic> complaintData) async {
    await _firestore.collection('complaints').add(complaintData);
  }

  Future<List<Map<String, dynamic>>> fetchComplaints() async {
    QuerySnapshot querySnapshot =
        await _firestore.collection('complaints').get();
    return querySnapshot.docs
        .map((doc) => {
              'id': doc.id,
              ...doc.data() as Map<String, dynamic>,
            })
        .toList();
  }

  Future<Map<String, dynamic>?> fetchUserData(String uid) async {
    DocumentSnapshot userDoc =
        await _firestore.collection('users').doc(uid).get();

    if (userDoc.exists) {
      return {
        'fullName': userDoc['fullName'],
        'email': userDoc['email'],
        'mobile': userDoc['mobile'],
        'nic': userDoc['nic'],
        'type': userDoc['type'],
      };
    }

    return null;
  }
}

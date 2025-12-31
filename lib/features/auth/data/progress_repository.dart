import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProgressRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ================= STREAM PROGRESS =================

  Stream<QuerySnapshot> streamProgress(DateTime fromDate) {
    final uid = _auth.currentUser!.uid;

    return _firestore
        .collection('progress_goals')
        .where('userId', isEqualTo: uid)
        .where(
          'createdAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(fromDate),
        )
        .orderBy('createdAt', descending: false)
        .snapshots();
  }

  // ================= ADD PROGRESS ENTRY =================

  Future<void> addProgress({
    required String skill,
    required double value,
    required String unit,
    String? goalId,
  }) async {
    final uid = _auth.currentUser!.uid;

    await _firestore.collection('progress_goals').add({
      'userId': uid,
      'skill': skill, // ✅ singular
      'value': value,
      'unit': unit,
      'goalId': goalId,
      'createdAt': Timestamp.now(),
    });
  }
}

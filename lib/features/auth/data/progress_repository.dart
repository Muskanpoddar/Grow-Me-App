import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProgressRepository {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

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
}

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:growme/core/goal_model.dart';
import '../../../../core/services/cloudinary_service.dart';

class GoalRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final CloudinaryService _cloudinary = CloudinaryService();
  final CollectionReference goalsRef = FirebaseFirestore.instance.collection('goals');

  Stream<List<GoalModel>> streamGoalsForUser(String uid) {
    return goalsRef
        .where('userId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => GoalModel.fromDoc(d)).toList());
  }

  Future<bool> userHasActiveGoalToday(String uid) async {
    // check if any goal with status 'active' and createdAt is today
    final start = DateTime.now();
    final startOfDay = DateTime(start.year, start.month, start.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    final q = await goalsRef
        .where('userId', isEqualTo: uid)
        .where('status', isEqualTo: 'active')
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('createdAt', isLessThan: Timestamp.fromDate(endOfDay))
        .get();
    return q.docs.isNotEmpty;
  }

  Future<GoalModel> createGoal({
    required String title,
    String? description,
    String? imagePath, // local file path
    required String category,
    required DateTime deadline,
  }) async {
    final user = _auth.currentUser!;
    String? imageUrl;
    if (imagePath != null && imagePath.isNotEmpty) {
      final file = File(imagePath);
      imageUrl = await _cloudinary.uploadImage(file);
    }

    final doc = goalsRef.doc();
    final goal = GoalModel(
      id: doc.id,
      userId: user.uid,
      title: title,
      description: description,
      imageUrl: imageUrl,
      category: category,
      deadline: deadline,
      createdAt: DateTime.now(),
      status: 'active',
    );

    await doc.set(goal.toMap());
    return goal;
  }
}

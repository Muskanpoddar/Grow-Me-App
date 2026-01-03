import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:growme/features/auth/domain/models/goal_model.dart';
import '../../../../core/services/cloudinary_service.dart';

class GoalRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CloudinaryService _cloudinary = CloudinaryService();

  CollectionReference get _goals => _db.collection('goals');
  CollectionReference get _stats => _db.collection('user_stats');

  // ================= STREAM GOALS =================

  Stream<List<GoalModel>> streamGoalsForUser(String uid) {
    return _goals
        .where('userId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => GoalModel.fromDoc(d)).toList());
  }

  // ================= CHECK TODAY ACTIVE =================

  Future<bool> userHasActiveGoalToday(String uid) async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));

    final q = await _goals
        .where('userId', isEqualTo: uid)
        .where('status', isEqualTo: 'active')
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('createdAt', isLessThan: Timestamp.fromDate(end))
        .get();

    return q.docs.isNotEmpty;
  }

  // ================= CLOSE PREVIOUS ACTIVE GOALS =================

  Future<void> _closePreviousActiveGoals(String uid) async {
    final q = await _goals
        .where('userId', isEqualTo: uid)
        .where('status', isEqualTo: 'active')
        .get();

    for (final d in q.docs) {
      await d.reference.update({'status': 'completed'});
    }
  }

  // ================= CREATE GOAL =================

  Future<GoalModel> createGoal({
    required String title,
    String? description,
    String? imagePath,
    required String category,
    required DateTime deadline,
  }) async {
    final user = _auth.currentUser!;
    String? imageUrl;

    // 🔒 ensure one goal per day
    await _closePreviousActiveGoals(user.uid);

    if (imagePath != null && imagePath.isNotEmpty) {
      imageUrl = await _cloudinary.uploadImage(File(imagePath));
    }

    final doc = _goals.doc();

    final goal = GoalModel(
      id: doc.id,
      userId: user.uid,
      title: title,
      description: description,
      imageUrl: imageUrl,
      category: category,
      deadline: deadline,
      createdAt: DateTime.now().toUtc(),
      status: 'active',
    );

    await doc.set(goal.toMap());
    return goal;
  }

  // ================= COMPLETE GOAL =================

 Future<void> completeGoal(GoalModel goal) async {
  final batch = _db.batch();

  final goalRef = _db.collection('goals').doc(goal.id);
  final progressRef = _db.collection('progress_goals').doc();
  final statsRef = _db.collection('user_stats').doc(goal.userId);

  // 1️⃣ Mark goal completed
  batch.update(goalRef, {
    'status': 'completed',
    'completedAt': Timestamp.now(),
  });

  // 2️⃣ Add progress entry
  batch.set(progressRef, {
    'userId': goal.userId,
    'skill': goal.category,
    'value': 1,
    'unit': 'goal',
    'goalId': goal.id,
    'createdAt': Timestamp.now(),
  });

  // 3️⃣ Increment completedGoals counter
  batch.set(
    statsRef,
    {
      'completedGoals': FieldValue.increment(1),
    },
    SetOptions(merge: true),
  );

  await batch.commit();

  // 4️⃣ Update streak (timezone-safe)
  await _incrementStreak(goal.userId);

  // 5️⃣ Unlock achievements (SAFE)
  await _unlockAchievements(goal.userId);
}
 Future<void> _unlockAchievements(String uid) async {
  final ref = _db.collection('user_stats').doc(uid);

  await _db.runTransaction((tx) async {
    final snap = await tx.get(ref);
    if (!snap.exists) return;

    final data = snap.data() as Map<String, dynamic>;

    final int completed = data['completedGoals'] ?? 0;
    final int streak = data['streak'] ?? 0;

    final Map<String, dynamic> achievements =
        Map<String, dynamic>.from(data['achievements'] ?? {});

    void unlock(String key) {
      if (achievements[key] != true) {
        achievements[key] = true;
      }
    }

    if (completed >= 1) unlock('first_step');
    if (streak >= 7) unlock('consistent');
    if (completed >= 30) unlock('champion');

    tx.update(ref, {
      'achievements': achievements,
    });
  });
}


  // ================= STREAK LOGIC =================
  Future<void> _incrementStreak(String uid) async {
    final ref = _db.collection('user_stats').doc(uid);

    await _db.runTransaction((tx) async {
      final snap = await tx.get(ref);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      if (!snap.exists) {
        // ✅ first ever completion
        tx.set(ref, {'streak': 1, 'lastCompleted': Timestamp.fromDate(today)});
        return;
      }

      final data = snap.data()!;
      final lastCompleted = (data['lastCompleted'] as Timestamp).toDate();
      final lastDay = DateTime(
        lastCompleted.year,
        lastCompleted.month,
        lastCompleted.day,
      );

      final diff = today.difference(lastDay).inDays;
      int streak = data['streak'] ?? 0;

      if (diff == 0) {
        // ✅ already completed today → do nothing
        return;
      } else if (diff == 1) {
        // ✅ consecutive day
        streak += 1;
      } else {
        // ❌ missed days → reset
        streak = 1;
      }

      tx.update(ref, {
        'streak': streak,
        'lastCompleted': Timestamp.fromDate(today),
      });
    });
  }

  Future<void> updateGoalStatus({
    required GoalModel goal,
    required String status, // completed | skipped
  }) async {
    final batch = FirebaseFirestore.instance.batch();

    final goalRef = _db.collection('goals').doc(goal.id);
    final progressRef = _db.collection('progress_goals').doc();

    batch.update(goalRef, {'status': status, 'completedAt': Timestamp.now()});

    // Only add progress if COMPLETED
    if (status == 'completed') {
      batch.set(progressRef, {
        'userId': goal.userId,
        'skill': goal.category,
        'value': 1,
        'unit': 'goal',
        'goalId': goal.id,
        'createdAt': Timestamp.now(),
      });

      await _incrementStreak(goal.userId);
    } else {
      // skipped → reset streak
      await _resetStreak(goal.userId);
    }

    await batch.commit();
  }

  Future<void> _resetStreak(String uid) async {
    await _stats.doc(uid).set({
      'streak': 0,
      'lastCompleted': Timestamp.now(),
    }, SetOptions(merge: true));
  }
}

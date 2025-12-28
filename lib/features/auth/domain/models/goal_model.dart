import 'package:cloud_firestore/cloud_firestore.dart';

class GoalModel {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final String? imageUrl;
  final String category;
  final DateTime deadline;
  final DateTime createdAt;
  final String status; // active, completed, skipped

  GoalModel({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    this.imageUrl,
    required this.category,
    required this.deadline,
    required this.createdAt,
    this.status = 'active',
  });

  Map<String, dynamic> toMap() => {
    'userId': userId,
    'title': title,
    'description': description,
    'imageUrl': imageUrl,
    'category': category,
    'deadline': Timestamp.fromDate(deadline),
    'createdAt': Timestamp.fromDate(createdAt),
    'status': status,
  };

  factory GoalModel.fromDoc(DocumentSnapshot doc) {
    final d = doc.data()! as Map<String, dynamic>;
    return GoalModel(
      id: doc.id,
      userId: d['userId'] ?? '',
      title: d['title'] ?? '',
      description: d['description'],
      imageUrl: d['imageUrl'],
      category: d['category'] ?? '',
      deadline: (d['deadline'] as Timestamp).toDate(),
      createdAt: (d['createdAt'] as Timestamp).toDate(),
      status: d['status'] ?? 'active',
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/models/user_model.dart';

class UserRepository {
  final users = FirebaseFirestore.instance.collection('users');

  Future<void> createUser(AppUser user) async {
    await users.doc(user.uid).set(user.toMap());
  }

  Future<AppUser?> getUser(String uid) async {
    final doc = await users.doc(uid).get();
    if (!doc.exists) return null;
    return AppUser.fromMap(doc.data()!);
  }
}

import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageHelper {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadProfileImage(String uid, File file) async {
    final ref = _storage.ref().child('user_profile_images/$uid/profile.jpg');
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }
}

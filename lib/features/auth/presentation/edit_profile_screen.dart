import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:growme/core/services/cloudinary_service.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  File? _newImage;
  bool _loading = false;

  final _picker = ImagePicker();
  final _cloudinary = CloudinaryService();

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final snap = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    final data = snap.data()!;
    _nameCtrl.text = data['name'] ?? '';
    _usernameCtrl.text = data['username'] ?? '';
  }

  Future<void> _pickImage() async {
    final img = await _picker.pickImage(source: ImageSource.gallery);
    if (img != null) {
      setState(() => _newImage = File(img.path));
    }
  }

  Future<void> _save() async {
    setState(() => _loading = true);

    final uid = FirebaseAuth.instance.currentUser!.uid;
    String? photoUrl;

    if (_newImage != null) {
      photoUrl = await _cloudinary.uploadImage(_newImage!);
    }

    final update = {
      'name': _nameCtrl.text.trim(),
      'username': _usernameCtrl.text.trim(),
    };

    if (photoUrl != null) {
      update['photoUrl'] = photoUrl;
    }

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .update(update);

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 45,
                backgroundImage: _newImage != null
                    ? FileImage(_newImage!)
                    : null,
                child: _newImage == null ? const Icon(Icons.camera_alt) : null,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Full Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _usernameCtrl,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loading ? null : _save,
              child: _loading
                  ? const CircularProgressIndicator()
                  : const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}

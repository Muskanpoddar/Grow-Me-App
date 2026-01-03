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
  final _bioCtrl = TextEditingController();

  final _picker = ImagePicker();
  final _cloudinary = CloudinaryService();

  File? _newImage;
  bool _loading = false;
  bool _pickingImage = false;

  List<String> _interests = [];
  String? _selectedInterest;

  static const bg = Color(0xffF6F9F6);
  static const green = Color(0xff00C853);

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final snap =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    final data = snap.data() ?? {};

    _nameCtrl.text = data['name'] ?? '';
    _usernameCtrl.text = data['username'] ?? '';
    _bioCtrl.text = data['bio'] ?? '';
    _interests = List<String>.from(data['interests'] ?? []);

    if (_interests.isNotEmpty) {
      _selectedInterest = _interests.first;
    }

    if (mounted) setState(() {});
  }

  Future<void> _pickImage() async {
    if (_pickingImage) return;
    _pickingImage = true;

    try {
      final img = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (img != null && mounted) {
        setState(() => _newImage = File(img.path));
      }
    } finally {
      _pickingImage = false;
    }
  }

  Future<void> _save() async {
    if (_loading) return;
    setState(() => _loading = true);

    final uid = FirebaseAuth.instance.currentUser!.uid;
    String? photoUrl;

    if (_newImage != null) {
      photoUrl = await _cloudinary.uploadImage(_newImage!);
    }

    final update = {
      'name': _nameCtrl.text.trim(),
      'username': _usernameCtrl.text.trim(),
      'bio': _bioCtrl.text.trim(),
      'interests': _interests,
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
  void dispose() {
    _nameCtrl.dispose();
    _usernameCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _profileCard(),
            const SizedBox(height: 16),
            _bioCard(),
            const SizedBox(height: 16),
            _interestsCard(),
            const SizedBox(height: 28),
            _saveButton(),
          ],
        ),
      ),
    );
  }

  // ================= SECTIONS =================

  Widget _profileCard() {
    return _card(
      Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: green.withOpacity(0.15),
                backgroundImage:
                    _newImage != null ? FileImage(_newImage!) : null,
                child: _newImage == null
                    ? const Icon(Icons.person, size: 44, color: green)
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _pickImage,
                  child: const CircleAvatar(
                    radius: 16,
                    backgroundColor: green,
                    child: Icon(Icons.camera_alt, size: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _input('Full Name', _nameCtrl),
          const SizedBox(height: 12),
          _input('Username', _usernameCtrl),
        ],
      ),
    );
  }

  Widget _bioCard() {
    return _card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bio',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _bioCtrl,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Tell something about yourself',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _interestsCard() {
    return _card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Interests',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _buildInterestChips(),
        ],
      ),
    );
  }

  // ================= INTEREST CHIPS (GOAL STYLE) =================

  Widget _buildInterestChips() {
    final chips = <Widget>[];

    for (final i in _interests) {
      final selected = i == _selectedInterest;
      chips.add(
        GestureDetector(
          onTap: () => setState(() => _selectedInterest = i),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: selected ? green : Colors.white,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: green.withOpacity(0.4)),
            ),
            child: Text(
              i,
              style: TextStyle(
                color: selected ? Colors.white : green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );
    }

    chips.add(
      GestureDetector(
        onTap: _showAddInterestDialog,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: green.withOpacity(0.4)),
          ),
          child: const Text(
            '+ Add',
            style: TextStyle(color: green, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(children: chips),
    );
  }

  Future<void> _showAddInterestDialog() async {
    final ctrl = TextEditingController();
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Interest'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(hintText: 'e.g., Fitness'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final v = ctrl.text.trim();
              if (v.isNotEmpty && !_interests.contains(v)) {
                setState(() {
                  _interests.add(v);
                  _selectedInterest = v;
                });
              }
              Navigator.pop(ctx);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  // ================= BUTTON =================

  Widget _saveButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _loading ? null : _save,
        style: ElevatedButton.styleFrom(
          backgroundColor: green,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: _loading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                'Save Changes',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  // ================= HELPERS =================

  Widget _input(String label, TextEditingController ctrl) {
    return TextField(
      controller: ctrl,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _card(Widget child) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

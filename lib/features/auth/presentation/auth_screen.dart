import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:growme/core/services/cloudinary_service.dart';
import 'package:image_picker/image_picker.dart';

import 'package:growme/features/auth/data/auth_repository.dart';
import 'package:growme/features/auth/data/user_repository.dart';
import 'package:growme/features/auth/domain/models/user_model.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true;
  bool showPassword = false;
  bool loading = false;

  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final nameCtrl = TextEditingController();
  final usernameCtrl = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  File? _profileImageFile;

  final List<String> interests = [
    "Fitness",
    "Learning",
    "Career",
    "Creative",
    "Health",
    "Finance",
  ];
  List<String> selectedInterests = [];

  final _authRepo = AuthRepository();
  final _userRepo = UserRepository();
  final cloudinaryService = CloudinaryService();

  @override
  void dispose() {
    emailCtrl.dispose();
    passwordCtrl.dispose();
    nameCtrl.dispose();
    usernameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F8F5),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              Text(
                isLogin ? "Welcome back" : "Set Up Your Profile",
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 25),

              _buildToggle(),
              const SizedBox(height: 20),

              _buildGoogleButton(),
              const SizedBox(height: 10),
              const Center(child: Text("or")),
              const SizedBox(height: 20),

              isLogin ? _buildLoginFields() : _buildRegisterFields(),
            ],
          ),
        ),
      ),
    );
  }

  // ----------------------------------------------------
  // UI
  // ----------------------------------------------------

  Widget _buildToggle() {
    return Container(
      height: 55,
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.10),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (!mounted) return;
                setState(() => isLogin = true);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isLogin ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Center(
                  child: Text(
                    "Login",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isLogin ? Colors.black : Colors.green,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (!mounted) return;
                setState(() => isLogin = false);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: !isLogin ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Center(
                  child: Text(
                    "Register",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: !isLogin ? Colors.black : Colors.green,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Email", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        _buildTextField(emailCtrl, "Enter your email"),

        const SizedBox(height: 15),
        const Text("Password", style: TextStyle(fontWeight: FontWeight.bold)),
        _buildPasswordField(),

        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {},
            child: const Text(
              "Forgot Password?",
              style: TextStyle(color: Colors.green),
            ),
          ),
        ),

        const SizedBox(height: 20),
        _buildActionButton(),
      ],
    );
  }

  Widget _buildRegisterFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),

        Center(
          child: GestureDetector(
            onTap: _pickProfileImage,
            child: Container(
              height: 90,
              width: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.green.withOpacity(0.1),
                image: _profileImageFile != null
                    ? DecorationImage(
                        image: FileImage(_profileImageFile!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: _profileImageFile == null
                  ? const Icon(Icons.camera_alt, color: Colors.green, size: 28)
                  : null,
            ),
          ),
        ),

        const SizedBox(height: 20),
        const Text("Full Name", style: TextStyle(fontWeight: FontWeight.bold)),
        _buildTextField(nameCtrl, "e.g. Alex Johnson"),

        const SizedBox(height: 15),
        const Text("Username", style: TextStyle(fontWeight: FontWeight.bold)),
        _buildTextField(usernameCtrl, "e.g. alexj"),

        const SizedBox(height: 15),
        const Text("Email", style: TextStyle(fontWeight: FontWeight.bold)),
        _buildTextField(emailCtrl, "Enter your email"),

        const SizedBox(height: 15),
        const Text("Password", style: TextStyle(fontWeight: FontWeight.bold)),
        _buildPasswordField(),

        const SizedBox(height: 20),
        const Text("Interests", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        _buildInterests(),

        const SizedBox(height: 30),
        _buildActionButton(),
      ],
    );
  }

  Widget _buildGoogleButton() {
    return InkWell(
      onTap: loading ? null : _handleGoogleSignIn,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(.1),
          borderRadius: BorderRadius.circular(25),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.g_mobiledata, size: 30, color: Colors.black),
            SizedBox(width: 10),
            Text("Sign in with Google"),
          ],
        ),
      ),
    );
  }

  Widget _buildInterests() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: interests.map((interest) {
        final selected = selectedInterests.contains(interest);
        return GestureDetector(
          onTap: () {
            if (!mounted) return;
            setState(() {
              selected
                  ? selectedInterests.remove(interest)
                  : selectedInterests.add(interest);
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: selected ? Colors.green : Colors.green.withOpacity(0.15),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Text(
              interest,
              style: TextStyle(
                color: selected ? Colors.white : Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTextField(TextEditingController c, String hint) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.green.withOpacity(0.4)),
      ),
      child: TextField(
        controller: c,
        decoration: InputDecoration(hintText: hint, border: InputBorder.none),
      ),
    );
  }

  Widget _buildPasswordField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.green.withOpacity(0.4)),
      ),
      child: TextField(
        controller: passwordCtrl,
        obscureText: !showPassword,
        decoration: InputDecoration(
          hintText: "Enter your password",
          border: InputBorder.none,
          suffixIcon: IconButton(
            icon: Icon(
              showPassword ? Icons.visibility : Icons.visibility_off,
              color: Colors.green,
            ),
            onPressed: () {
              if (!mounted) return;
              setState(() => showPassword = !showPassword);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton() {
    return GestureDetector(
      onTap: loading ? null : (isLogin ? _handleLogin : _handleRegister),
      child: Container(
        height: 55,
        decoration: BoxDecoration(
          color: loading ? Colors.green.shade300 : Colors.green,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Center(
          child: loading
              ? const CircularProgressIndicator(color: Colors.white)
              : Text(
                  isLogin ? "Login" : "Create Account",
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }

  // ----------------------------------------------------
  // LOGIC (with mounted checks)
  // ----------------------------------------------------

  void _showError(Object e) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(e.toString())));
  }

  Future<void> _pickProfileImage() async {
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
    );

    if (!mounted) return;

    if (picked != null) {
      setState(() => _profileImageFile = File(picked.path));
    }
  }

  Future<void> _handleLogin() async {
    if (!mounted) return;
    setState(() => loading = true);

    try {
      await _authRepo.signInWithEmail(
        emailCtrl.text.trim(),
        passwordCtrl.text.trim(),
      );
    } catch (e) {
      if (!mounted) return;
      _showError(e);
    } finally {
      if (!mounted) return;
      setState(() => loading = false);
    }
  }

  Future<void> _handleRegister() async {
    if (!mounted) return;
    setState(() => loading = true);

    User? firebaseUser;

    try {
      firebaseUser = await _authRepo.signUpWithEmail(
        emailCtrl.text.trim(),
        passwordCtrl.text.trim(),
      );

      if (firebaseUser == null) {
        throw Exception("User creation failed");
      }

      String? photoUrl;
      if (_profileImageFile != null) {
        photoUrl = await cloudinaryService.uploadImage(_profileImageFile!);
      }

      final username = usernameCtrl.text.trim();
      final usernameLower = username.toLowerCase();

      final appUser = AppUser(
        uid: firebaseUser.uid,
        name: nameCtrl.text.trim(),
        email: emailCtrl.text.trim(),
        username: username,
        usernameLower: usernameLower,
        photoUrl: photoUrl,
        interests: selectedInterests,
      );

      await _userRepo.createUser(appUser);
    } catch (e) {
      // 🔥 SAFE rollback
      try {
        await firebaseUser?.delete();
      } catch (_) {}

      await FirebaseAuth.instance.signOut();

      if (mounted) _showError(e);
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _handleGoogleSignIn() async {
    if (!mounted) return;
    setState(() => loading = true);

    try {
      await GoogleSignIn().signOut();
      final user = await _authRepo.signInWithGoogle();

      if (user == null) return;

      final existing = await _userRepo.getUser(user.uid);
      if (existing != null) return;

      final rawUsername = user.email?.split('@').first ?? 'user';
      final safeUsername = rawUsername
          .replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '')
          .toLowerCase();

      final appUser = AppUser(
        uid: user.uid,
        name: user.displayName ?? '',
        email: user.email ?? '',
        username: safeUsername,
        usernameLower: safeUsername,
        photoUrl: user.photoURL,
        interests: const [],
      );

      await _userRepo.createUser(appUser);
    } catch (e) {
      if (mounted) _showError(e);
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }
}

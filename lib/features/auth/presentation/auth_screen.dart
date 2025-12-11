import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:growme/features/auth/data/auth_repository.dart';
import 'package:growme/features/auth/data/user_repository.dart';
import 'package:growme/features/auth/data/storage_helper.dart';
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

  final interests = [
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
  final _storageHelper = StorageHelper();
  final _picker = ImagePicker();

  File? _profileImageFile;

  @override
  void dispose() {
    emailCtrl.dispose();
    passwordCtrl.dispose();
    nameCtrl.dispose();
    usernameCtrl.dispose();
    super.dispose();
  }

  // ----------------- UI --------------------

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
                  color: Colors.black,
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
              if (isLogin) _buildLoginFields() else _buildRegisterFields(),
            ],
          ),
        ),
      ),
    );
  }

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
              onTap: () => setState(() => isLogin = true),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isLogin ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: isLogin
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : [],
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
              onTap: () => setState(() => isLogin = false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: !isLogin ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: !isLogin
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : [],
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

  // ---------- LOGIN UI ----------

  Widget _buildLoginFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Email", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        _buildTextField(emailCtrl, "Enter your email address"),
        const SizedBox(height: 15),
        const Text("Password", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
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

  // ---------- REGISTER UI ----------

  Widget _buildRegisterFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),

        // profile photo
        Center(
          child: GestureDetector(
            onTap: _pickProfileImage,
            child: Container(
              height: 90,
              width: 90,
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
                image: _profileImageFile != null
                    ? DecorationImage(
                        image: FileImage(_profileImageFile!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: _profileImageFile == null
                  ? const Icon(Icons.camera_alt, color: Colors.green, size: 30)
                  : null,
            ),
          ),
        ),

        const SizedBox(height: 20),

        const Text("Full Name", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        _buildTextField(nameCtrl, "e.g. Alex Johnson"),
        const SizedBox(height: 15),

        const Text("Username", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        _buildTextField(usernameCtrl, "e.g. alexj"),
        const SizedBox(height: 15),

        const Text("Email", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        _buildTextField(emailCtrl, "Enter your email address"),
        const SizedBox(height: 15),

        const Text("Password", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        _buildPasswordField(),
        const SizedBox(height: 25),

        const Text(
          "What are your interests?",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 15),
        _buildInterests(),
        const SizedBox(height: 30),

        _buildActionButton(),
      ],
    );
  }

  Widget _buildGoogleButton() {
    return InkWell(
      onTap: _handleGoogleSignIn,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(.1),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.g_mobiledata, color: Colors.black),
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
      children: interests.map((i) {
        final selected = selectedInterests.contains(i);
        return GestureDetector(
          onTap: () {
            setState(() {
              selected ? selectedInterests.remove(i) : selectedInterests.add(i);
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: selected ? Colors.green : Colors.green.withOpacity(0.15),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Text(
              i,
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
        decoration: InputDecoration(border: InputBorder.none, hintText: hint),
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
          border: InputBorder.none,
          hintText: "Enter your password",
          suffixIcon: IconButton(
            icon: Icon(
              showPassword ? Icons.visibility : Icons.visibility_off,
              color: Colors.green,
            ),
            onPressed: () => setState(() => showPassword = !showPassword),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton() {
    return GestureDetector(
      onTap: loading
          ? null
          : () {
              if (isLogin) {
                _handleLogin();
              } else {
                _handleRegister();
              }
            },
      child: Container(
        height: 55,
        decoration: BoxDecoration(
          color: loading ? Colors.green.withOpacity(0.5) : Colors.green,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Center(
          child: loading
              ? const CircularProgressIndicator(color: Colors.white)
              : Text(
                  isLogin ? "Login" : "Create Account",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }

  // --------------- LOGIC ---------------

  void _showError(Object e) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(e.toString())));
  }

  Future<void> _pickProfileImage() async {
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
    );
    if (picked != null) {
      setState(() => _profileImageFile = File(picked.path));
    }
  }

  Future<void> _handleLogin() async {
    try {
      setState(() => loading = true);
      await _authRepo.signInWithEmail(
        emailCtrl.text.trim(),
        passwordCtrl.text.trim(),
      );
      // AuthStateWidget will move to Home automatically
    } catch (e) {
      _showError(e);
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> _handleRegister() async {
    try {
      setState(() => loading = true);

      final user = await _authRepo.signUpWithEmail(
        emailCtrl.text.trim(),
        passwordCtrl.text.trim(),
      );
      if (user == null) return;

      String? photoUrl;
      if (_profileImageFile != null) {
        photoUrl = await _storageHelper.uploadProfileImage(
          user.uid,
          _profileImageFile!,
        );
      }

      final appUser = AppUser(
        uid: user.uid,
        email: emailCtrl.text.trim(),
        name: nameCtrl.text.trim(),
        username: usernameCtrl.text.trim(),
        photoUrl: photoUrl,
        interests: selectedInterests,
      );

      await _userRepo.createUser(appUser);
      // logged in already -> stream will go to Home
    } catch (e) {
      _showError(e);
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> _handleGoogleSignIn() async {
    try {
      setState(() => loading = true);
      final user = await _authRepo.signInWithGoogle();
      if (user == null) return;

      // check if user doc exists; if not, create minimal profile
      final existing = await _userRepo.getUser(user.uid);
      if (existing == null) {
        final appUser = AppUser(
          uid: user.uid,
          email: user.email ?? '',
          name: user.displayName ?? '',
          username: user.email?.split('@').first ?? '',
          photoUrl: user.photoURL,
          interests: [],
        );
        await _userRepo.createUser(appUser);
      }
    } catch (e) {
      _showError(e);
    } finally {
      setState(() => loading = false);
    }
  }
}

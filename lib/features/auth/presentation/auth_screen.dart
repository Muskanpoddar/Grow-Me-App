import 'package:flutter/material.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true;
  bool showPassword = false;

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

  // -------------------------
  // Toggle buttons
  // -------------------------
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

  // -------------------------
  // LOGIN FIELDS
  // -------------------------
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

  // -------------------------
  // REGISTER FIELDS
  // -------------------------
  Widget _buildRegisterFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),

        Center(
          child: GestureDetector(
            onTap: () {}, // <-- we will add image picker later
            child: Container(
              height: 90,
              width: 90,
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.camera_alt,
                color: Colors.green.shade600,
                size: 32,
              ),
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

  // -------------------------
  // Google login button
  // -------------------------
  Widget _buildGoogleButton() {
    return Container(
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
    );
  }

  // -------------------------
  // Interest chips
  // -------------------------
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

  // -------------------------
  // Normal text field
  // -------------------------
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

  // -------------------------
  // Password field
  // -------------------------
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

  // -------------------------
  // Login/Register button
  // -------------------------
  Widget _buildActionButton() {
    return GestureDetector(
      onTap: () {},
      child: Container(
        height: 55,
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Center(
          child: Text(
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
}

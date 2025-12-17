import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ✅ SINGLE GoogleSignIn instance
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ----------------------------------------------------
  // EMAIL AUTH
  // ----------------------------------------------------

  Future<User?> signUpWithEmail(String email, String password) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await _createUserDocument(cred.user);
    return cred.user;
  }

  Future<User?> signInWithEmail(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    return cred.user;
  }

  // ----------------------------------------------------
  // GOOGLE AUTH (FORCED CHOOSER)
  // ----------------------------------------------------

  Future<User?> signInWithGoogle() async {
    // ✅ Clears cached account ONLY (safe)
    await _googleSignIn.signOut();

    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null;

    final googleAuth = await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await _auth.signInWithCredential(credential);

    return userCredential.user;
  }

  // ----------------------------------------------------
  // LOGOUT (ONLY PLACE)
  // ----------------------------------------------------

  Future<void> logout() async {
    await _auth.signOut();
    await _googleSignIn.signOut(); // ❌ NO disconnect
  }

  // ----------------------------------------------------
  // FIRESTORE
  // ----------------------------------------------------

  Future<void> _createUserDocument(User? user) async {
    if (user == null) return;

    final doc = _firestore.collection('users').doc(user.uid);
    final exists = await doc.get();

    if (exists.exists) return;

    await doc.set({
      "uid": user.uid,
      "email": user.email,
      "name": user.displayName ?? "",
      "username": user.email?.split("@")[0],
      "photoUrl": user.photoURL ?? "",
      "interests": [],
      "createdAt": DateTime.now(),
    });
  }
}

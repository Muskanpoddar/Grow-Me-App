import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

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

  Future<User?> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return null;

    final auth = await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: auth.accessToken,
      idToken: auth.idToken,
    );

    final userCred = await _auth.signInWithCredential(credential);

    await _createUserDocument(userCred.user);

    return userCred.user;
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await GoogleSignIn().signOut();
  }

  Future<void> _createUserDocument(User? user) async {
    if (user == null) return;

    final doc = _firestore.collection('users').doc(user.uid);

    final exists = await doc.get();
    if (exists.exists) return; // don't overwrite existing profile

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

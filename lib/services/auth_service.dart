import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 🔐 LOGIN
  Future<String?> login(String email, String password) async {
    try {
      UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(email: email, password: password);

      String uid = userCredential.user!.uid;

      // role fetch
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(uid).get();

      return userDoc['role']; // patient / doctor / admin
    } catch (e) {
      return e.toString();
    }
  }

  // 📝 REGISTER (Patient only)
  Future<String?> register(
      String email, String password, String role) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
              email: email, password: password);

      String uid = userCredential.user!.uid;

      await _firestore.collection('users').doc(uid).set({
        'email': email,
        'role': role,
      });

      return role;
    } catch (e) {
      return e.toString();
    }
  }

  // 👤 SAVE USER NAME (NEW – REQUIRED)
  Future<void> saveUserName(String name) async {
    String uid = _auth.currentUser!.uid;

    await _firestore.collection('users').doc(uid).update({
      'name': name,
    });
  }
}

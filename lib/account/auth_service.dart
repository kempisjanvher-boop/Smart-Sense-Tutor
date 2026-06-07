import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Track authentication state changes (e.g., logged in or out)
  Stream<User?> get userChanges => _auth.userChanges();

  // Get current user details
  User? get currentUser => _auth.currentUser;

  // Sign up a brand new user using our custom Username system
  Future<User?> signUpWithEmail(String email, String password) async {
    try {
      // 1. Create the credential mapping profile in Firebase Auth
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = credential.user;

      // 2. Extract the raw username back out of the pseudo-email mapping string
      // (Example: converts "janvher@smartsensetutor.internal" back to "janvher")
      if (user != null) {
        String rawUsername = email.split('@').first;

        // 3. WRITE TO FIRESTORE: This dynamically creates your "users" collection!
        await _db.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'username': rawUsername,
          'searchKey': rawUsername.toLowerCase(), // Invaluable for building search/lookup algorithms later
          'createdAt': FieldValue.serverTimestamp(),
          'avatarAsset': 'asset/bear_avatar.png', // Default initial avatar selection state
        });
      }

      return user;
    } catch (e) {
      print("Firebase Sign-Up Error: $e");
      return null;
    }
  }

  // Log in an existing user
  Future<User?> loginWithEmail(String email, String password) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } catch (e) {
      print("Firebase Login Error: $e");
      return null;
    }
  }

  // Log out of the account
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
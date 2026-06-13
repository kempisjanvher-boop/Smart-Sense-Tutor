import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_sense_tutor/progress.dart';

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
      // Wipe any lingering cached RAM states from a previous account
      // BEFORE generating new Firebase user bounds.
      ProgressService().clearLocalCache();

      // 1. Create the credential mapping profile in Firebase Auth
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = credential.user;

      // 2. Extract the raw username back out of the pseudo-email mapping string
      if (user != null) {
        String rawUsername = email.split('@').first;

        // 3. WRITE TO FIRESTORE: This dynamically creates your "users" collection!
        await _db.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'username': rawUsername,
          'searchKey': rawUsername.toLowerCase(),
          'createdAt': FieldValue.serverTimestamp(),
          'avatarAsset': 'asset/bear_avatar.png',
        });

        // 4. Downstream the empty progress map structure for this new user ID
        await ProgressService().downloadProgressFromCloud();
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
      // Wipe memory clear before pulling a different profile's data records
      ProgressService().clearLocalCache();

      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        // Automatically downstream the authenticated profile save files
        await ProgressService().downloadProgressFromCloud();
      }

      return credential.user;
    } catch (e) {
      print("Firebase Login Error: $e");
      return null;
    }
  }

  // Log out of the account
  Future<void> signOut() async {
    try {
      // 1. Terminate Firebase session authorization token validating your cloud writes
      await _auth.signOut();

      // 2. Flush the local memory state so a newly created account won't read stale variables
      ProgressService().clearLocalCache();
    } catch (e) {
      print("Error during application sign out phase: $e");
    }
  }
}
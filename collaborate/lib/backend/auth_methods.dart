import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:collaborate/models/user.dart' as model;
import 'package:collaborate/backend/storage_methods.dart';

class AuthMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String getUserId() {
    User currentUser = _auth.currentUser!;
    return currentUser.uid;
  }

  Future<model.User> getUserDetails() async {
    User currentUser = _auth.currentUser!;

    DocumentSnapshot documentSnapshot =
        await _firestore.collection('users').doc(currentUser.uid).get();

    return model.User.fromSnap(documentSnapshot);
  }

  //signup the user
  Future<String> signUpUser(
      {required String email,
      required String password,
      required String username,
      required String about,
      required String rollNumber,
      required Uint8List file,
      required List learnSkills,
      required List experienceSkills}) async {
    String res = "Some error Occurred";
    try {
      if (email.isNotEmpty ||
          password.isNotEmpty ||
          username.isNotEmpty ||
          about.isNotEmpty ||
          rollNumber.isNotEmpty) {
        UserCredential cred = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        cred.user!.updateDisplayName(username);

        String profilePic = await StorageMethods().uploadImageToStorage(
            'profilePics',
            file,
            false,
            false,
            ""); //storing the profile pic in firebase storage

        model.User user = model.User(
            username: username,
            uid: cred.user!.uid,
            profilePic: profilePic,
            email: email,
            rollNumber: rollNumber,
            about: about,
            followers: [],
            following: [],
            learnSkills: learnSkills,
            experienceSkills: experienceSkills);

        await _firestore
            .collection("users")
            .doc(cred.user!.uid)
            .set(user.toJson());

        res = "success";
      } else {
        res = "Please enter all the fields";
      }
    } catch (err) {
      return err.toString();
    }
    return res;
  }

  // logging in user
  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    String res = "Some error Occurred";
    try {
      if (email.isNotEmpty || password.isNotEmpty) {
        await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        res = "success";
      } else {
        res = "Please enter all the fields";
      }
    } catch (err) {
      return err.toString();
    }
    return res;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> resetPassword(email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }
}

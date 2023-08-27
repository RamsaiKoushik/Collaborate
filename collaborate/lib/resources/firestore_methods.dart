import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collaborate/resources/auth_methods.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
// import 'package:collaborate/models/post.dart';
import 'package:collaborate/resources/storage_methods.dart';
import 'package:uuid/uuid.dart';

import '../models/group.dart';

class FireStoreMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> createGroup(
      String groupName,
      String category,
      List skills,
      bool isHidden,
      String description,
      Uint8List file,
      String uid,
      String username,
      List domains) async {
    String res = "Error occured! Please Try again";
    try {
      String photoUrl = await StorageMethods()
          .uploadImageToStorage('posts', file, true, false, "");
      String groupId = const Uuid().v1();

      Group group = Group(
          groupId: groupId,
          groupName: groupName,
          description: description,
          category: category,
          skillsList: skills,
          isHidden: isHidden,
          profilePic: photoUrl,
          uid: uid,
          username: username,
          dateCreated: DateTime.now(),
          groupMembers: [uid],
          domains: domains);

      _firestore
          .collection('groups')
          .doc('collaborate')
          .collection('groups')
          .doc(groupId)
          .set(group.toJson());
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<void> deleteGroup(String groupId) async {
    try {
      await FirebaseFirestore.instance
          .collection('groups')
          .doc('collaborate')
          .collection('groups')
          .doc(groupId)
          .delete();
    } catch (e) {
      print("Error deleting group: $e");
    }
  }

  Future<Map<String, dynamic>?> getGroupDetails(String groupId) async {
    final doc = await _firestore
        .collection('groups')
        .doc('collaborate')
        .collection('groups')
        .doc(groupId)
        .get();

    if (doc.exists) {
      return doc.data() as Map<String, dynamic>;
    } else {
      return null;
    }
  }

  Future<void> updateGroupDetails(
      String groupId, Map<String, dynamic> newData) async {
    await _firestore
        .collection('groups')
        .doc('collaborate')
        .collection('groups')
        .doc(groupId)
        .update(newData);
  }

  Future<void> removeUserFromGroup(String groupId, String userId) async {
    try {
      // Remove user from group members
      await FirebaseFirestore.instance
          .collection('groups')
          .doc('collaborate')
          .collection('groups')
          .doc(groupId)
          .update({
        'groupMembers': FieldValue.arrayRemove([userId]),
      });
    } catch (e) {
      print("Error removing user from group: $e");
    }
  }

  Future<String> getUsernameForUserId(String userId) async {
    var userSnap =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    var userData = userSnap.data()!;

    return userData["username"];
  }
}

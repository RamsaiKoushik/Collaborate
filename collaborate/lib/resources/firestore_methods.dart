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
      String username) async {
    String res = "Error occured! Please Try again";
    try {
      String photoUrl =
          await StorageMethods().uploadImageToStorage('posts', file, true);
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
          groupMembers: [uid]);

      _firestore
          .collection('groups')
          .doc('colaborate')
          .collection('groups')
          .add(group.toJson());
    } catch (err) {
      res = err.toString();
    }
    return res;
  }
}

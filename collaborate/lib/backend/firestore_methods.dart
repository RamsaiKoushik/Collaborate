import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
// import 'package:collaborate/models/post.dart';
import 'package:collaborate/backend/storage_methods.dart';
import 'package:flutter/material.dart';
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
      List domains,
      List groupMembers) async {
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
          groupMembers: groupMembers,
          domains: domains);

      _firestore
          .collection('groups')
          .doc('collaborate')
          .collection('groups')
          .doc(groupId)
          .set(group.toJson());
      // print("inside create group");
      // print(groupId);

      return groupId;
      // print("after return");
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> deleteGroup(String groupId) async {
    String res = "";
    try {
      await FirebaseFirestore.instance
          .collection('groups')
          .doc('collaborate')
          .collection('groups')
          .doc(groupId)
          .delete();
    } catch (e) {
      return e.toString();
    }
    return res;
  }

  Future<Map<String, dynamic>?> getGroupDetails(String groupId) async {
    final snapshot = await _firestore
        .collection('groups')
        .doc('collaborate')
        .collection('groups')
        .doc(groupId)
        .get();

    if (snapshot.exists) {
      return snapshot.data() as Map<String, dynamic>;
    } else {
      return null;
    }
  }

  // Function to accept a join request
  Future<void> onAccept(
      String notificationId, String groupId, String userId) async {
    // Add the user to the group's members list
    await FirebaseFirestore.instance
        .collection('groups')
        .doc('collaborate')
        .collection('groups')
        .doc(groupId)
        .update({
      'groupMembers': FieldValue.arrayUnion([userId])
    });

    // var group = await getGroupDetails(groupId);

    // Update the notification status to "accepted"
    await FirebaseFirestore.instance
        .collection('notifications')
        .doc(notificationId)
        .delete();
  }

// Function to reject a join request
  Future<void> onReject(String notificationId) async {
    // Delete the notification document from the collection
    await FirebaseFirestore.instance
        .collection('notifications')
        .doc(notificationId)
        .delete();
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
      SnackBar(content: Text(e.toString()));
      // print("Error removing user from group: $e");
    }
  }

  Future<String> getUsernameForUserId(String userId) async {
    var userSnap =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    var userData = userSnap.data()!;

    return userData["username"];
  }

  Future<Map<String, dynamic>> getUserDetails(String userId) async {
    // Replace 'users' with the actual Firestore collection name
    DocumentSnapshot<Map<String, dynamic>> snapshot =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (snapshot.exists) {
      return snapshot.data() as Map<String, dynamic>;
    }
    return {};
  }

  Future<void> updateUserDetails(
      String userId, Map<String, dynamic> newData) async {
    await _firestore.collection('users').doc(userId).update(newData);
  }

  Future<void> followRequest(String uid, String followRequestId) async {
    try {
      Map<String, dynamic>? userDetails = await getUserDetails(uid);

      List followersList = userDetails['followers'];

      if (!followersList.contains(followRequestId)) {
        await _firestore.collection('users').doc(uid).update({
          'followers': FieldValue.arrayUnion([followRequestId])
        });

        await _firestore.collection('users').doc(followRequestId).update({
          'following': FieldValue.arrayUnion([uid])
        });
      }
    } catch (e) {
      SnackBar(
        content: Text(e.toString()),
      );
    }
  }

  Future<void> unFollowRequest(String uid, String unFollowRequestId) async {
    try {
      Map<String, dynamic>? userDetails = await getUserDetails(uid);

      List followersList = userDetails['followers'];

      if (followersList.contains(unFollowRequestId)) {
        await _firestore.collection('users').doc(uid).update({
          'followers': FieldValue.arrayRemove([unFollowRequestId])
        });

        await _firestore.collection('users').doc(unFollowRequestId).update({
          'following': FieldValue.arrayRemove([uid])
        });
      }
    } catch (e) {
      SnackBar(
        content: Text(e.toString()),
      );
    }
  }

  Future<bool> checkNotificationExistence(
      String groupId, String currentUserUid, String groupCreatorId) async {
    print("inside firestore");
    print(groupId);
    print(currentUserUid);
    print(groupCreatorId);
    // Perform the Firestore query to check if the notification exists
    QuerySnapshot notificationSnapshot = await FirebaseFirestore.instance
        .collection('notifications')
        .where('groupId', isEqualTo: groupId)
        .where('userId', isEqualTo: currentUserUid)
        .where('group_cid', isEqualTo: groupCreatorId)
        .get();

    print(notificationSnapshot.size);

    return notificationSnapshot.docs.isNotEmpty;
  }

  Future<List<QueryDocumentSnapshot>> fetchNotification(
    String groupId,
    String currentUserId,
    String groupCreatorId,
  ) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('notifications')
        .where('groupId', isEqualTo: groupId)
        .where('userId', isEqualTo: currentUserId)
        .where('group_cid', isEqualTo: groupCreatorId)
        .get();
    return querySnapshot.docs;
  }
}

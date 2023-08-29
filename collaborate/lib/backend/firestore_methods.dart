import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
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

      groupMembers.remove(uid);

      sendInviteNotifications(groupMembers,
          groupId); //it sends a notification to all the users that they were added to the group
      return groupId;
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

    await FirebaseFirestore.instance
        .collection('notifications')
        .doc(notificationId)
        .delete();
  }

// Function to reject a join request
  Future<void> onReject(
      String notificationId, String userId, String groupId) async {
    // Delete the notification document from the collection
    await FirebaseFirestore.instance
        .collection('notifications')
        .doc(notificationId)
        .delete();

    String newNotificationId = const Uuid().v1();

    // send a notification to the user, that his request was requested
    await FirebaseFirestore.instance
        .collection('notifications')
        .doc(newNotificationId)
        .set({
      'type': 'rejected_request',
      'userId': userId,
      'groupId': groupId,
      'notificationId': newNotificationId,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteNotification(String notificationId) async {
    await FirebaseFirestore.instance
        .collection('notifications')
        .doc(notificationId)
        .delete();
  }

  //this function basically is used to get all the new users that were added into an existing group, it will be used in sending notifications to all the new members
  Future<List> getNewGroupMembers(
      String groupId, Map<String, dynamic> newData) async {
    final groupDoc = await _firestore
        .collection('groups')
        .doc('collaborate')
        .collection('groups')
        .doc(groupId)
        .get();

    if (!groupDoc.exists) {
      throw Exception('Group not found');
    }

    final currentData = groupDoc.data();
    if (currentData == null) return [];

    final List existingMembers = List.from(currentData['groupMembers']);
    final List newMembers = List<String>.from(newData['groupMembers']);

    final List membersToAdd = [];

    for (String memberId in newMembers) {
      if (!existingMembers.contains(memberId)) {
        membersToAdd.add(memberId);
      }
    }

    return membersToAdd;
  }

  Future<void> updateGroupDetails(
      String groupId, Map<String, dynamic> newData) async {
    List newMembersToAdd = await getNewGroupMembers(groupId, newData);

    if (newMembersToAdd.isNotEmpty) {
      // in an update, if there were any new members added to the group, they will be notified
      sendInviteNotifications(newMembersToAdd, groupId);
    }

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
    }
  }

  Future<String> getUsernameForUserId(String userId) async {
    var userSnap =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    var userData = userSnap.data()!;

    return userData["username"];
  }

  Future<Map<String, dynamic>> getUserDetails(String userId) async {
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

  // this function is used to handle the follow request of a user
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

  // this function is used to handle the unfollow request of a user
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

  //this function is used to check if a certain notification exists, will be used to check if the user has already applied to the group or not
  Future<bool> checkNotificationExistence(
      String groupId, String currentUserUid, String groupCreatorId) async {
    QuerySnapshot notificationSnapshot = await FirebaseFirestore.instance
        .collection('notifications')
        .where('groupId', isEqualTo: groupId)
        .where('userId', isEqualTo: currentUserUid)
        .where('group_cid', isEqualTo: groupCreatorId)
        .get();

    return notificationSnapshot.docs.isNotEmpty;
  }

  // sends an invite all the new group members
  Future<void> sendInviteNotifications(List groupMembers, String gid) async {
    for (int i = 0; i < groupMembers.length; i++) {
      await sendInviteNotification(groupMembers[i], gid);
    }
  }

  //sends a notification to the user saying he is added to the group
  Future<void> sendInviteNotification(String userId, String gid) async {
    print('enterred send in');
    String notificationId = const Uuid().v1();
    await FirebaseFirestore.instance
        .collection('notifications')
        .doc(notificationId)
        .set({
      'type': 'invite_request',
      'userId': userId,
      'groupId': gid,
      'notificationId': notificationId,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}


//by sending a notification, I mean adding to the firestore notifications collection and on the user screen the notifications will be filtered accordingly

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

Future<void> applyToGroup(
    String groupId, String groupCid, String userId) async {
  // Check if there's an existing notification with the same userId, groupId, and type
  QuerySnapshot existingNotifications = await FirebaseFirestore.instance
      .collection('notifications')
      .where('type', isEqualTo: 'join_request')
      .where('userId', isEqualTo: userId)
      .where('groupId', isEqualTo: groupId)
      .where('status', isEqualTo: 'pending')
      .get();

  // If an existing notification is found, update its timestamp
  if (existingNotifications.docs.isNotEmpty) {
    DocumentSnapshot existingNotification = existingNotifications.docs[0];
    await existingNotification.reference.update({
      'timestamp': FieldValue.serverTimestamp(),
    });
  } else {
    String notificationId = const Uuid().v1();
    // Create a notification document in the 'notifications' collection
    await FirebaseFirestore.instance
        .collection('notifications')
        .doc(notificationId)
        .set({
      'notificationId': notificationId,
      'userId': userId,
      'groupId': groupId,
      'group_cid': groupCid,
      'status': 'pending',
      'type': 'join_request',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}

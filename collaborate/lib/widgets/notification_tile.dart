import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationTile extends StatelessWidget {
  final String groupId;
  final String userId;
  final String creatorUserId;

  const NotificationTile({
    Key? key,
    required this.groupId,
    required this.userId,
    required this.creatorUserId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container(); // Handle loading state
        }

        final userData = snapshot.data!.data() as Map<String, dynamic>?;
        if (userData == null) {
          return Container(); // Handle error state
        }

        return Row(
          children: [
            Expanded(
              child: Wrap(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(userData[
                        'profilePic']), // Assuming you have 'profilePic' in user data
                  ),
                  SizedBox(width: 8), // Add spacing
                  GestureDetector(
                    onTap: () {
                      // Navigate to user's profile page
                      // You need to implement the navigation logic here
                    },
                    child: Text(
                      userData[
                          'username'], // Assuming you have 'username' in user data
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  SizedBox(width: 8), // Add spacing
                  Text(
                    'wants to join the group',
                    style: TextStyle(color: Colors.black),
                  ),
                  SizedBox(width: 8), // Add spacing
                  GestureDetector(
                    onTap: () {
                      // Navigate to group info page
                      // You need to implement the navigation logic here
                    },
                    child: Text(
                      'groupName', // Replace with the actual group name
                      style: TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Add the user to the group (Implement this logic)
                  },
                  child: Text('Accept'),
                ),
                SizedBox(height: 8), // Add spacing
                ElevatedButton(
                  onPressed: () {
                    // Delete the notification document from Firestore (Implement this logic)
                  },
                  child: Text('Reject'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

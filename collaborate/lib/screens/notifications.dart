import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collaborate/backend/firestore_methods.dart';
import 'package:collaborate/models/group.dart';
import 'package:collaborate/utils/color_utils.dart';
import 'package:collaborate/widgets/join_request_tile.dart';
import 'package:collaborate/widgets/recommendation_tile.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationsScreen extends StatelessWidget {
  final String currentUserId; // Current user's UID
  final List<String> currentUserDomains; // Current user's domains

  const NotificationsScreen(
      {Key? key, required this.currentUserId, required this.currentUserDomains})
      : super(key: key);

  Future<Map<String, Group>> fetchAllGroup() async {
    QuerySnapshot groupsSnapshot = await FirebaseFirestore.instance
        .collection('groups')
        .doc('collaborate')
        .collection('groups')
        .get();
    Map<String, Group> groupMap = {};
    for (QueryDocumentSnapshot groupSnapshot in groupsSnapshot.docs) {
      Group group = Group.fromSnap(groupSnapshot);
      groupMap[group.groupId] = group;
    }

    return groupMap;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: collaborateAppBarBgColor,
        title: Text('Notifications',
            style: GoogleFonts.raleway(
                color: color4, fontWeight: FontWeight.bold)),
      ),
      body: FutureBuilder<Map<String, Group>>(
        future: fetchAllGroup(),
        builder: (context, groupMapSnapshot) {
          if (groupMapSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          Map<String, Group> allGroup = groupMapSnapshot.data!;

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('notifications')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text('No notifications'),
                );
              }

              List<QueryDocumentSnapshot> filteredNotifications =
                  snapshot.data!.docs.where((notification) {
                String type = notification['type'];
                String groupId = notification['groupId'];
                Group? group = allGroup[groupId];

                if (type == 'recommendation') {
                  if (group == null) return false;

                  bool rec;
                  rec = hasCommonItem(group.domains, currentUserDomains);
                  rec = rec && !group.groupMembers.contains(currentUserId);

                  return rec;
                } else if (type == 'join_request') {
                  String gCid = notification['group_cid'];

                  return currentUserId == gCid;
                } else {
                  return false;
                }
              }).toList();

              return ListView.builder(
                itemCount: filteredNotifications.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot notification = filteredNotifications[index];
                  String type = notification['type'];
                  String groupId = notification['groupId'];

                  Group? group = allGroup[groupId];
                  if (group == null) return Container();

                  if (type == 'recommendation') {
                    FutureBuilder<Map<String, dynamic>?>(
                      future: FireStoreMethods().getUserDetails(group.uid),
                      builder: (context, userSnapshot) {
                        if (userSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        }

                        if (userSnapshot.hasError) {
                          return const Text('Error loading user data');
                        }

                        Map<String, dynamic>? userData = userSnapshot.data;
                        if (userData == null ||
                            !userData['followers'].contains(currentUserId)) {
                          return Container();
                        }
                        return RecommendedGroupTile(
                          group: group,
                        );
                      },
                    );
                  } else if (type == 'join_request') {
                    return JoinRequestTile(
                        userId: notification['userId'],
                        groupId: group.groupId,
                        notificationId: filteredNotifications[index]
                            ['notificationId']);
                  } else {
                    return Container();
                  }
                  return null;
                },
              );
            },
          );
        },
      ),
    );
  }

  bool hasCommonItem(List<dynamic> list1, List<dynamic> list2) {
    for (var item in list1) {
      if (list2.contains(item)) {
        return true;
      }
    }
    return false;
  }
}

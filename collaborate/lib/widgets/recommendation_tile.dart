import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collaborate/models/group.dart';
import 'package:collaborate/backend/auth_methods.dart';
import 'package:collaborate/screens/groups/group_detail_info.dart';
import 'package:collaborate/screens/user/user_info.dart';
import 'package:collaborate/utils/color_utils.dart';
import 'package:collaborate/widgets/send_join.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RecommendedGroupTile extends StatelessWidget {
  final Group group; // Group details for the recommended group

  RecommendedGroupTile({required this.group});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20), color: color3),
        child: ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(group.profilePic),
              backgroundColor: collaborateAppBarBgColor,
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Collaborate recommends you',
                  style: GoogleFonts.raleway(
                      color: collaborateAppBarBgColor,
                      fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
                GestureDetector(
                  onTap: () => {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) =>
                            GroupDetailScreen(groupId: group.groupId)))
                  },
                  child: Container(
                    child: Text(
                      group.groupName,
                      style: GoogleFonts.raleway(
                          color: collaborateAppBarBgColor,
                          fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
            subtitle: Row(
              children: [
                Text('Created by: ',
                    style: GoogleFonts.raleway(
                        color: collaborateAppBarBgColor,
                        fontWeight: FontWeight.w500)),
                GestureDetector(
                    onTap: () => {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) =>
                                  ProfileScreen(uid: group.uid)))
                        },
                    child: Text(group.username,
                        style: GoogleFonts.raleway(
                            color: collaborateAppBarBgColor,
                            fontWeight: FontWeight.bold))),
              ],
            ),
            trailing: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('notifications')
                  .where('type', isEqualTo: 'join_request')
                  .where('groupId', isEqualTo: group.groupId)
                  .where('userId',
                      isEqualTo: AuthMethods()
                          .getUserId()) // Replace with actual user ID
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }

                bool notificationExists =
                    snapshot.hasData && snapshot.data!.docs.isNotEmpty;

                if (notificationExists) {
                  return Chip(
                      label: Text('Requested',
                          style: GoogleFonts.raleway(
                              color: blackColor,
                              fontWeight: FontWeight.bold,
                              fontSize: width * 0.03)));
                } else {
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: collaborateAppBarBgColor,
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                      ),
                      onPressed: () {
                        applyToGroup(group.groupId, group.uid,
                            AuthMethods().getUserId());
                      },
                      child: Text(
                        //when user clicks it, join request will be sent to the group creator
                        'Join',
                        style: GoogleFonts.raleway(
                          color: color4,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }
              },
            )),
      ),
    );
  }
}

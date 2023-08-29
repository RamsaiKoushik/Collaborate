import 'package:collaborate/backend/auth_methods.dart';
import 'package:collaborate/backend/firestore_methods.dart';
import 'package:collaborate/screens/groups/group_detail_info.dart';
import 'package:collaborate/screens/user/user_info.dart';
import 'package:collaborate/utils/color_utils.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class InvitationRequest extends StatelessWidget {
  final String groupId;
  final String notificationId; // Pass the group ID to the page

  InvitationRequest(this.groupId, this.notificationId);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20), color: color3),
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('groups')
              .doc('collaborate')
              .collection('groups')
              .doc(groupId)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return CircularProgressIndicator();
            }

            final group = snapshot.data!.data() as Map<String, dynamic>?;

            if (group == null) {
              return Container();
            }

            String creatorId = group['uid'];

            return StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(creatorId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return CircularProgressIndicator();
                }

                final userDetails =
                    snapshot.data!.data() as Map<String, dynamic>?;

                if (userDetails == null) {
                  return Container();
                }

                return Column(
                  children: [
                    ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(
                          group['profilePic'],
                        ),
                        backgroundColor: collaborateAppBarBgColor,
                      ),
                      title: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: userDetails['username'],
                              style: GoogleFonts.raleway(
                                  color: collaborateAppBarBgColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: width * 0.045),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) =>
                                        ProfileScreen(uid: userDetails['uid']),
                                  ));
                                  // Navigate to user profile using Navigator
                                },
                            ),
                            TextSpan(
                              text: ' added you to the group ',
                              style: GoogleFonts.raleway(
                                color: collaborateAppBarBgColor,
                                fontWeight: FontWeight.w400,
                                fontSize: width * 0.045,
                              ),
                            ),
                            TextSpan(
                              text: group['groupName'],
                              style: GoogleFonts.raleway(
                                color: collaborateAppBarBgColor,
                                fontWeight: FontWeight.bold,
                                fontSize: width * 0.045,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  // Navigate to group info page using Navigator
                                  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) =>
                                        GroupDetailScreen(groupId: groupId),
                                  ));
                                },
                            ),
                          ],
                        ),
                      ),
                    ),

                    //giving the user two choices accept(willing to continue in the group) and reject(exit from the group)
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              FireStoreMethods()
                                  .deleteNotification(notificationId);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: collaborateAppBarBgColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              'Accept',
                              style: GoogleFonts.raleway(color: color4),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8.0, vertical: 0),
                            child: ElevatedButton(
                              onPressed: () async {
                                await FireStoreMethods().removeUserFromGroup(
                                    groupId, AuthMethods().getUserId());
                                await FireStoreMethods()
                                    .deleteNotification(notificationId);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: blackColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                'Exit',
                                style: GoogleFonts.raleway(color: color4),
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                        ],
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collaborate/backend/firestore_methods.dart';
import 'package:collaborate/backend/auth_methods.dart';
import 'package:collaborate/screens/groups/group_detail_info.dart';
import 'package:collaborate/utils/color_utils.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RejectedRequestTile extends StatelessWidget {
  final String groupId;
  final String notificationId;

  RejectedRequestTile({required this.groupId, required this.notificationId});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: height * 0.005, horizontal: width * 0.01),
      child: Container(
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('groups')
              .doc('collaborate')
              .collection('groups')
              .doc(groupId)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }

            if (!snapshot.hasData) {
              return Container();
            }

            final group = snapshot.data!.data() as Map<String, dynamic>?;

            if (group == null) {
              // Group data is not available
              return Container();
            }

            if (!group['groupMembers'].contains(AuthMethods().getUserId())) {
              return Container(
                padding: EdgeInsets.symmetric(
                    vertical: height * 0.01, horizontal: width * 0.06),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20), color: color3),
                child: Column(
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'You request to join ',
                            style: GoogleFonts.raleway(
                                color: collaborateAppBarBgColor,
                                fontWeight: FontWeight.w500,
                                fontSize: width * 0.045),
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
                                // Handle the onTap action here
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) =>
                                      GroupDetailScreen(groupId: groupId),
                                ));
                              },
                          ),
                          TextSpan(
                            text: ' was rejected.',
                            style: GoogleFonts.raleway(
                                color: collaborateAppBarBgColor,
                                fontWeight: FontWeight.w500,
                                fontSize: width * 0.045),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: height * 0.0),
                    Container(
                      alignment: Alignment.bottomRight,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 0),
                      child: ElevatedButton(
                        onPressed: () {
                          FireStoreMethods().deleteNotification(notificationId);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: blackColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          //this will delete the notification from the firestore
                          'Delete',
                          style: GoogleFonts.raleway(color: color4),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return Container();
            }
          },
        ),
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collaborate/backend/firestore_methods.dart';
import 'package:collaborate/utils/color_utils.dart';
import 'package:collaborate/widgets/send_join.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../screens/groups/group_detail_info.dart';

//this is a group tile, which is used in teh rendering of all the groups
class GroupTile extends StatelessWidget {
  final String groupId;
  final String groupName;
  final List domains;
  final String profilePic;
  final String category;
  final String currentUserUid;

  const GroupTile(
      {super.key,
      required this.groupId,
      required this.groupName,
      required this.domains,
      required this.profilePic,
      required this.category,
      required this.currentUserUid});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Container(
      decoration:
          BoxDecoration(borderRadius: BorderRadius.circular(20), color: color3),
      padding: EdgeInsets.symmetric(
          horizontal: width * 0.04, vertical: height * 0.015),
      child: Row(
        children: [
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(profilePic),
                    backgroundColor: color1,
                  ),
                  SizedBox(width: width * 0.05),
                  Flexible(
                    child: Text(
                      groupName,
                      style: GoogleFonts.raleway(
                          fontWeight: FontWeight.w500,
                          fontSize: 28,
                          color: collaborateAppBarBgColor),
                    ),
                  )
                ],
              ),
              SizedBox(
                height: height * 0.01,
              ),
              Row(
                children: [
                  Text(
                    'Category: ',
                    style: GoogleFonts.raleway(
                        fontWeight: FontWeight.w500, fontSize: 18),
                  ),
                  Text(category,
                      style: GoogleFonts.raleway(
                          fontWeight: FontWeight.w500, fontSize: 18))
                ],
              ),
              SizedBox(
                height: height * 0.005,
              ),
              domains.isNotEmpty
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Domains: ',
                              style: GoogleFonts.raleway(
                                fontWeight: FontWeight.w500,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                        Wrap(
                          spacing: 4, // Adjust the spacing between domain items
                          runSpacing: 2, // Adjust the spacing between lines
                          children: domains.map<Widget>((domain) {
                            return Chip(
                              // shape: OutlinedBorder(side: BorderSide()),
                              // backgroundColor: color3,
                              label: Text(
                                domain,
                                style: GoogleFonts.raleway(
                                  fontWeight: FontWeight.w500,
                                  fontSize: width * 0.03,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    )
                  : Container()
            ]),
          ),
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('groups')
                .doc('collaborate')
                .collection('groups')
                .doc(groupId)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Container();
              }

              final group = snapshot.data!.data() as Map<String, dynamic>?;
              if (group == null) {
                return Container();
              }

              final members = group['groupMembers'];
              final isUserMember = members?.contains(currentUserUid) ?? false;

              if (!isUserMember) {
                // User is not a member of the group
                return Column(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.info,
                        color: collaborateAppBarBgColor,
                        size: 30,
                      ),
                      onPressed: () {
                        // Navigate to the GroupDetailScreen and pass the groupId
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                GroupDetailScreen(groupId: groupId),
                          ),
                        );
                      },
                    ),
                    SizedBox(
                      height: height * 0.03,
                    ),

                    //before rendering the apply button we check if the user has applied to the group or not
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('notifications')
                          .where('groupId', isEqualTo: groupId)
                          .where('userId', isEqualTo: currentUserUid)
                          .where('group_cid', isEqualTo: group['uid'])
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
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
                                      fontSize: width * 0.04)));
                        } else {
                          return ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: collaborateAppBarBgColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            onPressed: () {
                              applyToGroup(
                                  groupId, group['uid'], currentUserUid);
                            },
                            child: Text(group["category"] == "Group Study"
                                ? 'Join'
                                : 'Apply'),
                          );
                        }
                      },
                    )
                  ],
                );
              } else {
                return Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Column(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.info,
                          size: 40,
                        ),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    GroupDetailScreen(groupId: groupId),
                              ));
                        },
                        color: collaborateAppBarBgColor,
                      )
                    ],
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

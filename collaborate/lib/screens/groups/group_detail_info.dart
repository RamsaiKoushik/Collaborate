import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collaborate/resources/auth_methods.dart';
import 'package:collaborate/resources/firestore_methods.dart';
import 'package:collaborate/screens/groups/group_detail_edit.dart';
import 'package:collaborate/screens/home_screen.dart';
import 'package:collaborate/screens/user/user_info.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:collaborate/utils/color_utils.dart';
import 'package:collaborate/utils/utils.dart';

class GroupDetailScreen extends StatelessWidget {
  final String groupId;
  final String currentUserId = AuthMethods().getUserId();

  GroupDetailScreen({super.key, required this.groupId});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    // Implement the detailed group info screen here
    // You can use the groupId to fetch and display the info
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('groups')
          .doc('collaborate')
          .collection('groups')
          .doc(groupId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          // Data is loading, you can show a loading indicator
          return const CircularProgressIndicator();
        }

        final group = snapshot.data!.data() as Map<String, dynamic>?;

        if (group == null) {
          // Group data is not available
          return showSnackBar(context, 'Group not available');
        }

        return Scaffold(
          backgroundColor: collaborateAppBarBgColor,
          body: Container(
            constraints: BoxConstraints(minHeight: height),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: height * 0.1),
                  Align(
                    alignment: Alignment.center,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.grey,
                          backgroundImage: NetworkImage(
                            group['profilePic'],
                          ),
                          radius: width * 0.18,
                          child: FirebaseAuth.instance.currentUser!.uid ==
                                  group["uid"]
                              ? GestureDetector(onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (context) => GroupEditScreen(
                                            groupId: group["groupId"])),
                                  );
                                })
                              : Container(),
                        ),
                        if (FirebaseAuth.instance.currentUser!.uid ==
                            group["uid"])
                          Positioned(
                            bottom: 2,
                            right: 6,
                            child: ClipOval(
                              child: Container(
                                color: Colors.white,
                                padding: const EdgeInsets.all(4),
                                child: const Icon(
                                  Icons.edit,
                                  color: blackColor,
                                  size: 30,
                                ),
                              ),
                            ),
                          )
                      ],
                    ),
                  ),
                  SizedBox(height: height * 0.02),
                  Align(
                    alignment: Alignment.center,
                    child: Text(group['groupName'],
                        style: GoogleFonts.raleway(
                          fontSize: width * 0.08,
                          color: collaborateAppBarTextColor,
                          fontWeight: FontWeight.bold,
                        )),
                  ),
                  SizedBox(
                    height: height * 0.03,
                  ),
                  Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(8.0),
                    child: Column(children: [
                      Text(
                        'Created By',
                        style: GoogleFonts.raleway(
                          fontSize: width * 0.05,
                          color: collaborateAppBarTextColor,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                ProfileScreen(uid: group["uid"]),
                          ),
                        ),
                        child: Text(
                          group["username"],
                          style: GoogleFonts.raleway(
                            fontSize: width * 0.05,
                            color: collaborateAppBarTextColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    ]),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        Text('Description',
                            style: GoogleFonts.raleway(
                                fontSize: width * 0.06,
                                color: color4,
                                fontWeight: FontWeight.w400)),
                        SizedBox(
                          height: height * 0.01,
                        ),
                        Text(group["description"],
                            style: GoogleFonts.raleway(
                                fontSize: width * 0.04,
                                color: color4,
                                fontWeight: FontWeight.w300)),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: height * 0.03,
                  ),
                  Container(
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        Text('Category',
                            style: GoogleFonts.raleway(
                                fontSize: width * 0.06,
                                color: color4,
                                fontWeight: FontWeight.w400)),
                        SizedBox(
                          height: height * 0.01,
                        ),
                        Text(group["category"],
                            style: GoogleFonts.raleway(
                                fontSize: width * 0.04,
                                color: color4,
                                fontWeight: FontWeight.w300)),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: height * 0.03,
                  ),
                  Container(
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        Text('Domains',
                            style: GoogleFonts.raleway(
                                fontSize: width * 0.06,
                                color: color4,
                                fontWeight: FontWeight.w400)),
                        Wrap(
                          spacing: 8, // Adjust the spacing between chips
                          runSpacing: 4, // Adjust the spacing between lines
                          children: group["domains"].map<Widget>((domain) {
                            return Chip(
                              label: Text(domain,
                                  style: GoogleFonts.raleway(
                                      fontSize: width * 0.035,
                                      color: collaborateAppBarBgColor,
                                      fontWeight: FontWeight.w400)),
                              backgroundColor: Colors.grey[300],
                            );
                          }).toList(),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: height * 0.03,
                  ),
                  Container(
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        Text('Skillset',
                            style: GoogleFonts.raleway(
                                fontSize: width * 0.06,
                                color: color4,
                                fontWeight: FontWeight.w400)),
                        Wrap(
                          spacing: 8, // Adjust the spacing between chips
                          runSpacing: 4, // Adjust the spacing between lines
                          children: group["skillsList"].map<Widget>((skill) {
                            return Chip(
                              label: Text(skill,
                                  style: GoogleFonts.raleway(
                                      fontSize: width * 0.035,
                                      color: collaborateAppBarBgColor,
                                      fontWeight: FontWeight.w400)),
                              backgroundColor: Colors.grey[300],
                            );
                          }).toList(),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: height * 0.03,
                  ),
                  Container(
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        Text('Team Members',
                            style: GoogleFonts.raleway(
                                fontSize: width * 0.06,
                                color: color4,
                                fontWeight: FontWeight.w400)),
                        SizedBox(
                          height: height * 0.01,
                        ),
                        Wrap(
                          spacing: width, // Adjust the spacing between chips
                          runSpacing: 4, // Adjust the spacing between lines
                          children: group["groupMembers"].map<Widget>((member) {
                            return Container(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            ProfileScreen(uid: member)),
                                  );
                                },
                                child: FutureBuilder<String>(
                                  future: FireStoreMethods()
                                      .getUsernameForUserId(member),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const CircularProgressIndicator();
                                    } else if (snapshot.hasError) {
                                      return Text('Error: ${snapshot.error}');
                                    } else if (snapshot.hasData) {
                                      final username = snapshot.data!;
                                      return Text(username,
                                          style: GoogleFonts.raleway(
                                              color: color4,
                                              fontSize: width * 0.06,
                                              fontWeight: FontWeight.bold));
                                    } else {
                                      return const Text('No data');
                                    }
                                  },
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: height * 0.1),
                  Container(
                    alignment: Alignment.center,
                    child: Column(children: [
                      if (group["groupMembers"]
                          .contains(AuthMethods().getUserId()))
                        if (currentUserId ==
                            group["uid"]) // Creator of the group
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red),
                            onPressed: () async {
                              // Delete the group and navigate to home screen
                              await FireStoreMethods().deleteGroup(groupId);
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                    builder: (context) => const HomePage()),
                              );
                            },
                            child: Text(
                              'Delete Group',
                              style: GoogleFonts.raleway(
                                  color: blackColor,
                                  fontWeight: FontWeight.w500),
                            ),
                          )
                        else // Member of the group
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red),
                            onPressed: () async {
                              // Remove user from group and navigate to home screen
                              await FireStoreMethods()
                                  .removeUserFromGroup(groupId, currentUserId);
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                    builder: (context) => const HomePage()),
                              );
                            },
                            child: Text(
                              'Exit Group',
                              style: GoogleFonts.raleway(
                                  color: blackColor,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                    ]),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// import 'package:collaborate/resources/firestore_methods.dart';
// import 'package:collaborate/screens/groups/group_detail_info.dart';
// import 'package:collaborate/utils/color_utils.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// // import 'package:collaborate/resources/firestore_methods.dart';

// class JoinRequestTile extends StatelessWidget {
//   final String userId;
//   final String groupId;
//   final String notificationId;

//   JoinRequestTile({
//     required this.userId,
//     required this.groupId,
//     required this.notificationId,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder(
//       future: FireStoreMethods().getUserDetails(userId),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const ListTile(
//             title: Text('Loading user details...'),
//           );
//         }

//         if (!snapshot.hasData) {
//           return const ListTile(
//             title: Text('User details not found.'),
//           );
//         }

//         final userDetails = snapshot.data as Map<String, dynamic>;

//         return FutureBuilder(
//           future: FireStoreMethods().getGroupDetails(groupId),
//           builder: (context, groupSnapshot) {
//             if (groupSnapshot.connectionState == ConnectionState.waiting) {
//               return const ListTile(
//                 title: Text('Loading group details...'),
//               );
//             }

//             if (!groupSnapshot.hasData) {
//               return const ListTile(
//                 title: Text('Group details not found.'),
//               );
//             }

//             final groupDetails = groupSnapshot.data as Map<String, dynamic>;

//             return Padding(
//               padding: const EdgeInsets.all(4.0),
//               child: Container(
//                 decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(20), color: color3),
//                 child:Row(
//                   crossAxisAlignment: CrossAxisAlignment.stretch,
//                   children: [
//                     ListTile(
//                         leading: CircleAvatar(
//                           backgroundImage:
//                               NetworkImage(userDetails['profilePic']),
//                         ),
//                         title: Row(
//                           children: [
//                             Text(
//                               userDetails['username'],
//                               overflow: TextOverflow.ellipsis,
//                               style: GoogleFonts.raleway(
//                                   color: collaborateAppBarBgColor,
//                                   fontWeight: FontWeight.bold),
//                             ),
//                             Text(
//                               ' wants to join the following group',
//                               style: GoogleFonts.raleway(
//                                   color: collaborateAppBarBgColor,
//                                   fontWeight: FontWeight.w400),
//                             )
//                           ],
//                         ),
//                         subtitle: GestureDetector(
//                             onTap: () => {
//                                   Navigator.of(context).push(MaterialPageRoute(
//                                       builder: (context) =>
//                                           GroupDetailScreen(groupId: groupId)))
//                                 },
//                             child: Row(
//                               children: [
//                                 Text(
//                                   'Group: ',
//                                   style: GoogleFonts.raleway(
//                                       color: collaborateAppBarBgColor,
//                                       fontWeight: FontWeight.w400),
//                                 ),
//                                 Text(groupDetails['groupName'],
//                                     style: GoogleFonts.raleway(
//                                         color: collaborateAppBarBgColor,
//                                         fontWeight: FontWeight.bold)),
//                               ],
//                             )),
//                       ),
//                     ),
//                     Align(
//                       alignment: Alignment.bottomRight,
//                       child: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         mainAxisAlignment: MainAxisAlignment.end,
//                         children: [
//                           ElevatedButton(
//                             onPressed: () async {
//                               await FireStoreMethods()
//                                   .onAccept(notificationId, groupId, userId);
//                             },
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: collaborateAppBarBgColor,
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(10),
//                               ),
//                             ),
//                             child: Text(
//                               'Accept',
//                               style: GoogleFonts.raleway(color: color4),
//                             ),
//                           ),
//                           SizedBox(width: 10),
//                           Padding(
//                             padding: const EdgeInsets.symmetric(
//                                 horizontal: 8.0, vertical: 0),
//                             child: ElevatedButton(
//                               onPressed: () {
//                                 FireStoreMethods().onReject(notificationId);
//                               },
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: blackColor,
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(10),
//                                 ),
//                               ),
//                               child: Text(
//                                 'Reject',
//                                 style: GoogleFonts.raleway(color: color4),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }
// }

import 'package:collaborate/backend/firestore_methods.dart';
import 'package:collaborate/screens/groups/group_detail_info.dart';
import 'package:collaborate/screens/user/user_info.dart';
import 'package:collaborate/utils/color_utils.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:collaborate/resources/firestore_methods.dart';

class JoinRequestTile extends StatelessWidget {
  final String userId;
  final String groupId;
  final String notificationId;

  JoinRequestTile({
    required this.userId,
    required this.groupId,
    required this.notificationId,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return FutureBuilder(
      future: FireStoreMethods().getUserDetails(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const ListTile(
            title: Text('Loading user details...'),
          );
        }

        if (!snapshot.hasData) {
          return const ListTile(
            title: Text('User details not found.'),
          );
        }

        final userDetails = snapshot.data as Map<String, dynamic>;

        return FutureBuilder(
          future: FireStoreMethods().getGroupDetails(groupId),
          builder: (context, groupSnapshot) {
            if (groupSnapshot.connectionState == ConnectionState.waiting) {
              return const ListTile(
                title: Text('Loading group details...'),
              );
            }

            if (!groupSnapshot.hasData) {
              return const ListTile(
                title: Text('Group details not found.'),
              );
            }

            final groupDetails = groupSnapshot.data as Map<String, dynamic>;

            return Padding(
              padding: const EdgeInsets.all(4.0),
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20), color: color3),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(
                          userDetails['profilePic'],
                        ),
                        backgroundColor: collaborateAppBarBgColor,
                      ),
                      title: Row(
                        children: [
                          GestureDetector(
                            onTap: () => {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) =>
                                      ProfileScreen(uid: userId)))
                            },
                            child: Text(
                              userDetails['username'],
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.raleway(
                                  color: collaborateAppBarBgColor,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Text(
                            ' wants to join',
                            style: GoogleFonts.raleway(
                                color: collaborateAppBarBgColor,
                                fontWeight: FontWeight.w400),
                            overflow: TextOverflow.ellipsis,
                          )
                        ],
                      ),
                      subtitle: GestureDetector(
                          onTap: () => {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) =>
                                        GroupDetailScreen(groupId: groupId)))
                              },
                          child: Row(
                            children: [
                              Text(
                                'Group: ',
                                style: GoogleFonts.raleway(
                                    color: collaborateAppBarBgColor,
                                    fontWeight: FontWeight.w400),
                              ),
                              Text(groupDetails['groupName'],
                                  style: GoogleFonts.raleway(
                                      color: collaborateAppBarBgColor,
                                      fontWeight: FontWeight.bold)),
                            ],
                          )),
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              await FireStoreMethods()
                                  .onAccept(notificationId, groupId, userId);
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
                          SizedBox(width: 10),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8.0, vertical: 0),
                            child: ElevatedButton(
                              onPressed: () {
                                FireStoreMethods().onReject(notificationId);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: blackColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                'Reject',
                                style: GoogleFonts.raleway(color: color4),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

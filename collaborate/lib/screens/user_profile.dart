import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collaborate/screens/edit_user_profile.dart';
import 'package:collaborate/utils/color_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:collaborate/utils/utils.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileScreen extends StatefulWidget {
  final String uid;
  const ProfileScreen({Key? key, required this.uid}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  var userData = {};
  int postLen = 0;
  int followers = 0;
  int following = 0;
  bool isFollowing = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    setState(() {
      isLoading = true;
    });
    try {
      var userSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .get();

      // get post lENGTH
      var postSnap = await FirebaseFirestore.instance
          .collection('posts')
          .where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .get();

      postLen = postSnap.docs.length;
      userData = userSnap.data()!;
      followers = userSnap.data()!['followers'].length;
      following = userSnap.data()!['following'].length;
      isFollowing = userSnap
          .data()!['followers']
          .contains(FirebaseAuth.instance.currentUser!.uid);
      setState(() {});
    } catch (e) {
      showSnackBar(
        context,
        e.toString(),
      );
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : Scaffold(
            backgroundColor: collaborateAppBarBgColor,
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: height * 0.1),
                // ListView(physics: const BouncingScrollPhysics(), children: [
                Align(
                  alignment: Alignment.center,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.grey,
                        backgroundImage: NetworkImage(
                          userData['photoUrl'],
                        ),
                        radius: width * 0.18,
                        child:
                            FirebaseAuth.instance.currentUser!.uid == widget.uid
                                ? GestureDetector(onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const EditUserProfile()),
                                    );
                                  })
                                : Container(),
                      ),
                      FirebaseAuth.instance.currentUser!.uid == widget.uid
                          ? Positioned(
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
                          : Container(),
                    ],
                  ),
                ),
                SizedBox(height: height * 0.02),

                Align(
                  alignment: Alignment.center,
                  child: Text(userData['username'],
                      style: GoogleFonts.raleway(
                        fontSize: width * 0.08,
                        color: collaborateAppBarTextColor,
                        fontWeight: FontWeight.bold,
                      )),
                ),

                SizedBox(height: height * 0.01),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    buildButton(context, following.toString(), 'following'),
                    SizedBox(
                      height: height * 0.04,
                      child: const VerticalDivider(
                        color: collaborateAppBarTextColor,
                      ),
                    ),
                    buildButton(context, followers.toString(), 'followers')
                  ],
                ),

                SizedBox(height: height * 0.05),
                buildInfo('email', userData['email']),
                SizedBox(height: height * 0.05),
                buildInfo('rollNumber', userData['rollNumber']),
                SizedBox(height: height * 0.05),
                buildAbout('About', userData['about']),
              ],
            ),
            //   body: ListView(
            //     children: [
            //       Padding(
            //         padding: const EdgeInsets.all(16),
            //         child: Column(
            //           children: [
            //             Row(
            //               children: [
            //                 CircleAvatar(
            //                   backgroundColor: Colors.grey,
            //                   backgroundImage: NetworkImage(
            //                     userData['photoUrl'],
            //                   ),
            //                   radius: 40,
            //                 ),
            //                 Expanded(
            //                   flex: 1,
            //                   child: Column(
            //                     children: [
            //                       Row(
            //                         mainAxisSize: MainAxisSize.max,
            //                         mainAxisAlignment:
            //                             MainAxisAlignment.spaceEvenly,
            //                         children: [
            //                           buildStatColumn(postLen, "posts"),
            //                           buildStatColumn(followers, "followers"),
            //                           buildStatColumn(following, "following"),
            //                         ],
            //                       ),
            //                       Row(
            //                         mainAxisAlignment:
            //                             MainAxisAlignment.spaceEvenly,
            //                         children: [
            //                           FirebaseAuth.instance.currentUser!.uid ==
            //                                   widget.uid
            //                               ? FollowButton(
            //                                   text: 'Sign Out',
            //                                   backgroundColor:
            //                                       mobileBackgroundColor,
            //                                   textColor: primaryColor,
            //                                   borderColor: Colors.grey,
            //                                   function: () async {
            //                                     await AuthMethods().signOut();
            //                                     if (context.mounted) {
            //                                       Navigator.of(context)
            //                                           .pushReplacement(
            //                                         MaterialPageRoute(
            //                                           builder: (context) =>
            //                                               const LoginScreen(),
            //                                         ),
            //                                       );
            //                                     }
            //                                   },
            //                                 )
            //                               : isFollowing
            //                                   ? FollowButton(
            //                                       text: 'Unfollow',
            //                                       backgroundColor: Colors.white,
            //                                       textColor: Colors.black,
            //                                       borderColor: Colors.grey,
            //                                       function: () async {
            //                                         await FireStoreMethods()
            //                                             .followUser(
            //                                           FirebaseAuth.instance
            //                                               .currentUser!.uid,
            //                                           userData['uid'],
            //                                         );

            //                                         setState(() {
            //                                           isFollowing = false;
            //                                           followers--;
            //                                         });
            //                                       },
            //                                     )
            //                                   : FollowButton(
            //                                       text: 'Follow',
            //                                       backgroundColor: Colors.blue,
            //                                       textColor: Colors.white,
            //                                       borderColor: Colors.blue,
            //                                       function: () async {
            //                                         await FireStoreMethods()
            //                                             .followUser(
            //                                           FirebaseAuth.instance
            //                                               .currentUser!.uid,
            //                                           userData['uid'],
            //                                         );

            //                                         setState(() {
            //                                           isFollowing = true;
            //                                           followers++;
            //                                         });
            //                                       },
            //                                     )
            //                         ],
            //                       ),
            //                     ],
            //                   ),
            //                 ),
            //               ],
            //             ),
            //             Container(
            //               alignment: Alignment.centerLeft,
            //               padding: const EdgeInsets.only(
            //                 top: 15,
            //               ),
            //               child: Text(
            //                 userData['username'],
            //                 style: const TextStyle(
            //                   fontWeight: FontWeight.bold,
            //                 ),
            //               ),
            //             ),
            //             Container(
            //               alignment: Alignment.centerLeft,
            //               padding: const EdgeInsets.only(
            //                 top: 1,
            //               ),
            //               child: Text(
            //                 userData['about'],
            //               ),
            //             ),
            //           ],
            //         ),
            //       ),
            //       const Divider(),
            //       FutureBuilder(
            //         future: FirebaseFirestore.instance
            //             .collection('posts')
            //             .where('uid', isEqualTo: widget.uid)
            //             .get(),
            //         builder: (context, snapshot) {
            //           if (snapshot.connectionState == ConnectionState.waiting) {
            //             return const Center(
            //               child: CircularProgressIndicator(),
            //             );
            //           }

            //           return GridView.builder(
            //             shrinkWrap: true,
            //             itemCount: (snapshot.data! as dynamic).docs.length,
            //             gridDelegate:
            //                 const SliverGridDelegateWithFixedCrossAxisCount(
            //               crossAxisCount: 3,
            //               crossAxisSpacing: 5,
            //               mainAxisSpacing: 1.5,
            //               childAspectRatio: 1,
            //             ),
            //             itemBuilder: (context, index) {
            //               DocumentSnapshot snap =
            //                   (snapshot.data! as dynamic).docs[index];

            //               return SizedBox(
            //                 child: Image(
            //                   image: NetworkImage(snap['postUrl']),
            //                   fit: BoxFit.cover,
            //                 ),
            //               );
            //             },
            //           );
            //         },
            //       )
            //     ],
            //   ),
          );
  }

  // Widget buildEditIcon(Color color){

  // return ClipOval(
  //   child: Container(
  //       color: Colors.white,
  //       padding: EdgeInsets.all(8),
  //       child: const Icon(
  //         Icons.edit,
  //         color: Colors.white,
  //         size: 20,
  //       ),
  //       ),
  //     );
  // }

  Icon getIconFromName(String iconName) {
    switch (iconName) {
      case 'email':
        return const Icon(
          Icons.email_outlined,
          color: collaborateAppBarTextColor,
        );
      case 'rollNumber':
        return const Icon(Icons.perm_identity,
            color: collaborateAppBarTextColor);
      // Add more cases for other icons
      default:
        return const Icon(
          Icons.error,
          color: collaborateAppBarTextColor,
        ); // Default icon if the input doesn't match any case
    }
  }

  Widget buildInfo(String type, String info) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          getIconFromName(type),
          const SizedBox(width: 8),
          Text(
            info,
            style: GoogleFonts.raleway(
              color: collaborateAppBarTextColor,
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildAbout(String type, String info) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            type,
            style: GoogleFonts.raleway(
              color: collaborateAppBarTextColor,
              fontWeight: FontWeight.bold,
              fontSize: 25,
            ),
          ),
          // const SizedBox(width: 20),
          Text(
            info,
            style: GoogleFonts.raleway(
              color: collaborateAppBarTextColor,
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildButton(BuildContext context, String value, String text) {
    return MaterialButton(
      onPressed: () {},
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.raleway(
              color: collaborateAppBarTextColor,
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            text,
            style: GoogleFonts.raleway(
                color: collaborateAppBarTextColor,
                fontWeight: FontWeight.w600,
                fontSize: 18),
          ),
        ],
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collaborate/backend/auth_methods.dart';
import 'package:collaborate/backend/firestore_methods.dart';
import 'package:collaborate/screens/display_users.dart';
import 'package:collaborate/screens/user/edit_user_info.dart';
import 'package:collaborate/screens/auth/login_screen.dart';
import 'package:collaborate/utils/color_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileScreen extends StatefulWidget {
  final String uid;
  const ProfileScreen({Key? key, required this.uid}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
  }

  void signOut() async {
    try {
      // print("entered signout");
      await AuthMethods().signOut();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ),
        (Route<dynamic> route) => false,
      );
    } catch (err) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: color2,
          content: Text(
            err.toString(),
            style: GoogleFonts.raleway(fontSize: 18, color: color1),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(widget.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const CircularProgressIndicator();
          }

          final user = snapshot.data!.data() as Map<String, dynamic>?;

          if (user == null) {
            return const CircularProgressIndicator();
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
                              user['profilePic'],
                            ),
                            radius: width * 0.18,
                            child: FirebaseAuth.instance.currentUser!.uid ==
                                    widget.uid
                                ? GestureDetector(onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const EditUserProfile()),
                                    );
                                  })
                                : Container(),
                          ),
                          if (FirebaseAuth.instance.currentUser!.uid ==
                              widget.uid)
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
                      child: Text(user['username'],
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
                        buildButton(context, user['following'], 'following',
                            user['username']),
                        SizedBox(
                          height: height * 0.04,
                          child: const VerticalDivider(
                            color: collaborateAppBarTextColor,
                          ),
                        ),
                        buildButton(context, user['followers'], 'followers',
                            user['username'])
                      ],
                    ),
                    SizedBox(
                      height: height * 0.02,
                    ),
                    Column(
                      children: [
                        AuthMethods().getUserId() != widget.uid
                            ? user['followers']
                                    .whereType<String>()
                                    .toList()
                                    .contains(AuthMethods().getUserId())
                                ? Container(
                                    alignment: Alignment.center,
                                    child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: color3,
                                        ),
                                        onPressed: () async {
                                          await FireStoreMethods()
                                              .unFollowRequest(widget.uid,
                                                  AuthMethods().getUserId());
                                        },
                                        child: Text('UnFollow',
                                            style: GoogleFonts.raleway(
                                                color: collaborateAppBarBgColor,
                                                fontWeight: FontWeight.bold,
                                                fontSize: width * 0.05))),
                                  )
                                : Container(
                                    alignment: Alignment.center,
                                    child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: color3,
                                        ),
                                        onPressed: () async {
                                          await FireStoreMethods()
                                              .followRequest(widget.uid,
                                                  AuthMethods().getUserId());
                                        },
                                        child: Text('Follow',
                                            style: GoogleFonts.raleway(
                                                color: collaborateAppBarBgColor,
                                                fontWeight: FontWeight.bold,
                                                fontSize: width * 0.05))),
                                  )
                            : Container(),
                      ],
                    ),
                    SizedBox(height: height * 0.05),
                    buildInfo('email', user['email']),
                    SizedBox(height: height * 0.05),
                    buildInfo('rollNumber', user['rollNumber']),
                    SizedBox(height: height * 0.05),
                    buildAbout('About', user['about']),
                    SizedBox(height: height * 0.05),
                    buildSkills(
                        user['learnSkills'], 'Domains I want to Explore'),
                    SizedBox(height: height * 0.05),
                    buildSkills(
                        user['experienceSkills'], 'Domains with Experience.'),
                    if (FirebaseAuth.instance.currentUser!.uid == widget.uid)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Align(
                          alignment: Alignment.bottomRight,
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: color2,
                                shape: ContinuousRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      30.0), // Adjust the radius as needed
                                ),
                              ),
                              onPressed: signOut,
                              child: Text(
                                'Sign Out',
                                style: GoogleFonts.raleway(
                                    color: color4,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              )),
                        ),
                      )
                  ],
                ),
              ),
            ),
          );
        });
  }

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

  Widget buildSkills(List skills, String type) {
    return skills.length != 0
        ? Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  type,
                  style: const TextStyle(
                    color: collaborateAppBarTextColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                  ),
                ),
                SizedBox(height: 8),
                Wrap(
                  spacing: 8.0,
                  children: skills.map((skill) {
                    return Chip(label: Text(skill));
                  }).toList(),
                ),
              ],
            ),
          )
        : Container();
  }

  Widget buildButton(
      BuildContext context, List value, String text, String username) {
    return MaterialButton(
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
              builder: (context) => UserListingPge(
                  filter: value, title: text, userName: username)),
        );
      },
      child: Column(
        children: [
          Text(
            value.length.toString(),
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

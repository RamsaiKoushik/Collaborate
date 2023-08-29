import 'package:collaborate/screens/user/user_info.dart';
import 'package:collaborate/utils/color_utils.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Import your Firebase methods file

class UserTile extends StatelessWidget {
  final String userName;
  final String rollNumber;
  final String profilePic;
  final String uid;

  const UserTile(
      {required this.userName,
      required this.rollNumber,
      required this.profilePic,
      required this.uid});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(profilePic),
      ),
      title: GestureDetector(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => ProfileScreen(uid: uid),
          ));
        },
        child: Text(
          userName,
          style: GoogleFonts.raleway(
              color: collaborateAppBarBgColor, fontWeight: FontWeight.bold),
        ),
      ),
      subtitle: Text('Roll Number: ${rollNumber}',
          style: GoogleFonts.raleway(
              color: collaborateAppBarBgColor, fontWeight: FontWeight.w500)),
    );
  }
}

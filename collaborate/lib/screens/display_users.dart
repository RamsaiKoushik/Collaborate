import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collaborate/screens/user/user_info.dart';
import 'package:collaborate/utils/color_utils.dart';
import 'package:collaborate/widgets/user_tile.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UserListingPge extends StatefulWidget {
  final List filter;
  final String title;
  final String userName;

  const UserListingPge(
      {super.key,
      required this.filter,
      required this.title,
      required this.userName});

  @override
  State<UserListingPge> createState() => _UserListingPgeState();
}

class _UserListingPgeState extends State<UserListingPge> {
  late List _currentFilters;
  final _searchController = TextEditingController();
  String _searchTerm = '';

  @override
  void initState() {
    super.initState();
    _currentFilters = widget.filter;
  }

  @override
  void didUpdateWidget(covariant UserListingPge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_currentFilters != oldWidget.filter) {
      setState(() {
        _currentFilters = widget.filter;
      });
    }
  }

  String appBarTitle(String title) {
    switch (title) {
      case 'search':
        return 'Collaborate Members';
      case 'followers':
        return "${widget.userName}'s Followers";
      case 'following':
        return "${widget.userName} is Following";
      default:
        return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
        appBar: AppBar(
          iconTheme: const IconThemeData(color: collaborateAppBarBgColor),
          backgroundColor: color3,
          title: Text(appBarTitle(widget.title),
              style: GoogleFonts.raleway(
                  color: collaborateAppBarBgColor,
                  fontWeight: FontWeight.w600)),
        ),
        body: Container(
            color: collaborateAppBarBgColor,
            child: Column(children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  style: GoogleFonts.raleway(
                    color: color4,
                  ),
                  decoration: InputDecoration(
                      prefixIcon: const Icon(
                        Icons.search_outlined,
                        color: color4,
                        size: 20,
                      ),
                      labelText: 'Search',
                      labelStyle: GoogleFonts.raleway(color: color4),
                      suffixIcon: IconButton(
                        icon: const Icon(
                          Icons.clear,
                          color: color4,
                          size: 20,
                        ),
                        onPressed: () => {_searchController.clear()},
                      )

                      // hintStyle: GoogleFonts.raleway(color: color4),
                      ),
                  onChanged: (value) {
                    setState(() {
                      _searchTerm = value;
                    });
                  },
                ),
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    }

                    if (!snapshot.hasData) {
                      return Text('No user data available.');
                    }

                    final userList = snapshot.data!.docs;

                    final filteredUsers = userList.where((user) {
                      final followers = (widget.title == 'followers' &&
                          widget.filter.contains(user['uid']));
                      final following = (widget.title == 'following' &&
                          widget.filter.contains(user['uid']));
                      final allUsers = (widget.title == 'search');

                      final userNameMatches = user['username']
                          .toString()
                          .toLowerCase()
                          .contains(_searchTerm);

                      final rollNumberMatches = user['rollNumber']
                          .toString()
                          .toLowerCase()
                          .contains(_searchTerm);

                      return followers ||
                          following ||
                          allUsers && (userNameMatches || rollNumberMatches);
                    }).toList();

                    return ListView.builder(
                      itemCount: filteredUsers.length,
                      itemBuilder: (context, index) {
                        final userDetails = filteredUsers[index];
                        return Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: color3),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundImage:
                                    NetworkImage(userDetails['profilePic']),
                                backgroundColor: collaborateAppBarBgColor,
                              ),
                              title: GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) =>
                                        ProfileScreen(uid: userDetails['uid']),
                                  ));
                                },
                                child: Text(
                                  userDetails['username'],
                                  style: GoogleFonts.raleway(
                                      color: collaborateAppBarBgColor,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              subtitle: Text(
                                  'Roll Number: ${userDetails['rollNumber']}',
                                  style: GoogleFonts.raleway(
                                      color: collaborateAppBarBgColor,
                                      fontWeight: FontWeight.w500)),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ])));
  }
}

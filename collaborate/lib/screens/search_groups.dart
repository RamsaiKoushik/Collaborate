import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collaborate/backend/auth_methods.dart';
import 'package:collaborate/widgets/group_tile.dart';
import 'package:collaborate/utils/color_utils.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SearchGroup extends StatefulWidget {
  const SearchGroup({super.key});

  @override
  _SearchGroupState createState() => _SearchGroupState();
}

class _SearchGroupState extends State<SearchGroup> {
  final TextEditingController _searchController = TextEditingController();
  String searchTerm = "";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: collaborateAppBarBgColor),
        backgroundColor: color3,
        title: Text('Search Teams',
            style: GoogleFonts.raleway(
                color: collaborateAppBarBgColor, fontWeight: FontWeight.w600)),
      ),
      body: Container(
        color: collaborateAppBarBgColor,
        child: Column(
          children: [
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
                    searchTerm = value;
                  });
                },
              ),
            ),
            Expanded(
              child: StreamBuilder<List<QueryDocumentSnapshot>>(
                stream: FirebaseFirestore.instance
                    .collection('groups')
                    .doc('collaborate')
                    .collection('groups')
                    .snapshots()
                    .map((snapshot) => snapshot.docs),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  final groups = snapshot.data!;

                  final filteredGroups = groups.where((group) {
                    final searchMatches = group['category']
                            .toString()
                            .toLowerCase()
                            .contains(searchTerm.toLowerCase()) ||
                        group['groupName']
                            .toString()
                            .toLowerCase()
                            .contains(searchTerm.toLowerCase());

                    return searchMatches && !group['isHidden'];
                  }).toList();

                  return ListView.builder(
                    itemCount: filteredGroups.length,
                    itemBuilder: (context, index) {
                      final group = filteredGroups[index];

                      return Column(
                        children: [
                          SizedBox(
                            height: height * 0.01,
                          ),
                          GroupTile(
                            groupId: group["groupId"],
                            groupName: group["groupName"],
                            domains: group["domains"] ?? [],
                            profilePic: group['profilePic'],
                            category: group['category'],
                            currentUserUid: AuthMethods().getUserId(),
                          ),
                        ],
                      );
                      // Build your group list tile here
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

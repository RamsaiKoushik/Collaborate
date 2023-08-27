import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collaborate/resources/auth_methods.dart';
import 'package:collaborate/screens/group_tile.dart';
import 'package:collaborate/utils/color_utils.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  late Stream<List<QueryDocumentSnapshot>> _filteredGroupsStream;

  @override
  void initState() {
    super.initState();
    _filteredGroupsStream = FirebaseFirestore.instance
        .collection('groups')
        .doc('collaborate')
        .collection('groups')
        .snapshots()
        .map((snapshot) => snapshot.docs);
  }

  void _performSearch(String searchTerm) {
    if (searchTerm.isNotEmpty) {
      setState(() {
        _filteredGroupsStream = FirebaseFirestore.instance
            .collection('groups')
            .doc('collaborate')
            .collection('groups')
            .where('groupName', isGreaterThanOrEqualTo: searchTerm)
            .snapshots()
            .map((snapshot) => snapshot.docs);
      });
    } else {
      setState(() {
        _filteredGroupsStream = FirebaseFirestore.instance
            .collection('groups')
            .doc('collaborate')
            .collection('groups')
            .snapshots()
            .map((snapshot) => snapshot.docs);
      });
    }
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
                  _performSearch(value);
                },
              ),
            ),
            Expanded(
              child: StreamBuilder<List<QueryDocumentSnapshot>>(
                stream: _filteredGroupsStream,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  final groups = snapshot.data!;
                  return ListView.builder(
                    itemCount: groups.length,
                    itemBuilder: (context, index) {
                      final group = groups[index];

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

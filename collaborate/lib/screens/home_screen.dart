import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collaborate/resources/auth_methods.dart';
import 'package:collaborate/screens/filter_parameters.dart';
import 'package:collaborate/screens/group_creation_screen.dart';
import 'package:collaborate/screens/group_list.dart';
import 'package:collaborate/screens/group_tile.dart';
import 'package:collaborate/screens/user_profile.dart';
import 'package:collaborate/utils/color_utils.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'multislect.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String selectedFeature = 'Collaborate'; // Initially selected feature
  List categoryFilter = [];

  List domainFilter = [];

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: collaborateAppBarBgColor,
        title: Row(
          children: [
            DropdownButton<String>(
              value: selectedFeature,
              underline: Container(),
              dropdownColor: color2,
              borderRadius: BorderRadius.circular(10.0),
              focusColor: color2,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    selectedFeature = newValue;
                  });
                }
              },
              items: <String>['Collaborate', 'Feature 2', 'Feature 3']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: GoogleFonts.raleway(
                        color: value == selectedFeature ? color4 : Colors.black,
                        fontWeight: value == selectedFeature
                            ? FontWeight.bold
                            : FontWeight.normal,
                        fontSize: 24),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Handle search icon click
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Handle notification icon click
            },
          ),
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>
                      ProfileScreen(uid: AuthMethods().getUserId()),
                ),
              );
              // ProfileScreen(uid: AuthMethods().getUserId());
              // Handle profile icon click
            },
          ),
        ],
      ),
      body: DefaultTabController(
          length: 2,
          child: Column(
            children: [
              Container(
                color: collaborateAppBarBgColor,
                child: Column(
                  children: [
                    SizedBox(
                      height: height * 0.01,
                    ),
                    TabBar(
                      indicatorColor: color4,
                      labelStyle: GoogleFonts.raleway(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: color4,
                          textBaseline: TextBaseline.ideographic),
                      unselectedLabelStyle: GoogleFonts.raleway(
                          fontWeight: FontWeight.w400,
                          fontSize: 18,
                          color: color4),
                      tabs: const [
                        Tab(text: 'My Teams'),
                        Tab(text: 'Search Teams'),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                        child: Scaffold(
                      body: GroupListingPage(
                        filterParameters: FilterParameters(
                            category: [], domains: [], isMember: true),
                      ),
                      floatingActionButton: FloatingActionButton(
                        backgroundColor: collaborateAppBarBgColor,
                        elevation: 5,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => GroupCreationScreen()),
                          );
                        },
                        child: Icon(Icons.add),
                      ),
                    )),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Scaffold(
                      body: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('groups')
                            .doc('collaborate')
                            .collection('groups')
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          final groups = snapshot.data!.docs;
                          FilterParameters filterParameters = FilterParameters(
                              category: categoryFilter,
                              domains: domainFilter,
                              isMember: false);

                          final filteredGroups = groups.where((group) {
                            final categoryMatches =
                                filterParameters.category.isEmpty ||
                                    filterParameters.category.any((element) {
                                      return (group['category'] == element);
                                    });
                            final domainsMatch =
                                filterParameters.domains.isEmpty ||
                                    filterParameters.domains.every((domain) {
                                      return (group['domains'] as List)
                                          .contains(domain);
                                    });
                            final isMemberMatch = filterParameters.isMember ==
                                    null ||
                                (filterParameters.isMember! &&
                                    group['groupMembers']
                                        .contains(AuthMethods().getUserId())) ||
                                (!filterParameters.isMember! &&
                                    !group['groupMembers']
                                        .contains(AuthMethods().getUserId()));

                            return categoryMatches &&
                                domainsMatch &&
                                isMemberMatch;
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
                            },
                          );
                        },
                      ),
                      bottomNavigationBar: Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          Container(
                            height: height * 0.08,
                            decoration: const BoxDecoration(
                                // shape: BoxShape.rectangle,
                                color: collaborateAppBarBgColor,
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(25),
                                    topRight: Radius.circular(25))),
                          ),
                          Positioned(
                            left: width * 0.17,
                            bottom: 0,
                            child: GestureDetector(
                              onTap: () {
                                // _showSortDialog();
                              },
                              child: Container(
                                // color: Colors.transparent,
                                padding: const EdgeInsets.all(16),
                                child: Icon(
                                  Icons.sort,
                                  color: color4,
                                  size: height * 0.035,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            right: width * 0.17,
                            bottom: 0,
                            child: GestureDetector(
                              onTap: () {
                                _showFirstDialog(context);
                                // _showMultiSelect([])
                                // _showSortDialog();
                              },
                              child: Container(
                                padding: EdgeInsets.all(16),
                                child: Icon(
                                  Icons.filter_alt,
                                  color: color4,
                                  size: height * 0.035,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ] // },
                    ),
              ),
            ],
          )
          // ],
          ),
      // ),
    );
  }

  void _showFirstDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: collaborateAppBarBgColor,
          title: Text(
            'Choose an option you want to filter on',
            style: GoogleFonts.raleway(color: color4),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  textStyle: GoogleFonts.raleway(color: color4),
                  backgroundColor: color2,
                ),
                onPressed: () {
                  Navigator.pop(context); // Close first dialog
                  _showSecondDialog(context, 'Category');
                },
                child: Text(
                  'Category',
                  style: GoogleFonts.raleway(color: color4),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  textStyle: GoogleFonts.raleway(color: color4),
                  backgroundColor: color2,
                ),
                onPressed: () {
                  Navigator.pop(context); // Close first dialog
                  _showSecondDialog(context, 'Domains');
                },
                child: Text(
                  'Domain',
                  style: GoogleFonts.raleway(color: color4),
                ),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: blackColor,
                  ),
                  onPressed: () {
                    Navigator.pop(context); // Close first dialog
                  },
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.raleway(color: color4),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  List<String> items(String options) {
    List<String> list = [];
    switch (options) {
      case 'Category':
        list = [
          'Group Study',
          'Project Elective',
          'Reading Elective',
          'Hackathon',
          'Personal Project'
        ];
      case 'Domains':
        list = [
          'Web Dev',
          'App Dev',
          'Machine Learning',
          'DevOps',
          'BlockCchain',
          'CyberSecurity'
        ];
    }
    return list;
  }

  void _showSecondDialog(BuildContext context, String option) async {
    final List<String>? results = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return MultiSelect(items: items(option));
      },
    );

    // Update UI
    if (results != null) {
      switch (option) {
        case 'Category':
          setState(() {
            categoryFilter = results;
          });
        case 'Domains':
          setState(() {
            domainFilter = results;
          });
      }
    }
  }
}

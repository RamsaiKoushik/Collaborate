import 'package:collaborate/models/user.dart';
import 'package:collaborate/backend/auth_methods.dart';
import 'package:collaborate/filter_parameters.dart';
import 'package:collaborate/screens/display_users.dart';
import 'package:collaborate/screens/groups/group_creation_screen.dart';
import 'package:collaborate/screens/notifications.dart';
import 'package:collaborate/widgets/group_list.dart';
import 'package:collaborate/screens/search_groups.dart';
import 'package:collaborate/screens/user/user_info.dart';
import 'package:collaborate/utils/color_utils.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/multislect.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

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
        title: Text('Collaborate',
            style: GoogleFonts.raleway(
                color: color4,
                fontWeight: FontWeight.bold,
                fontSize: width * 0.07)),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SearchGroup(),
                ),
              );
              // Handle search icon click
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () async {
              User user = await AuthMethods().getUserDetails();
              List userSkills = user.experienceSkills + user.learnSkills;
              List<String> userSkillinStrings =
                  userSkills.map((item) => item.toString()).toList();
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => NotificationsScreen(
                  currentUserId: user.uid,
                  currentUserDomains: userSkillinStrings,
                ),
              ));
            },
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>
                      ProfileScreen(uid: AuthMethods().getUserId()),
                ),
              );
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
                        Tab(
                            text:
                                'My Teams'), //consisits of all the teams that user is part in
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
                                builder: (context) =>
                                    const GroupCreationScreen()),
                          );
                        },
                        child: const Icon(Icons.add),
                      ),
                    )),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Scaffold(
                      body: GroupListingPage(
                        filterParameters: FilterParameters(
                            category: categoryFilter,
                            domains: domainFilter,
                            isMember: false),
                      ),
                      bottomNavigationBar: Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          Container(
                            height: height * 0.08,
                            decoration: const BoxDecoration(
                                color: collaborateAppBarBgColor,
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(25),
                                    topRight: Radius.circular(25))),
                          ),
                          Positioned(
                            right: width * 0.17,
                            bottom: 5,
                            child: Column(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    _showFirstDialog(context);
                                  },
                                  child: Container(
                                    child: Icon(
                                      Icons.filter_alt,
                                      color: color4,
                                      size: height * 0.035,
                                    ),
                                  ),
                                ),
                                Text(
                                  'filter groups',
                                  style: GoogleFonts.raleway(
                                      color: color4,
                                      fontSize: width * 0.04,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            left: width * 0.17,
                            bottom: 5,
                            child: Column(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const UserListingPge(
                                                  filter: [],
                                                  title: 'search',
                                                  userName: "",
                                                )));
                                    // _showSortDialog();
                                  },
                                  child: Container(
                                    child: Icon(
                                      Icons.search,
                                      color: color4,
                                      size: height * 0.035,
                                    ),
                                  ),
                                ),
                                Text(
                                  'search users',
                                  style: GoogleFonts.raleway(
                                      color: color4,
                                      fontSize: width * 0.04,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
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

  //when user clicks on filter, he will be given two choices(firstDialog), based on which he wants to filter,the second dialog gives the list of items he can choose to filter
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

//using items based on need
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
    final List? results = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return MultiSelect(
            items: items(option),
            selectedItems:
                option == 'Category' ? categoryFilter : domainFilter);
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

import 'package:collaborate/resources/auth_methods.dart';
import 'package:collaborate/screens/group_creation_screen.dart';
import 'package:collaborate/screens/user_profile.dart';
import 'package:collaborate/utils/color_utils.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String selectedFeature = 'Collaborate'; // Initially selected feature

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

              // items: <String>['Collaborate', 'Sports', 'Car Pooling']
              //     .map<DropdownMenuItem<String>>((String value) {
              //   return DropdownMenuItem<String>(
              //     value: value,
              //     child: Text(
              //       value,
              //       style: GoogleFonts.raleway(
              //           fontWeight: FontWeight.bold,
              //           fontSize: 25,
              //           color: color4),
              //     ),
              //   );
              // }).toList(),
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
                      Tab(text: 'My Chats'),
                      Tab(text: 'Search Groups'),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  Center(
                      child: Scaffold(
                    floatingActionButton: FloatingActionButton(
                      backgroundColor: collaborateAppBarBgColor,
                      elevation: 5,

                      // onPressed: () => {},
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
                  Center(child: Text('Search Groups Tab')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

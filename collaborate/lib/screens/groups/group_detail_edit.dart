import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collaborate/backend/storage_methods.dart';
import 'package:collaborate/widgets/member_selection.dart';
import 'package:collaborate/widgets/multislect.dart';
import 'package:flutter/material.dart';
import 'package:collaborate/backend/firestore_methods.dart';
import 'package:collaborate/utils/color_utils.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:collaborate/utils/image_picker.dart';

class GroupEditScreen extends StatefulWidget {
  final String groupId;

  const GroupEditScreen({super.key, required this.groupId});

  @override
  _GroupEditScreenState createState() => _GroupEditScreenState();
}

class _GroupEditScreenState extends State<GroupEditScreen> {
  final FireStoreMethods _firestoreMethods = FireStoreMethods();
  Map<String, dynamic>? groupDetails;

  String selectedCategory = 'Select a Category'; // Store the selected category
  List skillsList = []; // Store user input skills
  bool isHidden = false; // Store the hide status
  String description = ''; // Store user input description
  String profilePicUrl = '';
  String groupName = ''; // Store the selected profile pic URL
  late Uint8List _image;
  List domains = [];
  bool isPicked = false;
  List groupMembers = [];
  List addedMembers = [];

  TextEditingController groupNameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController skillController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchGroupDetails();
  }

  // Fetch group details from Firestore
  void fetchGroupDetails() async {
    groupDetails = await _firestoreMethods.getGroupDetails(widget.groupId);

    if (groupDetails != null) {
      setState(() {
        groupNameController.text = groupDetails!['groupName'];
        descriptionController.text = groupDetails!['description'];
        isHidden = groupDetails!['isHidden'];
        skillsList = groupDetails!['skillsList'];
        profilePicUrl = groupDetails!['profilePic'];
        domains = groupDetails!['domains'];
        selectedCategory = groupDetails!['category'];
        groupMembers = groupDetails!['groupMembers'];
        // Initialize other controllers and variables if needed
      });
    }
  }

  // Update group details in Firestore
  void updateGroupDetails() async {
    if (isPicked) {
      profilePicUrl = await StorageMethods().uploadImageToStorage(
          'groups', _image, true, false, groupDetails!["groupId"]);
    }
    if (groupDetails != null) {
      Map<String, dynamic> updatedData = {
        'groupName': groupNameController.text,
        'description': descriptionController.text,
        'category': selectedCategory,
        'skillsList': skillsList,
        'isHidden': isHidden,
        'profilePic': profilePicUrl,
        'domains': domains,
        'groupMembers': groupMembers
        // Update other fields if needed
      };
      await _firestoreMethods.updateGroupDetails(widget.groupId, updatedData);
      // Navigate back to the group detail screen or any other screen
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Align(
          alignment: Alignment.center,
          child: Text(
            'Edit Team',
            style: GoogleFonts.raleway(
                fontWeight: FontWeight.bold, fontSize: 24, color: color4),
          ),
        ),
        elevation: 5,
        backgroundColor: collaborateAppBarBgColor,
      ),
      body: Container(
        color: collaborateAppBarBgColor,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            child: Column(
              // Main column for arranging content
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Widgets for displaying different UI elements
                SizedBox(height: height * 0.06),
                Align(
                  alignment: Alignment.center,
                  child: Stack(
                    children: [
                      isPicked == false
                          ? CircleAvatar(
                              radius: 64,
                              backgroundImage: NetworkImage(profilePicUrl),
                              backgroundColor: color3,
                            )
                          : CircleAvatar(
                              radius: 64,
                              backgroundImage: MemoryImage(_image),
                              backgroundColor: color3),
                      Positioned(
                        bottom: -10,
                        left: 80,
                        child: IconButton(
                          onPressed: selectImage,
                          icon: const Icon(Icons.add_a_photo),
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(height: height * 0.05),
                Center(
                  child: GestureDetector(
                    onTap: _showMemberSelectionDialog,
                    child: Container(
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(200)),
                        color: color2,
                      ),
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Add members',
                        style: GoogleFonts.raleway(
                            color: color4,
                            fontSize: width * 0.05,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: groupNameController,
                    style: GoogleFonts.raleway(
                      color: color4,
                    ),
                    maxLines: null,
                    maxLength: 25,
                    decoration: InputDecoration(
                        labelText: 'Team Name',
                        labelStyle:
                            GoogleFonts.raleway(color: color4, fontSize: 18)),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: DropdownButton<String>(
                    dropdownColor: color2,
                    value: selectedCategory,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedCategory = newValue!;
                      });
                    },
                    underline: Container(),
                    isExpanded: true,
                    items: <String>[
                      'Select a Category',
                      'Group Study',
                      'Project Elective',
                      'Personal Project',
                      'Hackathon',
                      'Reading Elective'
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: GoogleFonts.raleway(
                              color: value == selectedCategory
                                  ? color4
                                  : Colors.black,
                              fontWeight: value == selectedCategory
                                  ? FontWeight.w400
                                  : FontWeight.normal,
                              fontSize: 18), // Adjust text color
                        ),
                      );
                    }).toList(),
                  ),
                ),
                SizedBox(
                  height: height * 0.01,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ElevatedButton(
                            onPressed: () {
                              _showMultiSelect([
                                'Web Dev',
                                'App Dev',
                                'Machine Learning',
                                'DevOps',
                                'BlockCchain',
                                'CyberSecurity'
                              ]);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: collaborateAppBarBgColor,
                              elevation: 0,
                            ),
                            child: Align(
                              alignment: Alignment.center,
                              child: Text(
                                'Tap to Choose the domains',
                                style: GoogleFonts.raleway(
                                    color: color4,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w400),
                              ),
                            )),
                        Wrap(
                          children: domains
                              .map((e) => Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Chip(
                                      label: Text(e),
                                      backgroundColor: color3,
                                    ),
                                  ))
                              .toList(),
                        )
                      ]),
                ),

                // Skillset Input
                Column(
                  children: [
                    Row(
                      children: [
                        SizedBox(width: width * 0.04),
                        Expanded(
                          child: TextField(
                            style: const TextStyle(color: color4),
                            controller: skillController,
                            decoration: InputDecoration(
                                labelText: 'Frameworks/Libraries',
                                labelStyle: GoogleFonts.raleway(
                                    color: color4, fontSize: 18)),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add, color: color4),
                          onPressed: addSkill,
                        ),
                      ],
                    ),
                    for (int i = 0; i < skillsList.length; i++)
                      Row(
                        children: [
                          SizedBox(width: width * 0.1),
                          Expanded(
                            child: Text(skillsList[i],
                                style: GoogleFonts.raleway(
                                    color: color4,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w400)),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: color4),
                            onPressed: () => removeSkill(i),
                          ),
                          SizedBox(width: width * 0.1),
                        ],
                      ),
                  ],
                ),

                SizedBox(height: height * 0.06),
                // isHide Toggle
                ListTile(
                  title: Text('Do you wanna make the team private?',
                      style: GoogleFonts.raleway(
                          color: color4,
                          fontSize: 18,
                          fontWeight: FontWeight.w400)),
                  trailing: Switch(
                    value: isHidden,
                    onChanged: (value) {
                      setState(() {
                        isHidden = value;
                      });
                    },
                  ),
                ),

                SizedBox(
                  height: height * 0.06,
                ),
                // Description Input
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: descriptionController,
                    style: GoogleFonts.raleway(
                      color: color4,
                    ),
                    onChanged: (value) {
                      setState(() {
                        description = value;
                      });
                    },
                    maxLines: null,
                    maxLength: 500,
                    decoration: InputDecoration(
                        labelText: 'Description',
                        labelStyle:
                            GoogleFonts.raleway(color: color4, fontSize: 18)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Text(
                        'Members of the team',
                        style: GoogleFonts.raleway(
                            color: color4,
                            fontWeight: FontWeight.w500,
                            fontSize: 18),
                      ),
                      SizedBox(height: height * 0.02),
                      for (int i = 0; i < groupMembers.length; i++)
                        Row(
                          children: [
                            SizedBox(width: width * 0.1),
                            Expanded(
                              child: FutureBuilder<String>(
                                future: FireStoreMethods()
                                    .getUsernameForUserId(groupMembers[i]),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const CircularProgressIndicator();
                                  } else if (snapshot.hasError) {
                                    return Text('Error: ${snapshot.error}');
                                  } else if (snapshot.hasData) {
                                    final username = snapshot.data!;
                                    return Text(username,
                                        style: GoogleFonts.raleway(
                                            color: color4,
                                            fontSize: width * 0.06,
                                            fontWeight: FontWeight.bold));
                                  } else {
                                    return const Text('No data');
                                  }
                                },
                              ),
                            ),
                            if (groupMembers[i] != groupDetails!['uid'])
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => removeMember(i),
                              ),
                            SizedBox(width: width * 0.1),
                          ],
                        ),
                    ],
                  ),
                ),
                SizedBox(
                  height: height * 0.08,
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      style:
                          ElevatedButton.styleFrom(backgroundColor: blackColor),
                      onPressed: () {
                        Navigator.pop(context); // Cancel button
                      },
                      child: Text('Cancel',
                          style: GoogleFonts.raleway(
                              color: color4,
                              fontWeight: FontWeight.w400,
                              fontSize: 18)),
                    ),
                    SizedBox(width: width * 0.04),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: orange),
                      onPressed: updateGroupDetails, // Submit button
                      child: Text('Apply',
                          style: GoogleFonts.raleway(
                              color: blackColor,
                              fontWeight: FontWeight.w500,
                              fontSize: 18)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  //this function is used to get all the user details, this function will be used in show memberselectionDialog
  Future<Map<String, String>> _fetchUserNamesFromFirestore() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('users').get();

    Map<String, String> userNames = {};

    for (QueryDocumentSnapshot doc in querySnapshot.docs) {
      String userId = doc.id;
      String userName = doc['username'];

      if (!groupMembers.contains(userId)) {
        userNames[userId] = userName;
      }
    }
    return userNames;
  }

  //it shows all the users and we can select users to add
  Future<void> _showMemberSelectionDialog() async {
    Map<String, String> availableMembers = await _fetchUserNamesFromFirestore();

    final result = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return MemberSelectionDialog(
          availableMembers: availableMembers,
          displayMembers: availableMembers,
        );
      },
    );

    if (result != null) {
      setState(() {
        groupMembers = groupMembers + result;
      });
    }
  }

  // Function to add a skill from the skillsList
  void addSkill() {
    if (skillController.text != '') {
      setState(() {
        skillsList.add(skillController.text);
        skillController.clear();
      });
    }
  }

  // Function to remove a skill from the skillsList
  void removeSkill(int index) {
    setState(() {
      skillsList.removeAt(index);
    });
  }

  // Function to remove a member from the skillsList
  void removeMember(int index) {
    setState(() {
      groupMembers.removeAt(index);
    });
  }

  //select an image from gallery
  selectImage() async {
    Uint8List im = await pickImage(ImageSource.gallery);
    setState(() {
      isPicked = true;
      _image = im;
    });
  }

  //it shows all the skills in a dialog box and we can select from that
  void _showMultiSelect(items) async {
    final List? results = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return MultiSelect(
          items: items,
          selectedItems: domains,
        );
      },
    );

    // Update UI
    if (results != null) {
      setState(() {
        domains = results;
      });
    }
  }
}

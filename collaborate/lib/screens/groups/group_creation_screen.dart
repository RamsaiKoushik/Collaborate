import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collaborate/resources/auth_methods.dart';
import 'package:collaborate/resources/firestore_methods.dart';
import 'package:collaborate/widgets/member_selection.dart';
import 'package:collaborate/widgets/multislect.dart';
import 'package:collaborate/utils/color_utils.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:collaborate/utils/utils.dart';

class GroupCreationScreen extends StatefulWidget {
  const GroupCreationScreen({super.key});

  @override
  _GroupCreationScreenState createState() => _GroupCreationScreenState();
}

class _GroupCreationScreenState extends State<GroupCreationScreen> {
  String selectedCategory = 'Select a Category'; // Store the selected category
  List<String> skillsList = []; // Store user input skills
  bool isHidden = false; // Store the hide status
  String description = ''; // Store user input description
  String profilePicUrl = ''; // Store the selected profile pic URL
  String groupName = '';
  Uint8List? _image;
  List domains = [];
  List _selectedDomains = [];
  List groupMembers = [AuthMethods().getUserId()];

  TextEditingController skillController = TextEditingController();

  TextEditingController groupNameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  // Controller for adding skills

  // Function to add a skill to the skillsList
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

  selectImage() async {
    Uint8List im = await pickImage(ImageSource.gallery);
    // set state because we need to display the image we selected on the circle avatar
    setState(() {
      _image = im;
    });
  }

  void _showMultiSelect(items) async {
    // a list of selectable items
    // these items can be hard-coded or dynamically fetched from a database/API

    final List? results = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return MultiSelect(
          items: items,
          selectedItems: _selectedDomains,
        );
      },
    );

    // Update UI
    if (results != null) {
      setState(() {
        domains = results;
        _selectedDomains = domains;
      });
    }
  }

  // Function to create the group and save details to Firestore
  void createGroup() async {
    _image ??= (await rootBundle.load('assets/defaultProfileIcon.png'))
        .buffer
        .asUint8List();

    final user = FirebaseAuth.instance.currentUser;

    String groupName = groupNameController.text.trim();
    String description = descriptionController.text.trim();
    if (user != null &&
        groupName.isNotEmpty &&
        selectedCategory != 'Select a Category' &&
        description.isNotEmpty) {
      FireStoreMethods().createGroup(
          groupName,
          selectedCategory,
          skillsList,
          isHidden,
          description,
          _image!,
          user.uid,
          user.displayName!,
          domains,
          groupMembers);
      // Navigate back to the home page
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Align(
          alignment: Alignment.center,
          child: Text(
            'Create Team',
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: height * 0.06),
                Align(
                  alignment: Alignment.center,
                  child: Stack(
                    children: [
                      _image != null
                          ? CircleAvatar(
                              radius: 64,
                              backgroundImage: MemoryImage(_image!),
                              backgroundColor: color3,
                            )
                          : const CircleAvatar(
                              radius: 64,
                              backgroundImage: NetworkImage(
                                  'https://i.stack.imgur.com/l60Hf.png'),
                              backgroundColor: color3,
                            ),
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

                SizedBox(height: height * 0.06),

                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: groupNameController,
                    style: GoogleFonts.raleway(
                      color: color4,
                    ),
                    onChanged: (value) {
                      setState(() {
                        groupName = value;
                      });
                    },
                    maxLines: null,
                    maxLength: 50,
                    decoration: InputDecoration(
                        labelText: 'Team Name',
                        labelStyle:
                            GoogleFonts.raleway(color: color4, fontSize: 18)),
                  ),
                ),

                Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  // decoration: BoxDecoration(
                  //   color: textFieldColor,
                  //   borderRadius: BorderRadius.circular(20),
                  // ),
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
                  height: height * 0.04,
                ),

                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // use this button to open the multi-select dialog
                        ElevatedButton(
                            onPressed: () {
                              _showMultiSelect([
                                'Web Dev',
                                'App Dev',
                                'Machine Learning',
                                'DevOps',
                                'BlockChain',
                                'CyberSecurity'
                              ]);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: collaborateAppBarBgColor,
                              elevation: 0,
                            ),
                            child: Text(
                              'Choose the domains involved',
                              style: GoogleFonts.raleway(
                                  color: color4,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w400),
                            )
                            // const Text('Which areas would you like to explore'),
                            ),

                        Wrap(
                          children: domains
                              .map((e) => Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Chip(
                                      label: Text(
                                        e,
                                        style:
                                            GoogleFonts.raleway(color: color4),
                                      ),
                                      backgroundColor: color2,
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

                const SizedBox(height: 16),

                // Submit and Cancel Buttons
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
                      onPressed: createGroup, // Submit button
                      child: Text('Submit',
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

  void removeMember(int index) {
    setState(() {
      groupMembers.removeAt(index);
    });
  }

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
}

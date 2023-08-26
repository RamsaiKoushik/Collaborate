import 'dart:typed_data';

import 'package:collaborate/resources/firestore_methods.dart';
import 'package:collaborate/utils/color_utils.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth for user authentication
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../resources/storage_methods.dart';
import '../utils/utils.dart'; // Import Firestore for database operations

class GroupCreationScreen extends StatefulWidget {
  @override
  _GroupCreationScreenState createState() => _GroupCreationScreenState();
}

class _GroupCreationScreenState extends State<GroupCreationScreen> {
  String selectedCategory = 'Select a Category'; // Store the selected category
  List<String> skillsList = []; // Store user input skills
  bool isHidden = false; // Store the hide status
  String description = ''; // Store user input description
  String profilePicUrl = ''; // Store the selected profile pic URL
  Uint8List? _image;

  TextEditingController skillController = TextEditingController();

  TextEditingController groupNameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  // Controller for adding skills

  // Function to add a skill to the skillsList
  void addSkill() {
    setState(() {
      skillsList.add(skillController.text);
      skillController.clear();
    });
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
      FireStoreMethods().createGroup(groupName, selectedCategory, skillsList,
          isHidden, description, _image!, user.uid, user.displayName!);
      // Create a document in Firestore for the new group
      // await FirebaseFirestore.instance.collection('groups').add({
      //   'category': selectedCategory,
      //   'skills': skillsList,
      //   'isHidden': isHidden,
      //   'description': description,
      //   'profilePicUrl': profilePicUrl,
      //   'createdBy': user.uid,
      // });

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
          padding: EdgeInsets.all(16.0),
          child: Container(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                        description = value;
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
                  padding: EdgeInsets.symmetric(horizontal: 16),
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
                  height: height * 0.06,
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
                    maxLength: 200,
                    decoration: InputDecoration(
                        labelText: 'Description',
                        labelStyle:
                            GoogleFonts.raleway(color: color4, fontSize: 18)),
                  ),
                ),

                SizedBox(height: 16),

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
                              fontWeight: FontWeight.w400,
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
}

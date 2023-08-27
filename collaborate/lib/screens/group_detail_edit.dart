import 'package:collaborate/resources/storage_methods.dart';
import 'package:collaborate/screens/multislect.dart';
import 'package:flutter/material.dart';
import 'package:collaborate/resources/firestore_methods.dart';
import 'package:collaborate/utils/color_utils.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../utils/utils.dart';

class GroupEditScreen extends StatefulWidget {
  final String groupId;

  const GroupEditScreen({required this.groupId});

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
  String profilePicUrl = ''; // Store the selected profile pic URL
  late Uint8List _image;
  List domains = [];
  bool isPicked = false;

  TextEditingController groupNameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController skillController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchGroupDetails();
  }

  void fetchGroupDetails() async {
    groupDetails = await _firestoreMethods.getGroupDetails(widget.groupId);

    if (groupDetails != null) {
      setState(() {
        groupNameController.text = groupDetails!['groupName'];
        descriptionController.text = groupDetails!['description'];
        isHidden = groupDetails!["isHidden"];
        skillsList = groupDetails!["skillsList"];
        profilePicUrl = groupDetails!["profilePic"];
        domains = groupDetails!["domains"];
        // Initialize other controllers and variables if needed
      });
    }
  }

  void updateGroupDetails() async {
    if (groupDetails != null) {
      Map<String, dynamic> updatedData = {
        'groupName': groupNameController.text,
        'description': descriptionController.text,
        // Update other fields if needed
      };
      await _firestoreMethods.updateGroupDetails(widget.groupId, updatedData);
      // Navigate back to the group detail screen or any other screen
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Build your UI here using the fetched group details
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
              ],
            ),
          ),
        ),
      ),
    );
  }

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
      isPicked = true;
      _image = im;
    });
  }

  void _showMultiSelect(items) async {
    // a list of selectable items
    // these items can be hard-coded or dynamically fetched from a database/API

    final List<String>? results = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return MultiSelect(items: items);
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

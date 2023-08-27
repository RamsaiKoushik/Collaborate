import 'package:collaborate/resources/auth_methods.dart';
import 'package:collaborate/resources/firestore_methods.dart';
import 'package:collaborate/resources/storage_methods.dart';
import 'package:collaborate/screens/multislect.dart';
import 'package:collaborate/utils/color_utils.dart';
import 'package:collaborate/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class EditUserProfile extends StatefulWidget {
  const EditUserProfile({super.key});

  @override
  _EditUserProfileState createState() => _EditUserProfileState();
}

class _EditUserProfileState extends State<EditUserProfile> {
  Map<String, dynamic>? userDetails;
  final TextEditingController _aboutController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _rollNumberController = TextEditingController();
  String profilePic = "";
  List _learnSkills = [];
  List _selectedLearnSkills = [];
  List _experienceSkills = [];
  List _selectedExperienceSkills = [];

  final FireStoreMethods _firestoreMethods = FireStoreMethods();

  @override
  void initState() {
    super.initState();
    fetchUserDetails();
  }

  Uint8List? _image;

  selectImage() async {
    Uint8List im = await pickImage(ImageSource.gallery);
    setState(() {
      _image = im;
    });
  }

  void _cancel() {
    Navigator.pop(context);
  }

  void fetchUserDetails() async {
    userDetails =
        await _firestoreMethods.getUserDetails(AuthMethods().getUserId());

    if (userDetails != null) {
      setState(() {
        _userNameController.text = userDetails!['username'];
        _aboutController.text = userDetails!['about'];
        _rollNumberController.text = userDetails!['rollNumber'];
        _learnSkills = userDetails!['learnSkills'];
        _experienceSkills = userDetails!['experienceSkills'];
        profilePic = userDetails!['profilePic'];
        _selectedLearnSkills = _learnSkills;
        _selectedExperienceSkills = _experienceSkills;
      });
    }
  }

  void updateUserDetails() async {
    if (_image != null) {
      profilePic = await StorageMethods()
          .uploadImageToStorage('groups', _image!, false, false, "");
    }

    if (userDetails != null &&
        _userNameController.text.trim() != '' &&
        (_rollNumberController.text.trim().length == 10 ||
            _rollNumberController.text.trim().length == 10) &&
        _aboutController.text.trim() != '') {
      Map<String, dynamic> updatedData = {
        'username': _userNameController.text,
        'about': _aboutController.text,
        'rollNumber': _rollNumberController.text,
        'learnSkills': _learnSkills,
        'experienceSkills': _experienceSkills,
        'profilePic': profilePic,
      };
      await _firestoreMethods.updateUserDetails(
          AuthMethods().getUserId(), updatedData);

      Navigator.pop(context);
    }
  }

  void _showMultiSelectLearn(items) async {
    final List? results = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return MultiSelect(
          items: items,
          selectedItems: _selectedLearnSkills,
        );
      },
    );

    // Update UI
    if (results != null) {
      setState(() {
        _learnSkills = results;
        _selectedLearnSkills = _learnSkills;
      });
    }
  }

  void _showMultiSelectExperience(items) async {
    final List? results = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return MultiSelect(
          items: items,
          selectedItems: _selectedExperienceSkills,
        );
      },
    );

    // Update UI
    if (results != null) {
      setState(() {
        _experienceSkills = results;
        _selectedExperienceSkills = results;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width; // Screen width
    final height = MediaQuery.of(context).size.height; // Screen height

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Container(
          color: collaborateAppBarBgColor,
          padding: const EdgeInsets.symmetric(horizontal: 32),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: height * 0.1),
              Text('Collaborate',
                  style: GoogleFonts.raleway(
                    fontSize: width * 0.14,
                    color: collaborateAppBarTextColor,
                    fontWeight: FontWeight.w500,
                  )),
              SizedBox(
                height: height * 0.05,
              ),
              Stack(
                children: [
                  _image != null
                      ? CircleAvatar(
                          radius: 64,
                          backgroundImage: MemoryImage(_image!),
                          backgroundColor: color3,
                        )
                      : CircleAvatar(
                          radius: 64,
                          backgroundImage: NetworkImage(profilePic),
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
              SizedBox(height: height * 0.03),
              TextField(
                controller: _userNameController,
                autocorrect: true,
                cursorColor: color4,
                style: TextStyle(color: Colors.white.withOpacity(0.9)),
                decoration: InputDecoration(
                  prefixIcon: const Icon(
                    Icons.person_2_outlined,
                    color: Colors.white70,
                  ),
                  labelText: 'Your username',
                  labelStyle: const TextStyle(color: color4),
                  filled: true,
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                  fillColor: Colors.white.withOpacity(0.3),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide:
                          const BorderSide(width: 0, style: BorderStyle.none)),
                ),
                keyboardType: TextInputType.text,
              ),
              SizedBox(
                height: height * 0.025,
              ),
              TextField(
                controller: _rollNumberController,
                autocorrect: true,
                cursorColor: color4,
                style: const TextStyle(color: color4),
                decoration: InputDecoration(
                  prefixIcon: const Icon(
                    Icons.numbers_outlined,
                    color: Colors.white70,
                  ),
                  labelText: 'Roll Number',
                  labelStyle: const TextStyle(color: color4),
                  filled: true,
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                  fillColor: Colors.white.withOpacity(0.3),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide:
                          const BorderSide(width: 0, style: BorderStyle.none)),
                ),
                keyboardType: TextInputType.text,
              ),
              SizedBox(
                height: height * 0.025,
              ),
              TextField(
                controller: _aboutController,
                autocorrect: true,
                cursorColor: color4,
                style: const TextStyle(color: color4),
                decoration: InputDecoration(
                  prefixIcon: const Icon(
                    Icons.person_2_outlined,
                    color: Colors.white70,
                  ),
                  labelText: 'about you',
                  labelStyle: const TextStyle(color: color4),
                  filled: true,
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                  fillColor: Colors.white.withOpacity(0.3),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide:
                          const BorderSide(width: 0, style: BorderStyle.none)),
                ),
                maxLength: 500,
                maxLines: null,
                keyboardType: TextInputType.text,
              ),
              SizedBox(
                height: height * 0.075,
              ),
              Text(
                'Which areas are you interested to explore?',
                style: TextStyle(color: color4, fontSize: width * 0.06),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // use this button to open the multi-select dialog
                      ElevatedButton(
                          onPressed: () => {
                                _showMultiSelectLearn([
                                  'Web Dev',
                                  'App Dev',
                                  'Machine Learning',
                                  'DevOps',
                                  'BlockChain',
                                  'CyberSecurity'
                                ])
                              },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white
                                .withOpacity(0.3), // Set the background color
                            foregroundColor: Colors.white, // Set the text color
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  30.0), // Set border radius
                            ),
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 10), // Set padding
                            textStyle: const TextStyle(fontSize: 16),
                          ),
                          child: const Text('choose')
                          // const Text('Which areas would you like to explore'),
                          ),

                      Wrap(
                        children: _learnSkills
                            .map((e) => Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Chip(
                                    label: Text(e),
                                    backgroundColor: checkBoxColor,
                                  ),
                                ))
                            .toList(),
                      )
                    ]),
              ),
              Text(
                'Which domains do you have experience?',
                style: TextStyle(color: color4, fontSize: width * 0.06),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // use this button to open the multi-select dialog
                      ElevatedButton(
                          onPressed: () => {
                                _showMultiSelectExperience([
                                  'Web Dev',
                                  'App Dev',
                                  'Machine Learning',
                                  'DevOps',
                                  'BlockChain',
                                  'CyberSecurity'
                                ])
                              },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white
                                .withOpacity(0.3), // Set the background color
                            foregroundColor: Colors.white, // Set the text color
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  30.0), // Set border radius
                            ),
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 10), // Set padding
                            textStyle: const TextStyle(fontSize: 16),
                          ),
                          child: const Text('choose')
                          // const Text('Which areas would you like to explore'),
                          ),

                      Wrap(
                        children: _experienceSkills
                            .map((e) => Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Chip(
                                    label: Text(e),
                                    backgroundColor: checkBoxColor,
                                  ),
                                ))
                            .toList(),
                      )
                    ]),
              ),
              SizedBox(
                height: height * 0.05,
              ),
              Row(
                children: [
                  InkWell(
                    onTap: _cancel,
                    child: Container(
                        height: height * 0.060,
                        width: width * 0.25,
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: const ShapeDecoration(
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(30.0)),
                          ),
                          color: Colors.black,
                        ),
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.ptSans(
                              fontWeight: FontWeight.bold, color: color4),
                        )),
                  ),
                  SizedBox(
                    width: width * 0.3,
                  ),
                  InkWell(
                    onTap: updateUserDetails,
                    child: Container(
                        height: height * 0.060,
                        width: width * 0.25,
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: const ShapeDecoration(
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(30.0)),
                          ),
                          color: Colors.black,
                        ),
                        child: Text(
                          'Apply',
                          style: GoogleFonts.ptSans(
                              fontWeight: FontWeight.bold, color: color4),
                        )),
                  ),
                ],
              ),
              SizedBox(
                height: height * 0.025,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

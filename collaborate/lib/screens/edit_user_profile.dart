import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collaborate/providers/user_provider.dart';
import 'package:collaborate/utils/color_utils.dart';
import 'package:collaborate/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:collaborate/models/user.dart' as model;
import 'package:collaborate/widgets/text_field.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class EditUserProfile extends StatefulWidget {
  const EditUserProfile({super.key});

  @override
  _EditUserProfileState createState() => _EditUserProfileState();
}

class _EditUserProfileState extends State<EditUserProfile> {
  final TextEditingController aboutController = TextEditingController();
  final TextEditingController rollNumberController = TextEditingController();
  var userPhotoUrl;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Uint8List? _image;

  selectImage() async {
    Uint8List im = await pickImage(ImageSource.gallery);
    // set state because we need to display the image we selected on the circle avatar
    setState(() {
      _image = im;
    });
  }

  void _cancel() {
    Navigator.pop(context);
  }

  void _submit(TextEditingController aboutController,
      TextEditingController rollNumberController) {
    var updatedAbout = aboutController.text.trim();
    var updatedRollNumber = rollNumberController.text.trim();

    if (updatedAbout != '' &&
        (updatedRollNumber.length == 10 || updatedRollNumber == 11)) {
      updateUser(updatedAbout, updatedRollNumber);
    } else {
      showSnackBar(context, 'invalid update');
      return;
    }
    Navigator.pop(context);
  }

  void updateUser(String about, String rollNumber) async {
    User user = FirebaseAuth.instance.currentUser!;

    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    model.User modelUser = model.User.fromSnap(documentSnapshot);

    model.User updatedUser = model.User(
        username: modelUser.username,
        uid: modelUser.uid,
        photoUrl: modelUser.photoUrl,
        email: modelUser.email,
        rollNumber: rollNumber,
        about: about,
        followers: modelUser.followers,
        following: modelUser.following,
        learnSkills: modelUser.learnSkills);

    await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .set(updatedUser.toJson());
  }

  Future<void> _loadUserData() async {
    setState(() {
      isLoading = true;
    });

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.refreshUser(); // Refresh user data from the provider

    setState(() {
      aboutController.text = userProvider.getUser.about;
      rollNumberController.text = userProvider.getUser.rollNumber;
      userPhotoUrl = userProvider.getUser.photoUrl;
      isLoading = false;
    });
  }
  // User user = UserPreferences.myUser;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: collaborateAppBarBgColor,
      // appBar: buildAppBar(context),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              physics: const BouncingScrollPhysics(),
              children: [
                SizedBox(
                  height: height * 0.2,
                ),
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
                          : CircleAvatar(
                              radius: 64,
                              backgroundImage: NetworkImage(userPhotoUrl),
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
                const SizedBox(height: 24),
                CustomTextField(
                  controller: aboutController,
                  label: 'about',
                  text: aboutController.text,
                  prefixIcon: const Icon(
                    Icons.person_2_outlined,
                    color: Colors.white70,
                  ),
                  maxLines: 10,
                ),
                const SizedBox(height: 24),
                CustomTextField(
                  controller: rollNumberController,
                  label: 'Roll Number',
                  text: rollNumberController.text,
                  prefixIcon: const Icon(
                    Icons.numbers_outlined,
                    color: Colors.white70,
                  ),
                ),
                SizedBox(
                  height: height * 0.05,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                        onPressed: _cancel,
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.black,
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(color: color4),
                        )),
                    SizedBox(width: width * 0.1),
                    ElevatedButton(
                      onPressed: () =>
                          {_submit(aboutController, rollNumberController)},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: checkBoxColor,
                      ),
                      child: const Text(
                        'Submit',
                        style: TextStyle(color: blackColor),
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}

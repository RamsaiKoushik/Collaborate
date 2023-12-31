import 'package:collaborate/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:collaborate/backend/auth_methods.dart';
import 'package:collaborate/screens/auth/login_screen.dart';
import 'package:collaborate/utils/image_picker.dart';
import 'package:collaborate/utils/color_utils.dart';
import 'package:collaborate/widgets/multislect.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _aboutController = TextEditingController();
  final TextEditingController _rollNumberController = TextEditingController();
  bool isObscured = true;
  bool _isLoading = false;
  Uint8List? _image;

  List _learnSkills = [];
  List _selectedlearnSkills = [];
  List _experienceSkills = [];
  List _selectedExperienceSkills = [];

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    _aboutController.dispose();
    _rollNumberController.dispose();
  }

  void signUpUser() async {
    // set loading to true
    setState(() {
      _isLoading = true;
    });

    //if user didn't select image from gallery, uploading a default profile pic
    _image ??= (await rootBundle.load('assets/defaultProfileIcon.png'))
        .buffer
        .asUint8List();

    // signing up the user, by using the AuthMehods class
    String res = await AuthMethods().signUpUser(
        email: _emailController.text,
        password: _passwordController.text,
        username: _usernameController.text,
        rollNumber: _rollNumberController.text.trim(),
        about: _aboutController.text,
        file: _image!,
        learnSkills: _learnSkills,
        experienceSkills: _experienceSkills);
    if (res == "success") {
      setState(() {
        _isLoading = false;
      });
      // navigate to the home screen
      if (context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const HomePage(),
          ),
        );
      }
    } else {
      setState(() {
        _isLoading = false;
      });

      //displays a snackbar if there is any error signing up the user
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: color2,
            content: Text(
              res,
              style: GoogleFonts.raleway(fontSize: 18, color: color1),
            ),
          ),
        );
      }
    }
  }

  //sets the image to the image selected from gallery
  selectImage() async {
    Uint8List im = await pickImage(ImageSource.gallery);
    setState(() {
      _image = im;
    });
  }

  //this shows up a multiselect window which can be used to select the skills(learn) from a set of options
  void _showMultiSelectLearn(items) async {
    final List? results = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return MultiSelect(
          items: items,
          selectedItems: _selectedlearnSkills,
        );
      },
    );

    // Update UI
    if (results != null) {
      setState(() {
        _learnSkills = results;
        _selectedlearnSkills = _learnSkills;
      });
    }
  }

  //this has similar funactionality as the above function, but using a different function to set experience skills
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
      resizeToAvoidBottomInset: true,
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
                    fontSize: width * 0.12,
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
              SizedBox(height: height * 0.03),
              TextField(
                controller: _usernameController,
                autocorrect: true,
                cursorColor: color4,
                maxLength: 18,
                style: const TextStyle(color: color4),
                decoration: InputDecoration(
                  prefixIcon: const Icon(
                    Icons.person_2_outlined,
                    color: color4,
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
                controller: _emailController,
                autocorrect: true,
                cursorColor: color4,
                style: TextStyle(color: color4),
                decoration: InputDecoration(
                  prefixIcon: const Icon(
                    Icons.email_outlined,
                    color: color4,
                  ),
                  labelText: 'Your email',
                  labelStyle: const TextStyle(color: color4),
                  filled: true,
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                  fillColor: Colors.white.withOpacity(0.3),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide:
                          const BorderSide(width: 0, style: BorderStyle.none)),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(
                height: height * 0.025,
              ),
              TextField(
                controller: _passwordController,
                obscureText: isObscured,
                autocorrect: false,
                cursorColor: color4,
                style: const TextStyle(color: color4),
                decoration: InputDecoration(
                  prefixIcon: const Icon(
                    Icons.lock_outline,
                    color: color4,
                  ),
                  suffixIcon: IconButton(
                      icon: Icon(
                        isObscured ? Icons.visibility_off : Icons.visibility,
                        color: color4,
                      ),
                      onPressed: () {
                        setState(() {
                          isObscured = !isObscured;
                        });
                      }),
                  labelText: 'Your password',
                  labelStyle: const TextStyle(color: color4),
                  filled: true,
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                  fillColor: Colors.white.withOpacity(0.3),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide:
                          const BorderSide(width: 0, style: BorderStyle.none)),
                ),
                keyboardType: TextInputType.visiblePassword,
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
                    color: color4,
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
                    color: color4,
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
                maxLines: null,
                maxLength: 500,
                keyboardType: TextInputType.text,
              ),
              SizedBox(
                height: height * 0.075,
              ),
              Text(
                'Which areas are you interested to explore in?',
                style: TextStyle(color: color4, fontSize: width * 0.06),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ElevatedButton(
                          //this button is used to open the multiselect box, from which user can select skills
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
                          child: const Text('choose')),
                      Wrap(
                        children: _learnSkills
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
              Text(
                'Which domains do you have experience?',
                style: TextStyle(color: color4, fontSize: width * 0.06),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ElevatedButton(
                          //this button is used to open the multiselect box, from which user can select skills
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
                          child: const Text('choose')),
                      Wrap(
                        children: _experienceSkills
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
              InkWell(
                onTap: signUpUser,
                child: Container(
                  height: height * 0.065,
                  width: double.infinity,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: const ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(30.0)),
                    ),
                    color: Colors.black,
                  ),
                  child: !_isLoading
                      ? Text(
                          'Sign up',
                          style: GoogleFonts.ptSans(
                              fontWeight: FontWeight.bold, color: color4),
                        )
                      : const CircularProgressIndicator(
                          color: Colors.blue,
                        ),
                ),
              ),
              SizedBox(
                height: height * 0.025,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: const Text(
                      'Already have an account?',
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: const Text(
                        ' Login.',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

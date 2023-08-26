// import 'package:collaborate/reusable_widgets/reusable_widget.dart';
// import 'package:collaborate/screens/home_screen.dart';
import 'package:collaborate/utils/color_utils.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:collaborate/resources/auth_methods.dart';

class ResetPassword extends StatefulWidget {
  const ResetPassword({Key? key}) : super(key: key);

  @override
  _ResetPasswordState createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final TextEditingController _emailTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
        body: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Scaffold(
              backgroundColor: collaborateAppBarBgColor,
              body: Padding(
                padding: const EdgeInsets.fromLTRB(20, 120, 20, 0),
                child: Column(
                  children: [
                    SizedBox(
                      height: height * 0.2,
                    ),
                    Text('Collaborate',
                        style: GoogleFonts.raleway(
                          fontSize: width * 0.14,
                          color: collaborateAppBarTextColor,
                          fontWeight: FontWeight.w500,
                        )),
                    SizedBox(
                      height: height * 0.1,
                    ),
                    TextField(
                      controller: _emailTextController,
                      autocorrect: true,
                      cursorColor: color4,
                      style: TextStyle(color: Colors.white.withOpacity(0.9)),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.email_outlined,
                          color: Colors.white70,
                        ),
                        labelText: 'Your email',
                        labelStyle: const TextStyle(color: color4),
                        filled: true,
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        fillColor: Colors.white.withOpacity(0.3),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide: const BorderSide(
                                width: 0, style: BorderStyle.none)),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    SizedBox(
                      height: height * 0.05,
                    ),
                    InkWell(
                        onTap: () => {
                              AuthMethods()
                                  .resetPassword(
                                      _emailTextController.text.trim())
                                  .then((value) => Navigator.of(context).pop())
                            },
                        child: Container(
                            width: double.infinity,
                            alignment: Alignment.center,
                            height: height * 0.065,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: const ShapeDecoration(
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(30)),
                              ),
                              color: Colors.black,
                            ),
                            child: Text(
                              'Reset Password',
                              style: GoogleFonts.ptSans(
                                fontSize: height * 0.025,
                                color: color4,
                                fontWeight: FontWeight.bold,
                              ),
                            ))),
                  ],
                ),
              ),
            )));
  }
}

import 'package:collaborate/screens/home_screen.dart';
import 'package:collaborate/screens/reset_password.dart';
import 'package:collaborate/utils/color_utils.dart';
import 'package:flutter/material.dart';
import 'package:collaborate/resources/auth_methods.dart';
import 'package:collaborate/screens/signup_screen.dart';
import 'package:collaborate/utils/utils.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }

  void loginUser() async {
    setState(() {
      _isLoading = true;
    });
    String res = await AuthMethods().loginUser(
        email: _emailController.text, password: _passwordController.text);
    if (res == 'success') {
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => HomePage()),
            (route) => false);

        setState(() {
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _isLoading = false;
      });
      if (context.mounted) {
        showSnackBar(context, res);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width; // Screen width
    final height = MediaQuery.of(context).size.height; // Screen height

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        color: collaborateAppBarBgColor,
        padding: const EdgeInsets.symmetric(horizontal: 32),
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: height * 0.25,
            ),
            Text('Collaborate',
                style: GoogleFonts.raleway(
                  fontSize: width * 0.14,
                  color: collaborateAppBarTextColor,
                  fontWeight: FontWeight.w500,
                )),
            const SizedBox(
              height: 64,
            ),
            TextField(
              controller: _emailController,
              enableSuggestions: true,
              cursorColor: color4,
              style: GoogleFonts.ptSans(color: color4),
              decoration: InputDecoration(
                prefixIcon: const Icon(
                  Icons.email_outlined,
                  color: Colors.white70,
                ),
                labelText: 'Enter your email',
                labelStyle: GoogleFonts.ptSans(color: color4),
                filled: true,
                floatingLabelBehavior: FloatingLabelBehavior.never,
                fillColor: color5,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide:
                        const BorderSide(width: 0, style: BorderStyle.none)),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(
              height: 30,
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              enableSuggestions: false,
              autocorrect: false,
              cursorColor: Colors.white,
              style: GoogleFonts.ptSans(color: Colors.white.withOpacity(0.9)),
              decoration: InputDecoration(
                prefixIcon: const Icon(
                  Icons.lock_outline,
                  color: Colors.white70,
                ),
                labelText: 'Enter your password',
                labelStyle:
                    GoogleFonts.ptSans(color: Colors.white.withOpacity(0.9)),
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
            GestureDetector(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ResetPassword(),
                ),
              ),
              child: Container(
                alignment: Alignment.topRight,
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'Reset Password?',
                  style: GoogleFonts.ptSans(
                      fontWeight: FontWeight.bold, color: color4),
                ),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            InkWell(
              onTap: loginUser,
              child: Container(
                width: double.infinity,
                alignment: Alignment.center,
                height: height * 0.065,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: const ShapeDecoration(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                  ),
                  color: Colors.black,
                ),
                child: !_isLoading
                    ? Text(
                        'Log in',
                        style: GoogleFonts.ptSans(
                          fontSize: height * 0.025,
                          color: color4,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : const CircularProgressIndicator(
                        color: Colors.blue,
                      ),
              ),
            ),
            const SizedBox(
              height: 18,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    'Dont have an account? ',
                    style: GoogleFonts.ptSans(
                        color: color4, fontWeight: FontWeight.w400),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const SignupScreen(),
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      ' Signup.',
                      style: GoogleFonts.ptSans(
                          fontWeight: FontWeight.bold, color: color4),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tiffin/auth/forgotpassword.dart';
import 'package:tiffin/auth/signup.dart';
import 'package:tiffin/home_screens/home.dart';
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:tiffin/models/user.dart';
import 'package:tiffin/util/app_constants.dart';
import 'package:tiffin/util/snackbar.dart';
import 'package:tiffin/util/shared_pref.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final GlobalKey<FormState> _globalKey = GlobalKey<FormState>();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isChecked = false;
  bool rememberMe = false;

  @override
  void initState() {
    super.initState();
    getRememberMePreference();
    // _emailController.text = 'karan74406@gmail.com';
    // _passwordController.text = 'Karan1234';
  }

  // bool _rememberMe = false;
  String? _email;
  String? _password;

  @override
  void dispose() {
    _emailController.dispose();
  _passwordController.dispose();
    // ignore: avoid_print
    print('Dispose used');
    super.dispose();
  }

  Future<void> getRememberMePreference() async {
    await SharedPrefHelper.init();
    bool rememberMe = SharedPrefHelper.getBool('rememberMe') ?? false;
    print('getRememberMePreference');
    print(rememberMe);
    print(SharedPrefHelper.getString('email'));
    setState(() {
      this.rememberMe = rememberMe;
      if (rememberMe) {
        // Retrieve saved email and password
        _emailController.text = SharedPrefHelper.getString('email') ?? '';
        _passwordController.text =
            SharedPrefHelper.getString('password') ?? '';
      }
    });
  }

  Future<void> setRememberMePreference(bool value) async {
    await SharedPrefHelper.init();
    rememberMe = value;
    await SharedPrefHelper.setBool('rememberMe', value);
    print('setRememberMePreference');
    print(rememberMe);
    print(SharedPrefHelper.getString('email'));
    if (!value) {
      // Clear saved email and password
      await SharedPrefHelper.remove('email');
      await SharedPrefHelper.remove('password');
    }
  }

  Future<void> saveCredentials() async {
    await SharedPrefHelper.init();
    await SharedPrefHelper.setString('email', _emailController.text);
   await SharedPrefHelper.setString('password', _passwordController.text);

  }

  Future<void> handleSignIn(String email, String password) async{
    // Perform sign-in logic here

    if (rememberMe) {
      saveCredentials();
    } else {
      // Clear saved email and password
      setRememberMePreference(false);
    }

    await loginWithEmail(_emailController.text, _passwordController.text);

    // Navigate to the next screen or perform any other actions
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _globalKey,
        child: SingleChildScrollView(
          child: Container(
            height: 1000,
            decoration: BoxDecoration(
              image: DecorationImage(
                alignment: Alignment.topCenter,
                image: AssetImage('assets/image/t2.jpg'),
                fit: BoxFit.fitWidth,
              ),
            ), //

            child: Container(
              margin: EdgeInsets.only(top: 210),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[50],
                // color: Color(0xFFEDECF2),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50),
                  topRight: Radius.circular(50),
                ),
              ),

              //here i want  container somehow
              child: Column(children: [
                Container(
                  margin: EdgeInsets.only(top: 20),
                  child: Text(
                    "Sign In",
                    style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                        fontStyle: FontStyle.normal,
                        fontFamily: GoogleFonts.abhayaLibre().fontFamily),
                  ),
                ),
                Container(
                    margin: EdgeInsets.only(top: 40, left: 10, right: 10),
                    height: 450,
                    decoration: BoxDecoration(
                      color: Colors.white70,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Container(
                      margin: EdgeInsets.only(top: 50, left: 20, right: 20),
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _emailController,
                            focusNode: _emailFocus,
                            decoration: InputDecoration(
                              prefixIcon: Icon(
                                Icons.email,
                                color: Theme.of(context).primaryColor,
                              ),
                              labelText: 'Email',
                              labelStyle: TextStyle(
                                color: Theme.of(context).primaryColor,
                              ),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                      color: Theme.of(context).primaryColor)),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor,
                                  width: 1.0,
                                ),
                              ),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Email is required';
                              }
                              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                  .hasMatch(value)) {
                                return "Enter a valid Email Address";
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _email = value;
                            },
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          TextFormField(
                            controller: _passwordController,
                            focusNode: _passwordFocus,
                            decoration: InputDecoration(
                              prefixIcon: Icon(
                                Icons.lock,
                                color: Theme.of(context).primaryColor,
                              ),
                              labelText: 'Password',
                              labelStyle: TextStyle(
                                  color: Theme.of(context).primaryColor),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context).primaryColor),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context).primaryColor),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            obscureText: true,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Password is required';
                              }

                              if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }

                              return null;
                            },
                            onSaved: (value) {
                              _password = value;
                            },
                          ),
                          Row(
                            children: [
                              Container(
                                height: 20,
                                child: Row(children: [
                                  Theme(
                                    data: ThemeData(
                                      checkboxTheme: CheckboxThemeData(
                                        fillColor: MaterialStateProperty
                                            .resolveWith<Color>(
                                          (Set<MaterialState> states) {
                                            if (states.contains(
                                                MaterialState.selected)) {
                                              return Theme.of(context)
                                                  .primaryColor;
                                            }
                                            return Theme.of(context)
                                                .primaryColor; // default color of the square box
                                          },
                                        ),
                                      ),
                                    ),
                                    child: Checkbox(
                                      shape: RoundedRectangleBorder(
                                        side: BorderSide(
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      ),
                                      value: rememberMe,
                                      onChanged: (value) {
                                        setState(() {
                                          rememberMe = value!;
                                        });
                                        setRememberMePreference(value!);
                                      },
                                    ),
                                  ),
                                  Text(
                                    'Remember Me',
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                ]),
                              ),
                              SizedBox(
                                height: 30,
                                width: 20,
                              ),
                              Container(
                                alignment: Alignment.center,
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ForgotPasswordScreen(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    'Forgot Password?',
                                    style: TextStyle(
                                        color: Theme.of(context).primaryColor),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              text:
                                  'By Clicking Sign in you certify that you agree to our ',
                              style: TextStyle(
                                color: Colors.grey,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Privacy policy',
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      // Navigate to privacy policy URL
                                      //  launchPrivacyPolicyURL();
                                      _privacyUrl();
                                    },
                                ),
                                TextSpan(text: ' and '),
                                TextSpan(
                                  text: 'Terms and conditions',
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      // Navigate to terms and conditions URL
                                      _termsUrl();
                                      // launchTermsAndConditionsURL();
                                    },
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          ElevatedButton(
                            onPressed: () async{
                              if (!_globalKey.currentState!.validate()) {
                                return;
                              }

                              _globalKey.currentState!.save();
                              // Navigator.pushReplacement(
                              //   context,
                              //   MaterialPageRoute(builder: (context) => MyHomePage()),
                              // );
                             await handleSignIn(_emailController.text,
                                  _passwordController.text);
                                 // .then((value) => {
                                 //    Get.to(MyHomePage()),
                             // Navigator.pushReplacement(
                             // context,
                             // MaterialPageRoute(builder: (context) => MyHomePage()),
                             // )
                           //  });
                            },
                            child: Text(
                              'Sign In',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,

                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 15.0),
                              minimumSize: Size(double.infinity, 50.0),
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SignUp()),
                              );
                            },
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Don\'t have an account? ',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                  TextSpan(
                                    text: 'Sign Up',
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ))
              ]),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _termsUrl() async {
    final Uri _privUrl = Uri.parse(
        'https://doc-hosting.flycricket.io/brampton-tiffin-terms-conditions/83ec4a56-84f6-445a-a208-6a7bc805245e/terms');

    if (!await launchUrl(_privUrl)) {
      throw Exception('Could not launch $_privUrl');
    }
  }

  Future<void> _privacyUrl() async {
    final Uri _privUrl = Uri.parse(
        'https://doc-hosting.flycricket.io/brampton-tiffin-privacy-policy/a331e2a2-ba9e-4714-a359-9fb4f8513c9a/privacy');

    if (!await launchUrl(_privUrl)) {
      throw Exception('Could not launch $_privUrl');
    }
  }



  Future<void> loginWithEmail(String email, String password) async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = await userCredential.user;
      if (user == null) {
        // Handle the case when the user object is null
        return;
      }

      if (!user.emailVerified) {
        show(context, "Email not verified. Please verify your email.",
            isError: true);

        // If the email is not verified, show an error message and prompt the user to verify their email
        throw FirebaseAuthException(
            code: 'user-not-verified',
            message: 'Please verify your email before logging in.');
      }else{
        print('Sign in success');

        Get.to(MyHomePage());
      }
      // final uid = FirebaseAuth.instance.currentUser!.uid;
      // final firebaseUser = await getUserData(uid);
      // final modelUser = Users(email: email, user_type: firebaseUser?.user_type ?? '');
      //
      // await saveUser(modelUser, password);




      // The email is verified, allow the user to log in
      // You can navigate the user to the home screen or do any other action here
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        show(context, "User not found or Invalid email or password",
            isError: true);
        print('Invalid email or password');
      } else {
        print('Sign in Error ${e.toString()}');
      }
    } catch (e) {
      print('Sign in catch Error ${e.toString()}');
    }
  }

   Future<void> saveUser(
      Users user, String password) async {
    await SharedPrefHelper.init();
    await SharedPrefHelper.setString('email', user.email!);
    await SharedPrefHelper.setString('password', password);
    await SharedPrefHelper.setString('userType', user.user_type!);
  }

  Future<Users?> getUserData(String uid) async {
    final _firestore = FirebaseFirestore.instance;
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot =
      await _firestore.collection('users').doc(uid).get();
      if (snapshot.exists) {
        // Map the document data to a User object
        return Users.fromJson(snapshot.data()!);
      } else {
        print('User data not found');
        return null;
      }
    } catch (e) {
      print("Error getting user data: $e");
      return null;
    }
  }
}

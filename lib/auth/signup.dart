import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tiffin/auth/signin.dart';
import 'package:tiffin/home_screens/home.dart';

import 'package:dio/dio.dart';
import 'package:tiffin/util/app_constants.dart';
import 'package:tiffin/util/shared_pref.dart';
import 'package:tiffin/util/snackbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tiffin/models/user.dart';
class SignUp extends StatefulWidget {
  final Function(String)? onSelected;

  SignUp({this.onSelected});

  @override
  _SignUpState createState() => _SignUpState();
}
                                   
class _SignUpState extends State<SignUp> {
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  final GlobalKey<FormState> _globalKey = GlobalKey<FormState>();
  String _selectedType = '';
  bool _showError = false;

  bool _rememberMe = false;
  String? _email;
  String? _password;

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
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50),
                  topRight: Radius.circular(50),
                ),
              ),

              //here i want  container somehow
              child: Column(children: [
                Container(
                  margin: EdgeInsets.only(top: 10),
                  child: Text(
                    "Sign Up",
                    style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                        fontStyle: FontStyle.normal,
                        fontFamily: GoogleFonts.abhayaLibre().fontFamily),
                  ),
                ),
                Container(
                    margin: EdgeInsets.only(top: 20, left: 10, right: 10),
                    height: 580,
                    decoration: BoxDecoration(
                      color: Colors.white70,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Container(
                      margin: EdgeInsets.only(top: 40, left: 20, right: 20),
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
                              _email = value as String;
                            },
                          ),
                          SizedBox(
                            height: 10,
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
                              _password = value as String;
                            },
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          TextFormField(
                            controller: _confirmPasswordController,
                            focusNode: _confirmPasswordFocus,
                            decoration: InputDecoration(
                              prefixIcon: Icon(
                                Icons.lock,
                                color: Theme.of(context).primaryColor,
                              ),
                              labelText: 'Confirm Password',
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
                                return 'Confirm Password is required';
                              }

                              if (value.length < 6) {
                                return 'Confirm Password must be at least 6 characters';
                              }

                              return null;
                            },
                            onSaved: (value) {
                              _password = value as String;
                            },
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '  I am a...',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                  fontSize: 18,
                                ),
                              ),
                              SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _selectedType = 'Customer';
                                          _showError = false;
                                        });
                                      },
                                      child: Container(
                                        padding: EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          color: _selectedType == 'Customer'
                                              ? Theme.of(context).primaryColor
                                              : Colors.green[50],
                                        ),
                                        child: Text(
                                          'Customer',
                                          style: TextStyle(
                                            color: _selectedType == 'Customer'
                                                ? Colors.white
                                                : Colors.grey,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 16),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _selectedType = 'Seller';
                                          _showError = false;
                                        });
                                      },
                                      child: Container(
                                        padding: EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          color: _selectedType == 'Seller'
                                              ? Theme.of(context).primaryColor
                                              : Colors.green[50],
                                        ),
                                        child: Text(
                                          'Seller',
                                          style: TextStyle(
                                            color: _selectedType == 'Seller'
                                                ? Colors.white
                                                : Colors.grey,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          if (_showError)
                            Padding(
                              padding: EdgeInsets.only(top: 8),
                              child: Text(
                                'Please select a user type',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          SizedBox(
                            height: 10,
                          ),
                          RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              text:
                                  'By Clicking Sign up you certify that you agree to our ',
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
                            height: 10,
                          ),
                          ElevatedButton(
                            onPressed: () {
                              if (_selectedType == '') {
                                setState(() {
                                  _showError = true;
                                });
                                return;
                              }
                              if (!_globalKey.currentState!.validate()) {
                                return;
                              }

                              _globalKey.currentState!.save();
                              _register();
                            },
                            child: Text(
                              'Sign Up',
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
                                    builder: (context) => SignIn()),
                              );
                            },
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Already have an account? ',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                  TextSpan(
                                    text: 'Sign In',
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

  void _register() async {
    print("click signup");
    print("email for firebase testing" + _emailController.text);
    String _email = _emailController.text.trim();
    String _password = _passwordController.text.trim();
    String _confirmPassword = _confirmPasswordController.text.trim();
    String userType = _selectedType;
    if (_password != _confirmPassword) {
      show(context, 'Passwords do not match');
    } else {
      try {
        signUpWithEmail(_email, _password, userType);

      } catch (error) {
        show(context, 'Error: $error');
        print('catch $error');
      }
    }
  }

  Future<void> signUpWithEmail(String email, String password, String userType) async {
    print("signUpWithEmail");
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Send email verification link to the user
      await userCredential.user?.sendEmailVerification();

      final user = Users(email: email, user_type: userType);

      await addUser(user, _passwordController.text);

      print("firebase signup success");
      show(context, "Verification link sent. Please check your email",
          isError: false);
      setState(() {
        _emailController.text = '';
        _passwordController.text = '';
        _confirmPasswordController.text = '';
        _selectedType = '';
        _emailFocus.unfocus();
        _passwordFocus.unfocus();
        _confirmPasswordFocus.unfocus();
      });

      // You can show a success message to the user and prompt them to verify their email
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
    } catch (e) {
      print('FIREBASE ERROR ${e.toString()}');
    }
  }

  void sendEmailVerification() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  Future<void> addUser(Users user, String password) async{
    final _usersCollection = FirebaseFirestore.instance.collection('users');
    String uid = FirebaseAuth.instance.currentUser!.uid;

    try{
      await _usersCollection.doc(uid).set(user.toJson());
      await saveUser(user, password);

    }catch (e){
      print("Error adding user: $e");
    }
  }

  static Future<void> saveUser(
     Users user, String password) async {
    await SharedPrefHelper.init();
    await SharedPrefHelper.setString('email', user.email!);
    await SharedPrefHelper.setString('password', password);
    await SharedPrefHelper.setString('userType', user.user_type!);
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
}

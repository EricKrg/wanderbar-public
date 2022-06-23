import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hungry/models/helper/quick_log_helper.dart';
import 'package:hungry/views/utils/AppColor.dart';
import 'package:hungry/views/widgets/custom_text_field.dart';

class StatefulLoginModal extends StatefulWidget {
  const StatefulLoginModal({Key key}) : super(key: key);

  @override
  State<StatefulLoginModal> createState() => _StatefulLoginModalState();
}

class _StatefulLoginModalState extends State<StatefulLoginModal> {
  TextEditingController _mailController;
  TextEditingController _pwController;

  bool loginFailed = false;

  bool hasCredentials = false;

  @override
  void initState() {
    super.initState();
    _mailController = TextEditingController();
    _pwController = TextEditingController();
    _mailController.addListener(() {
      this.checkCredentials();
    });
    _pwController.addListener(() {
      this.checkCredentials();
    });
  }

  @override
  void dispose() {
    _mailController.dispose();
    _pwController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 85 / 100,
          padding: EdgeInsets.only(left: 16, right: 16, bottom: 32, top: 16),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20), topRight: Radius.circular(20))),
          child: ListView(
            shrinkWrap: true,
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            physics: BouncingScrollPhysics(),
            children: [
              Align(
                alignment: Alignment.center,
                child: Container(
                  width: MediaQuery.of(context).size.width * 35 / 100,
                  margin: EdgeInsets.only(bottom: 20),
                  height: 6,
                  decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(20)),
                ),
              ),
              // header
              Container(
                margin: EdgeInsets.only(bottom: 24),
                child: Text(
                  'Login',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'inter'),
                ),
              ),
              // Form
              CustomTextField(
                  title: 'Email',
                  hint: 'youremail@email.com',
                  controller: _mailController),
              CustomTextField(
                  title: 'Password',
                  hint: '**********',
                  controller: _pwController,
                  obsecureText: true,
                  margin: EdgeInsets.only(top: 16)),
              // Log in Button
              Container(
                margin: EdgeInsets.only(top: 32, bottom: 6),
                width: MediaQuery.of(context).size.width,
                height: 60,
                child: ElevatedButton(
                  onPressed: !hasCredentials
                      ? null
                      : () async {
                          try {
                            await signIn();
                            Navigator.of(context).pop();
                          } catch (e) {
                            setState(() {
                              loginFailed = true;
                              _pwController.clear();
                            });
                          }
                        },
                  child: Text('Login',
                      style: TextStyle(
                          color: AppColor.whiteSoft,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'inter')),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    primary: AppColor.primary,
                  ),
                ),
              ),
              if (loginFailed)
                Container(
                    margin: EdgeInsets.only(top: 32, bottom: 6),
                    alignment: Alignment.center,
                    width: MediaQuery.of(context).size.width,
                    child: Text("Login Failed",
                        style: TextStyle(
                            color: Colors.red[800],
                            fontWeight: FontWeight.w800)))
            ],
          ),
        )
      ],
    );
  }

  Future<UserCredential> signIn() async {
    UserCredential userCredential = await this.signInWithEmail();

    final isUserDataCreated = await QuickLogHelper.instance
        .getUserSimpleByEmail(userCredential.user.email);

    if (isUserDataCreated.docs.isEmpty) {
      QuickLogHelper.instance.createSimpleUser(userCredential.user);
    }
    return userCredential;
    //return await this.signInWithGoogle();
  }

  Future<UserCredential> signInWithEmail() async {
    return await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _mailController.text.trim(),
        password: _pwController.text.trim());
  }

  Future<UserCredential> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth =
        await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  void checkCredentials() {
    setState(() {
      hasCredentials =
          _pwController.text.isNotEmpty && _mailController.text.isNotEmpty;
    });
  }
}

class LoginModal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StatefulLoginModal();
  }
}

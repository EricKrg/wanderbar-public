import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hungry/models/helper/quick_log_helper.dart';
import 'package:hungry/views/utils/AppColor.dart';
import 'package:hungry/views/widgets/custom_text_field.dart';

class RegisterModal extends StatefulWidget {
  const RegisterModal({Key key}) : super(key: key);

  @override
  _RegisterModalState createState() => _RegisterModalState();
}

class _RegisterModalState extends State<RegisterModal> {
  final displayNameController = TextEditingController();
  final pwController1 = TextEditingController();
  final pwController2 = TextEditingController();
  bool isValid = false;
  bool isLoading = false;
  String errorDetail;

  @override
  void initState() {
    super.initState();
    this.validateInput();
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.7,
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
                  'Edit your Account',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'inter'),
                ),
              ),
              // Form
              CustomTextField(
                  controller: displayNameController,
                  title: 'Display Name',
                  hint: 'Your display Name',
                  margin: EdgeInsets.only(top: 16)),
              CustomTextField(
                  controller: pwController1,
                  title: 'Password',
                  hint: '**********',
                  obsecureText: true,
                  margin: EdgeInsets.only(top: 16)),
              CustomTextField(
                  controller: pwController2,
                  title: 'Retype Password',
                  hint: '**********',
                  obsecureText: true,
                  margin: EdgeInsets.only(top: 16)),
              // Register Button
              Container(
                margin: EdgeInsets.only(top: 32, bottom: 6),
                width: MediaQuery.of(context).size.width,
                height: 60,
                child: ElevatedButton(
                  onPressed: this.isValid ? getSaveFunction : null,
                  child: isLoading
                      ? CircularProgressIndicator(
                          color: AppColor.primary,
                        )
                      : Text('Save changes',
                          style: TextStyle(
                              color: AppColor.primary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'inter')),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    primary: AppColor.primarySoft,
                  ),
                ),
              ),
              errorDetail != null
                  ? Text(
                      errorDetail,
                      style: TextStyle(
                          color: AppColor.warn,
                          fontSize: 12,
                          fontWeight: FontWeight.w400),
                    )
                  : Container()
            ],
          ),
        )
      ],
    );
  }

  validateInput() {
    displayNameController.addListener(() {
      return this.isInputCorrect();
    });
    pwController1.addListener(() {
      return this.isInputCorrect();
    });

    pwController2.addListener(() {
      return this.isInputCorrect();
    });
  }

  void isInputCorrect() {
    bool isInputValid = (pwController1.text.trim().isNotEmpty &&
            pwController2.text.trim().isNotEmpty) &&
        (pwController1.text.trim() == pwController2.text.trim()) &&
        displayNameController.text.trim().isNotEmpty;
    print("is input valid $isInputValid");
    setState(() {
      this.isValid = isInputValid;
    });
  }

  getSaveFunction() async {
    if (isValid) {
      setState(() {
        isLoading = true;
      });
      try {
        await FirebaseAuth.instance.currentUser
            .updatePassword(pwController1.text.trim());
      } catch (e) {
        setState(() {
          errorDetail = (e as FirebaseAuthException).message;
        });
        return;
      } finally {
        setState(() {
          isLoading = false;
        });
      }
      print("Save info");
      await FirebaseAuth.instance.currentUser
          .updateDisplayName(displayNameController.text.trim());
      QuickLogHelper.instance
          .createSimpleUser(FirebaseAuth.instance.currentUser);
      Navigator.of(context).pop();
    } else {
      return null;
    }
  }
}

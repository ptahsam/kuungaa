import 'package:date_field/date_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:group_radio_button/group_radio_button.dart';
import 'package:intl/intl.dart';
import 'package:kuungaa/AllWidgets/progressDialog.dart';
import 'package:kuungaa/Models/media.dart';
import 'package:kuungaa/config/config.dart';
import 'package:kuungaa/config/utilities.dart';
import 'package:kuungaa/sharedWidgets/widgets.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:snippet_coder_utils/FormHelper.dart';
import 'package:snippet_coder_utils/ProgressHUD.dart';
import 'package:snippet_coder_utils/hex_color.dart';

import '../main.dart';
import 'screens.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  static const String idScreen = "registerPage";
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with AutomaticKeepAliveClientMixin{
  final int _numPages = 3;
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;

  bool hidePassword = true;
  bool hidePassword2 = true;


  bool isCheckedTandC = false;

  String _verticalGroupValue = "Male";

  List<String> _status = ["Male", "Female", "Other"];

  List<Widget> _buildPageIndicator() {
    List<Widget> list = [];
    for (int i = 0; i < _numPages; i++) {
      list.add(i == _currentPage ? _indicator(true) : _indicator(false));
    }
    return list;
  }

  TextEditingController userFirstname = TextEditingController();
  TextEditingController userLastname = TextEditingController();
  TextEditingController userEmail = TextEditingController();
  TextEditingController userBirthday = TextEditingController();
  TextEditingController userPassword = TextEditingController();
  TextEditingController userConfirmPassword = TextEditingController();

  Widget _indicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      height: 8.0,
      width: isActive ? 24.0 : 24.0,
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.black,
        borderRadius: const BorderRadius.all(Radius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        //resizeToAvoidBottomInset: false,
        backgroundColor: HexColor("#2dce89"),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height / 2.5,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xff040404),
                      Color(0xff040404),
                    ],
                  ),
                  borderRadius: BorderRadius.only(
                    //topLeft: Radius.circular(100),
                    //topRight: Radius.circular(150),
                    bottomRight: Radius.circular(5),
                    bottomLeft: Radius.circular(5),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: Center(
                        child: Text(
                          "KUUNGAA",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                            color: HexColor("#2dce89"),
                          ),
                        ),
                      ),
                    ),

                    Expanded(
                      child: Align(
                        alignment: Alignment.center,
                        child: Image.asset(
                          "images/login_logo_dark.png",
                          fit: BoxFit.contain,
                          width: 250,
                          height: 250,
                          //height: MediaQuery.of(context).size.height / 2.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 15.0, ),
                child: Center(
                  child: Text(
                    "Register",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(bottom: 15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _buildPageIndicator(),
                ),
              ),

              Wrap(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.35,
                    child: PageView(
                      physics: const NeverScrollableScrollPhysics(),
                      controller: _pageController,
                      onPageChanged: (int page) {
                        setState(() {
                          _currentPage = page;
                        });
                      },
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: SingleChildScrollView(
                            physics: const NeverScrollableScrollPhysics(),
                            child: Column(
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 10.0),
                                  child: TextField(
                                      controller: userFirstname,
                                    decoration: InputDecoration(
                                      prefixIcon: Icon(Icons.person, color: Colors.white,),

                                      labelText: "First name",

                                      labelStyle: TextStyle(
                                          color: Colors.white
                                      ),
                                      hintText: 'Enter your first name',
                                      hintStyle: TextStyle(
                                        color: Colors.white
                                      ),

                                      contentPadding:
                                      const EdgeInsets.only(top: 10.0, bottom: 10.0, left: 35.0),
                                      border: const OutlineInputBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide:
                                        BorderSide(color: Colors.white, width: 1.0),
                                        borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                                      ),
                                      focusedBorder: const OutlineInputBorder(
                                        borderSide:
                                        BorderSide(color: Colors.white, width: 1.5),
                                        borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                      ),

                                    ),
                                    style: TextStyle(
                                        color: Colors.white
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(bottom: 10.0),
                                  child: TextField(
                                    controller: userLastname,
                                    decoration: InputDecoration(
                                      prefixIcon: Icon(Icons.person, color: Colors.white,),
                                      labelText: "Last name",

                                      labelStyle: TextStyle(
                                          color: Colors.white
                                      ),
                                      hintText: 'Enter your last name',
                                      hintStyle: TextStyle(
                                          color: Colors.white
                                      ),
                                      contentPadding:
                                      const EdgeInsets.only(top: 10.0, bottom: 10.0, left: 35.0),
                                      border: const OutlineInputBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide:
                                        BorderSide(color: Colors.white, width: 1.0),
                                        borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                                      ),
                                      focusedBorder: const OutlineInputBorder(
                                        borderSide:
                                        BorderSide(color: Colors.white, width: 1.5),
                                        borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                      ),

                                    ),
                                    style: TextStyle(
                                        color: Colors.white
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(bottom: 10.0),
                                  child: TextField(
                                    controller: userEmail,
                                    decoration: InputDecoration(
                                      prefixIcon: Icon(Icons.mail, color: Colors.white,),
                                      labelText: "Email address",

                                      labelStyle: TextStyle(
                                          color: Colors.white
                                      ),
                                      hintText: 'Enter your email address',
                                      hintStyle: TextStyle(
                                          color: Colors.white
                                      ),
                                      contentPadding:
                                      const EdgeInsets.only(top: 10.0, bottom: 10.0, left: 35.0),
                                      border: const OutlineInputBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide:
                                        BorderSide(color: Colors.white, width: 1.0),
                                        borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                                      ),
                                      focusedBorder: const OutlineInputBorder(
                                        borderSide:
                                        BorderSide(color: Colors.white, width: 1.5),
                                        borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                      ),

                                    ),
                                    style: TextStyle(
                                        color: Colors.white
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        SingleChildScrollView(
                          physics: const NeverScrollableScrollPhysics(),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12.0),
                            child: Column(
                              children: [

                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10, top: 15.0),
                                  child: TextField(
                                    controller: userBirthday, //editing controller of this TextField
                                    decoration: InputDecoration(
                                      prefixIcon: Icon(Icons.calendar_today, color: Colors.white,),
                                      labelText: "Date of birth",

                                      labelStyle: TextStyle(
                                        color: Colors.white
                                      ),
                                      hintText: 'Select date of birth',
                                      contentPadding:
                                      const EdgeInsets.only(top: 10.0, bottom: 10.0, left: 35.0),
                                      border: const OutlineInputBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide:
                                        BorderSide(color: Colors.white, width: 0.2),
                                        borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                                      ),
                                      focusedBorder: const OutlineInputBorder(
                                        borderSide:
                                        BorderSide(color: Colors.white, width: 1.0),
                                        borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                      ),

                                    ),
                                    style: TextStyle(
                                      color: Colors.white
                                    ),
                                    readOnly: true,  //set it true, so that user will not able to edit text
                                    onTap: () async {
                                      DateTime? pickedDate = await showDatePicker(
                                          context: context, initialDate: DateTime.now(),
                                          firstDate: DateTime(1900), //DateTime.now() - not to allow to choose before today.
                                          lastDate: DateTime(2101)
                                      );

                                      if(pickedDate != null ){
                                        print(pickedDate);  //pickedDate output format => 2021-03-10 00:00:00.000
                                        String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
                                        print(formattedDate); //formatted date output using intl package =>  2021-03-16
                                        //you can implement different kind of Date Format here according to your requirement

                                        setState(() {
                                          userBirthday.text = formattedDate; //set output date to TextField value.
                                        });
                                      }else{
                                        print("Date is not selected");
                                      }
                                    },
                                  ),
                                ),

                                Padding(
                                  padding: EdgeInsets.only(bottom: 10.0),
                                  child: TextField(
                                   controller: userPassword,
                                    decoration: InputDecoration(
                                      prefixIcon: Icon(Icons.lock, color: Colors.white,),
                                      suffixIcon: IconButton(
                                        onPressed: () {
                                          setState(() {
                                            hidePassword = !hidePassword;
                                          });
                                        },
                                        color: Colors.white.withOpacity(0.7),
                                        icon: Icon(
                                          hidePassword ? Icons.visibility_off : Icons.visibility,
                                        ),
                                      ),
                                      labelText: "Password",

                                      labelStyle: TextStyle(
                                          color: Colors.white
                                      ),
                                      hintText: 'Enter your password',
                                      hintStyle: TextStyle(
                                          color: Colors.white
                                      ),
                                      contentPadding:
                                      const EdgeInsets.only(top: 10.0, bottom: 10.0, left: 35.0),
                                      border: const OutlineInputBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide:
                                        BorderSide(color: Colors.white, width: 1.0),
                                        borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                                      ),
                                      focusedBorder: const OutlineInputBorder(
                                        borderSide:
                                        BorderSide(color: Colors.white, width: 1.5),
                                        borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                      ),

                                    ),
                                    style: TextStyle(
                                        color: Colors.white
                                    ),
                                    obscureText: hidePassword,
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(bottom: 10.0),
                                  child: TextField(
                                    controller: userConfirmPassword,
                                    decoration: InputDecoration(
                                      prefixIcon: Icon(Icons.lock, color: Colors.white,),
                                      suffixIcon: IconButton(
                                        onPressed: () {
                                          setState(() {
                                            hidePassword2 = !hidePassword2;
                                          });
                                        },
                                        color: Colors.white.withOpacity(0.7),
                                        icon: Icon(
                                          hidePassword2 ? Icons.visibility_off : Icons.visibility,
                                        ),
                                      ),
                                      labelText: "Confirm password",

                                      labelStyle: TextStyle(
                                          color: Colors.white
                                      ),
                                      hintText: 'Enter confirmation password',
                                      hintStyle: TextStyle(
                                          color: Colors.white
                                      ),
                                      contentPadding:
                                      const EdgeInsets.only(top: 10.0, bottom: 10.0, left: 35.0),
                                      border: const OutlineInputBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide:
                                        BorderSide(color: Colors.white, width: 1.0),
                                        borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                                      ),
                                      focusedBorder: const OutlineInputBorder(
                                        borderSide:
                                        BorderSide(color: Colors.white, width: 1.5),
                                        borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                      ),

                                    ),
                                    style: TextStyle(
                                        color: Colors.white
                                    ),
                                    obscureText: hidePassword2,
                                  ),
                                ),
                                /*Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: FormHelper.inputFieldWidget(
                                    context,
                                    const Icon(Icons.lock),
                                    "Password",
                                    "Password",
                                        (onValidateVal) {
                                      if (onValidateVal.isEmpty) {
                                        return 'Password can\'t be empty.';
                                      }

                                      return null;
                                    },
                                        (onSavedVal) => {
                                      userPassword = onSavedVal,
                                    },

                                    initialValue: "",
                                    obscureText: hidePassword,
                                    borderFocusColor: Colors.white,
                                    prefixIconColor: Colors.white,
                                    borderColor: Colors.white,
                                    textColor: Colors.white,
                                    hintColor: Colors.white.withOpacity(0.7),
                                    borderRadius: 5,
                                    suffixIcon: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          hidePassword = !hidePassword;
                                        });
                                      },
                                      color: Colors.white.withOpacity(0.7),
                                      icon: Icon(
                                        hidePassword ? Icons.visibility_off : Icons.visibility,
                                      ),
                                    ),
                                  ),
                                ),*/
                              ],
                            ),
                          ),
                        ),

                        SingleChildScrollView(
                          physics: const NeverScrollableScrollPhysics(),
                          child: Align(
                            alignment: Alignment.center,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 15.0),
                              child: Center(
                                child: Column(
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.only(bottom: 10.0),
                                      child: const Center(
                                        child: const Text(
                                          "Select your gender",
                                          style: TextStyle(color: Colors.white, fontSize: 18.0),
                                        ),
                                      ),
                                    ),

                                    Container(
                                      margin: const EdgeInsets.symmetric(horizontal: 12.0),
                                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.0),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 0.9
                                        ),
                                        borderRadius: BorderRadius.circular(10.0),
                                      ),
                                      child: RadioGroup<String>.builder(
                                        direction: Axis.horizontal,
                                        groupValue: _verticalGroupValue,
                                        horizontalAlignment: MainAxisAlignment.spaceAround,
                                        onChanged: (value) => setState(() {
                                          _verticalGroupValue = value!;
                                        }),
                                        items: _status,
                                        textStyle: const TextStyle(
                                            fontSize: 15,
                                            color: Colors.white
                                        ),
                                        itemBuilder: (item) => RadioButtonBuilder(
                                          item,

                                        ),
                                      ),
                                    ),

                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
                                      child: Row(
                                        children: [
                                          Checkbox(
                                            value: isCheckedTandC,
                                            onChanged: (value) {
                                              setState(() {
                                                isCheckedTandC = value!;
                                              });
                                            },
                                          ),
                                          const Text(
                                            "I accept the Terms of Use & Privacy Policy",
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [

                        _currentPage > 0
                            ?TextButton(
                          onPressed: () {
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.ease,
                            );
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              const Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                                size: 30.0,
                              ),
                              const SizedBox(width: 5.0),
                              const Text(
                                'Back',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18.0,
                                ),
                              ),
                            ],
                          ),
                        ): const SizedBox.shrink(),

                        _currentPage != _numPages - 1
                            ?TextButton(
                          onPressed: () {
                            if(_currentPage == 0){
                              if(validateAndSaveForm1()){
                                _pageController.nextPage(
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.ease,
                                );
                              }else{
                                displayToastMessage("Please enter all fields correctly before continuing", context);
                              }
                            }

                            if(_currentPage == 1){
                              if(validateAndSaveForm2()){
                                _pageController.nextPage(
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.ease,
                                );
                              }else{
                                displayToastMessage("Please enter all fields correctly before continuing", context);
                              }
                            }
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              const Text(
                                'Next',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18.0,
                                ),
                              ),
                              const SizedBox(width: 5.0),
                              const Icon(
                                Icons.arrow_forward,
                                color: Colors.white,
                                size: 30.0,
                              ),
                            ],
                          ),
                        ): const SizedBox.shrink(),
                        _currentPage == _numPages - 1 ?
                        ElevatedButton(

                          onPressed: (){
                            if(isCheckedTandC){
                              registerUser();
                            }else{
                              displayToastMessage("Read our terms and policies and agree before continuing", context);
                            }
                          },
                          child: const Text(
                              "REGISTER"
                          ),
                        ):const SizedBox.shrink(),
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(color: Colors.white, fontSize: 14.0),
                        children: <TextSpan>[
                          const TextSpan(
                            text: 'Already have an account? ',
                          ),
                          TextSpan(
                            text: 'Login',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                //Navigator.pushAndRemoveUntil(context, RegistrationScreen, (route) => false);
                                Navigator.pushNamedAndRemoveUntil(context, LoginPage.idScreen, (route) => false);
                              },
                          ),
                        ],
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
  bool validateAndSaveForm1() {
    if(userFirstname.text != "" && userLastname.text != "" && userEmail.text != ""){
      return true;
    }
    return false;
  }

  bool validateAndSaveForm2() {
    if(userBirthday.text != "" && userPassword.text != "" && userConfirmPassword.text != "" && userPassword.text == userConfirmPassword.text){
      return true;
    }
    return false;
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  void registerUser() async {

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context)
        {
          return ProgressDialog(message: "Registering, please wait ....",);
        }
    );

    //Authenticating user email and password
    final User? user = (await _firebaseAuth.
    createUserWithEmailAndPassword(
        email: userEmail.text,
        password: userPassword.text
    ).catchError((errorMsg){
      Navigator.pop(context);
      var errorCode = errorMsg.code;
      // var errorMessage = errMsg.message;

      if (errorCode == "email-already-in-use")
      {
        //errorNotif = "No account found for this email!. Create a new account";
        displayToastMessage("An account with similar email already exists! Try to sign in.", context);
      }else if (errorCode == "weak-password")
      {
        //errorNotif = "The password you entered is wrong. Enter correct password and try again";
        displayToastMessage("Password is too week!", context);
      }else{
        displayToastMessage("An error occurred. Please try again later!", context);
      }
      //displayToastMessage("Error: " + errorMsg.toString(), context);
    })).user;


    int currenttime = await getCurrentTime();

    Map userDataMap = {
      "user_id" : user!.uid,
      "user_firstname" : userFirstname.text,
      "user_lastname" : userLastname.text,
      "user_email" : userEmail.text,
      "user_profileimage" : uProfile,
      "user_coverimage" : "",
      "user_nickname" : "",
      "user_bio" : "",
      "user_mobilenumber" : "",
      "user_birthday" : userBirthday.text,
      "user_gender" : _verticalGroupValue,
      "user_status" : "1",
      "user_statusinfo" : "Normal",
      "time_created" : currenttime,
      "time_updated" : ""
    };

    usersRef.child(user.uid).set(userDataMap).then((onValue) {
      displayToastMessage("Your account was created successfully! You can now login", context);
      _firebaseAuth.signOut();
      Navigator.pushNamedAndRemoveUntil(context, LoginPage.idScreen, (route) => false);
    }).catchError((onError) {
      //Navigator.pop(context);
      _firebaseAuth.signOut();
      displayToastMessage("An error occurred. Please try again later", context);
    });

  }

}
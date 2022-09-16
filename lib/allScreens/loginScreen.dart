
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kuungaa/AllWidgets/progressDialog.dart';
import 'package:kuungaa/allScreens/nav_screen.dart';
import 'package:kuungaa/config/config.dart';
import 'package:kuungaa/main.dart';
import 'package:snippet_coder_utils/FormHelper.dart';
import 'package:snippet_coder_utils/ProgressHUD.dart';
import 'package:snippet_coder_utils/hex_color.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  static const String idScreen = "loginPage";

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isApiCallProcess = false;
  bool hidePassword = true;
  GlobalKey<FormState> globalFormKey = GlobalKey<FormState>();
  String? userEmail;
  String? password;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        //resizeToAvoidBottomInset: false,
        backgroundColor: HexColor("#2dce89"),
        body: ProgressHUD(
          child: Form(
            key: globalFormKey,
            child: _loginUI(context),
          ),
          inAsyncCall: isApiCallProcess,
          opacity: 0.3,
          key: UniqueKey(),
        ),
      ),
    );
  }

  Widget _loginUI(BuildContext context) {
    return SingleChildScrollView(
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
                //SizedBox(height: 5.0,),

                //Align(
                //  alignment: Alignment.center,
                //  child: Text(
                //    "KUUNGAA",
                 //   style: TextStyle(color: Color(0xff2dce89), fontSize: 22.0),
                 // ),
               // ),


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
            padding: EdgeInsets.symmetric(vertical: 15.0),
            child: Center(
              child: Text(
                "Login",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: FormHelper.inputFieldWidget(
              context,
              "Email",
              "Email",
                  (onValidateVal) {
                if (onValidateVal.isEmpty) {
                  return 'Email can\'t be empty.';
                }

                return null;
              },
                  (onSavedVal) => {
                userEmail = onSavedVal,
              },
              initialValue: "",
              obscureText: false,
              borderFocusColor: Colors.white,
              prefixIconColor: Colors.white,
              prefixIcon: Icon(Icons.email),
              borderColor: Colors.white,
              textColor: Colors.white,
              hintColor: Colors.white.withOpacity(0.7),
              borderRadius: 5,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: FormHelper.inputFieldWidget(
              context,
              "Password",
              "Password",
                  (onValidateVal) {
                if (onValidateVal.isEmpty) {
                  return 'Password can\'t be empty.';
                }

                return null;
              },
                  (onSavedVal) => {
                password = onSavedVal,
              },
              initialValue: "",
              obscureText: hidePassword,
              borderFocusColor: Colors.white,
              prefixIconColor: Colors.white,
              prefixIcon: Icon(Icons.lock),
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
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.only(
                right: 25,
              ),
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(color: Colors.grey, fontSize: 14.0),
                  children: <TextSpan>[
                    TextSpan(
                      text: 'Forgot Password ?',
                      style: const TextStyle(
                        color: Colors.white,
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: TapGestureRecognizer()..onTap = () {
                        Navigator.pushNamed(context, "/forgotpassword");
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(
            height: 10,
          ),

          Center(
            child: FormHelper.submitButton(
                "Login",
                (){
                  //print("Login");
                  if(validateAndSave()){
                   // print("Ready email : " + userEmail.toString());
                    loginAndAuthenticateUser(context, userEmail, password);
                  }
                },
                btnColor: HexColor("#2dce89"),
                borderColor: HexColor("#ffffff"),
                txtColor: Colors.white,
                borderRadius: 5.0,
                ),
          ),

          const SizedBox(
            height: 10,
          ),

          const Center(
            child: Text(
              "OR",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.only(
                right: 25,
              ),
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(color: Colors.white, fontSize: 14.0),
                  children: <TextSpan>[
                    const TextSpan(
                      text: "Don't have an account?",
                    ),
                    TextSpan(
                      text: 'Sign up',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          //Navigator.pushAndRemoveUntil(context, RegistrationScreen, (route) => false);
                          Navigator.pushNamed(context, "/register");
                        },
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }

  bool validateAndSave() {
    final form = globalFormKey.currentState;
    if (form!.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  void loginAndAuthenticateUser(BuildContext context, String? userEmail, String? userPassword) async {

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context)
        {
          return ProgressDialog(message: "Authenticating, Please wait...",);
        }
    );

    try{
      await _firebaseAuth.signInWithEmailAndPassword(
          email: userEmail!,
          password: userPassword!
      );

      User? firebaseUser = _firebaseAuth.currentUser!;
      if(firebaseUser != null)
      {
        Navigator.pop(context);
        usersRef.child(firebaseUser.uid).once().then((DataSnapshot snap){
          if(snap.value != null)
          {
            displayToastMessage("You are logged in. Welcome to Kuungaa... ", context);
            Navigator.pushNamedAndRemoveUntil(context, NavScreen.idScreen, (route) => false);

          }
          else{
            Navigator.pop(context);
            _firebaseAuth.signOut();
            displayToastMessage("Create an account first then try to log in ", context);
          }
        },);
      }else
      {
        Navigator.pop(context);
        displayToastMessage("An error occured! Try again later. ", context);
      }
    }catch(exp){
      Navigator.pop(context);
      print("error :: " + exp.toString());
      var errorCode = exp;
      // var errorMessage = errMsg.message;

      if (errorCode == "user-not-found")
      {
        //errorNotif = "No account found for this email!. Create a new account";
        displayToastMessage("No account found for this email!. Create a new account: ", context);
      }

      if (errorCode == "wrong-password")
      {
        //errorNotif = "The password you entered is wrong. Enter correct password and try again";
        displayToastMessage("The password you entered is wrong. Enter correct password and try again", context);
      }
    }
  }

  displayToastMessage(String message, BuildContext context) {
    Fluttertoast.showToast(msg: message);
  }
}

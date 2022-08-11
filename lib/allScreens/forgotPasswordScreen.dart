import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:kuungaa/AllWidgets/progressDialog.dart';
import 'package:kuungaa/main.dart';
import 'package:kuungaa/sharedWidgets/widgets.dart';
import 'package:snippet_coder_utils/FormHelper.dart';
import 'package:snippet_coder_utils/ProgressHUD.dart';
import 'package:snippet_coder_utils/hex_color.dart';
class ForgotpasswordScreen extends StatefulWidget {
  const ForgotpasswordScreen({Key? key}) : super(key: key);

  static const String idScreen = "forgotPassword";

  @override
  State<ForgotpasswordScreen> createState() => _ForgotpasswordScreenState();
}

class _ForgotpasswordScreenState extends State<ForgotpasswordScreen> {

  bool isApiCallProcess = false;
  bool hidePassword = true;
  GlobalKey<FormState> globalFormKey = GlobalKey<FormState>();
  String? userEmail;

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
                "Forgot Password",
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
              "Enter your account email",
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
              prefixIcon: Icon(Icons.email),
              prefixIconColor: Colors.white,
              borderColor: Colors.white,
              textColor: Colors.white,
              hintColor: Colors.white.withOpacity(0.7),
              borderRadius: 5,
            ),
          ),
          /*Align(
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
                      text: 'Forget Password ?',
                      style: const TextStyle(
                        color: Colors.white,
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: TapGestureRecognizer()..onTap = () {},
                    ),
                  ],
                ),
              ),
            ),
          ),*/

          const SizedBox(
            height: 10,
          ),

          Center(
            child: FormHelper.submitButton(
              "Send Reset Link",
                  (){
                //print("Login");
                if(validateAndSave()){
                  // print("Ready email : " + userEmail.toString());
                  sendEmailLink(context, userEmail);
                }
              },
              btnColor: HexColor("#007E33"),
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
                      text: 'Remembered your password? ',
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
                          Navigator.pushNamed(context, "/login");
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
  void sendEmailLink(BuildContext context, String? userEmail) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context)
        {
          return ProgressDialog(message: "Sending, Please wait...",);
        }
    );

    usersRef.orderByChild("user_email").equalTo(userEmail!).once().then((DataSnapshot snapshot){
      if(snapshot.exists){
        _firebaseAuth.sendPasswordResetEmail(email: userEmail).then((value){
          Navigator.pop(context);
          displayToastMessage("A link to reset your password has been send to your email", context);
        }).catchError((errMsg){
          Navigator.pop(context);
          var errorMessage = errMsg.message;
          displayToastMessage(errorMessage, context);
        });
      }else{
        Navigator.pop(context);
        displayToastMessage("No account associated with the email address!", context);
      }
    });
  }

}

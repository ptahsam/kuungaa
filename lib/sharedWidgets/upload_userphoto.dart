import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kuungaa/AllWidgets/progressDialog.dart';
import 'package:kuungaa/Models/user.dart';
import 'package:kuungaa/config/config.dart';
import 'package:kuungaa/config/palette.dart';
import 'package:snippet_coder_utils/hex_color.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:path/path.dart' as path;

import 'widgets.dart';
class UploadUserPhoto extends StatefulWidget {
  final Users user;
  final String type;
  const UploadUserPhoto({
    Key? key,
    required this.user,
    required this.type
  }) : super(key: key);

  @override
  _UploadUserPhotoState createState() => _UploadUserPhotoState();
}

class _UploadUserPhotoState extends State<UploadUserPhoto> {

  File? userSelectedPhoto;
  bool _isButtonDisabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Palette.kuungaaDefault,
        leading: IconButton(
          icon: Icon(Icons.close),
          //iconSize: 36.0,
          color: Colors.white,
          onPressed: (){
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Upload " + widget.type + " photo",
          style: TextStyle(
            color: Colors.white,
            //fontSize: 22.0,
            //fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0.0,
        actions: [
          Container(
            margin: EdgeInsets.fromLTRB(0.0, 8.0, 12.0, 8.0),
            child: ElevatedButton(
              onPressed: _isButtonDisabled? (){
                savePhoto();
              } : null,
              child: Text("Done"),
            ),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 6.0,),
                userSelectedPhoto != null? Stack(
                  children: [
                    Container(
                      height: 200.0,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: FileImage(userSelectedPhoto!),
                          fit: BoxFit.cover,
                        ),
                        border: Border.all(
                          width: 0.5,
                          color: HexColor("#ced4da"),
                        ),
                        borderRadius: BorderRadius.circular(5.0),
                      ),

                    ),
                    Positioned(
                      right: 8.0,
                      top: 4.0,
                      child: ElevatedButton(
                        onPressed:  () async {
                          var res = await Navigator.push(context, MaterialPageRoute(builder: (context)=>FileSelector(allowMultiple: false, isUserPhoto: true,)));
                          setState(() {
                            userSelectedPhoto = res;
                            _isButtonDisabled = true;
                          });
                        },
                        child: Text("Change"),
                      ),
                    ),
                  ],
                ): Stack(
                  children: [
                    Container(
                        height: 200.0,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          border: Border.all(
                            width: 0.5,
                            color: HexColor("#ced4da"),
                          ),
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        child: Center(
                          child: Icon(
                            FontAwesomeIcons.image,
                            size: 40.0,
                            color: Colors.grey,
                          ),
                        )
                    ),
                    Positioned(
                      right: 8.0,
                      top: 4.0,
                      child: ElevatedButton(
                        onPressed:  () async {
                          var res = await Navigator.push(context, MaterialPageRoute(builder: (context)=>FileSelector(allowMultiple: false, isUserPhoto: true,)));
                          setState(() {
                            userSelectedPhoto = res;
                            _isButtonDisabled = true;
                          });
                        },
                        child: Text("Select"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> savePhoto() async {
    if(userSelectedPhoto != null){
      File file = File(userSelectedPhoto!.path);
      String basename = path.basename(userSelectedPhoto!.path);
      String filename = DateTime.now().millisecondsSinceEpoch.toString() + "-" + basename;
      if(widget.type == "profile"){
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context)
            {
              return ProgressDialog(message: "Uploading your profile photo, Please wait...",);
            }
        );
        firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance.ref().child("KUUNGAA").child("Users").child(userCurrentInfo!.user_id!).child("profiles").child(filename);

        firebase_storage.UploadTask uploadTask = ref.putFile(file);

        String imageUrl = await(await uploadTask).ref.getDownloadURL();

        Map<String, dynamic> updatePhotoMap = {
          "user_profileimage" : imageUrl,
        };

        FirebaseDatabase.instance.reference().child("KUUNGAA").child("Users").child(userCurrentInfo!.user_id!).update(updatePhotoMap).then((onValue) {
        displayToastMessage("Your have updated your profile image successfully", context);
        Navigator.pop(context);
        Navigator.pop(context);
        }).catchError((onError) {
          Navigator.pop(context);
          displayToastMessage("An error occurred. Please try again later", context);
        });
      }else{
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context)
            {
              return ProgressDialog(message: "Uploading your cover photo, Please wait...",);
            }
        );
        firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance.ref().child("KUUNGAA").child("Users").child(userCurrentInfo!.user_id!).child("covers").child(filename);

        firebase_storage.UploadTask uploadTask = ref.putFile(file);

        String imageUrl = await(await uploadTask).ref.getDownloadURL();

        Map<String, dynamic> updatePhotoMap = {
          "user_coverimage" : imageUrl,
        };

        FirebaseDatabase.instance.reference().child("KUUNGAA").child("Users").child(userCurrentInfo!.user_id!).update(updatePhotoMap).then((onValue) {
          displayToastMessage("Your have updated your cover image successfully", context);
          Navigator.pop(context);
          Navigator.pop(context);
        }).catchError((onError) {
          Navigator.pop(context);
          displayToastMessage("An error occurred. Please try again later", context);
        });
      }
    }
  }
}

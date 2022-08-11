import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:kuungaa/AllWidgets/progressDialog.dart';
import 'package:kuungaa/Assistants/assistantMethods.dart';
import 'package:kuungaa/DataHandler/appData.dart';
import 'package:kuungaa/Models/tagged.dart';
import 'package:kuungaa/config/config.dart';
import 'package:kuungaa/config/palette.dart';
import 'package:kuungaa/sharedWidgets/post_location.dart';
import 'package:kuungaa/sharedWidgets/select_expression.dart';
import 'package:kuungaa/sharedWidgets/widgets.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mime/mime.dart';
import 'package:provider/provider.dart';
import 'package:snippet_coder_utils/hex_color.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:path/path.dart' as path;

class CreateTravelPost extends StatefulWidget {
  const CreateTravelPost({Key? key}) : super(key: key);

  @override
  _CreateTravelPostState createState() => _CreateTravelPostState();
}



class _CreateTravelPostState extends State<CreateTravelPost> {

  late Position currentPosition;
  var geoLocator = Geolocator();
  String address = "";

  bool _isButtonDisabled = false;

  bool showLocation = true;

  List<File>? userTravelSelectedFileList = [];
  List travelSelectedTagged = [];

  String dropdownvalue = 'Public';

  String selectedCategoryName = "";
  String selectedCategoryId = "";

  TextEditingController postTextEditingController = TextEditingController();

  var items =  ['Public','Friends','Only Me'];

  String selectedExpression = "";


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    locatePosition();
  }

  //show your current location
  void locatePosition() async
  {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    currentPosition = position;

    address = await AssistantMethods.searchCoordinateAddress(position, context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Provider.of<AppData>(context).darkTheme?Palette.darker:Colors.white,
            pinned: true,
            leadingWidth: 30.0,
            leading: InkWell(
              onTap:()
              {
                Navigator.pop(context);
              },
              child: Icon(
                Icons.arrow_back,
                color: Provider.of<AppData>(context).darkTheme?Colors.white:Colors.black,
              ),
            ),
            title: Text("Create a travel post", style: TextStyle(fontSize: 18.0, color: Provider.of<AppData>(context).darkTheme?Colors.white:Colors.black)),
            actions: [
              Container(
                padding: const EdgeInsets.only(right: 12.0, top: 5.0, bottom: 5.0),
                child: ElevatedButton(
                  onPressed: _isButtonDisabled? (){
                    saveTravelPost();
                  } : null,
                  child: const Text("Post"),
                ),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      ProfileAvatar(imageUrl: userCurrentInfo != null?userCurrentInfo!.user_profileimage! : "", radius: 28.0,),
                      const SizedBox(width: 10.0,),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 15.0,),
                          Row(
                            children: [
                              Text(userCurrentInfo!.user_firstname != null? userCurrentInfo!.user_firstname! + " " + userCurrentInfo!.user_lastname! : ""),
                              selectedExpression != ""? const SizedBox(width: 6.0,):const SizedBox.shrink(),
                              selectedExpression != ""? Text(" - Feeling " + selectedExpression): const SizedBox.shrink(),
                            ],
                          ),
                          DropdownButtonHideUnderline(
                            child: DropdownButton(

                              value: dropdownvalue,
                              icon: const Icon(Icons.keyboard_arrow_down),
                              items:items.map((String items) {
                                return DropdownMenuItem(
                                    value: items,
                                    child: Row(
                                      children: [
                                        Text(items, style: const TextStyle(fontSize: 14.0),),
                                      ],
                                    )
                                );
                              }
                              ).toList(),
                              onChanged: (newValue){
                                setState(() {
                                  dropdownvalue = newValue!.toString();
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () async {
                    var res = await Navigator.push(context, MaterialPageRoute(builder: (context)=> const SelectTravelCategories()));
                    if(res != ""){
                      setState(() {
                        selectedCategoryName = res["category_name"];
                        selectedCategoryId = res["category_id"];
                      });
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12.0),
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 0.5,
                        color: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:HexColor("#ced4da"),
                      ),
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(selectedCategoryName != ""? selectedCategoryName  : "Select a category"),
                        const Icon(Icons.keyboard_arrow_down)
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
                  child: TextField(
                    onChanged: (value) {
                      //Do something with the user input.
                    },
                    controller: postTextEditingController,
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.newline,
                    minLines: 5,
                    maxLines: 5,
                    onTap: (){
                      if(_isButtonDisabled){}else{
                        setState(() {
                          _isButtonDisabled = true;
                        });
                      }
                    },
                    style: TextStyle(
                      color: Provider.of<AppData>(context).darkTheme?Colors.white:Colors.black,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Type something here',
                      hintStyle: TextStyle(
                        color: Provider.of<AppData>(context).darkTheme?Colors.white:Colors.black,
                      ),
                      contentPadding:
                      const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5.0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide:
                        BorderSide(color: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:HexColor("#ced4da"), width: 0.2),
                        borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide:
                        BorderSide(color: Colors.blueAccent, width: 0.2),
                        borderRadius: BorderRadius.all(Radius.circular(5.0)),
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(top: 15.0),
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(
                              color: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:HexColor("#ced4da"),
                              width: 0.5,

                            ),
                          ),
                        ),
                        child: InkWell(
                          onTap: () async {

                            var res = await Navigator.push(context, MaterialPageRoute(builder: (context)=>const FileSelector(allowMultiple: true, isUserPhoto: false,)));
                            setState(() {
                              userTravelSelectedFileList = res;
                              if(userTravelSelectedFileList!.isNotEmpty){
                                if(_isButtonDisabled){}else{

                                  _isButtonDisabled = true;

                                }
                              }
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(12.0, 8.0, 12.0, 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8.0),
                                  width: 55.0,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5.0),
                                    color: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.grey[300],
                                  ),
                                  child: const Icon(
                                    IconData(0xe92e, fontFamily: "icomoon"),
                                    color: Colors.green,
                                  ),
                                ),
                                const SizedBox(width: 12.0,),
                                const Expanded(
                                  child: Text(
                                      "Photo/Videos"
                                  ),
                                ),

                                userTravelSelectedFileList!.isNotEmpty ?
                                Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(60.0),
                                    ),
                                    child: Text(userTravelSelectedFileList!.length.toString())
                                ) :
                                const SizedBox.shrink(),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              border: Border(
                                top: BorderSide(
                                  color: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:HexColor("#ced4da"),
                                  width: 0.5,

                                ),
                              ),
                            ),
                            child: InkWell(
                              onTap: () async {
                                var res = await Navigator.push(context, MaterialPageRoute(builder: (context)=> const SelectExpression()));
                                if(res != ""){
                                  setState(() {
                                    selectedExpression = res;
                                  });
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8.0),
                                      width: 55.0,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5.0),
                                        color: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.grey[300],
                                      ),
                                      child: const Icon(
                                        IconData(0xe910, fontFamily: "icomoon"),
                                        color: Colors.blue,
                                      ),
                                    ),
                                    const SizedBox(width: 12.0,),
                                    const Expanded(
                                      child: Text(
                                          "Expression"
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              border: Border(
                                top: BorderSide(
                                  color: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:HexColor("#ced4da"),
                                  width: 0.5,

                                ),
                              ),
                            ),
                            child: InkWell(
                              onTap: () async{
                                var res = await Navigator.push(context, MaterialPageRoute(builder: (context)=>const PostLocation()));
                                if(res != ""){
                                  setState(() {
                                    showLocation = res;
                                  });
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8.0),
                                      width: 55.0,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5.0),
                                        color: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.grey[300],
                                      ),
                                      child: showLocation? const Icon(
                                        IconData(0xe926, fontFamily: "icomoon"),
                                        color: Colors.blue,
                                      ) : const Icon(
                                        MdiIcons.mapMarkerOffOutline,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(width: 12.0,),
                                    const Expanded(
                                      child: Text(
                                          "Location"
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                    top: BorderSide(
                                      color: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:HexColor("#ced4da"),
                                      width: 0.5,

                                    ),
                                    bottom: BorderSide(
                                      color: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:HexColor("#ced4da"),
                                      width: 0.5,

                                    ),
                                  ),
                                ),
                                child: InkWell(
                                  onTap: () async {
                                    var res = await Navigator.push(context, MaterialPageRoute(builder: (context)=>const TagUsers()));
                                    setState(() {
                                      travelSelectedTagged = res;
                                      if(travelSelectedTagged.isNotEmpty){
                                        if(_isButtonDisabled){}else{

                                          _isButtonDisabled = true;

                                        }
                                      }
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8.0),
                                          width: 55.0,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(5.0),
                                            color: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.grey[300],
                                          ),
                                          child: const Icon(
                                            IconData(0xe939, fontFamily: "icomoon"),
                                            color: Colors.red,
                                          ),
                                        ),
                                        const SizedBox(width: 12.0,),
                                        const Expanded(
                                          child: Text(
                                              "Tag other people"
                                          ),
                                        ),
                                        travelSelectedTagged.isNotEmpty ?
                                        Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
                                            decoration: BoxDecoration(
                                              color: Colors.green,
                                              borderRadius: BorderRadius.circular(60.0),
                                            ),
                                            child: Text(travelSelectedTagged.length.toString())
                                        ) :
                                        const SizedBox.shrink(),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void saveTravelPost() async {

      if(selectedCategoryId != ""){

        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context)
            {
              return ProgressDialog(message: "Uploading your post, Please wait... ",);
            }
        );

        DatabaseReference postRef = FirebaseDatabase.instance.reference().child('KUUNGAA').child('Posts').push();
        String refKey = postRef.key;
        String postcitylocation = Provider.of<AppData>(context, listen: false).userCurrentLocation!.placeCityName!;
        String postcountrylocation = Provider.of<AppData>(context, listen: false).userCurrentLocation!.placeCountryName!;
        String postcountrycode = Provider.of<AppData>(context, listen: false).userCurrentLocation!.placeCountryCode!;
        String postfinelocation = Provider.of<AppData>(context, listen: false).userCurrentLocation!.placeFormattedAddress!;
        String posterId = userCurrentInfo!.user_id!;
        String description = postTextEditingController.text;
        List tagged = [];
        List postmedia = [];
        String postprivacy = "";
        Map postlocation = {
          "latitude" : Provider.of<AppData>(context, listen: false).userCurrentLocation!.latitude!,
          "longitude" : Provider.of<AppData>(context, listen: false).userCurrentLocation!.longitude!,
          "locationaddress" : Provider.of<AppData>(context, listen: false).userCurrentLocation!.placeFormattedAddress!,
        };

        if(dropdownvalue == "Public"){
          postprivacy = "public";
        }else if(dropdownvalue == "Friends"){
          postprivacy = "friends";
        }else{
          postprivacy = "onlyme";
        }

        if(showLocation){
          postprivacy = "on";
        }else{
          postprivacy = "off";
        }

        if(travelSelectedTagged.isNotEmpty){
          for(var i = 0; i < travelSelectedTagged.length; i++){
            Tagged tag = Tagged();
            tag = travelSelectedTagged[i];

            Map userTaggedDetails = {
              "userid" : tag.userid!
            };

            tagged.add(userTaggedDetails);
          }
        }

        if(userTravelSelectedFileList!.isNotEmpty){
          for(var i = 0; i < userTravelSelectedFileList!.length; i++){
            String? mimeType = lookupMimeType(userTravelSelectedFileList![i].path);
            //print("User selected file" + mimeType!);
            File file = File(userTravelSelectedFileList![i].path);
            String basename = path.basename(userTravelSelectedFileList![i].path);
            firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance.ref().child("KUUNGAA").child("Posts").child(refKey).child(basename);
            //await ref.putFile(file).whenComplete((snapshot) => {});
            firebase_storage.UploadTask uploadTask = ref.putFile(file);

            String imageUrl = await(await uploadTask).ref.getDownloadURL();

            Map postmediadetails = {
              "url" : imageUrl,
              "type" : mimeType
            };

            postmedia.add(postmediadetails);

          }

          var offsetRef = FirebaseDatabase.instance.reference().child(".info/serverTimeOffset");
          offsetRef.onValue.listen((event){
            int offset = event.snapshot.value;
            var posttime = ((DateTime.now().millisecondsSinceEpoch) + offset);
            Map postDataMap = {
              "poster_id" : posterId,
              "post_id" : refKey,
              "post_description" : description,
              "post_time" : posttime,
              "post_category" : "travelfeed",
              "post_city" : postcitylocation,
              "post_countrycode" : postcountrycode,
              "post_countryname" : postcountrylocation,
              "post_finelocation" : postfinelocation,
              "post_location" : postlocation,
              "post_privacy" : postprivacy,
              "post_media" : postmedia,
              "post_tagged" : tagged.isEmpty? "" : tagged,
              "post_travelcategory" : selectedCategoryId,
              "post_expression" : selectedExpression,
            };
            postRef.set(postDataMap).then((onValue) {
              userTravelSelectedFileList!.clear();
              createNotification(refKey);
              Navigator.pop(context, "created_travel_post");
              Navigator.pop(context, "created_travel_post");
              displayToastMessage("Your post was uploaded successfully", context);
            }).catchError((onError) {
              Navigator.pop(context);
              displayToastMessage("An error occurred. Please try again later", context);
            });
            //print("Server offset: " + posttime);
          });

        }else{
          var offsetRef = FirebaseDatabase.instance.reference().child(".info/serverTimeOffset");
          offsetRef.onValue.listen((event){

            int offset = event.snapshot.value;
            var posttime = ((DateTime.now().millisecondsSinceEpoch) + offset);

            Map postDataMap = {
              "poster_id" : posterId,
              "post_id" : refKey,
              "post_description" : description,
              "post_time" : posttime,
              "post_category" : "travelfeed",
              "post_city" : postcitylocation,
              "post_countrycode" : postcountrycode,
              "post_countryname" : postcountrylocation,
              "post_finelocation" : postfinelocation,
              "post_location" : postlocation,
              "post_privacy" : postprivacy,
              "post_media" : "",
              "post_tagged" : tagged.isEmpty? "" : tagged,
              "post_travelcategory" : selectedCategoryId,
              "post_expression" : selectedExpression,
            };

            postRef.set(postDataMap).then((onValue) {
              createNotification(refKey);
              Navigator.pop(context, "created_travel_post");
              Navigator.pop(context, "create_travel_post");
              displayToastMessage("Your post was uploaded successfully", context);
            }).catchError((onError) {
              Navigator.pop(context);
              displayToastMessage("An error occurred. Please try again later", context);
            });

          });
      }
    }else{
      displayToastMessage("Please select a travel category", context);
    }
  }

  void createNotification(String refKey) {
    if(travelSelectedTagged.isNotEmpty){
      for(var i = 0; i < travelSelectedTagged.length; i++){
        Tagged tag = Tagged();
        tag = travelSelectedTagged[i];
        saveGeneralNotification("tagged you in a post", tag.userid!, "tagged", refKey);
      }
    }
  }

}



import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/bubble_type.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:flutter_chat_bubble/clippers/chat_bubble_clipper_8.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kuungaa/AllWidgets/progressDialog.dart';
import 'package:kuungaa/Assistants/assistantMethods.dart';
import 'package:kuungaa/DataHandler/appData.dart';
import 'package:kuungaa/Models/chat.dart';
import 'package:kuungaa/Models/message.dart';
import 'package:kuungaa/config/config.dart';
import 'package:kuungaa/config/palette.dart';
import 'package:kuungaa/sharedWidgets/make_channel.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mime/mime.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:path/path.dart' as path;
import 'package:snippet_coder_utils/hex_color.dart';

import 'widgets.dart';
class ChatScreen extends StatefulWidget {
  final Chat chat;
  const ChatScreen({
    Key? key,
    required this.chat
  }) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  List<File>? userSelectedFileList = [];

  TextEditingController messageTextEditingController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    AssistantMethods.getChatMessages(context, widget.chat.chat_id!);
    AssistantMethods.updateOnlineStatus(context, widget.chat.chat_opponentid!);
    AssistantMethods.userIsTyping(context, widget.chat.chat_id!, widget.chat.chat_opponentid!);
    updateChatMessages(widget.chat.chat_id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.kuungaaDefault,
      appBar: AppBar(
        backgroundColor: Palette.kuungaaDefault,
        leadingWidth: 30.0,
        title:InkWell(
          onTap: (){
            Navigator.pop(context);
            Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: UserProfile(userid: widget.chat.chat_opponentid!,)));

          },
          child: Row(
            children: [
              ProfileAvatar(imageUrl: widget.chat.opponentUser!.user_profileimage!),
              const SizedBox(width: 5.0,),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.chat.opponentUser!.user_firstname! + " " + widget.chat.opponentUser!.user_lastname!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w200,
                        fontSize: 13.0,

                        //fontSize: 22.0,
                        //fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),

                    Provider.of<AppData>(context).isTyping?
                    Text(
                      "... typing",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w100,
                        fontSize: 11.0,
                      ),
                    )

                    :Provider.of<AppData>(context).userOnlineStatus != null ? Text(
                      Provider.of<AppData>(context).userOnlineStatus!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w100,
                        fontSize: 11.0,
                      ),
                    ) : const Text(""),
                  ],
                ),
              ),
            ],
          ),
        ),
        centerTitle: false,
        elevation: 0.0,
        actions: [
          IconButton(
            icon: const Icon(MdiIcons.phone),
            //iconSize: 36.0,
            color: Colors.white,
            onPressed: (){
              displayToastMessage("This feature is currently under development.", context);
              //Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: MakeCall(username: widget.chat.opponentUser!.user_id!,)));
            },
          ),
          IconButton(
            icon: const Icon(MdiIcons.video),
            //iconSize: 36.0,
            color: Colors.white,
            onPressed: (){
              displayToastMessage("This feature is currently under development.", context);
              //Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: DataChannelSample(host: 'ws://192.168.100.211:3000',)));
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            //iconSize: 36.0,
            color: Colors.white,
            onPressed: (){

            },
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Provider.of<AppData>(context).darkTheme?Palette.lessDarker:Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    topRight: Radius.circular(30.0),
                  ),
                ),
                child: Provider.of<AppData>(context).chatMessages != null?
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    topRight: Radius.circular(30.0),
                  ),
                  child: ListView.builder(
                    itemCount: Provider.of<AppData>(context).chatMessages!.length,
                    reverse: true,
                    padding: const EdgeInsets.only(top: 15.0),
                    itemBuilder: (context, int index){
                      Message message = Provider.of<AppData>(context).chatMessages![index];
                      final bool isMe = message.sender_id == userCurrentInfo!.user_id!;
                      return _buildMessage(message, isMe);
                    },
                  ),
                ):const SizedBox.shrink(),
              ),
            ),
            Container(
              color: Provider.of<AppData>(context).darkTheme?Palette.lessDarker:Colors.white,
              child: Column(
                children: [
                  userSelectedFileList!.isNotEmpty ? Container(
                    height: 100.0,
                    color: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.grey[200]!,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.0),
                      itemCount: userSelectedFileList!.length,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (BuildContext context, int index){
                        File file = userSelectedFileList![index];
                        return Padding(
                          padding: const EdgeInsets.only(right: 5.0),
                          child: SizedBox(
                            height: 90.0,
                            width: 90.0,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(5.0),
                              child: Image.file(file, fit: BoxFit.cover,),
                            ),
                          ),
                        );
                      },
                    ),
                  ):const SizedBox.shrink(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                    margin: const EdgeInsets.only(bottom: 8.0, left: 10.0, right: 10.0),
                    decoration: BoxDecoration(
                      color: Palette.kuungaaDefault,
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(MdiIcons.attachment),
                          //iconSize: 36.0,
                          color: Colors.white,
                          onPressed: () => showModalBottomSheet(
                            isScrollControlled: true,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0)),
                            ),
                            context: context,
                            builder: (context) => buildSelectMediaSheet(),
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            textCapitalization: TextCapitalization.sentences,
                            controller: messageTextEditingController,
                            onChanged: (text) {
                              Map typingMap = {
                                "isTyping" : true,
                                "member_id" : userCurrentInfo!.user_id!
                              };
                              FirebaseDatabase.instance.reference().child("KUUNGAA").child("Chats").child(widget.chat.chat_id!).child("members").child(userCurrentInfo!.user_id!).set(typingMap);
                            },
                            decoration: const InputDecoration.collapsed(
                              hintText: "Type a message ...",
                              hintStyle: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.send_sharp),
                          //iconSize: 36.0,
                          color: Colors.white,
                          onPressed: (){
                            saveMessage();
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _buildMessage(Message message, bool isMe) {
    return isMe ? Wrap(
      alignment: WrapAlignment.end,
      children: [
        InkWell(
          onLongPress: (){
            showModalBottomSheet(
              isScrollControlled: true,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0)),
              ),
              context: context,
              builder: (context) => buildMessageSheet(message),
            );
          },
          child: Container(
            margin:  const EdgeInsets.only(top: 8.0, bottom: 8.0, right: 8.0, left: 15.0),
            child: ChatBubble(
              alignment: Alignment.centerRight,
              clipper: ChatBubbleClipper8(type: BubbleType.sendBubble),
              backGroundColor: Provider.of<AppData>(context).darkTheme?Palette.lessMediumDarker:Palette.kuungaaAccent,
              padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    convertToDate(message.time_created!),
                    style: TextStyle(
                      color: Provider.of<AppData>(context).darkTheme?Colors.white70:Colors.grey,
                      fontSize: 12.0,
                      fontWeight: FontWeight.w100,
                    ),
                  ),
                  message.messageMedia != null?
                  Padding(
                    padding: const EdgeInsets.only(top: 5.0),
                    child: MessageMedia(messageMedia: message.messageMedia!,),
                  ):const SizedBox.shrink(),
                  const SizedBox(height: 3.0,),
                  Text(
                    message.message!,
                    style: TextStyle(
                      color: Provider.of<AppData>(context).darkTheme?Colors.white:Colors.blueGrey,
                      fontSize: 15.0,
                      fontWeight: FontWeight.w100,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        /*InkWell(
          onLongPress: (){
            showModalBottomSheet(
              isScrollControlled: true,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0)),
              ),
              context: context,
                builder: (context) => buildMessageSheet(message),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 15.0),
            margin:  const EdgeInsets.only(top: 8.0, bottom: 8.0, right: 8.0, left: 15.0),
            decoration: BoxDecoration(
              color: Provider.of<AppData>(context).darkTheme?Palette.lessMediumDarker:Palette.kuungaaAccent,
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  convertToDate(message.time_created!),
                  style: TextStyle(
                    color: Provider.of<AppData>(context).darkTheme?Colors.white70:Colors.grey,
                    fontSize: 12.0,
                    fontWeight: FontWeight.w100,
                  ),
                ),
                message.messageMedia != null?
                Padding(
                  padding: const EdgeInsets.only(top: 5.0),
                  child: MessageMedia(messageMedia: message.messageMedia!,),
                ):const SizedBox.shrink(),
                const SizedBox(height: 3.0,),
                Text(
                  message.message!,
                  style: TextStyle(
                    color: Provider.of<AppData>(context).darkTheme?Colors.white:Colors.blueGrey,
                    fontSize: 15.0,
                    fontWeight: FontWeight.w100,
                  ),
                ),
              ],
            ),
          ),
        ),*/
      ],
    )
        :
    Wrap(
      alignment: WrapAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 8.0, bottom: 8.0, left: 8.0, right: 15.0),
          child: ChatBubble(
            alignment: Alignment.centerLeft,
            clipper: ChatBubbleClipper8(type: BubbleType.receiverBubble),
            backGroundColor: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Color(0xFFFFEFEE),
            padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  convertToDate(message.time_created!),
                  style: TextStyle(
                    color: Provider.of<AppData>(context).darkTheme?Colors.white70:Colors.grey,
                    fontSize: 12.0,
                    fontWeight: FontWeight.w100,
                  ),
                ),
                message.messageMedia != null?
                Padding(
                  padding: const EdgeInsets.only(top: 5.0),
                  child: MessageMedia(messageMedia: message.messageMedia!,),
                ):const SizedBox.shrink(),
                const SizedBox(height: 3.0,),
                Text(
                  message.message!,
                  style: TextStyle(
                    color: Provider.of<AppData>(context).darkTheme?Colors.white:Colors.blueGrey,
                    fontSize: 15.0,
                    fontWeight: FontWeight.w100,
                  ),
                ),
              ],
            ),
          ),
        ),
        /*Container(
          padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 15.0),
          margin: const EdgeInsets.only(top: 8.0, bottom: 8.0, left: 8.0, right: 15.0),
          decoration: BoxDecoration(
            color: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Color(0xFFFFEFEE),
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                convertToDate(message.time_created!),
                style: TextStyle(
                  color: Provider.of<AppData>(context).darkTheme?Colors.white70:Colors.grey,
                  fontSize: 12.0,
                  fontWeight: FontWeight.w100,
                ),
              ),
              message.messageMedia != null?
              Padding(
                padding: const EdgeInsets.only(top: 5.0),
                child: MessageMedia(messageMedia: message.messageMedia!,),
              ):const SizedBox.shrink(),
              const SizedBox(height: 3.0,),
              Text(
                message.message!,
                style: TextStyle(
                  color: Provider.of<AppData>(context).darkTheme?Colors.white:Colors.blueGrey,
                  fontSize: 15.0,
                  fontWeight: FontWeight.w100,
                ),
              ),
            ],
          ),
        ),*/
      ],
    )
    ;
  }

  Future<void> saveMessage() async {
    if(userSelectedFileList!.isNotEmpty){
      DatabaseReference msgRef = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Chats").child(widget.chat.chat_id!).child("messages").push();

      String msgkey = msgRef.key;
      int time = await getCurrentTime();
      String status = "0";
      List messagemedia = [];

      for(var i = 0; i < userSelectedFileList!.length; i++){
        String? mimeType = lookupMimeType(userSelectedFileList![i].path);
        String basename = path.basename(userSelectedFileList![i].path);
        //print("User selected file" + mimeType!);
        File file = File(userSelectedFileList![i].path);
        firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance.ref().child("KUUNGAA").child("Messages").child(msgkey).child(basename);
        //await ref.putFile(file).whenComplete((snapshot) => {});
        firebase_storage.UploadTask uploadTask = ref.putFile(file);

        String imageUrl = await(await uploadTask).ref.getDownloadURL();

        Map messagemediamap = {
          "url" : imageUrl,
          "type" : mimeType
        };

        messagemedia.add(messagemediamap);

      }

      Map msgMap = {
        "message_id" : msgkey,
        "message" : messageTextEditingController.text,
        "time_created" : time,
        "message_status" : status,
        "message_media" : messagemedia,
        "sender_id" : userCurrentInfo!.user_id!
      };

      msgRef.set(msgMap).then((onValue) {
        messageTextEditingController.text = "";
        userSelectedFileList!.clear();
        Map typingMap = {
          "isTyping" : false,
          "member_id" : userCurrentInfo!.user_id!
        };

        FirebaseDatabase.instance.reference().child("KUUNGAA").child("Chats").child(widget.chat.chat_id!).child("members").child(userCurrentInfo!.user_id!).set(typingMap);


        //displayToastMessage("Your post was uploaded successfully", context);
      }).catchError((onError) {

        Navigator.pop(context);
        displayToastMessage("An error occurred. Please try again later", context);
      });
    }else{
      DatabaseReference msgRef = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Chats").child(widget.chat.chat_id!).child("messages").push();

      String msgkey = msgRef.key;
      int time = await getCurrentTime();
      String status = "0";

      Map msgMap = {
        "message_id" : msgkey,
        "message" : messageTextEditingController.text,
        "time_created" : time,
        "message_status" : status,
        "message_media" : "",
        "sender_id" : userCurrentInfo!.user_id!
      };

      msgRef.set(msgMap).then((onValue) {
        messageTextEditingController.text = "";

        Map typingMap = {
          "isTyping" : false,
          "member_id" : userCurrentInfo!.user_id!
        };

        FirebaseDatabase.instance.reference().child("KUUNGAA").child("Chats").child(widget.chat.chat_id!).child("members").child(userCurrentInfo!.user_id!).set(typingMap);


        //displayToastMessage("Your post was uploaded successfully", context);
      }).catchError((onError) {
        Navigator.pop(context);
        displayToastMessage("An error occurred. Please try again later", context);
      });
    }
  }

  Widget buildSelectMediaSheet() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(3.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[200]!,
                ),
                child: Center(
                  child: IconButton(
                    icon: const Icon(MdiIcons.camera),
                    color: Palette.kuungaaDefault,
                    hoverColor: Colors.grey[100]!,
                    onPressed: (){

                    },
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(3.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[200]!,
                ),
                child: Center(
                  child: IconButton(
                    icon: const Icon(FontAwesomeIcons.photoVideo),
                    color: Palette.kuungaaDefault,
                    hoverColor: Colors.grey[100]!,
                    onPressed: () async {
                      Navigator.of(context).pop();
                      var res = await Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: const FileSelector(allowMultiple: true, isUserPhoto: false,)));
                      setState(() {
                        userSelectedFileList = res;
                        if(userSelectedFileList!.isNotEmpty){

                        }
                      });
                    },
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(3.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[200]!,
                ),
                child: Center(
                  child: IconButton(
                    icon: const Icon(MdiIcons.file),
                    color: Palette.kuungaaDefault,
                    hoverColor: Colors.grey[100]!,
                    onPressed: (){

                    },
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(3.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[200]!,
                ),
                child: Center(
                  child: IconButton(
                    icon: const Icon(MdiIcons.mapMarker),
                    color: Palette.kuungaaDefault,
                    hoverColor: Colors.grey[100]!,
                    onPressed: (){
                      //getLocationMap();
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildMessageSheet(Message message) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: (){
              Navigator.pop(context);
              deleteMessage(message);
            },
            child: Row(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8.0),
                  height: 60.0,
                  width: 60.0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        color: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.grey[200],
                        shape: BoxShape.circle,
                      ),
                      child: Provider.of<AppData>(context).darkTheme?Icon(
                        const IconData(0xe929, fontFamily: "icomoon"),
                        size: 26.0,
                        color: HexColor("#2dce89"),
                      ):ShaderMask(
                        shaderCallback: (rect) => Palette.createIconGradient.createShader(rect),
                        child: Icon(
                          const IconData(0xe929, fontFamily: "icomoon"),
                          size: 26.0,
                          color: HexColor("#2dce89"),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14.0,),
                const Text(
                  "Delete message",
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void deleteMessage(Message message) async{
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context)
        {
          return ProgressDialog(message: "Deleting message, Please wait...",);
        }
    );
    firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance.ref().child("KUUNGAA").child("Messages").child(message.message_id!);

    await ref.listAll().then((result) async {
      for (var file in result.items) {
        file.delete();
      }

      DatabaseReference msgRef = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Chats").child(widget.chat.chat_id!).child("messages").child(message.message_id!);
      await msgRef.remove().then((onValue) {
        Navigator.pop(context);
        displayToastMessage("Message deleted successfully", context);

      }).catchError((onError) {
        Navigator.pop(context);
        displayToastMessage("An error occurred. Please try again later", context);
      });
    });
  }

  getLocationMap() async {
    try {
      final Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.bestForNavigation);

      final Marker marker = Marker(
          markerId: MarkerId('locate'),
          zIndex: 1.0,
          draggable: true,
          position: LatLng(position.latitude, position.longitude));
      
      showDialog(
          context: context,
          builder: (_) => AlertDialog(
            content: FittedBox(
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                ),
                child: GoogleMap(
                  mapType: MapType.hybrid,
                  markers: Set.of([marker]),
                  initialCameraPosition: CameraPosition(
                    target: LatLng(position.latitude, position.longitude),
                    zoom: 18.4746,
                  ),
                ),
              ),
            ),
          )
      );
      
    }  catch (e) {
      print('Map Show Error: ${e.toString()}');
      displayToastMessage(e.toString(), context);
    }
  }

  void updateChatMessages(String? chat_id) async{
    Query query = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Chats").child(chat_id!).child("messages");
    await query.orderByChild("message_status").equalTo("0").once().then((DataSnapshot snapshot){
      if(snapshot.exists){
        var keys = snapshot.value.keys;
        var value = snapshot.value;
        for(var key in keys){
          Map<String, dynamic> messageMap = {
            "message_status" : "1",
          };
          FirebaseDatabase.instance.reference().child("KUUNGAA").child("Chats").child(chat_id).child("messages").child(key)
          .update(messageMap);
        }
      }
    });
    //displayToastMessage("Messages updated successfully", context);
  }

}


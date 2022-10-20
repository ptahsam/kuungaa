import 'dart:io';

import 'package:anim_search_bar/anim_search_bar.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/bubble_type.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:flutter_chat_bubble/clippers/chat_bubble_clipper_8.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:inview_notifier_list/inview_notifier_list.dart';
import 'package:kuungaa/AllWidgets/progressDialog.dart';
import 'package:kuungaa/Assistants/assistantMethods.dart';
import 'package:kuungaa/DataHandler/appData.dart';
import 'package:kuungaa/Models/chat.dart';
import 'package:kuungaa/Models/media.dart';
import 'package:kuungaa/Models/message.dart';
import 'package:kuungaa/Models/user.dart';
import 'package:kuungaa/config/config.dart';
import 'package:kuungaa/config/palette.dart';
import 'package:marquee/marquee.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mime/mime.dart';
import 'package:page_transition/page_transition.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:path/path.dart' as path;
import 'package:snippet_coder_utils/hex_color.dart';
import 'package:url_launcher/url_launcher.dart';

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
  List<Message> selectedMessages = [];

  TextEditingController messageTextEditingController = TextEditingController();

  Chat currentChat = Chat();

  double attachmentHeight = 100.0;
  bool isAttatchmentDefault = false;
  final recorder = FlutterSoundRecorder();
  bool isRecorderReady = false;
  PermissionStatus? status;
  bool isSending = false;
  bool messageSelectMode = false;
  bool isDeleting = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initRecorder();
    AssistantMethods.getChatMessages(context, widget.chat.chat_id!);
    AssistantMethods.updateOnlineStatus(context, widget.chat.chat_opponentid!);
    AssistantMethods.userIsTyping(context, widget.chat.chat_id!, widget.chat.chat_opponentid!);
    updateChatMessages(widget.chat.chat_id);
    currentChat = widget.chat;
    currentChat.chatIsOpen = true;
    Provider.of<AppData>(context, listen: false).updateCurrentChat(currentChat);
    messageTextEditingController.addListener(handleTextchange);
  }

   void handleTextchange() {
    if(messageTextEditingController.text != "" || messageTextEditingController != null){
      Map typingMap = {
        "isTyping" : true,
        "member_id" : userCurrentInfo!.user_id!
      };
      FirebaseDatabase.instance.reference().child("KUUNGAA").child("Chats").child(widget.chat.chat_id!).child("members").child(userCurrentInfo!.user_id!).set(typingMap);
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    recorder.closeRecorder();
    messageTextEditingController.removeListener(() { });
    super.dispose();
  }

  Future initRecorder() async {
    status = await Permission.microphone.request();
    if(status != PermissionStatus.granted){
      throw "Microphone access permission not granted";
    }
    await recorder.openRecorder();
    setState((){
      isRecorderReady = true;
    });
    recorder.setSubscriptionDuration(
      const Duration(microseconds: 500),
    );
  }

  Future record() async{
    if(!isRecorderReady) return;
    await recorder.startRecorder(
      toFile: "audio",
    );
  }

  Future stop() async{
    if(!isRecorderReady) return;
    final path = await recorder.stopRecorder();
    final audioFile = File(path!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.kuungaaDefault,
      appBar: selectedMessages.isNotEmpty?AppBar(
        backgroundColor: Palette.kuungaaDefault,
        leadingWidth: 40.0,
        leading: InkWell(
          onTap: (){
            setState(() {
              selectedMessages.clear();
            });
          },
          child: Icon(
            Icons.close,
            color: Colors.white,
          ),
        ),
        title: Text(
          selectedMessages.length.toString(),
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        actions: [
          isDeleting?Spinner(
          icon: FontAwesomeIcons.circleNotch)
          :IconButton(
            icon: const Icon(MdiIcons.delete),
            //iconSize: 36.0,
            color: Colors.white,
            onPressed: (){
              deleteMessages();
            },
          ),
          IconButton(
            icon: const Icon(MdiIcons.shareOutline),
            //iconSize: 36.0,
            color: Colors.white,
            onPressed: (){
              Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: ForwardContainer(forwardMessageList: selectedMessages,)));
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
      ):AppBar(
        backgroundColor: Palette.kuungaaDefault,
        leadingWidth: 40.0,
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

                    :Provider.of<AppData>(context).userOnlineStatus != null ?
                    Provider.of<AppData>(context).userOnlineStatus == "online"?Text(
                      Provider.of<AppData>(context).userOnlineStatus!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w100,
                        fontSize: 11.0,
                      ),
                    ):Container(
                      height: 20,
                      width: MediaQuery.of(context).size.width * 0.3,
                      child: Marquee(
                        text: Provider.of<AppData>(context).userOnlineStatus!,
                        style: TextStyle(fontSize: 11.0, color: Colors.white, fontWeight: FontWeight.w100,),
                        scrollAxis: Axis.horizontal,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        blankSpace: 20.0,
                        velocity: 100.0,
                        pauseAfterRound: Duration(seconds: 1),
                        startPadding: 10.0,
                        accelerationDuration: Duration(seconds: 1),
                        accelerationCurve: Curves.linear,
                        decelerationDuration: Duration(milliseconds: 500),
                        decelerationCurve: Curves.easeOut,
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
                  //color: Provider.of<AppData>(context).darkTheme?Palette.lessDarker:Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    topRight: Radius.circular(30.0),
                  ),
                  image: DecorationImage(
                    image: Provider.of<AppData>(context).darkTheme?AssetImage("images/chat_bg_dark.png"):AssetImage("images/chat_bg.png"),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Provider.of<AppData>(context).chatMessages != null?
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    topRight: Radius.circular(30.0),
                  ),
                  child: InViewNotifierList(
                    isInViewPortCondition:
                        (double deltaTop, double deltaBottom, double vpHeight) {
                      return deltaTop < (0.5 * vpHeight) && deltaBottom > (0.5 * vpHeight);
                    },
                    itemCount: Provider.of<AppData>(context).chatMessages!.length,
                    reverse: true,
                    padding: const EdgeInsets.only(top: 15.0),
                    builder: (context, int index){

                      Message message = Provider.of<AppData>(context).chatMessages![index];
                      Message nextMessage =  Provider.of<AppData>(context).chatMessages!.length - 1 > index?Provider.of<AppData>(context).chatMessages![index + 1]:Provider.of<AppData>(context).chatMessages![index];
                      Message prevMessage = index != 0?Provider.of<AppData>(context).chatMessages![index - 1]:Provider.of<AppData>(context).chatMessages![index];

                      final bool isMe = message.sender_id == userCurrentInfo!.user_id!;
                      final bool isFirst = index == Provider.of<AppData>(context).chatMessages!.length - 1;
                      //final bool prevMsgIsMine = prevMessage.sender_id == message.sender_id!;

                      return Column(
                          children: [
                            checkIsWhen(nextMessage.time_created!) != checkIsWhen(message.time_created!)?Container(
                              margin: EdgeInsets.only(top: 20, bottom: 10),
                              child: Center(
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                  decoration: BoxDecoration(
                                    color: Provider.of<AppData>(context).darkTheme?Palette.darker:Colors.grey[100]!,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    convertToWhen(message.time_created!),
                                  ),
                                ),
                              ),
                            ):message == nextMessage?Container(
                              margin: EdgeInsets.only(top: 20, bottom: 10),
                              child: Center(
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                  decoration: BoxDecoration(
                                    color: Provider.of<AppData>(context).darkTheme?Palette.darker:Colors.grey[100]!,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    convertToWhen(message.time_created!),
                                  ),
                                ),
                              ),
                            ):SizedBox.shrink(),
                            InViewNotifierWidget(
                              id: message.message_id!,
                              builder: (BuildContext context, bool isInView, Widget? child) {
                                //print("widget ${message.message_id} is in view status :: ${isInView}");
                                if(message.message_status != "1" && !isInView && message.sender_id != FirebaseAuth.instance.currentUser!.uid){
                                  //print("widget ${message.message_id} is in view status :: ${isInView}");
                                }
                                updateMessageStatus(message, isInView);
                                return InkWell(
                                  onLongPress: (){
                                    setState(() {
                                      selectedMessages.add(message);
                                    });
                                  },
                                  onTap: (){
                                    if(selectedMessages.isNotEmpty){
                                      if(selectedMessages.any((Message oldMessage) => oldMessage.message_id == message.message_id!)){
                                        setState(() {
                                          selectedMessages.removeWhere((Message oldMessage) => oldMessage.message_id == message.message_id!);
                                        });
                                      }else{
                                        setState(() {
                                          selectedMessages.add(message);
                                        });
                                      }
                                    }
                                  },
                                  child: MessageContainer(message: message, chat: widget.chat, isMe: isMe, isSelected: selectedMessages.any((Message oldMessage) => oldMessage.message_id == message.message_id!), isFirst:isFirst),
                                );
                              }
                            ),
                          ],
                      );
                    },
                  ),
                ):const SizedBox.shrink(),
              ),
            ),
            Container(
              color: Provider.of<AppData>(context).darkTheme?Palette.lessDarker:Colors.white,
              child: Column(
                children: [
                  userSelectedFileList!.isNotEmpty ? InkWell(
                    onTap: (){
                      setState(() {
                        if(isAttatchmentDefault){
                          attachmentHeight = 100;
                          isAttatchmentDefault = false;
                        }else{
                          attachmentHeight = 200;
                          isAttatchmentDefault = true;
                        }
                      });
                    },
                    child: Container(
                      child: Center(
                        child: isAttatchmentDefault?Icon(
                          Icons.keyboard_arrow_down_outlined,
                          size: 22,
                        ):Icon(
                          Icons.keyboard_arrow_up_outlined,
                          size: 22,
                        ),
                      ),
                    ),
                  ):SizedBox.shrink(),
                  userSelectedFileList!.isNotEmpty ? Container(
                    height: attachmentHeight,
                    color: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.grey[200]!,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.0),
                      itemCount: userSelectedFileList!.length,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (BuildContext context, int index){
                        File file = userSelectedFileList![index];
                        String? mimeType = lookupMimeType(file.path);
                        String basename = path.basename(file.path);
                        return Padding(
                          padding: const EdgeInsets.only(right: 5.0),
                          child: Stack(
                            children: [
                              mimeType!.contains("image/")?InkWell(
                                onTap: () async {
                                  var res = await Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: ImageViewEditor(imgFile: file,),));
                                },
                                child: SizedBox(
                                  height: attachmentHeight - 10,
                                  width: attachmentHeight - 10,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(5.0),
                                    child: Image.file(file, fit: BoxFit.cover,),
                                  ),
                                ),
                              ):mimeType.contains("audio/")?InkWell(
                                onTap: () async {
                                  final String filePath = file.absolute.path;
                                  final Uri uri = Uri.file(filePath);

                                  if (!File(uri.toFilePath()).existsSync()) {
                                    throw '$uri does not exist!';
                                  }
                                  if (!await launchUrl(uri)) {
                                  throw 'Could not launch $uri';
                                  }
                                },
                                child: SizedBox(
                                  height: attachmentHeight -10,
                                  width: attachmentHeight - 10,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5.0),
                                      color: Colors.white,
                                    ),
                                    child: Stack(
                                      children: [
                                        Positioned.fill(
                                          child: Icon(
                                            MdiIcons.music,
                                            color: Colors.red,
                                            size: 30,
                                          ),
                                        ),
                                        Positioned(
                                          bottom: 20,
                                          right: 10,
                                          left: 10,
                                          child: isAttatchmentDefault?Center(
                                            child: Text(
                                              basename,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ):SizedBox.shrink(),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ):mimeType.contains("application/")?SizedBox(
                                height: attachmentHeight -10,
                                width: attachmentHeight - 10,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5.0),
                                    color: Colors.white
                                  ),
                                  child: Stack(
                                    children: [
                                      Positioned.fill(
                                        child: mimeType.contains("application/pdf")?Icon(
                                          MdiIcons.filePdfBox,
                                          color: Colors.blue,
                                          size: 30,
                                        ):
                                        mimeType.contains("application/vnd.openxmlformats-officedocument.wordprocessingml.document")?Icon(
                                          MdiIcons.microsoftWord,
                                          color: Colors.greenAccent,
                                          size: 30,
                                        ):SizedBox.shrink(),
                                      ),
                                      Positioned(
                                        bottom: 20,
                                        right: 10,
                                        left: 10,
                                        child: isAttatchmentDefault?Center(
                                          child: Text(
                                            basename,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ):SizedBox.shrink(),
                                      ),
                                    ],
                                  ),
                                ),
                              ):SizedBox.shrink(),
                              isAttatchmentDefault?Positioned(
                                top: 10.0,
                                right: 10.0,
                                child: InkWell(
                                  onTap: (){
                                    setState(() {
                                      bool exists = userSelectedFileList!.any((File oldfile) => oldfile.path == file.path);
                                      if(exists){
                                        userSelectedFileList!.removeWhere((File oldfile) => oldfile.path == file.path);
                                      }
                                    });
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(6.0),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.close,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ):SizedBox.shrink(),
                            ],
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
                            onEditingComplete: (){
                                Map typingMap = {
                                  "isTyping" : false,
                                  "member_id" : userCurrentInfo!.user_id!
                                };
                                FirebaseDatabase.instance.reference().child("KUUNGAA").child("Chats").child(widget.chat.chat_id!).child("members").child(userCurrentInfo!.user_id!).set(typingMap);
                            },
                            onSubmitted: (String){
                                Map typingMap = {
                                  "isTyping" : false,
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
                        isSending?Container(
                          height: 20.0,
                          width: 20.0,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        ):IconButton(
                          icon: const Icon(Icons.send_sharp),
                          //iconSize: 36.0,
                          color: Colors.white,
                          onPressed: (){
                            setState(() {
                              isSending = true;
                            });
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

  Future<void> saveMessage() async {
    if(userSelectedFileList!.isNotEmpty){
      DatabaseReference msgRef = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Chats").child(widget.chat.chat_id!).child("messages").push();

      String msgkey = msgRef.key;
      var time = DateTime.now().millisecondsSinceEpoch;
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
          "type" : mimeType,
          "name" : basename
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
        isSending = false;

        Map typingMap = {
          "isTyping" : false,
          "member_id" : userCurrentInfo!.user_id!
        };

        FirebaseDatabase.instance.reference().child("KUUNGAA").child("Chats").child(widget.chat.chat_id!).child("members").child(userCurrentInfo!.user_id!).set(typingMap);

        //displayToastMessage("Your post was uploaded successfully", context);

      }).catchError((onError) {
        isSending = false;
        Navigator.pop(context);
        displayToastMessage("An error occurred. Please try again later", context);
      });
    }else{

      DatabaseReference msgRef = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Chats").child(widget.chat.chat_id!).child("messages").push();

      String msgkey = msgRef.key;
      var time = DateTime.now().millisecondsSinceEpoch;
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
        isSending = false;

        Map typingMap = {
          "isTyping" : false,
          "member_id" : userCurrentInfo!.user_id!
        };

        FirebaseDatabase.instance.reference().child("KUUNGAA").child("Chats").child(widget.chat.chat_id!).child("members").child(userCurrentInfo!.user_id!).set(typingMap);

        //displayToastMessage("Your post was uploaded successfully", context);
      }).catchError((onError) {
        isSending = false;
        Navigator.pop(context);
        displayToastMessage("An error occurred. Please try again later", context);
      });
    }
  }

  Widget buildRecordSoundSheet() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Record", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),),
              InkWell(
                onTap: (){
                  Navigator.pop(context);
                },
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.grey[200]!,
                  ),
                  child: const Icon(
                    Icons.close,
                    size: 25.0,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.0,),
          Center(
            child: Container(
              padding: EdgeInsets.all(6.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[200]!,
              ),
              child: Icon(
                MdiIcons.microphone,
                color: recorder.isRecording?Palette.kuungaaDefault:Colors.black,
                size: 40.0,
              ),
            ),
          ),
          SizedBox(height: 10.0,),
          StreamBuilder<RecordingDisposition>(
            stream: recorder.onProgress,
            builder: (ctx, snapshot){
              final duration = snapshot.hasData ? snapshot.data!.duration : Duration.zero;
              String twoDigits(int n) => n.toString().padLeft(0);
              final twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
              final twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
              return Text('$twoDigitMinutes:$twoDigitSeconds');
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: () async {
                    if (recorder.isRecording) {
                      await stop();
                    } else {
                      await record();
                    }
                    setState(() {

                    });
                },
                child: Row(
                  children: [
                    Icon(
                      recorder.isRecording?Icons.pause:Icons.play_arrow,
                    ),
                    Text(recorder.isRecording?"Stop":"Start"),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
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
              const Text("Select", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),),
              InkWell(
                onTap: (){
                  Navigator.pop(context);
                },
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.grey[200]!,
                  ),
                  child: const Icon(
                    Icons.close,
                    size: 25.0,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20.0,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(3.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.purpleAccent,
                ),
                child: Center(
                  child: IconButton(
                    icon: const Icon(MdiIcons.microphone),
                    color: Colors.white,
                    hoverColor: Colors.grey[100]!,
                    onPressed: () async {
                      Navigator.of(context).pop();
                      showModalBottomSheet(
                        isScrollControlled: true,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0)),
                        ),
                        context: context,
                        builder: (context) => buildRecordSoundSheet(),
                      );
                    },
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(3.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red,
                ),
                child: Center(
                  child: IconButton(
                    icon: const Icon(MdiIcons.music),
                    color: Colors.white,
                    hoverColor: Colors.grey[100]!,
                    onPressed: () async {
                      Navigator.of(context).pop();
                      FilePickerResult? result = await FilePicker.platform.pickFiles(
                          type: FileType.custom,
                          allowedExtensions: ['mp3', 'aac', 'flac', 'alac', 'wav', 'aiff', 'dsd'],
                          allowMultiple: true,
                          allowCompression: true
                      );
                      if(result != null){
                        setState(() {
                          userSelectedFileList = result.paths.map((path) => File(path!)).toList();
                        });
                      }
                    },
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(3.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blueAccent,
                ),
                child: Center(
                  child: IconButton(
                    icon: const Icon(FontAwesomeIcons.photoVideo),
                    color: Colors.white,
                    hoverColor: Colors.grey[100]!,
                    onPressed: () async {
                      Navigator.of(context).pop();
                      var res = await Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: const FileSelector(allowMultiple: true, isUserPhoto: false,)));
                      setState(() {
                        if(res != null || res != ""){
                          userSelectedFileList = res;
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
                  color: Colors.amberAccent,
                ),
                child: Center(
                  child: IconButton(
                    icon: const Icon(MdiIcons.file),
                    color: Colors.white,
                    hoverColor: Colors.grey[100]!,
                    onPressed: () async {
                      Navigator.of(context).pop();
                      FilePickerResult? result = await FilePicker.platform.pickFiles(
                        type: FileType.custom,
                        allowedExtensions: ['txt', 'pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx'],
                        allowMultiple: true,
                        allowCompression: true
                      );
                      if(result != null){
                        setState(() {
                          userSelectedFileList = result.paths.map((path) => File(path!)).toList();
                        });
                      }
                    },
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(3.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green,
                ),
                child: Center(
                  child: IconButton(
                    icon: const Icon(MdiIcons.mapMarker),
                    color: Colors.white,
                    hoverColor: Colors.grey[100]!,
                    onPressed: (){
                      getLocationMap();
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10.0,),
        ],
      ),
    );
  }

  getLocationMap() async {
    try {
      final Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.bestForNavigation);

          var res = await Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: ShareLocation(position: position,)));
      
      /*showDialog(
          context: context,
          builder: (_) => AlertDialog(
            content: FittedBox(
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.8,
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                ),
                child: Column(
                  children: [

                    GoogleMap(
                      mapType: MapType.normal,
                      markers: Set.of([marker]),
                      initialCameraPosition: CameraPosition(
                        target: LatLng(position.latitude, position.longitude),
                        zoom: 18.4746,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
      );*/
      
    }  catch (e) {
      print('Map Show Error: ${e.toString()}');
      displayToastMessage(e.toString(), context);
    }
  }

  void updateChatMessages(String? chat_id) async {
    Query query = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Chats").child(chat_id!).child("messages");
    await query.orderByChild("message_status").equalTo("0").once().then((DataSnapshot snapshot){
      if(snapshot.exists){
        var keys = snapshot.value.keys;
        var value = snapshot.value;
        for(var key in keys){
          if(value[key]["sender_id"] != FirebaseAuth.instance.currentUser!.uid){
            Map<String, dynamic> messageMap = {
              "message_status" : "1",
            };
            FirebaseDatabase.instance.reference().child("KUUNGAA").child("Chats").child(chat_id).child("messages").child(key)
                .update(messageMap);
          }
        }
      }
    });
    //displayToastMessage("Messages updated successfully", context);
  }

  void updateMessageStatus(Message message, bool isInView) {
    if(message.sender_id != FirebaseAuth.instance.currentUser!.uid && message.message_status != "1"){
      Map<String, dynamic> messageMap = {
        "message_status" : "1",
      };
      FirebaseDatabase.instance.reference().child("KUUNGAA").child("Chats").child(widget.chat.chat_id!).child("messages").child(message.message_id!)
          .update(messageMap);
    }
  }

  Future<void> deleteMessages() async {
    setState(() {
      isDeleting = true;
    });
    var count = 0;
    for(var i = 0; i < selectedMessages.length; i++){
      Message message = selectedMessages[i];
      if(message.messageMedia != null){
        firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance.ref().child("KUUNGAA").child("Messages").child(message.message_id!);
        await ref.listAll().then((result) async{
          for (var file in result.items) {
            file.delete();
          }
        });
      }

      DatabaseReference msgRef = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Chats").child(widget.chat.chat_id!).child("messages").child(message.message_id!);
        await msgRef.remove().then((onValue) {
          count = count + 1;
      }).catchError((onError) {
        displayToastMessage("An error occurred. Please try again later", context);
      });
      if(count == selectedMessages.length){
        setState(() {
          isDeleting = false;
          selectedMessages.clear();
        });
      }
    }
  }

}

class MessageContainer extends StatefulWidget {
  final Message message;
  final Chat chat;
  final bool isMe;
  final bool isSelected;
  final bool isFirst;
  const MessageContainer({
    Key? key,
    required this.message,
    required this.chat,
    required this.isMe,
    required this.isSelected,
    required this.isFirst,
  }) : super(key: key);

  @override
  State<MessageContainer> createState() => _MessageContainerState();
}

class _MessageContainerState extends State<MessageContainer> {

  String messageStatus = "";
  Query? msgRef;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    FirebaseDatabase database = FirebaseDatabase.instance;
    msgRef = database.reference().child('KUUNGAA').child("Chats").child(widget.chat.chat_id!).child("messages").child(widget.message.message_id!);
    messageStatus = widget.message.message_status!;
    msgRef!.onChildChanged.listen(_updateStatus);
  }

  _setStatus(Event event) {
    if(event.snapshot.exists){
      setState(() {
        messageStatus = event.snapshot.value["message_status"];
        print("message status ::: " + event.snapshot.value["message_status"]);
      });
    }
  }

  _updateStatus(Event event) {
    if(event.snapshot.exists){
      print("message status ::: " + event.snapshot.value);
      setState(() {
        messageStatus = event.snapshot.value["message_status"];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if(widget.isFirst){
      return Container(
        margin: EdgeInsets.only(bottom: 30.0, top: 5.0),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 15.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              color: Palette.kuungaaAccent,
            ),
            child: Text(
              "${widget.isMe?"You":widget.chat.opponentUser!.user_firstname! + " " + widget.chat.opponentUser!.user_lastname!} created this chat",
              style: TextStyle(
                color: Colors.blueGrey,
                fontWeight: FontWeight.w500,
                fontSize: 16.0,
              ),
            ),
          ),
        ),
      );
    }
    return widget.isMe ? Wrap(
      alignment: WrapAlignment.end,
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          decoration: Provider.of<AppData>(context).darkTheme?BoxDecoration(
            color: widget.isSelected?Colors.black26.withOpacity(0.5):Colors.transparent,
          ):BoxDecoration(
            color: widget.isSelected?Colors.grey[300]!.withOpacity(0.5):Colors.transparent,
          ),
          margin: widget.isSelected?EdgeInsets.symmetric(vertical: 8.0,):EdgeInsets.zero,
          child: Container(
            margin:  const EdgeInsets.only(top: 8.0, bottom: 8.0, right: 8.0, left: 35.0),
            child: ChatBubble(
              alignment: Alignment.centerRight,
              clipper: ChatBubbleClipper8(type: BubbleType.sendBubble),
              backGroundColor: Provider.of<AppData>(context).darkTheme?HexColor("#b7e3a8"):HexColor("#F0F9ED"),
              padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  widget.message.origin != null?Container(
                    padding: EdgeInsets.all(2.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(
                          MdiIcons.shareOutline,
                          color: Colors.grey,
                        ),
                        SizedBox(width: 4.0,),
                        Text(
                          "Forwarded",
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontStyle: FontStyle.italic,
                            color: Colors.grey
                          ),
                        ),
                      ],
                    ),
                  ):SizedBox.shrink(),
                  widget.message.messageMedia != null?
                  Padding(
                    padding: const EdgeInsets.only(top: 5.0),
                    child: MessageMedia(messageMedia: widget.message.messageMedia!,),
                  ):const SizedBox.shrink(),
                  const SizedBox(height: 3.0,),
                  Linkify(
                    onOpen: (link) async {
                      if (await canLaunchUrl(Uri.parse(link.url))) {
                        await launchUrl(Uri.parse(link.url));
                      } else {
                        throw 'Could not launch $link';
                      }
                    },
                    text: widget.message.message!,
                    style: TextStyle(color: Provider.of<AppData>(context).darkTheme?Colors.white:Colors.blueGrey,),
                    linkStyle: TextStyle(color: Colors.blue)
                  ),
                  SizedBox(height: 10.0,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        convertToPMAM(widget.message.time_created!),
                        style: TextStyle(
                          color: Provider.of<AppData>(context).darkTheme?Colors.black54:Colors.grey,
                          fontSize: 12.0,
                          fontWeight: FontWeight.w100,
                        ),
                      ),
                      SizedBox(width: 10.0,),
                      widget.message.message_status == "1"?Icon(
                        MdiIcons.checkAll,
                        color:Palette.kuungaaDefault,
                        size: 16.0,
                      ):Icon(
                        MdiIcons.check,
                        color:Colors.grey,
                        size: 16.0,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ):
    Wrap(
      alignment: WrapAlignment.start,
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          decoration: Provider.of<AppData>(context).darkTheme?BoxDecoration(
            color: widget.isSelected?Colors.black26.withOpacity(0.5):Colors.transparent,
          ):BoxDecoration(
            color: widget.isSelected?Colors.grey[300]!.withOpacity(0.5):Colors.transparent,
          ),
          margin: widget.isSelected?EdgeInsets.symmetric(vertical: 8.0,):EdgeInsets.zero,
          child: Container(
            margin: const EdgeInsets.only(top: 8.0, bottom: 8.0, left: 8.0, right: 35.0),
            child: ChatBubble(
              alignment: Alignment.centerLeft,
              clipper: ChatBubbleClipper8(type: BubbleType.receiverBubble),
              backGroundColor: Provider.of<AppData>(context).darkTheme?Palette.lessMediumDarker:HexColor("#ffffff"),
              padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  widget.message.origin != null?Container(
                    padding: EdgeInsets.all(2.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(
                          MdiIcons.shareOutline,
                          color: Colors.grey,
                        ),
                        SizedBox(width: 4.0,),
                        Text(
                          "Forwarded",
                          style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontStyle: FontStyle.italic,
                              color: Colors.grey
                          ),
                        ),
                      ],
                    ),
                  ):SizedBox.shrink(),
                  widget.message.messageMedia != null?
                  Padding(
                    padding: const EdgeInsets.only(top: 5.0),
                    child: MessageMedia(messageMedia: widget.message.messageMedia!,),
                  ):const SizedBox.shrink(),
                  const SizedBox(height: 3.0,),
                  Linkify(
                    onOpen: (link) async {
                      if (await canLaunch(link.url)) {
                        await launch(link.url);
                      } else {
                        throw 'Could not launch $link';
                      }
                    },
                    text: widget.message.message!,
                    style: TextStyle(color: Provider.of<AppData>(context).darkTheme?Colors.white:Colors.blueGrey,),
                    linkStyle: const TextStyle(color: Colors.blue),
                  ),
                  /*Text(
                    widget.message.message!,
                    style: TextStyle(
                      color: Provider.of<AppData>(context).darkTheme?Colors.white:Colors.blueGrey,
                      fontSize: 15.0,
                      fontWeight: FontWeight.w100,
                    ),
                  ),*/
                  SizedBox(height: 10.0,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        convertToPMAM(widget.message.time_created!),
                        style: TextStyle(
                          color: Provider.of<AppData>(context).darkTheme?Colors.white70:Colors.grey,
                          fontSize: 12.0,
                          fontWeight: FontWeight.w100,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
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
                        Icons.delete_forever_rounded,
                        size: 26.0,
                        color: Colors.red,
                      ):Icon(
                        Icons.delete_forever_rounded,
                        size: 26.0,
                        color: Colors.red,
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

}

class ShareLocation extends StatefulWidget {
  final Position position;
  const ShareLocation({
    Key? key,
    required this.position
  }) : super(key: key);

  @override
  State<ShareLocation> createState() => _ShareLocationState();
}

class _ShareLocationState extends State<ShareLocation> {

  Marker? marker;

  bool isContainerVisible = false;
  double containerHeight = 0.0;
  double toolBarHeight = 0.0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    marker = Marker(
    markerId: MarkerId('locate'),
    zIndex: 1.0,
    draggable: true,
    position: LatLng(widget.position.latitude, widget.position.longitude));

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Palette.kuungaaDefault,
            pinned: true,
            leadingWidth: 30.0,
            leading: InkWell(
              onTap:()
              {
                Navigator.pop(context);
              },
              child: Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
            ),
            title: Text("Share location", style: TextStyle(fontSize: 18.0, color: Colors.white)),
            centerTitle: false,
            actions: [
              IconButton(
                icon: isContainerVisible?Icon(Icons.close):Icon(Icons.search),
                //iconSize: 36.0,
                color: Colors.white,
                onPressed: (){
                  setState(() {
                    if(isContainerVisible){
                      toolBarHeight = 0.0;
                      containerHeight = 0.0;
                      isContainerVisible = false;
                    }else{
                      toolBarHeight = 150.0;
                      containerHeight = 130.0;
                      isContainerVisible = true;
                    }
                  });
                },
              ),
            ],
            bottom: AppBar(
              backgroundColor: Palette.kuungaaDefault,
              automaticallyImplyLeading: false,
              title: Visibility(
                visible: isContainerVisible,
                child: Container(
                  width: double.infinity,
                  height: containerHeight,
                  color: Colors.transparent,
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25.0)
                        ),
                        child: const Center(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Search for places...',
                              hintStyle: TextStyle(
                                color: Palette.kuungaaDefault
                              ),
                              prefixIcon: Icon(Icons.location_pin, color: Palette.kuungaaDefault,),
                              suffixIcon: Icon(Icons.keyboard_arrow_down_outlined, color: Palette.kuungaaDefault,),
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              toolbarHeight: toolBarHeight,
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.5,
              child: GoogleMap(
                mapType: MapType.normal,
                markers: Set.of([marker!]),
                initialCameraPosition: CameraPosition(
                  target: LatLng(widget.position.latitude, widget.position.longitude),
                  zoom: 18.4746,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ImageViewEditor extends StatefulWidget {
  final File imgFile;
  const ImageViewEditor({
    Key? key,
    required this.imgFile
  }) : super(key: key);

  @override
  State<ImageViewEditor> createState() => _ImageViewEditorState();
}

class _ImageViewEditorState extends State<ImageViewEditor> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Palette.kuungaaDefault,
        leading: InkWell(
          onTap: (){
            Navigator.pop(context);
          },
          child: Icon(
            Icons.close,
          ),
        ),
        title: Text("Edit Image"),
        centerTitle: false,
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Align(
          alignment: Alignment.center,
          child: Center(
            child: Image.file(widget.imgFile),
          ),
        ),
      ),
    );
  }
}

class ForwardContainer extends StatefulWidget {
  final List<Message> forwardMessageList;
  const ForwardContainer({
    Key? key,
    required this.forwardMessageList
  }) : super(key: key);

  @override
  State<ForwardContainer> createState() => _ForwardContainerState();
}

class _ForwardContainerState extends State<ForwardContainer> {

  List<Users> listUsers = [];
  List<Users> searchedList = [];
  List<Users> selectedUsers = [];
  TextEditingController textEditingController = TextEditingController();
  Query? itemRefUsers;
  bool _anchorToBottom = false;
  bool isForwarding = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final FirebaseDatabase database = FirebaseDatabase.instance;
    itemRefUsers = database.reference().child("KUUNGAA").child("Users");
    itemRefUsers!.onChildAdded.listen(_onEntryAddedUsers);
    textEditingController.addListener(handleTextchange);
  }

  _onEntryAddedUsers(Event event) async {
    if(event.snapshot.exists){
      if(event.snapshot.value["user_id"] != userCurrentInfo!.user_id!){
        Users users = Users();
        users.user_id = event.snapshot.value["user_id"];
        users.user_firstname = event.snapshot.value["user_firstname"];
        users.user_lastname = event.snapshot.value["user_lastname"];
        users.user_profileimage = event.snapshot.value["user_profileimage"];

        setState(() {
          listUsers.add(users);
        });
      }
    }
  }

  void handleTextchange() {
    if(textEditingController.text != "" || textEditingController != null){
      List<Users> result = listUsers.where((Users user)
      => user.user_firstname!.toLowerCase().contains(textEditingController.text.toLowerCase())
          || user.user_lastname!.toLowerCase().contains(textEditingController.text.toLowerCase())
      ).toSet().toList();
      setState(() {
        searchedList = result.toSet().toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
      return Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: Palette.kuungaaDefault,
              leadingWidth: 30.0,
              pinned: true,
              leading: InkWell(
                onTap: (){
                  Navigator.pop(context);
                },
                child: Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ),
              ),
              centerTitle: false,
              title: Text(
                "Forward to...",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              actions: [
                selectedUsers.isNotEmpty?Padding(
                  padding: const EdgeInsets.only(right: 20.0),
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      selectedUsers.length.toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.0,
                        fontWeight: FontWeight.w700
                      ),
                    ),
                  ),
                ):SizedBox.shrink(),
              ],
            ),
            SliverToBoxAdapter(
              child: Container(
                width: double.infinity,
                color: Provider.of<AppData>(context).darkTheme?Palette.lessDarker:Colors.white,
                padding: const EdgeInsets.only(left: 12.0, right: 12.0, top: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("SELECT"),
                    AnimSearchBar(
                      width: MediaQuery.of(context).size.width * 0.65,
                      textController: textEditingController,
                      color: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.grey[100]!,
                      style: TextStyle(
                        color: Provider.of<AppData>(context).darkTheme?Colors.white:Colors.black,
                      ),
                      rtl: true,
                      onSuffixTap: () {
                        setState(() {
                          textEditingController.clear();
                          searchedList.clear();
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: searchedList.isNotEmpty?Container(
                margin: EdgeInsets.only(bottom: 10.0),
                padding: const EdgeInsets.symmetric(horizontal: 12.0,),
                child: ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: searchedList.length,
                  itemBuilder: (ctx, int index){
                    return UsersList(user: searchedList[index],);
                  },
                ),
              ): Container(
                margin: EdgeInsets.only(bottom: 10.0),
                padding: const EdgeInsets.symmetric(horizontal: 12.0,),
                child: listUsers.isNotEmpty?FirebaseAnimatedList(
                    physics: const NeverScrollableScrollPhysics(),
                    query: itemRefUsers!,
                    reverse: _anchorToBottom,
                    key: ValueKey<bool>(_anchorToBottom),
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemBuilder:(_, DataSnapshot snapshot, Animation<double> animation, int index){
                      if(snapshot.exists){
                        if(index + 1 <= listUsers.length){
                          Users user = listUsers[index];
                          return InkWell(
                            onTap: (){
                              setState(() {
                                if(selectedUsers.any((Users oldUser) => oldUser.user_id == user.user_id!)){
                                  selectedUsers.removeWhere((Users oldUser) => oldUser.user_id == user.user_id);
                                }else{
                                  selectedUsers.add(user);
                                }
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                              margin: const EdgeInsets.only(bottom: 4.0,),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 0.1,
                                  color: Provider.of<AppData>(context).darkTheme?Palette.darker:Colors.grey
                                  ,
                                ),
                                color: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.white,
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      ProfileAvatar(imageUrl: user.user_profileimage != null? user.user_profileimage! : uProfile),
                                      const SizedBox(width: 6.0,),
                                      Text(user.user_firstname != null? user.user_firstname! : ""),
                                      const SizedBox(width: 4.0,),
                                      Text(user.user_lastname != null? user.user_lastname! : ""),
                                    ],
                                  ),
                                  selectedUsers.any((Users oldUser) => oldUser.user_id == user.user_id!) ? const Icon(
                                    MdiIcons.checkboxMarked,
                                    color: Palette.kuungaaDefault,
                                    size: 24.0,
                                  ) : const Icon(
                                    MdiIcons.checkboxBlankOutline,
                                    size: 24.0,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }else{
                          return SizedBox.shrink();
                        }
                      }else{
                        return SizedBox.shrink();
                      }
                    }
                ):Align(
                  alignment: Alignment.center,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),
            )
          ],
        ),
        floatingActionButton: selectedUsers.isNotEmpty?FloatingActionButton(
          backgroundColor: Palette.kuungaaDefault,
          onPressed: (){
            setState(() {
              isForwarding = true;
              sendMessages();
            });
          },
          child: isForwarding?SizedBox(
            width: 30.0,
            height: 30.0,
            child: CircularProgressIndicator(
              color: Colors.white,
            ),
          ):Icon(
            Icons.send,
            color: Colors.white,
            size: 32.0,
          ),
        ):null,
      );
  }

  void sendMessages() {
    var count = 0;
    for(var i = 0; i < widget.forwardMessageList.length; i++){
      Message forwardMessage = widget.forwardMessageList[i];

      var time = DateTime.now().millisecondsSinceEpoch;
      String status = "0";

      for(var j = 0; j < selectedUsers.length; j++){
        String selectedUserId = selectedUsers[j].user_id!;

        String commonid = "";
        String userid = userCurrentInfo!.user_id!;

        if(selectedUserId.compareTo(userid) == -1 ){
          commonid = selectedUserId + userid;
        }else{
          commonid = userid + selectedUserId;
        }

        var ref = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Chats").child(commonid);

        ref.once().then((DataSnapshot snapshot) async {
          if(snapshot.exists){
            DatabaseReference msgRef = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Chats").child(commonid).child("messages").push();

            List messageMedia = [];

            bool hasMedia = false;

            if(forwardMessage.messageMedia != null){
              hasMedia = true;
              for(var m = 0; m < forwardMessage.messageMedia!.length; m++){
                Media media = forwardMessage.messageMedia![m];

                Map messagemediamap = {
                  "url" : media.url!,
                  "type" : media.type!,
                  "name" : media.name != null?media.name!:""
                };

                messageMedia.add(messagemediamap);
              }
            }

            Map msgMap = {
              "message_id" : msgRef.key,
              "message" : forwardMessage.message!,
              "time_created" : time,
              "message_status" : status,
              "message_media" : hasMedia?messageMedia:"",
              "sender_id" : userCurrentInfo!.user_id!,
              "origin": "forwarded"
            };

            msgRef.set(msgMap).then((value){
              count = count + 1;
            });
          }else{
            var chattime = DateTime.now().millisecondsSinceEpoch;;
            Map membersMap = {};

            membersMap[userCurrentInfo!.user_id!] = {
              "member_id" : userCurrentInfo!.user_id!
            };
            membersMap[selectedUserId] = {
              "member_id" : selectedUserId
            };

            Map chatMap = {
              "chat_id" : commonid,
              "chat_creatorid" : userid,
              "chat_partnerid" : selectedUserId,
              "members" : membersMap,
              "chat_createdAt" : chattime
            };

            ref.set(chatMap).then((onValue) async {

              DatabaseReference msgRef = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Chats").child(commonid).child("messages").push();

              List messageMedia = [];

              bool hasMedia = false;

              if(forwardMessage.messageMedia != null){
                hasMedia = true;
                for(var m = 0; m < forwardMessage.messageMedia!.length; m++){
                  Media media = forwardMessage.messageMedia![m];

                  Map messagemediamap = {
                    "url" : media.url!,
                    "type" : media.type!,
                    "name" : media.name != null?media.name!:""
                  };

                  messageMedia.add(messagemediamap);
                }
              }

              Map msgMap = {
                "message_id" : msgRef.key,
                "message" : forwardMessage.message!,
                "time_created" : time,
                "message_status" : status,
                "message_media" : hasMedia?messageMedia:"",
                "sender_id" : userCurrentInfo!.user_id!,
                "origin": "forwarded"
              };

              msgRef.set(msgMap).then((value){
                count = count + 1;
              });
            }).catchError((onError) {
              displayToastMessage("An error occurred. Please try again later", context);
            });
          }
        });
      }
      if(count == ((widget.forwardMessageList.length)*selectedUsers.length)){
        setState(() {
          isForwarding = false;
        });
      }
    }
  }
}






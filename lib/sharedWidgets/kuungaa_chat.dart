import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:kuungaa/Assistants/assistantMethods.dart';
import 'package:kuungaa/DataHandler/appData.dart';
import 'package:kuungaa/Models/chat.dart';
import 'package:kuungaa/Models/user.dart';
import 'package:kuungaa/config/config.dart';
import 'package:kuungaa/config/palette.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';


import 'widgets.dart';
class KuungaaChat extends StatefulWidget {
  final ReceivedAction? receivedAction;
  const KuungaaChat({
    Key? key,
    this.receivedAction
  }) : super(
      key: key,
  );

  @override
  _KuungaaChatState createState() => _KuungaaChatState();
}

class _KuungaaChatState extends State<KuungaaChat> {

  final intInStr = RegExp(r'\d+');

  @override
  void initState() {
    // TODO: implement initState
    if(widget.receivedAction != null){
      navigateToChat(widget.receivedAction!.payload?['chatid']);
    }
    super.initState();
    AssistantMethods.getChats(context);
    AssistantMethods.getChatUsers(context);

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.kuungaaDefault,
      body: DefaultTabController(
        length: 3,
        child: NestedScrollView(
          scrollDirection: Axis.vertical,
          headerSliverBuilder: (context, bool s) => [
            SliverAppBar(
              backgroundColor: Palette.kuungaaDefault,
              leading: IconButton(
                icon: const Icon(Icons.close),
                //iconSize: 36.0,
                color: Colors.white,
                onPressed: (){
                  Navigator.of(context).pop();
                },
              ),
              /*title: const Text(
                "Chat",
                style: TextStyle(
                  color: Colors.white,
                  //fontSize: 22.0,
                  //fontWeight: FontWeight.bold,
                ),
              ),*/
              centerTitle: false,
              elevation: 0.0,
              actions: [
                /*IconButton(
                  icon: const Icon(Icons.search),
                  //iconSize: 36.0,
                  color: Colors.white,
                  onPressed: (){},
                ),*/
              ],
              bottom: TabBar(
                padding: EdgeInsets.symmetric(horizontal: 10.0,),
                indicator: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.white,
                      width: 3.0,
                    ),
                  ),
                  //borderRadius: BorderRadius.circular(5.0),
                ),
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            "Chats",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        Provider.of<AppData>(context).messageCount != null && userMessageCount > 0?SizedBox(width: 5.0,):SizedBox.shrink(),
                        Provider.of<AppData>(context).messageCount != null && userMessageCount > 0?Container(
                          height: 28,
                          width: 28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          child: Center(
                            child: Text(
                              Provider.of<AppData>(context).messageCount!.message_count!.toString(),
                              style: TextStyle(
                                color: Palette.kuungaaDefault,
                              ),
                            ),
                          ),
                        ):SizedBox.shrink(),
                      ],
                    ),
                  ),
                  Tab(
                    child: Text(
                      "Contacts",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  Tab(
                    child: Text(
                      "Calls",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ), //systemOverlayStyle: SystemUiOverlayStyle.dark,
            ),
          ],
            body: TabBarView(
              physics: const NeverScrollableScrollPhysics(),
              children: [
                CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Container(
                        margin: const EdgeInsets.only(top: 0.0),
                        height: MediaQuery.of(context).size.height,
                        decoration: BoxDecoration(
                          color: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Palette.kuungaaAccent,
                         /* borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30.0),
                            topRight: Radius.circular(30.0),
                          ),*/
                        ),
                        child: Column(
                          children: [
                            const FavoriteContacts(),
                            const ContactList(),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Provider.of<AppData>(context).darkTheme?Palette.lessDarker:Colors.white,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(30.0),
                                    topRight: Radius.circular(30.0),
                                  ),
                                ),

                                child: Provider.of<AppData>(context).userChats != null ?
                                Provider.of<AppData>(context).userChats!.isNotEmpty?ListView.builder(
                                    scrollDirection: Axis.vertical,
                                    itemCount: Provider.of<AppData>(context).userChats!.length,
                                    itemBuilder: (BuildContext context, int index)  {
                                      Chat chat = Provider.of<AppData>(context).userChats![index];
                                      AssistantMethods.userIsTyping(context, chat.chat_id!, chat.chat_opponentid!);
                                      String message = chat.message!.message!;
                                      int cutLength = 0;

                                      if(MediaQuery.of(context).size.width.toInt() > 375){
                                        cutLength = 17;
                                      }else if(MediaQuery.of(context).size.width.toInt() < 375 && MediaQuery.of(context).size.width.toInt() > 360){
                                        cutLength = 10;
                                      }else if(MediaQuery.of(context).size.width.toInt() < 360){
                                        cutLength = 7;
                                      }
                                      //print("message media type :: ${chat.message!.messageMedia != null?chat.message!.messageMedia![0].type:""}");
                                      if(intInStr.allMatches(message).map((m) => m.group(0)) != "" || intInStr.allMatches(message).map((m) => m.group(0)) != null){
                                        String num = intInStr.allMatches(message).map((m) => m.group(0)).toString();
                                        String fNum = num.replaceAll("(", "");
                                               fNum = num.replaceAll(")", "");
                                      }
                                      return InkWell(
                                        onTap: (){
                                          Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: ChatScreen(chat: chat,)));
                                        },
                                        child: Container(
                                          width: MediaQuery.of(context).size.width,
                                          margin: const EdgeInsets.only(top: 5.0, bottom: 0.0,),
                                          padding: const EdgeInsets.symmetric(horizontal: 12.0,),
                                          decoration: const BoxDecoration(
                                            //color: Color(0xFFFFEFEE),
                                            borderRadius: BorderRadius.only(
                                              bottomRight: Radius.circular(20.0),
                                              topRight: Radius.circular(20.0),
                                            ),
                                          ),
                                          child: ListTile(
                                            minVerticalPadding: 0,
                                            leading: ProfileAvatar(imageUrl: chat.opponentUser!.user_profileimage!, radius: 24.0,),
                                            title: Text(
                                              chat.opponentUser!.user_firstname! + " " + chat.opponentUser!.user_lastname!,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Provider.of<AppData>(context).darkTheme?Colors.white:Colors.black54,
                                                fontSize: 15.0,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            subtitle: chat.opponentUser!.isTyping?Text(
                                              "typing...",
                                              style: TextStyle(
                                                color: Palette.kuungaaDefault,
                                                fontSize: 12.0,
                                                fontWeight: FontWeight.w100,
                                              ),
                                            ):Row(
                                              children: [
                                                chat.message!.messageMedia != null? Padding(
                                                  padding: EdgeInsets.only(right: 5.0),
                                                  child: chat.message!.messageMedia![0].type!.contains("image/")?Icon(
                                                    MdiIcons.image,
                                                    size: 18.0,
                                                    color: Provider.of<AppData>(context).darkTheme?Colors.white:Colors.grey,
                                                  ):chat.message!.messageMedia![0].type!.contains("audio/")?Icon(
                                                    MdiIcons.headset,
                                                    size: 18.0,
                                                    color: Provider.of<AppData>(context).darkTheme?Colors.white:Colors.grey,
                                                  ):chat.message!.messageMedia![0].type!.contains("application/pdf")?Icon(
                                                    MdiIcons.filePdfBox,
                                                    size: 18.0,
                                                    color: Provider.of<AppData>(context).darkTheme?Colors.white:Colors.grey,
                                                  ):chat.message!.messageMedia![0].type!.contains("application/vnd.openxmlformats-officedocument.wordprocessingml.document") ||
                                                    chat.message!.messageMedia![0].type!.contains("application/msword")?Icon(
                                                    MdiIcons.fileWordBox,
                                                    size: 18.0,
                                                    color: Provider.of<AppData>(context).darkTheme?Colors.white:Colors.grey,
                                                  ):chat.message!.messageMedia![0].type!.contains("application/vnd.ms-excel") ||
                                                    chat.message!.messageMedia![0].type!.contains("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")?Icon(
                                                    MdiIcons.fileExcelBox,
                                                    size: 18.0,
                                                    color: Provider.of<AppData>(context).darkTheme?Colors.white:Colors.grey,
                                                  ):chat.message!.messageMedia![0].type!.contains("application/vnd.ms-powerpoint")?Icon(
                                                    MdiIcons.filePowerpointBox,
                                                    size: 18.0,
                                                    color: Provider.of<AppData>(context).darkTheme?Colors.white:Colors.grey,
                                                  ):chat.message!.messageMedia![0].type!.contains("application/vnd.openxmlformats-officedocument.presentationml.presentation")?Icon(
                                                    MdiIcons.filePresentationBox,
                                                    size: 18.0,
                                                    color: Provider.of<AppData>(context).darkTheme?Colors.white:Colors.grey,
                                                  ):chat.message!.messageMedia![0].type!.contains("text/plain")?Icon(
                                                    MdiIcons.fileDocument,
                                                    size: 18.0,
                                                    color: Provider.of<AppData>(context).darkTheme?Colors.white:Colors.grey,
                                                  ):chat.message!.messageMedia![0].type!.contains("video/")?Icon(
                                                    MdiIcons.videoBox,
                                                    size: 18.0,
                                                    color: Provider.of<AppData>(context).darkTheme?Colors.white:Colors.grey,
                                                  ):SizedBox.shrink(),
                                                ):const SizedBox.shrink(),
                                                chat.message != null? chat.message!.sender_id == userCurrentInfo!.user_id?Expanded(
                                                  child: Row(
                                                    children: [
                                                      Text(
                                                        message.length > 20?message.substring(0, 17) + " ...":message,
                                                        style: TextStyle(
                                                          color: Provider.of<AppData>(context).darkTheme?Colors.white:Colors.blueGrey,
                                                          fontSize: 14.0,
                                                          fontWeight: FontWeight.w100,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                      chat.message!.message_status == "1"?SizedBox(width: 8.0,):SizedBox.shrink(),
                                                      chat.message!.message_status == "1"?Icon(
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
                                                ):chat.chatCount != null && chat.chatCount != 0?Text(
                                                  message.length > 20?message.substring(0, cutLength) + " ...":message,
                                                  style: TextStyle(
                                                    color: Palette.kuungaaDefault,
                                                    fontSize: 14.0,
                                                    fontWeight: FontWeight.w100,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ):Text(
                                                  message.length > 20?message.substring(0, cutLength) + " ...":message,
                                                  style: TextStyle(
                                                    color: Provider.of<AppData>(context).darkTheme?Colors.white:Colors.blueGrey,
                                                    fontSize: 14.0,
                                                    fontWeight: FontWeight.w100,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ): const Text(""),
                                              ],
                                            ),
                                            trailing: Column(
                                              crossAxisAlignment: CrossAxisAlignment.end,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  convertToChattime(chat.message!.time_created!),
                                                  style: TextStyle(
                                                    color: Provider.of<AppData>(context).darkTheme?Colors.white:Colors.grey,
                                                    fontSize: 12.0,
                                                    fontWeight: FontWeight.w100,
                                                  ),
                                                ),
                                                chat.chatCount != null && chat.chatCount != 0?Container(
                                                  padding: EdgeInsets.all(5.0),
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: Palette.kuungaaDefault,
                                                  ),
                                                  child: Text(
                                                    chat.chatCount.toString(),
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ):SizedBox.shrink(),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                ): Align(
                                    alignment: Alignment.center,
                                    child: Container(
                                      height: MediaQuery.of(context).size.height * 0.13,
                                      width: MediaQuery.of(context).size.width * 0.65,
                                      decoration: BoxDecoration(
                                        color: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.grey[100]!,
                                        borderRadius: BorderRadius.circular(10.0),
                                      ),
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.message,
                                              color: Provider.of<AppData>(context).darkTheme?Colors.white70:Colors.grey,
                                            ),
                                            SizedBox(height: 6.0,),
                                            Text("Select a contact \n to start a conversation", textAlign: TextAlign.center,),
                                          ],
                                        ),
                                      ),
                                    ),
                                ) : Align(
                                  alignment: Alignment.center,
                                  child: Container(
                                    height: 40,
                                    width: 40,
                                    child: Center(
                                      child: LoadingAnimationWidget.horizontalRotatingDots(
                                        color: Palette.kuungaaDefault,
                                        size: 40
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: UserContacts(),
                    ),
                  ],
                ),
                CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Container(
                        color: Provider.of<AppData>(context).darkTheme?Palette.lessDarker:Colors.white,
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                        child: const Align(
                          alignment: Alignment.center,
                          child: Center(
                            child: Text("No call history"),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            )
        ),
      ),
    );
  }

  Future<List> getChats() async{
    List<Chat> userChatList = [];
    DatabaseReference dbRef = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Chats");
    await dbRef.once().then((DataSnapshot snapshot) async {
      if(snapshot.exists){
        userChatList.clear();
        var keys = snapshot.value.keys;
        var values = snapshot.value;

        for(var key in keys){
          Chat chat = Chat();
          DatabaseReference userChatRef = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Chats").child(key).child("members").child(userCurrentInfo!.user_id!);
          await userChatRef.once().then((DataSnapshot dataSnapshot) async {
            if(dataSnapshot.exists){
              chat.chat_createddate = values[key]["chat_createddate"];
              chat.chat_id = values[key]["chat_id"];
              chat.chat_creatorid = values[key]["chat_creatorid"];
              chat.chat_partnerid = values[key]["chat_partnerid"];
              DatabaseReference memberRef = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Chats").child(key).child("members");
              await memberRef.once().then((DataSnapshot members){
                var zees = members.value.keys;
                var data = members.value;
                for(var zee in zees){
                  if(data[zee]["member_id"] != userCurrentInfo!.user_id!){
                    chat.chat_opponentid = data[zee]["member_id"];
                  }
                }
              });
              chat.opponentUser = await AssistantMethods.getCurrentOnlineUser(chat.chat_opponentid!);
              userChatList.add(chat);
            }
          });
        }
      }
    });
    return userChatList.reversed.toList();
  }

  Future<Chat> getChatFromID(String chatid) async{
    Chat chat = Chat();
    DatabaseReference userChatRef = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Chats").child(chatid);
    await userChatRef.once().then((DataSnapshot dataSnapshot) async {
      if(dataSnapshot.exists){
        chat.chat_createddate = dataSnapshot.value["chat_createddate"];
        chat.chat_id = dataSnapshot.value["chat_id"];
        chat.chat_creatorid = dataSnapshot.value["chat_creatorid"];
        chat.chat_partnerid = dataSnapshot.value["chat_partnerid"];
        DatabaseReference memberRef = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Chats").child(chatid).child("members");
        await memberRef.once().then((DataSnapshot members){
          var zees = members.value.keys;
          var data = members.value;
          for(var zee in zees){
            if(data[zee]["member_id"] != userCurrentInfo!.user_id!){
              chat.chat_opponentid = data[zee]["member_id"];
            }
          }
        });
        chat.opponentUser = await AssistantMethods.getCurrentOnlineUser(chat.chat_opponentid!);
      }
    });
    return chat;
  }

  void navigateToChat(String? payload) {
    Future.delayed(Duration.zero,()
    async{
      Chat chat = await getChatFromID(payload!);
      Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: ChatScreen(chat: chat,)));
    });
  }
}


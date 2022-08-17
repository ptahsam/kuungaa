import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:kuungaa/Assistants/assistantMethods.dart';
import 'package:kuungaa/DataHandler/appData.dart';
import 'package:kuungaa/Models/chat.dart';
import 'package:kuungaa/Models/user.dart';
import 'package:kuungaa/config/config.dart';
import 'package:kuungaa/config/palette.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';


import 'widgets.dart';
class KuungaaChat extends StatefulWidget {
  const KuungaaChat({Key? key}) : super(key: key);

  @override
  _KuungaaChatState createState() => _KuungaaChatState();
}

class _KuungaaChatState extends State<KuungaaChat> {
  @override
  void initState() {
    // TODO: implement initState
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
              title: const Text(
                "Chat",
                style: TextStyle(
                  color: Colors.white,
                  //fontSize: 22.0,
                  //fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: false,
              elevation: 0.0,
              actions: [
                IconButton(
                  icon: const Icon(Icons.search),
                  //iconSize: 36.0,
                  color: Colors.white,
                  onPressed: (){},
                ),
              ],
              bottom: const TabBar(
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
                    child: Text(
                      "Chats",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
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
                                      return InkWell(
                                        onTap: (){
                                          Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: ChatScreen(chat: chat,)));
                                        },
                                        child: Container(
                                          width: MediaQuery.of(context).size.width,
                                          margin: const EdgeInsets.only(top: 5.0, bottom: 0.0,),
                                          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                                          decoration: const BoxDecoration(
                                            //color: Color(0xFFFFEFEE),
                                            borderRadius: BorderRadius.only(
                                              bottomRight: Radius.circular(20.0),
                                              topRight: Radius.circular(20.0),
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              ProfileAvatar(imageUrl: chat.opponentUser!.user_profileimage!, radius: 24.0,),
                                              const SizedBox(width: 10.0,),
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        Text(
                                                          chat.opponentUser!.user_firstname! + " " + chat.opponentUser!.user_lastname!,
                                                          style: TextStyle(
                                                            fontWeight: FontWeight.bold,
                                                            color: Provider.of<AppData>(context).darkTheme?Colors.white:Colors.black54,
                                                            fontSize: 15.0,
                                                          ),
                                                        ),
                                                        chat.message != null? Text(
                                                          convertToDate(chat.message!.time_created!),
                                                          style: TextStyle(
                                                            color: Provider.of<AppData>(context).darkTheme?Colors.white:Colors.grey,
                                                            fontSize: 12.0,
                                                            fontWeight: FontWeight.w100,
                                                          ),
                                                        ): const Text(""),
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4.0,),
                                                  Row(
                                                    children: [
                                                      chat.message!.messageMedia != null? Padding(
                                                        padding: EdgeInsets.only(right: 5.0),
                                                        child: Icon(
                                                          Icons.perm_media_outlined,
                                                          size: 18.0,
                                                          color: Provider.of<AppData>(context).darkTheme?Colors.white:Colors.grey,
                                                        ),
                                                      ):const SizedBox.shrink(),
                                                      chat.message != null? Text(
                                                        chat.message!.message!,
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
                                                ],
                                              ),
                                            ],
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
                      child: Container(
                        color: Provider.of<AppData>(context).darkTheme?Palette.lessDarker:Colors.white,
                        padding: const EdgeInsets.only(left: 12.0, right: 12.0, top: 0.0),
                        height: MediaQuery.of(context).size.height,
                        child: Provider.of<AppData>(context).chatUsersList != null?
                        ListView.builder(
                          itemCount: Provider.of<AppData>(context).chatUsersList!.length,
                          scrollDirection: Axis.vertical,
                          itemBuilder: (BuildContext context, int index){
                            Users user = Provider.of<AppData>(context).chatUsersList![index];
                            return InkWell(
                              onTap: (){
                                startMessegeUser(context, user.user_id!);
                              },
                              child: ListTile(
                                leading: ProfileAvatar(imageUrl: user.user_profileimage!,),
                                title: Text(user.user_firstname! + " " + user.user_lastname!),
                                subtitle: Text(user.user_bio!),
                              ),
                            );
                          },
                        ):const SizedBox.shrink(),
                      ),
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
}


import 'package:anim_search_bar/anim_search_bar.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:kuungaa/DataHandler/appData.dart';
import 'package:kuungaa/Models/tagged.dart';
import 'package:kuungaa/Models/user.dart';
import 'package:kuungaa/config/config.dart';
import 'package:kuungaa/config/palette.dart';
import 'package:kuungaa/sharedWidgets/profile_avatar.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
class TagUsers extends StatefulWidget {
  const TagUsers({Key? key}) : super(key: key);

  @override
  _TagUsersState createState() => _TagUsersState();
}

class _TagUsersState extends State<TagUsers> {

  //bool _isChecked = false;
  TextEditingController textEditingController = TextEditingController();
  List<Users> listUsers = [];
  List<Users> searchedList = [];
  Query? itemRefUsers;
  bool _anchorToBottom = false;

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
            backgroundColor: Provider.of<AppData>(context).darkTheme?Palette.darker:Colors.white,
            pinned: true,
            leadingWidth: 30.0,
            title: Text("Tag other people", style: TextStyle(fontSize: 18.0,color: Provider.of<AppData>(context).darkTheme?Colors.white:Colors.black)),
            leading: GestureDetector(
              onTap:()
              {
                Navigator.pop(context, taggedUsers);
              },
              child: Icon(
                  Icons.arrow_back,
                  color: Provider.of<AppData>(context).darkTheme?Colors.white:Colors.black,
              ),
            ),
            actions: [
              Container(
                padding:  EdgeInsets.only(top: 5.0,right: 5.0,bottom: 5.0),
                child: ElevatedButton(
                  onPressed: () => {
                    Navigator.pop(context, taggedUsers),
                  },
                  child: const Text("Done"),
                ),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Container(
              width: double.infinity,
              color: Provider.of<AppData>(context).darkTheme?Palette.lessDarker:Colors.white,
              padding: const EdgeInsets.only(left: 12.0, right: 12.0, top: 12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Tag other people to include in your post"),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("SELECT"),
                      AnimSearchBar(
                        width: MediaQuery.of(context).size.width * 0.65,
                        textController: textEditingController,
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
                      return UsersList(user: listUsers[index],);
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
              /*ListView.builder(
              itemCount: usersList.length,
              itemBuilder: (BuildContext context, int index)
              {
              if(usersList[index].user_id != userCurrentInfo!.user_id!){
                return InkWell(
                    onTap: (){
                      Tagged tagged = new Tagged();

                      taggedUsers.removeWhere((element) => element.userid == taggedUsers[index].userid!);

                      tagged.userid = usersList[index].user_id!;
                      taggedUsers.add(tagged);
                      setState(() {
                        taggedCount = taggedUsers.length.toString();
                      });
                      print("Tagged users " + taggedUsers.toString());
                    },
                    child: UsersList(user: usersList[index]),
                );
              }
                return SizedBox.shrink();
              }
            ),*/
            ),
          ),
        ],
      ),
    );
  }

  Future<List> fetchListItems() async {
    List<Users> usersList = [];
    DatabaseReference dbReference = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Users");
    await dbReference.once().then((DataSnapshot dataSnapshot){
      usersList.clear();
      var keys = dataSnapshot.value.keys;
      var values = dataSnapshot.value;

      for (var key in keys)
      {
        if(values [key]["user_id"] != userCurrentInfo!.user_id!){
          Users users = Users();
          users.user_id = values [key]["user_id"];
          users.user_firstname = values [key]["user_firstname"];
          users.user_lastname = values [key]["user_lastname"];
          users.user_profileimage = values [key]["user_profileimage"];

          usersList.add(users);
        }
      }
    });
    return usersList;
  }
}

class UsersList extends StatefulWidget {
  final Users? user;

  const UsersList({
    Key? key,
    this.user
  }) : super(key: key);

  @override
  State<UsersList> createState() => _UsersListState();
}

class _UsersListState extends State<UsersList> {
  bool _isChecked = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(taggedUsers.isNotEmpty){
    for(var i = 0; i < taggedUsers.length; i++){
    }
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){
        setState(() {
          if(_isChecked){
            _isChecked = false;
            taggedUsers.removeWhere((Tagged tagged) => tagged.userid == widget.user!.user_id!);
          }else{
            _isChecked = true;
            /*var tagged = {
              'userid': widget.user!.user_id!
            };*/
            Tagged tagged = Tagged();
            tagged.userid = widget.user!.user_id!;
            taggedUsers.add(tagged);
            print(taggedUsers.length);
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
                ProfileAvatar(imageUrl: widget.user!.user_profileimage != null? widget.user!.user_profileimage! : uProfile),
                const SizedBox(width: 6.0,),
                Text(widget.user!.user_firstname != null? widget.user!.user_firstname! : ""),
                const SizedBox(width: 4.0,),
                Text(widget.user!.user_lastname != null? widget.user!.user_lastname! : ""),
              ],
            ),
            _isChecked ? const Icon(
               MdiIcons.checkboxMarked,
              color: Colors.blue,
              size: 24.0,
            ) : const Icon(
               MdiIcons.checkboxBlankOutline,
              size: 24.0,
            ),
            /*Checkbox(
              value: _isChecked,
              onChanged: (value){

                setState(() {

                  if(value == true){
                    _isChecked = true;
                    taggedUsers.removeWhere((Tagged tagged) => tagged.userid == widget.user!.user_id!);
                  }else{
                    _isChecked = false;
                    Tagged tagged = Tagged();
                    tagged.userid = widget.user!.user_id!;
                    taggedUsers.add(tagged);

                  }
                });

              },
            ),*/
          ],
        ),
      ),
    );
  }
}



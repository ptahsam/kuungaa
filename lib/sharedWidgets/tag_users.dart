import 'package:firebase_database/firebase_database.dart';
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //taggedUsers.clear();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Flexible(
            flex: 2,
            child: Container(
              height: 100.0,
              decoration: BoxDecoration(
                color: Provider.of<AppData>(context).darkTheme?Palette.darker:Colors.white,
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 12.0, top: 40.0, right: 12.0,bottom: 0.0),
                child: Column(
                  children: [
                    const SizedBox(height: 5.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            GestureDetector(
                              onTap:()
                              {
                                Navigator.pop(context, taggedUsers);
                              },
                              child: const Icon(
                                  Icons.arrow_back
                              ),
                            ),
                            const SizedBox(width: 10.0,),
                            const Text("Tag other people", style: TextStyle(fontSize: 18.0,),
                            ),
                          ],
                        ),
                        ElevatedButton(
                          onPressed: () => {
                          Navigator.pop(context, taggedUsers),
                          },
                          child: const Text("Done"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              color: Provider.of<AppData>(context).darkTheme?Palette.lessDarker:Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12.0,),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Tag other people to include in your post"),
                  const SizedBox(height: 4.0,),
                  Row(
                    children: const [
                      Text("SUGGESTED"),
                      /*Container(
                        width: 40.0,
                        height: 35.0,
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: Text(taggedUsers.length.toString()),
                      ),*/
                    ],
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12.0,),
            height: MediaQuery.of(context).size.height * 0.75,
            child: FutureBuilder(
                future: fetchListItems(),
                builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
                  if (snapshot.hasData) {
                      //print("User list" + snapshot.data!.toString());
                      return Column (
                        children: <Widget>[
                          Expanded(
                              child: ListView.builder(
                                itemCount: snapshot.data!.length,
                                itemBuilder: (BuildContext context, int index){

                                  return UsersList(user: snapshot.data![index]);
                                },
                              ),
                          ),
                        ],
                      );

                  }else{
                    return const Center(child: CircularProgressIndicator());
                  }
                }
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



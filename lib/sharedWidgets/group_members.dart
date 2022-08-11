import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:kuungaa/DataHandler/appData.dart';
import 'package:kuungaa/Models/user.dart';
import 'package:kuungaa/config/palette.dart';
import 'package:kuungaa/sharedWidgets/profile_avatar.dart';
import 'package:provider/provider.dart';

class GroupMembers extends StatefulWidget {
  final String groupid;
  final String groupcreatorid;
  const GroupMembers({
    Key? key,
    required this.groupid,
    required this.groupcreatorid
  }) : super(key: key);

  @override
  _GroupMembersState createState() => _GroupMembersState();
}

class _GroupMembersState extends State<GroupMembers> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0,),
      child: FutureBuilder(
        future: getGroupMembers(widget.groupid),
          builder: (BuildContext context, AsyncSnapshot<List> snapshot){
            if(snapshot.hasData)
            {
              return ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: snapshot.data!.length,
                itemBuilder: (BuildContext context, int index){
                  Users members = snapshot.data![index];
                  if(widget.groupcreatorid == members.user_id){
                      return Container(
                        padding: const EdgeInsets.all(8.0),
                        margin: const EdgeInsets.only(bottom: 5.0),
                        decoration: BoxDecoration(
                          color: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.white,
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        child: ListTile(
                          leading: ProfileAvatar(imageUrl: members.user_profileimage!,),
                          title: Text(
                            members.user_firstname! + " " + members.user_lastname!,
                          ),
                          subtitle: const Text("Admin", style: TextStyle(color: Palette.kuungaaDefault, fontSize: 12.0),),
                        trailing: const Icon(
                            Icons.more_horiz
                        ),
                      ),
                    );
                  }
                  return Container(
                    padding: const EdgeInsets.all(8.0),
                    margin: const EdgeInsets.only(bottom: 5.0),
                    decoration: BoxDecoration(
                      color: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.white,
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    child: ListTile(
                      leading: ProfileAvatar(imageUrl: members.user_profileimage!,),
                      title: Text(
                        members.user_firstname! + " " + members.user_lastname!,
                      ),
                      subtitle: const Text("Member", style: TextStyle(fontSize: 12.0),),
                      trailing: const Icon(
                        Icons.more_horiz
                      ),
                    ),
                  );
                },
              );
            }
            else
            {
              return const Center(child: CircularProgressIndicator());
            }
          }
      ),
    );
  }

  Future<List> getGroupMembers(String groupid) async{
    List<Users> membersList = [];

    final Query query = FirebaseDatabase.instance.reference().child('KUUNGAA').child('Groups').child(groupid).child("members");
    await query.once().then((event) async {
      membersList.clear();
      var keys = event.value.keys;

      if(event.value != ''){
        //Posts post = Posts.fromSnapshot(event.snapshot);
        //allPosts.add(post);
        // servicesList.add(userServices!);
        for (var key in keys)
        {
          String memberid = key;


          DatabaseReference reference = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Users");

          await reference.child(memberid).once().then((DataSnapshot snap)
          {
            if(snap.value != null)
            {
              //print("User infodetails" + snap.value.toString());
              Users users = Users.fromSnapshot(snap);
              //print("User infodetails:" + userCurrentInfo.toString());
              membersList.add(users);

            }
          });
        }
      }
    });
    return membersList;
   }
}

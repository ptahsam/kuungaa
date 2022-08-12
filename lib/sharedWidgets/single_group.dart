import 'package:extended_image/extended_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kuungaa/AllWidgets/progressDialog.dart';
import 'package:kuungaa/Assistants/assistantMethods.dart';
import 'package:kuungaa/DataHandler/appData.dart';
import 'package:kuungaa/Models/group.dart';
import 'package:kuungaa/config/config.dart';
import 'package:kuungaa/config/palette.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:snippet_coder_utils/hex_color.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

import 'widgets.dart';

class SingleGroup extends StatefulWidget {
  final Group group;
  const SingleGroup({
    Key? key,
    required this.group
  }) : super(key: key);

  @override
  _SingleGroupState createState() => _SingleGroupState();
}

class _SingleGroupState extends State<SingleGroup> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Provider.of<AppData>(context).darkTheme?Palette.lessDarker:Colors.white,
      body: DefaultTabController(
        length: 3,
        child: NestedScrollView(
          scrollDirection: Axis.vertical,
          headerSliverBuilder: (context, bool s) => [
            SliverAppBar(
              systemOverlayStyle: SystemUiOverlayStyle.light,
              shadowColor: Colors.transparent,
              backgroundColor: Palette.kuungaaDefault,
              title: Text(widget.group.group_name!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                  )
              ),
              centerTitle: false,
              floating: true,
              automaticallyImplyLeading: true,
              snap: true,
              elevation: 40.0,
              pinned: true,
              expandedHeight: 200.0,
              flexibleSpace: FlexibleSpaceBar(
                  background: ExtendedImage.network(
                    widget.group.group_icon!,
                    fit: BoxFit.cover,
                  )
              ),
              actions: [
                IconButton(
                  icon: const Icon(
                    Icons.more_vert,
                    color: Colors.white,
                    //size: 28.0,
                  ),
                  iconSize: 22.0,
                  onPressed: () => {
                    showModalBottomSheet(
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0)),
                      ),
                      context: context,
                      builder: (context) => buildGroupPostSheet(widget.group.group_id!, widget.group.group_name!, widget.group.group_icon!),
                    ),
                  },
                )
              ],
            ),
            SliverPersistentHeader(
              delegate: _SliverAppBarDelegate(
                TabBar(
                  padding: EdgeInsets.zero,
                  indicator: const BoxDecoration(
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
                      child: Center(
                        child: Text("Discussion", style: TextStyle(color: HexColor("#ffffff"),),),
                      ),

                    ),
                    Tab(
                      child: Center(
                        child: Text("Members", style: TextStyle(color: HexColor("#ffffff"),),),
                      ),
                    ),
                    Tab(
                      child: Center(
                        child: Text("About", style: TextStyle(color: HexColor("#ffffff"),),),
                      ),
                    ),
                  ],
                ),
              ),
              pinned: true,
            ),
          ],
          body: TabBarView(
            physics: const NeverScrollableScrollPhysics(),
            children: [
              CustomScrollView(
                slivers: [

                  SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        SingleGroupPost(groupid: widget.group.group_id!,),
                      ]
                    ),
                  ),
                ],
              ),

              CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.only(top: 10.0),
                    sliver: SliverToBoxAdapter(
                      child: GroupMembers(groupid: widget.group.group_id!,groupcreatorid: widget.group.group_creator!,),
                    ),
                  ),
                ],
              ),
              CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(
                                MdiIcons.accountLock
                            ),
                            title: const Text("Group privacy"),
                            subtitle: Text(widget.group.group_privacy!),
                          ),
                          ListTile(
                            leading: const Icon(
                                MdiIcons.history
                            ),
                            title: const Text("Group history"),
                            subtitle: Text(convertToRealDate(int.parse(widget.group.group_createddate!))),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildGroupPostSheet(String groupid, String groupname, String groupicon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 20.0),

      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FutureBuilder(
            future: checkGroupUserIsMember(groupid),
            builder: (BuildContext context, AsyncSnapshot<bool> snapshot){
              if(snapshot.hasData){
                return snapshot.data! == true? Column(
                  children: [
                    InkWell(
                      onTap: () async {
                        Navigator.pop(context);
                        var res = await Navigator.push(context, MaterialPageRoute(builder: (context)=>CreateGroupPost(groupname: groupname, groupid: groupid, groupicon: groupicon,)));
                        if(res != null){
                          setState(() {
                            Navigator.pop(context);
                          });
                        }
                      },
                      child: Row(
                        children: [
                          Container(
                            margin: const EdgeInsets.all(6.0),
                            decoration: BoxDecoration(
                              color: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.grey[200],
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: Icon(
                                Icons.add,
                                color: Colors.green,
                              ),
                              iconSize: 22.0,
                              onPressed: () => {},
                            ),
                          ),
                          const SizedBox(width: 14.0,),
                          const Text(
                            "Create a group post",
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () async {
                        Navigator.pop(context);
                        DatabaseReference gRef = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Groups").child(widget.group.group_id!).child("members");
                        gRef.child(userCurrentInfo!.user_id!).remove().then((value){
                          displayToastMessage("You have left this group", context);
                          setState(() {

                          });

                        });
                      },
                      child: Row(
                        children: [
                          Container(
                            margin: const EdgeInsets.all(6.0),
                            decoration: BoxDecoration(
                              color: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.grey[200],
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: Icon(
                                MdiIcons.doorSlidingOpen,
                                color: Colors.red,
                              ),
                              iconSize: 22.0,
                              onPressed: (){

                            },
                            ),
                          ),
                          const SizedBox(width: 14.0,),
                          const Text(
                            "Leave this group",
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w400,
                              color: Colors.red
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ) :InkWell(
                  onTap: () async {
                    Navigator.pop(context);
                    DatabaseReference gRef = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Groups").child(widget.group.group_id!).child("members");
                    /*Map groupMemberMap = {
                            userCurrentInfo!.user_id! : userCurrentInfo!.user_id!
                          };*/
                    gRef.child(userCurrentInfo!.user_id!).set(userCurrentInfo!.user_id!).then((onValue) {
                      displayToastMessage("Your request to join " + widget.group.group_name! + " Group has been sent.", context);
                      setState(() {

                      });
                    }).catchError((onError) {
                      Navigator.pop(context);
                      displayToastMessage("An error occurred. Please try again later", context);
                    });
                  },
                  child: Row(
                    children: [
                      Container(
                        margin: const EdgeInsets.all(6.0),
                        decoration: BoxDecoration(
                          color: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.grey[200],
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(
                            MdiIcons.plus,
                            color: Colors.green,
                          ),
                          iconSize: 22.0,
                          onPressed: () => {},
                        ),
                      ),
                      const SizedBox(width: 14.0,),
                      const Text(
                        "Join this group",
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w400,
                          color: Colors.green
                        ),
                      ),
                    ],
                  ),
                );
                /*Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text("You are not a member"),
                        Text("You need to join this group to post", style: TextStyle(fontSize: 12.0),),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: (){

                      },
                      child: Row(
                        children: const [
                          Icon(
                            FontAwesomeIcons.plus,
                          ),
                          Text("Join Group"),
                        ],
                      ),
                    ),
                  ],
                );*/
              }else{
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
          widget.group.group_creator == userCurrentInfo!.user_id?InkWell(
            onTap: () async {
              Navigator.pop(context);
              openDialog(context);
            },
            child: Row(
              children: [
                Container(
                  margin: const EdgeInsets.all(6.0),
                  decoration: BoxDecoration(
                    color: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.grey[200],
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(
                      MdiIcons.delete,
                      color: Colors.red,
                    ),
                    iconSize: 22.0,
                    onPressed: (){

                    },
                  ),
                ),
                const SizedBox(width: 14.0,),
                const Text(
                  "Delete this group",
                  style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w400,
                      color: Colors.red
                  ),
                ),
              ],
            ),
          ):SizedBox.shrink(),
        ],
      ),
    );
  }

  Future<Group> getGroupDetails(String groupid) async{
    Group groupInfo = await AssistantMethods.getGroupInfo(groupid);
    return groupInfo;
  }

  Future<bool> checkGroupUserIsMember(String groupid) async{
    bool userIsMember = await AssistantMethods.checkUserIsMember("Groups", groupid, userCurrentInfo!.user_id!);
    return userIsMember;
  }

  openDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete group"),
        content: Text(
          "Do you want to delete this group and all its data ?"
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "Cancel",
                  style: TextStyle(
                    color: Colors.green,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  deleteGroup();
                },
                child: const Text(
                  "Delete",
                  style: TextStyle(
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void deleteGroup() async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context)
        {
          return ProgressDialog(message: "Deleting group, Please wait...",);
        }
    );
    final Query query = FirebaseDatabase.instance.reference().child('KUUNGAA').child('Posts')
        .orderByChild('post_id').equalTo(widget.group.group_id!);
    await query.once().then((event) async {
      if(event.exists){
        var keys = event.value.keys;
        for (var key in keys)
        {
          DatabaseReference hiddenRef = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Hidden");
          await hiddenRef.once().then((hiddenSnap) async {
            if(hiddenSnap.exists){
              var hiddenKeys = hiddenSnap.value.keys;
              for(var hiddenKey in hiddenKeys){
                await hiddenRef.child(hiddenKey).child(key).once().then((hiddenPost) async {
                  if(hiddenPost.exists){
                    await hiddenRef.child(hiddenKey).child(key).remove();
                  }
                });
              }
            }
          });

          DatabaseReference folderRef = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Folders");
          await folderRef.once().then((folderSnap) async {
            if(folderSnap.exists){
              var folderKeys = folderSnap.value.keys;
              for(var folderKey in folderKeys){
                DatabaseReference saveRef = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Saves");
                await saveRef.once().then((saveSnap) async {
                  if(saveSnap.exists){
                    var saveKeys = saveSnap.value.keys;
                    for(var saveKey in saveKeys){
                      await saveRef.child(saveKey).child(folderKey).child(key).once().then((savePost) async {
                        if(savePost.exists){
                          await saveRef.child(saveKey).child(folderKey).child(key).remove();
                        }
                      });
                    }
                  }
                });
              }
            }
          });

          firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance.ref().child("KUUNGAA").child("Posts").child(key);
          await ref.listAll().then((result) async {
            for (var file in result.items) {
              file.delete();
            }
            DatabaseReference postRef = FirebaseDatabase.instance.reference().child('KUUNGAA').child('Posts').child(key);
            await postRef.remove();
          });
        }
      }
    });

    firebase_storage.Reference refGroup = firebase_storage.FirebaseStorage.instance.ref().child("KUUNGAA").child("Groups").child("icons").child(widget.group.group_id!);
    await refGroup.listAll().then((result) async {
      for (var file in result.items) {
        file.delete();
      }
      DatabaseReference groupRef = FirebaseDatabase.instance.reference().child('KUUNGAA').child('Groups').child(widget.group.group_id!);
      await groupRef.remove();
    });

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Group deleted successfully'),
      duration: const Duration(seconds: 2),
    ));

    Navigator.pop(context);

  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      decoration: const BoxDecoration(
      color: Palette.kuungaaDefault,
        border: Border(
          bottom: BorderSide(
            color: Palette.kuungaaDefault,
            width: 0.2,

          ),
        ),
        //borderRadius: BorderRadius.circular(5.0),
      ),
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}

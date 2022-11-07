import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:kuungaa/AllWidgets/progressDialog.dart';
import 'package:kuungaa/DataHandler/appData.dart';
import 'package:kuungaa/Models/folder.dart';
import 'package:kuungaa/Models/post.dart';
import 'package:kuungaa/Models/tagged.dart';
import 'package:kuungaa/config/config.dart';
import 'package:kuungaa/config/palette.dart';
import 'package:kuungaa/sharedWidgets/widgets.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class ContextMenu extends StatefulWidget {
  final Posts post;
  const ContextMenu({
    Key? key,
    required this.post
  }) : super(key: key);

  @override
  _ContextMenuState createState() => _ContextMenuState();
}

class _ContextMenuState extends State<ContextMenu> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.more_horiz),
      onPressed: () => showModalBottomSheet(
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0)),
        ),
        context: context,
        builder: (context) => buildSheet(),
      ),
    );
  }

  Widget buildSheet() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 20.0),

      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: (){
              Navigator.of(context).pop();
              showModalBottomSheet(
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0)),
                ),
                context: context,
                builder: (context){
                  return StatefulBuilder(
                      builder: (BuildContext context, StateSetter mystate){
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 20.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text("Save post", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),),
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
                              const SizedBox(height: 6.0,),
                              InkWell(
                                onTap: (){
                                  Navigator.of(context).pop();
                                  openNewFolderDialog(context);
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
                                        icon: ShaderMask(
                                          shaderCallback: (rect) => Palette.createIconGradient.createShader(rect),
                                          child: Icon(
                                            MdiIcons.plus,
                                            color: Provider.of<AppData>(context).darkTheme?Colors.white:Colors.green,
                                          ),
                                        ),
                                        iconSize: 22.0,
                                        onPressed: () => {},
                                      ),
                                    ),
                                    const SizedBox(width: 14.0,),
                                    const Text(
                                      "New Folder",
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 6.0,),
                              FutureBuilder(
                                  future: getUserSaveFolders(),
                                  builder: (BuildContext context, AsyncSnapshot<List> snapshot){
                                    if(snapshot.connectionState == ConnectionState.done){
                                      if(snapshot.hasData){
                                        return ListView.builder(
                                          padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 8.0),
                                          itemCount: snapshot.data!.length,
                                          scrollDirection: Axis.vertical,
                                          shrinkWrap: true,
                                          itemBuilder: (BuildContext context, int index){
                                            Folder folder = snapshot.data![index];

                                            return InkWell(
                                              onTap: (){
                                                Navigator.pop(context);
                                                showSaveDialog(folder);
                                              },
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
                                                margin: const EdgeInsets.only(bottom: 3.0),
                                                decoration: BoxDecoration(
                                                  color: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.grey[100]!,
                                                  borderRadius: BorderRadius.circular(5.0),
                                                ),
                                                child: ListTile(
                                                  leading: Container(
                                                    height: 40.0,
                                                    width: 40.0,
                                                    decoration: BoxDecoration(
                                                      color: Provider.of<AppData>(context).darkTheme?Palette.darker:Colors.grey[300]!,
                                                      borderRadius: BorderRadius.circular(5.0),
                                                    ),
                                                  ),
                                                  title: Text(folder.folder_name!),
                                                  subtitle: Text(folder.folder_count!.toString()),
                                                  trailing: const Icon(Icons.keyboard_arrow_right, size: 26.0,),
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      }else{
                                        return const SizedBox.shrink();
                                      }
                                    }else{
                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    }
                                  }
                              ),
                            ],
                          ),
                        );
                      }
                  );
                },
              );
            },
            child: Padding(
              padding: const EdgeInsets.only(bottom: 9.0),
              child: Row(
                children: [
                  Icon(
                    Icons.download,
                    color: Provider.of<AppData>(context).darkTheme?Colors.white:Colors.grey,
                    size: 28.0,
                  ),
                  const SizedBox(width: 8.0,),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Save post",
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Text(
                        "Add post to your saved items",
                        style: TextStyle(
                            fontSize: 12.0,
                            color: Colors.grey
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          /*const Padding(
            padding: EdgeInsets.symmetric(vertical: 6.0),
            child: Divider(
              height: 1.0,
              color: Colors.grey,
            ),
          ),*/

          FutureBuilder(
            future: getPostTagged(),
            builder: (ctx, AsyncSnapshot<bool> snapshot){
              if(snapshot.connectionState == ConnectionState.done){
                if(snapshot.hasData){
                  print("post tagged :: " + snapshot.data!.toString());
                  if(snapshot.data == true){
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 9.0),
                      child: InkWell(
                        onTap: (){
                          removeTagging();
                        },
                        child: Row(
                          children: [
                            Icon(
                              Icons.person_remove,
                              color: Provider.of<AppData>(context).darkTheme?Colors.white:Colors.grey,
                            ),
                            SizedBox(width: 8.0,),
                            Text(
                              "Remove tagging",
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.w400,
                              ),
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
              }else{
                return SizedBox.shrink();
              }
            },
          ),

          InkWell(
            onTap: (){
              onShare(context, "Share from kuungaa", "");
            },
            child: Padding(
              padding: const EdgeInsets.only(bottom: 9.0),
              child: Row(
                children: [
                  Icon(
                    Icons.share,
                    color: Provider.of<AppData>(context).darkTheme?Colors.white:Colors.grey,
                    //size: 28.0,
                  ),
                  const SizedBox(width: 8.0,),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Share post",
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      /*Text(
                        "Add post to your saved items",
                        style: TextStyle(
                            fontSize: 12.0,
                            color: Colors.grey
                        ),
                      ),*/
                    ],
                  ),
                ],
              ),
            ),
          ),
          /*const Padding(
            padding: EdgeInsets.symmetric(vertical: 6.0),
            child: Divider(
              height: 1.0,
              color: Colors.grey,
            ),
          ),*/

          InkWell(
            onTap: (){
              hidePost(widget.post.post_id!);
            },
            child: Padding(
              padding: const EdgeInsets.only(bottom: 9.0),
              child: Row(
                children: [
                  Icon(
                    Icons.remove_circle,
                    color: Provider.of<AppData>(context).darkTheme?Colors.white:Colors.grey,
                    //size: 28.0,
                  ),
                  const SizedBox(width: 8.0,),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Hide post",
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Text(
                        "Hide post from timeline",
                        style: TextStyle(
                            fontSize: 12.0,
                            color: Colors.grey
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          /*widget.post.poster_id == userCurrentInfo!.user_id!?
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 6.0),
            child: Divider(
              height: 1.0,
              color: Colors.grey,
            ),
          ):const SizedBox.shrink(),*/

          widget.post.poster_id == userCurrentInfo!.user_id! ?
          InkWell(
            onTap: (){
              if(widget.post.post_category == "pagesfeed"){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>CreatePagePost(pagename: widget.post.kpage!.page_name!, pageid: widget.post.kpage!.page_id!, post: widget.post,)));
              }else if(widget.post.post_category == "groupsfeed"){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>CreateGroupPost(groupname: widget.post.group!.group_name!, groupid: widget.post.group!.group_id!, groupicon: widget.post.group!.group_icon!, post: widget.post,)));
              }else if(widget.post.post_category == "newsfeed"){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>CreatePost(isSelectMedia: false, isSelectExpression: false, post: widget.post,)));
              }else if(widget.post.post_category == "travelfeed"){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>CreateTravelPost(post: widget.post,)));
              }
            },
            child: Padding(
              padding: const EdgeInsets.only(bottom: 9.0),
              child: Row(
                children: [
                  Icon(
                    Icons.edit,
                    color: Provider.of<AppData>(context).darkTheme?Colors.white:Colors.grey,
                    //size: 28.0,
                  ),
                  const SizedBox(width: 8.0,),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Edit post",
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      /*Text(
                  "Add post to your saved items",
                  style: TextStyle(
                      fontSize: 12.0,
                      color: Colors.grey
                  ),
                ),*/
                    ],
                  ),
                ],
              ),
            ),
          ) : const SizedBox.shrink(),

          widget.post.poster_id == userCurrentInfo!.user_id! ?
          InkWell(
            onTap: (){
              Navigator.of(context).pop();
              deletePost(widget.post.post_id!);
            },
            child: Row(
              children: [
                Icon(
                  Icons.delete,
                  color: Provider.of<AppData>(context).darkTheme?Colors.white:Colors.grey,
                  //size: 28.0,
                ),
                const SizedBox(width: 8.0,),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "Delete post",
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    /*Text(
                      "Add post to your saved items",
                      style: TextStyle(
                          fontSize: 12.0,
                          color: Colors.grey
                      ),
                    ),*/
                  ],
                ),
              ],
            ),
          ) : const SizedBox.shrink(),
        ],
      ),
    );
  }

  void onShare(BuildContext context, String text, String subject) async {
    // A builder is used to retrieve the context immediately
    // surrounding the ElevatedButton.
    //
    // The context's `findRenderObject` returns the first
    // RenderObject in its descendent tree when it's not
    // a RenderObjectWidget. The ElevatedButton's RenderObject
    // has its position and size after it's built.
    String shareMedia = "https://firebasestorage.googleapis.com/v0/b/kuungaa-42ba2.appspot.com/o/KUUNGAA%2Fimages%2Flogin_logo_dark.png?alt=media&token=f2f27b5c-966c-4eee-b1a9-b680edcaa2d9";
    String photoImg = await getShareMedia(widget.post.post_id!);

    if(photoImg != ""){
      shareMedia = photoImg;
    }

    String postUrl = "https://www.kuungaa.com/view-post/?pid="+widget.post.post_id!;

    //print("d-link :: " + Uri.parse(postUrl).toString());

    final dynamicLinkParams = DynamicLinkParameters(
      link: Uri.parse(postUrl),
      uriPrefix: "https://kuungaa.page.link",
      androidParameters: AndroidParameters(packageName: "com.developer.kuungaa",minimumVersion: 21,fallbackUrl: Uri.parse(postUrl)),
      iosParameters: const IOSParameters(bundleId: "com.developer.kuungaa.ios"),
      socialMetaTagParameters: SocialMetaTagParameters(
        description: widget.post.post_description!,
        title: widget.post.postUser!.user_firstname! + " " + widget.post.postUser!.user_lastname! + " on Kuungaa",
        imageUrl: Uri.parse(shareMedia),
      ),
    );

    final unguessableDynamicLink = await FirebaseDynamicLinks.instance.buildShortLink(
      dynamicLinkParams,
      shortLinkType: ShortDynamicLinkType.unguessable,
    );

    final box = context.findRenderObject() as RenderBox?;

    String shortLink = unguessableDynamicLink.shortUrl.toString();

    await Share.share(shortLink,
        subject: subject,
        sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size);
  }

  Future<void> deletePost(String postid) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context)
        {
          return ProgressDialog(message: "Deleting your post, Please wait...",);
        }
    );
    firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance.ref().child("KUUNGAA").child("Posts").child(postid);

    await ref.listAll().then((result) async {
      for (var file in result.items) {
        file.delete();
      }

      DatabaseReference hiddenRef = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Hidden");
      await hiddenRef.once().then((hiddenSnap) async {
        if(hiddenSnap.exists){
          var hiddenKeys = hiddenSnap.value.keys;
          for(var hiddenKey in hiddenKeys){
            await hiddenRef.child(hiddenKey).child(postid).once().then((hiddenPost) async {
              if(hiddenPost.exists){
                await hiddenRef.child(hiddenKey).child(postid).remove();
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
                  await saveRef.child(saveKey).child(folderKey).child(postid).once().then((savePost) async {
                    if(savePost.exists){
                      await saveRef.child(saveKey).child(folderKey).child(postid).remove();
                    }
                  });
                }
              }
            });
          }
        }
      });

      DatabaseReference postRef = FirebaseDatabase.instance.reference().child('KUUNGAA').child('Posts').child(postid);
      await postRef.remove().then((onValue) {
        if(mounted) {
          Navigator.pop(context);
          displayToastMessage("Your post was deleted successfully", context);
        }
      }).catchError((onError) {
        if(mounted) {
          Navigator.pop(context);
          displayToastMessage(
              "An error occurred. Please try again later", context);
        }
      });
    });
  }


  void hidePost(String postid) {
    DatabaseReference postRef = FirebaseDatabase.instance.reference().child('KUUNGAA').child('Hidden').child(userCurrentInfo!.user_id!).child(postid);
    Map postRefMap = {
      "post_id" : postid
    };
    postRef.set(postRefMap).then((onValue) {
      Navigator.pop(context);
      displayToastMessage("This post will be hidden from your timeline", context);
      setState(() {

      });
    }).catchError((onError) {
      Navigator.pop(context);
      displayToastMessage("An error occurred. Please try again later", context);
    });
  }

  Future<List> getUserSaveFolders() async {
    List<Folder> folderList = [];
    final DatabaseReference dbFolders = FirebaseDatabase.instance.reference().child('KUUNGAA').child('Folders').child(userCurrentInfo!.user_id!);
    await dbFolders.once().then((DataSnapshot snapshotFolders){
      if(snapshotFolders.exists){
        folderList.clear();
        var keys = snapshotFolders.value.keys;
        var values = snapshotFolders.value;
        for (var key in keys)
        {
          Folder folder = Folder();
          folder.folder_name = values [key]["folder_name"];
          folder.folder_key = values [key]["folder_key"];
          folder.folder_count = values [key]["folder_count"];

          folderList.add(folder);
        }
      }
    });
    return folderList.reversed.toList();
  }

  void openNewFolderDialog(BuildContext context) {
    TextEditingController folderTextEditingController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Create a new folder"),
        content: TextField(
          controller: folderTextEditingController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: "Enter new folder name",
            hintStyle: TextStyle(
              color: Provider.of<AppData>(context).darkTheme?Colors.white:Colors.black,
            ),
          ),
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () => saveFolder(folderTextEditingController.text),
                child: const Text("Save"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void showSaveDialog(Folder folder) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Save post"),
        content: ListTile(
          leading: Container(
            height: 40.0,
            width: 40.0,
            decoration: BoxDecoration(
              color: Provider.of<AppData>(context).darkTheme?Palette.darker:Colors.grey[300]!,
              borderRadius: BorderRadius.circular(5.0),
            ),
          ),
          title: Text(folder.folder_name!),
          subtitle: Text(folder.folder_count!.toString()),
          trailing: const Icon(MdiIcons.checkboxMarked, size: 26.0, color: Palette.kuungaaDefault,),
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () => savePostInFolder(folder),
                child: const Text("Save"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  saveFolder(String text) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context)
        {
          return ProgressDialog(message: "saving your folder, Please wait...",);
        }
    );
    DatabaseReference folderRef = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Folders").child(userCurrentInfo!.user_id!).push();
    String folderKey = folderRef.key;

    Map folderMap = {
      "folder_name" : text,
      "folder_key" : folderKey,
      "folder_count" : 1
    };

    folderRef.set(folderMap).then((onValue) {
      DatabaseReference saveRef = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Saves").child(userCurrentInfo!.user_id!).child(folderKey).child(widget.post.post_id!);
      Map saveMap = {
        "post_id" : widget.post.post_id!
      };
      saveRef.set(saveMap);
      displayToastMessage("Post saved in " + text, context);
      Navigator.pop(context);
      Navigator.pop(context);
    }).catchError((onError) {
      Navigator.pop(context);
      displayToastMessage("An error occurred. Please try again later", context);
    });
  }

  savePostInFolder(Folder folder) {

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context)
        {
          return ProgressDialog(message: "saving your folder, Please wait...",);
        }
    );

    DatabaseReference folderRef = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Folders").child(userCurrentInfo!.user_id!).child(folder.folder_key!);
    folderRef.once().then((DataSnapshot snapshot){
      if(snapshot.exists){
        int folderCount = snapshot.value["folder_count"];
        DatabaseReference saveRef = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Saves").child(userCurrentInfo!.user_id!).child(folder.folder_key!).child(widget.post.post_id!);
        saveRef.once().then((DataSnapshot dataSnapshot){
          if(!dataSnapshot.exists){
            Map saveMap = {
              "post_id" : widget.post.post_id!
            };
            saveRef.set(saveMap).
            then((onValue) {
              Map<String, dynamic> updateFolderMap = {
                "folder_count" : folderCount + 1
              };
              folderRef.update(updateFolderMap);
              displayToastMessage("Post saved in " + folder.folder_name!, context);
              Navigator.pop(context);
              Navigator.pop(context);
            }).catchError((onError) {
              Navigator.pop(context);
              displayToastMessage("An error occurred. Please try again later", context);
            });
          }else{
            Navigator.pop(context);
            displayToastMessage("You have already saved this post in " + folder.folder_name!, context);
          }
        });
      }
    });
  }

  Future<bool> getPostTagged() async {
    bool isTagged = false;
    Query dbRef = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Posts").child(widget.post.post_id!)
        .child("post_tagged")                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               ;
        await dbRef.once().then((DataSnapshot dataSnapshot){
          if(dataSnapshot.exists){
            print("post tagged snapshot :: " + dataSnapshot.value.toString());
            print("post tagged userid :: " + userCurrentInfo!.user_id!);
            for(var i in dataSnapshot.value){
              Tagged tagged = Tagged.fromJson(Map<String, dynamic>.from(i));
              if(tagged.userid == userCurrentInfo!.user_id!){
                isTagged = true;
              }
            }
          }
    });
    return isTagged;
  }

  void removeTagging() async{
    Query dbRef = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Posts").child(widget.post.post_id!)
        .child("post_tagged").orderByChild("userid").equalTo(userCurrentInfo!.user_id!);
    await dbRef.once().then((DataSnapshot dataSnapshot){
      if(dataSnapshot.exists){
        print("post tagged key :: " + dataSnapshot.value.key);
      }
    });
  }
}

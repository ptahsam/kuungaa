import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:kuungaa/Models/media.dart';
import 'package:kuungaa/Models/user.dart';
import 'package:kuungaa/config/config.dart';
import 'package:kuungaa/config/palette.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
class ViewUserPhotos extends StatefulWidget {
  final Users user;
  final List userMedia;
  const ViewUserPhotos({
    Key? key,
    required this.user,
    required this.userMedia
  }) : super(key: key);

  @override
  _ViewUserPhotosState createState() => _ViewUserPhotosState();
}

class _ViewUserPhotosState extends State<ViewUserPhotos> {
  Media? userMediaPhoto;
  int selectedIndex = 0;
  final List<String> photocategories = ["Your photos", "Cover photos", "Profile photos"];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    userMediaPhoto = widget.userMedia[0];
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Palette.kuungaaDefault,
        leadingWidth: 40.0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white,),
          //iconSize: 36.0,
          color: Colors.white,
          onPressed: (){
            Navigator.pop(context);
          },
        ),
        title: Text(
          widget.user.user_id == userCurrentInfo!.user_id!? "Your photos": widget.user.user_firstname! + "'" + "s" + " photos",
          style: const TextStyle(
            color: Colors.white,
            //fontSize: 22.0,
            //fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        elevation: 0.0,
        actions: const [
          /*IconButton(
            icon: Icon(Icons.search),
            //iconSize: 36.0,
            color: Colors.white,
            onPressed: (){},
          ),*/
        ],
      ),
      body:
         Column(
          children: [
           Container(
             height: 60.0,
             color: Palette.kuungaaDefault,
             child: ListView.builder(
               scrollDirection: Axis.horizontal,
               itemCount: photocategories.length,
               itemBuilder: (BuildContext context, int index){
                 return InkWell(
                   onTap: (){
                     setState(() {
                       selectedIndex = index;
                     });
                   },
                   child: Padding(
                     padding: const EdgeInsets.only(left: 20.0, right: 15.0, top: 30.0, bottom: 5.0),
                     child: Text(
                       index == 0? widget.user.user_id == userCurrentInfo!.user_id!? "Your photos": widget.user.user_firstname! + "'" + "s" + " photos" : photocategories[index],
                       style: TextStyle(
                         color: index == selectedIndex ? Colors.white : Colors.white60,
                         fontSize: 16.0,
                         fontWeight: FontWeight.bold,
                         letterSpacing: 0.8,
                       ),
                     ),
                   ),
                 );
               },
             ),
           ),
            if(selectedIndex == 0)
            Expanded(
              child: widget.userMedia.length > 0 ?Container(
                height: MediaQuery.of(context).size.height,
                margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 15.0),
                child:  StaggeredGridView.countBuilder(
                    crossAxisCount: 2,
                    crossAxisSpacing: 5,
                    mainAxisSpacing: 6,
                    itemCount: widget.userMedia.length,
                    itemBuilder: (context, index) {
                      Media media = widget.userMedia[index];
                      return Container(
                        decoration: const BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.all(
                                Radius.circular(15))
                        ),
                        child: ClipRRect(
                          borderRadius: const BorderRadius.all(
                              Radius.circular(5.0)
                          ),
                          child: ExtendedImage.network(
                            media.url!,
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  staggeredTileBuilder: (index) {
                    return StaggeredTile.count(1, index.isEven ? 1.2 : 1.8);
                  }),
              ):Align(
                alignment: Alignment.center,
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.13,
                  width: MediaQuery.of(context).size.width * 0.65,
                  decoration: BoxDecoration(
                    color: Colors.grey[100]!,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.image,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 6.0,),
                        Text("No photos", textAlign: TextAlign.center,),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if(selectedIndex == 1)
              FutureBuilder(
                future: getUserPhotos(widget.user.user_id!, "covers"),
                builder: (BuildContext context, AsyncSnapshot<List> snapshot){
                  if(snapshot.connectionState == ConnectionState.done){
                    if(snapshot.hasData){
                      if(snapshot.data!.isNotEmpty){
                        return Expanded(
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 15.0),
                            child:  StaggeredGridView.countBuilder(
                                crossAxisCount: 2,
                                crossAxisSpacing: 5,
                                mainAxisSpacing: 6,
                                itemCount: snapshot.data!.length,
                                itemBuilder: (context, index) {
                                  Media media = snapshot.data![index];
                                  return Container(
                                    decoration: const BoxDecoration(
                                        color: Colors.transparent,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(15))
                                    ),
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(5.0)
                                      ),
                                      child: ExtendedImage.network(
                                        media.url!,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  );
                                },
                                staggeredTileBuilder: (index) {
                                  return StaggeredTile.count(1, index.isEven ? 1.2 : 1.8);
                                }),
                          ),
                        );
                      }else{
                        return Align(
                          alignment: Alignment.center,
                          child: Container(
                            margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.25),
                            height: MediaQuery.of(context).size.height * 0.13,
                            width: MediaQuery.of(context).size.width * 0.65,
                            decoration: BoxDecoration(
                              color: Colors.grey[100]!,
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.image,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 6.0,),
                                  Text("No cover photos", textAlign: TextAlign.center,),
                                ],
                              ),
                            ),
                          ),
                        );
                      }
                    }else{
                      return const Center(
                        child: Text("No photos", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black),),
                      );
                    }
                  }else{
                    return Container(
                      margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.25),
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                },
              ),
            if(selectedIndex == 2)
              FutureBuilder(
                future: getUserPhotos(widget.user.user_id!, "profiles"),
                builder: (BuildContext context, AsyncSnapshot<List> snapshot){
                  if(snapshot.connectionState == ConnectionState.done){
                    if(snapshot.hasData){
                      if(snapshot.data!.isNotEmpty){
                        return Expanded(
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 15.0),
                            child:  StaggeredGridView.countBuilder(
                                crossAxisCount: 2,
                                crossAxisSpacing: 5,
                                mainAxisSpacing: 6,
                                itemCount: snapshot.data!.length,
                                itemBuilder: (context, index) {
                                  Media media = snapshot.data![index];
                                  return Container(
                                    decoration: const BoxDecoration(
                                        color: Colors.transparent,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(15))
                                    ),
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(5.0)
                                      ),
                                      child: ExtendedImage.network(
                                        media.url!,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  );
                                },
                                staggeredTileBuilder: (index) {
                                  return StaggeredTile.count(1, index.isEven ? 1.2 : 1.8);
                                }),
                          ),
                        );
                      }else{
                        return Align(
                          alignment: Alignment.center,
                          child: Container(
                            margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.25),
                            height: MediaQuery.of(context).size.height * 0.13,
                            width: MediaQuery.of(context).size.width * 0.65,
                            decoration: BoxDecoration(
                              color: Colors.grey[100]!,
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.image,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 6.0,),
                                  Text("No profile photos", textAlign: TextAlign.center,),
                                ],
                              ),
                            ),
                          ),
                        );
                      }
                    }else{
                      return const Center(
                        child: Text("No photos", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black),),
                      );
                    }
                  }else{
                    return Container(
                      margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.25),
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                },
              ),
          ],
        ),
    );
  }

  Future<List> getUserPhotos(String userId, String phototype) async{
    List<Media> userPhotosList = [];
    firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance.ref().child("KUUNGAA").child("Users").child(userId).child(phototype);

    await ref.listAll().then((result) async {
      for (var file in result.items) {
        Media media = Media();
        media.url = await file.getDownloadURL();
        userPhotosList.add(media);
      }
    });
    return userPhotosList.reversed.toList();
  }
}

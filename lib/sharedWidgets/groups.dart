import 'package:extended_image/extended_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:kuungaa/DataHandler/appData.dart';
import 'package:kuungaa/Models/group.dart';
import 'package:kuungaa/config/palette.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import 'widgets.dart';

class Groups extends StatefulWidget {
  const Groups({Key? key}) : super(key: key);

  //const Groups({Key? key}) : super(key: key);

  @override
  _GroupsState createState() => _GroupsState();
}

class _GroupsState extends State<Groups> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150.0,
      color: Provider.of<AppData>(context).darkTheme?Palette.lessDarker:Colors.white,
      child: FutureBuilder(
        future: getGroupsList(),
        builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
          if(snapshot.connectionState == ConnectionState.done){
            if(snapshot.hasData){
              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        vertical: 15.0,
                        horizontal: 8.0,
                      ),
                      scrollDirection: Axis.horizontal,
                      itemCount: snapshot.data!.length,
                      itemBuilder: (BuildContext context, int index)
                      {

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: _GroupCard(group: snapshot.data![index]),
                        );

                      },
                    ),
                  ),
                ],
              );
            }else{
             return Align(
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
                          Icons.notifications,
                          color: Provider.of<AppData>(context).darkTheme?Colors.white:Colors.grey,
                        ),
                        SizedBox(height: 6.0,),
                        Text("No groups available", textAlign: TextAlign.center,),
                      ],
                    ),
                  ),
                ),
              );
            }
          }else{
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      vertical: 15.0,
                      horizontal: 8.0,
                    ),
                    scrollDirection: Axis.horizontal,
                    itemCount: 4,
                    itemBuilder: (BuildContext context, int index)
                    {

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: Shimmer.fromColors(
                          baseColor: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.grey[300]!,
                          highlightColor: Provider.of<AppData>(context).darkTheme?Palette.lessDarker:Colors.grey[100]!,
                          child: Container(
                            height: 120.0,
                            width: 120.0,
                            decoration: BoxDecoration(
                              color: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.grey[300]!,
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                          ),
                        ),
                      );

                    },
                  ),
                ),
              ],
            );
          }
        }
      ),
    );
  }

  Future<List> getGroupsList() async{
    List<Group> groupsList = [];

    DatabaseReference dbReference = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Groups");
    await dbReference.once().then((DataSnapshot dataSnapshot){
      groupsList.clear();
      var keys = dataSnapshot.value.keys;
      var values = dataSnapshot.value;

      print("groups ::" + dataSnapshot.value.toString());

      for (var key in keys)
      {
        Group group = Group();
        group.group_id = values [key]["group_id"];
        group.group_name = values [key]["group_name"];
        group.group_icon = values [key]["group_icon"];
        group.group_privacy = values [key]["group_privacy"];
        group.group_creator = values [key]["group_creator"];
        group.group_createddate = values [key]["group_createddate"];

        groupsList.add(group);

        //print("groups single ::" + values);
      }
    });

    return groupsList;
  }
}

class _GroupCard extends StatelessWidget {

  final Group group;

  const _GroupCard({
    Key? key,
    required this.group
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){
        Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: SingleGroup(group: group,)));
      },
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(5.0),
            child: ExtendedImage.network(
              group.group_icon!,
              height: 120.0,
              width: 120.0,
              fit: BoxFit.cover,
            ),
          ),
          ShaderMask(
            shaderCallback: (rect) => Palette.createStoryGradient.createShader(rect),
            child: Container(
              height: 120.0,
              //padding: EdgeInsets.all(2.0),
              width: 120.0,
              decoration: BoxDecoration(
                gradient: Palette.storyGradient,
                border: Border.all(
                  width: 0.2,
                  color: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.grey,
                ),
                borderRadius: BorderRadius.circular(5.0),

              ),
            ),
          ),
          Positioned(
            bottom: 8.0,
            left: 8.0,
            right: 8.0,
            child: Text(
              group.group_name!,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12.0,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}


import 'package:extended_image/extended_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:kuungaa/Assistants/assistantMethods.dart';
import 'package:kuungaa/DataHandler/appData.dart';
import 'package:kuungaa/Models/page.dart';
import 'package:kuungaa/Models/user.dart';
import 'package:kuungaa/config/palette.dart';
import 'package:kuungaa/sharedWidgets/single_page.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class KPages extends StatefulWidget {
  const KPages({Key? key}) : super(key: key);

  @override
  _KPagesState createState() => _KPagesState();
}

class _KPagesState extends State<KPages> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150.0,
      color: Provider.of<AppData>(context).darkTheme?Palette.lessDarker:Colors.white,
      child: FutureBuilder(
          future: getPagesList(),
          builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
            if(snapshot.connectionState == ConnectionState.done){
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
                          child: _PageCard(kpage: snapshot.data![index]),
                        );

                      },
                    ),
                  ),
                ],
              );
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

  Future<List> getPagesList() async {
    List<Kpage> pagesList = [];

    DatabaseReference dbReference = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Pages");
    await dbReference.once().then((DataSnapshot dataSnapshot) async {

      pagesList.clear();
      var keys = dataSnapshot.value.keys;
      var values = dataSnapshot.value;

      for (var key in keys)
      {

        Kpage kpage = Kpage();

        kpage.page_id = values [key]["page_id"];
        kpage.page_name = values [key]["page_name"];
        kpage.page_icon = values [key]["page_icon"];
        kpage.page_description = values [key]["page_description"];
        kpage.page_creator = values [key]["page_creator"];
        kpage.page_createddate = values [key]["page_createddate"];
        kpage.page_category = values [key]["page_category"];

        Users users = await AssistantMethods.getCurrentOnlineUser(kpage.page_creator!);
        kpage.creator = users;

        pagesList.add(kpage);

      }

    });

    return pagesList;
  }
}

class _PageCard extends StatelessWidget {

  final Kpage kpage;

  const _PageCard({
    Key? key,
    required this.kpage
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){
        Navigator.push(context, MaterialPageRoute(builder: (context)=>SinglePage(kpage: kpage,)));
      },
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(5.0),
            child: ExtendedImage.network(
              kpage.page_icon!,
              height: 120.0,
              width: 120.0,
              fit: BoxFit.cover,
              enableMemoryCache: true,
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
              kpage.page_name!,
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

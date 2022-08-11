import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kuungaa/DataHandler/appData.dart';
import 'package:kuungaa/Models/category.dart';
import 'package:kuungaa/config/palette.dart';
import 'package:provider/provider.dart';
import 'package:snippet_coder_utils/hex_color.dart';
class SelectTravelCategories extends StatefulWidget {
  const SelectTravelCategories({Key? key}) : super(key: key);

  @override
  _SelectTravelCategoriesState createState() => _SelectTravelCategoriesState();
}

class _SelectTravelCategoriesState extends State<SelectTravelCategories> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Provider.of<AppData>(context).darkTheme?Palette.lessDarker:HexColor("#e9ecef"),
      body: CustomScrollView(
        slivers: [
          const SliverAppBar(
            systemOverlayStyle: SystemUiOverlayStyle.light,
            shadowColor: Colors.transparent,
            backgroundColor: Palette.kuungaaDefault,
            title: Text("Select a category",
                style: TextStyle(
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


          ),
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
              child: FutureBuilder(
                future: getCategoriesList(),
                  builder: (BuildContext context, AsyncSnapshot<List> snapshot){
                    if(snapshot.hasData)
                    {
                      return ListView.builder(
                        padding: EdgeInsets.zero,
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: snapshot.data!.length,
                        itemBuilder: (BuildContext context, int index){
                          Category category = snapshot.data![index];
                          Map categoryMap = {
                            "category_name" : category.category_name!,
                            "category_id" : category.category_id!
                          };
                          return InkWell(
                            onTap: (){
                              Navigator.pop(context, categoryMap);
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 3.0),
                              decoration: BoxDecoration(
                                color: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.white,
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              child: ListTile(
                                title: Text(category.category_name!),
                                trailing: const Icon(Icons.keyboard_arrow_right),
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
            ),
          ),
        ],
      ),
    );
  }
  Future<List> getCategoriesList() async {
    List<Category> cat = [];
    DatabaseReference dbReference = FirebaseDatabase.instance.reference().child("KUUNGAA").child("TravelCategories");
    await dbReference.once().then((DataSnapshot dataSnapshot){
      cat.clear();
      var keys = dataSnapshot.value.keys;
      var values = dataSnapshot.value;

      for (var key in keys)
      {
        Category category = Category();
        category.category_id = values [key]["category_id"];
        category.category_name = values [key]["category_name"];

        cat.add(category);
      }
    });
    return cat.reversed.toList();
  }

}

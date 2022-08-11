
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:kuungaa/DataHandler/appData.dart';
import 'package:kuungaa/Models/category.dart';
import 'package:kuungaa/config/palette.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:snippet_coder_utils/hex_color.dart';

import 'widgets.dart';

class TravelCategories extends StatefulWidget {
  const TravelCategories({Key? key}) : super(key: key);



  @override
  _TravelCategoriesState createState() => _TravelCategoriesState();
}

class _TravelCategoriesState extends State<TravelCategories> {

  late Future<List> getCategories;

  int selectedIndex = 0;

  String travelCategory = "All";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCategories = getCategoriesList();

  }
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          sliver: SliverToBoxAdapter(
            child: Container(
              height: 60.0,
              color: Provider.of<AppData>(context).darkTheme?Palette.lessDarker:Colors.white,
              child: FutureBuilder(
                  future: getCategories,
                  builder: (BuildContext context, AsyncSnapshot<List> snapshot){
                    if(snapshot.connectionState == ConnectionState.done){
                      return Column(
                        children: [
                          Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                vertical: 10.0,
                                horizontal: 4.0,
                              ),
                              scrollDirection: Axis.horizontal,
                              itemCount: 1 + snapshot.data!.length,
                              itemBuilder: (BuildContext context, int index){
                                /*if(index == 0){
                              return Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8.0),
                                child: _CreateCategoryButton(),
                              );
                            }*/
                                if(index == 0){
                                  return InkWell(
                                    onTap: (){
                                      setState(() {
                                        selectedIndex = 0;
                                        travelCategory = "All";
                                        //print("selected index" + selectedIndex!.toString());
                                      });
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.all(2.0),
                                      padding: const EdgeInsets.all(8.0),
                                      height: 20.0,

                                      decoration: Provider.of<AppData>(context).darkTheme?BoxDecoration(
                                        color: selectedIndex == 0? Palette.darker : Palette.mediumDarker,
                                        border: Border.all(
                                          width: 1.0,
                                          color: Palette.lessMediumDarker,
                                        ),
                                        borderRadius: BorderRadius.circular(15.0),
                                      ):BoxDecoration(
                                        color: selectedIndex == 0? HexColor("#ced4da") : HexColor("#e9ecef"),
                                        border: Border.all(
                                          width: 1.0,
                                          color: HexColor("#dddddd"),
                                        ),
                                        borderRadius: BorderRadius.circular(15.0),
                                      ),

                                      child: selectedIndex == 0? const Text(
                                        "All",
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ) : const Text("All"),
                                    ),
                                  );
                                }
                                final Category cat = snapshot.data![index - 1];
                                return InkWell(
                                  onTap: (){
                                    setState(() {
                                      selectedIndex = index;
                                      travelCategory = cat.category_id!;
                                      //print("selected index" + selectedIndex!.toString());
                                    });
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.all(2.0),
                                    padding: const EdgeInsets.all(8.0),
                                    height: 20.0,

                                    decoration: Provider.of<AppData>(context).darkTheme?BoxDecoration(
                                      color: selectedIndex == index? Palette.darker : Palette.mediumDarker,
                                      border: Border.all(
                                        width: 1.0,
                                        color: Palette.lessMediumDarker,
                                      ),
                                      borderRadius: BorderRadius.circular(15.0),
                                    ):BoxDecoration(
                                      color: selectedIndex == index? HexColor("#ced4da") : HexColor("#e9ecef"),
                                      border: Border.all(
                                        width: 1.0,
                                        color: HexColor("#dddddd"),
                                      ),
                                      borderRadius: BorderRadius.circular(15.0),
                                    ),

                                    child: selectedIndex == index? Text(
                                      cat.category_name!,
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ) : Text(cat.category_name!),
                                  ),
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
                              itemCount: 15,
                              padding: const EdgeInsets.symmetric(
                                vertical: 10.0,
                                horizontal: 4.0,
                              ),
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (BuildContext context, int index){
                                return Shimmer.fromColors(
                                  baseColor: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.grey[300]!,
                                  highlightColor: Provider.of<AppData>(context).darkTheme?Palette.lessDarker:Colors.grey[100]!,
                                  child: Container(
                                    margin: const EdgeInsets.all(2.0),
                                    padding: const EdgeInsets.all(8.0),
                                    width: 80.0,
                                    height: 20.0,
                                    decoration: BoxDecoration(
                                      color:  Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.grey[300]!,
                                      border: Border.all(
                                        width: 1.0,
                                        color: HexColor("#dddddd"),
                                      ),
                                      borderRadius: BorderRadius.circular(15.0),
                                    ),

                                  ),
                                );
                              }
                            ),
                          ),
                        ],
                      );
                    }
                  }
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Container(
            height: 1.0,
            width: MediaQuery.of(context).size.width,
            color: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.grey[300]!,
          ),
        ),
        SliverList(
          delegate: SliverChildListDelegate([
            TravelPostContainer(travelCategory: travelCategory,),
          ]),
        ),
      ],
    );
  }

  Future<List> getCategoriesList() async {
    List<Category> categoriesList = [];
    DatabaseReference dbReference = FirebaseDatabase.instance.reference().child("KUUNGAA").child("TravelCategories");
    await dbReference.once().then((DataSnapshot dataSnapshot){
      categoriesList.clear();
      var keys = dataSnapshot.value.keys;
      var values = dataSnapshot.value;

      for (var key in keys)
      {
        Category category = Category();
        category.category_id = values [key]["category_id"];
        category.category_name = values [key]["category_name"];

        categoriesList.add(category);
      }
    });
    return categoriesList;
  }
}

class _CreateCategoryButton extends StatefulWidget {
  const _CreateCategoryButton({Key? key}) : super(key: key);

  @override
  State<_CreateCategoryButton> createState() => _CreateCategoryButtonState();
}

class _CreateCategoryButtonState extends State<_CreateCategoryButton> {
  TextEditingController categoryTextEditingController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () => openDialog(context),
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        backgroundColor: Colors.white,
        side: const BorderSide(
          width: 2.0,
          color: Palette.kuungaaDefault,
        ),
        textStyle: TextStyle(
          color: Palette.kuungaaDefault,
        ),
      ),
      child: Row(
        children: [
          ShaderMask(
            shaderCallback: (rect) => Palette.createRoomGradient.createShader(rect),
            child: const Icon(
              Icons.add,
              size: 30.0,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 2.0,),
          const Text('Add'),
        ],
      ),
    );
  }

  openDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Create a new category"),
        content: TextField(
          controller: categoryTextEditingController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: "Enter new category",
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
                onPressed: () => saveCategory(),
                child: const Text("Save"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  saveCategory() {
    if(categoryTextEditingController.text.isNotEmpty){
      DatabaseReference newCatRef = FirebaseDatabase.instance.reference().child('KUUNGAA').child('TravelCategories').push();
      String categoryid = newCatRef.key;

      Map categoryDataMap = {
        "category_id" : categoryid,
        "category_name" : categoryTextEditingController.text,
      };

      newCatRef.set(categoryDataMap).then((onValue) {
        Navigator.pop(context);
        displayToastMessage("A new category was saved successfully.", context);
        setState(() {

        });
      }).catchError((onError) {
        Navigator.pop(context);
        displayToastMessage("An error occurred. Please try again later", context);
      });

    }
  }
}



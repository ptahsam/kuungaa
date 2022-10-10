import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kuungaa/Assistants/assistantMethods.dart';
import 'package:kuungaa/DataHandler/appData.dart';
import 'package:kuungaa/Models/category.dart';
import 'package:kuungaa/Models/user.dart';
import 'package:kuungaa/config/config.dart';
import 'package:kuungaa/config/palette.dart';
import 'package:kuungaa/sharedWidgets/widgets.dart';
import 'package:provider/provider.dart';
import 'package:snippet_coder_utils/hex_color.dart';

class TravelPage extends StatefulWidget {

  static const String idScreen = "travelPage";

  const TravelPage({Key? key}) : super(key: key);

  @override
  _TravelPageState createState() => _TravelPageState();
}

class _TravelPageState extends State<TravelPage> with AutomaticKeepAliveClientMixin<TravelPage>{

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: Provider.of<AppData>(context).darkTheme?Palette.lessDarker:Colors.white,
        body: Responsive(
          mobile: _TravelScreenMobile(),
          desktop: _TravelScreenDesktop(),
          tablet: _TravelScreenDesktop(),
        ),
      ),
    );
  }
}

class MultiSelectChip extends StatefulWidget {
  final List<Category> categoryList;

  const MultiSelectChip({Key? key, required this.categoryList}) : super(key: key);



  @override
  _MultiSelectChipState createState() => _MultiSelectChipState();
}

class _MultiSelectChipState extends State<MultiSelectChip>  {
  String selectedChoice = "";
  List<Category> selectedList = [];
  // this function will build and return the choice list

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserInterests();
  }


  _buildChoiceList() {
    List<Widget> choices = [];

    for (var item in widget.categoryList) {
      choices.add(
        Container(
          padding: const EdgeInsets.all(2.0),
          child: Provider.of<AppData>(context).darkTheme?ChoiceChip(
            backgroundColor: selectedList.contains(item)? Palette.kuungaaDefault : Palette.mediumDarker,
            label: Text(item.category_name!, style: TextStyle(color: selectedList.contains(item)? Colors.white : Colors.black),),
            selected: selectedChoice == item.category_name!,
            onSelected: (selected) {
              setState(() {

                DatabaseReference dbRef = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Interests").child(userCurrentInfo!.user_id!).child(item.category_id!);
                if(selectedList.contains(item)){
                  selectedList.removeWhere((Category category) => category.category_name == item.category_name!);
                  dbRef.remove();
                }else{
                  selectedList.add(item);
                  Map selectedCategoryMap = {
                    "category_id" : item.category_id,
                    "category_name" : item.category_name
                  };
                  dbRef.set(selectedCategoryMap);
                }
                //selectedChoice = item.category_name!;
              });
            },
          ):ChoiceChip(
            backgroundColor: selectedList.contains(item)? Palette.kuungaaDefault : Colors.grey[200]!,
            label: Text(item.category_name!, style: TextStyle(color: selectedList.contains(item)? Colors.white : Colors.black),),
            selected: selectedChoice == item.category_name!,
            onSelected: (selected) {
              setState(() {

                DatabaseReference dbRef = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Interests").child(userCurrentInfo!.user_id!).child(item.category_id!);
                if(selectedList.contains(item)){
                  selectedList.removeWhere((Category category) => category.category_name == item.category_name!);
                  dbRef.remove();
                }else{
                  selectedList.add(item);
                  Map selectedCategoryMap = {
                    "category_id" : item.category_id,
                    "category_name" : item.category_name
                  };
                  dbRef.set(selectedCategoryMap);
                }
                //selectedChoice = item.category_name!;
              });
            },
          ),
        ),
      );
    }
    return choices;
  }


  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: _buildChoiceList(),
    );
  }

  Future<void> getUserInterests()  async {
    DatabaseReference dbRef = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Interests").child(FirebaseAuth.instance.currentUser!.uid);
    dbRef.once().then((DataSnapshot snapshot){
      if(snapshot.exists){
        var keys = snapshot.value.keys;
        var value = snapshot.value;

        for(var key in keys){
          Category category = Category();
          category.category_id = value[key]["category_id"];
          category.category_name = value[key]["category_name"];
          selectedList.add(category);
        }
      }
    });
  }
}

class _TravelScreenMobile extends StatefulWidget {
  const _TravelScreenMobile({Key? key}) : super(key: key);

  @override
  State<_TravelScreenMobile> createState() => _TravelScreenMobileState();
}

class _TravelScreenMobileState extends State<_TravelScreenMobile> {

  late Future<List<Category>> getCategories;
  TextEditingController categoryTextEditingController = TextEditingController();

  int _selectedIndex = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCategories = getCategoriesList();
  }
  
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: NestedScrollView(
        scrollDirection: Axis.vertical,
        headerSliverBuilder: (context, bool s) => [
          SliverAppBar(
            backgroundColor: Provider.of<AppData>(context).darkTheme?Palette.darker:Colors.white,
            shadowColor: Colors.transparent,
            floating: true,
            leadingWidth: 0.0,
            snap: true,
            elevation: 40.0,
            pinned: true,
            title: Text(
              "Travel & Culture",
              style: TextStyle(
                color: HexColor("#2dce89"),
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.start,
            ),
            centerTitle: false,
            /*leading: Icon(
                  const IconData(0xe900, fontFamily: "icomoon"),
                  size: 24.0,
                  color: HexColor("#2dce89"),
                ),*/
            actions: [
              CircleButton(
                icon: const IconData(0xe929, fontFamily: "icomoon"),
                iconSize: 22.0,
                onPressed: () => showModalBottomSheet(
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0)),
                  ),
                  context: context,
                  builder: (context) => buildTravelSheet(),
                ),
              ),
              /*CircleButton(
                  icon: IconData(0xe908, fontFamily: "icomoon"),
                  iconSize: 22.0,
                  onPressed: () => print("Chat"),
                ),
                */
            ],
            bottom: TabBar(
              onTap: (index){
                setState(() {
                  _selectedIndex = index;
                });
              },
              padding: const EdgeInsets.symmetric(horizontal: 10.0,),
              indicator: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Provider.of<AppData>(context).darkTheme?Colors.white:HexColor("#2dce89"),
                    width: 3.0,

                  ),
                ),
                //borderRadius: BorderRadius.circular(5.0),
              ),
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Provider.of<AppData>(context).darkTheme?Icon(
                        const IconData(0xe91f, fontFamily: "icomoon"), color: Colors.white, size: 18.0,
                      ):ShaderMask(
                          shaderCallback: (rect) => Palette.createIconGradient.createShader(rect),
                          child: Icon(const IconData(0xe91f, fontFamily: "icomoon"), color: HexColor("#2dce89"), size: 18.0,)
                      ),
                      const SizedBox(width: 6.0,),
                      Provider.of<AppData>(context).darkTheme?Text(
                        "Home",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ):ShaderMask(
                          shaderCallback: (rect) => Palette.createIconGradient.createShader(rect),
                          child: Text("Home", style: TextStyle(color: HexColor("#2dce89"),),)),
                    ],
                  ),

                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Provider.of<AppData>(context).darkTheme?const Icon(
                        IconData(0xe93c, fontFamily: "icomoon"),
                        color: Colors.white,
                        size: 18.0,
                      ):
                      ShaderMask(
                          shaderCallback: (rect) => Palette.createIconGradient.createShader(rect),
                          child: Icon(const IconData(0xe93c, fontFamily: "icomoon"), color: HexColor("#2dce89"), size: 18.0,)),
                      const SizedBox(width: 10.0,),
                      Provider.of<AppData>(context).darkTheme?Text(
                        "Explore",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ):ShaderMask(
                          shaderCallback: (rect) => Palette.createIconGradient.createShader(rect),
                          child: Text("Explore", style: TextStyle(color: HexColor("#2dce89"),),)),
                    ],
                  ),
                ),
                /*Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ShaderMask(
                              shaderCallback: (rect) => Palette.createIconGradient.createShader(rect),
                              child: Icon(const IconData(0xe91e, fontFamily: "icomoon"), color: HexColor("#2dce89"), size: 18.0,)),
                          const SizedBox(width: 6.0,),
                          ShaderMask(
                              shaderCallback: (rect) => Palette.createIconGradient.createShader(rect),
                              child: Text("History", style: TextStyle(color: HexColor("#2dce89"),),)),
                        ],
                      ),
                    ),*/
              ],
            ), systemOverlayStyle: SystemUiOverlayStyle.dark,
          ),
        ],
        body: IndexedStack(
          index: _selectedIndex,
          children: [
            TravelCategories(),
            CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Container(
                    padding: EdgeInsets.only(top: 15.0, left: 12.0, right: 12.0),
                    height: MediaQuery.of(context).size.height,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Center(
                            child: Text("Select topics you are interested in", style: TextStyle(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis, maxLines: 2,),
                          ),
                        ),
                        FutureBuilder<List<Category>>(
                            future: getCategories,
                            builder: (BuildContext context, AsyncSnapshot<List<Category>> snapshot){
                              if(snapshot.connectionState == ConnectionState.done){
                                if(snapshot.hasData){
                                  List<Category> categoryList = snapshot.data!;
                                  return MultiSelectChip(categoryList: categoryList,);
                                }else{
                                  return Align(
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
                                              Icons.category_outlined,
                                              color: Colors.grey,
                                            ),
                                            SizedBox(height: 6.0,),
                                            Text("No topics found!", textAlign: TextAlign.center,),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }
                              }else{
                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                            }
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            //Text("History"),
          ],
        ),
      ),
    );
  }

  Future<List<Category>> getCategoriesList() async {
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

  Widget buildTravelSheet() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 20.0),

      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () {
              if(userCurrentInfo != null){
                Navigator.pop(context);
                openDialog(context);
              }
            },
            child: Row(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8.0),
                  height: 60.0,
                  width: 60.0,

                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        color: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.grey[200],
                        shape: BoxShape.circle,
                      ),
                      child: Provider.of<AppData>(context).darkTheme?Icon(
                        const IconData(0xe929, fontFamily: "icomoon"),
                        size: 26.0,
                        color: HexColor("#2dce89"),
                      ):ShaderMask(
                        shaderCallback: (rect) => Palette.createIconGradient.createShader(rect),
                        child: Icon(
                          const IconData(0xe929, fontFamily: "icomoon"),
                          size: 26.0,
                          color: HexColor("#2dce89"),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14.0,),
                const Text(
                  "Create a travel category",
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () async{
              if(userCurrentInfo != null){
                Navigator.pop(context);
                var res= await Navigator.push(context, MaterialPageRoute(builder: (context)=> CreateTravelPost()));
                if(res != ""){
                  setState(() {

                  });
                }
              }
            },
            child: Row(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8.0),
                  height: 60.0,
                  width: 60.0,
                  child: Stack(
                    children: [
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(10.0),
                          decoration: BoxDecoration(
                            color: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.grey[200],
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            const IconData(0xe900, fontFamily: "icomoon"),
                            size: 26.0,
                            color: HexColor("#2dce89"),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 15.0,
                        right: 0.0,
                        child: Container(
                          padding: const EdgeInsets.all(3.0),
                          decoration: BoxDecoration(
                            color: HexColor("#2dce89"),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            IconData(0xe929, fontFamily: "icomoon"),
                            color: Colors.white,
                            size: 16.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14.0,),
                const Text(
                  "Create a travel post",
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
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

  openDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Create a new category"),
        content: TextField(
          controller: categoryTextEditingController,
          autofocus: true,
          style: TextStyle(
            color: Provider.of<AppData>(context).darkTheme?Colors.white:Colors.black,
          ),
          decoration: InputDecoration(
            hintText: "Enter new category",
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
                onPressed: () => saveCategory(),
                child: const Text("Save"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TravelScreenDesktop extends StatefulWidget {
  const _TravelScreenDesktop({Key? key}) : super(key: key);

  @override
  State<_TravelScreenDesktop> createState() => _TravelScreenDesktopState();
}

class _TravelScreenDesktopState extends State<_TravelScreenDesktop> {

  late Future<List<Category>> getCategories;
  TextEditingController categoryTextEditingController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCategories = getCategoriesList();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          flex: 2,
          child: Container(),
        ),
        Spacer(),
        Container(
          width: 600.0,
          child: TravelCategories(),
        ),
        Spacer(),
        Flexible(
          flex: 2,
          child: Container(),
        ),
      ],
    );
  }

  Future<List<Category>> getCategoriesList() async {
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



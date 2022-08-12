import 'package:anim_search_bar/anim_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kuungaa/DataHandler/appData.dart';
import 'package:kuungaa/config/palette.dart';
import 'package:provider/provider.dart';
class SelectExpression extends StatefulWidget {
  const SelectExpression({Key? key}) : super(key: key);

  @override
  _SelectExpressionState createState() => _SelectExpressionState();
}

class _SelectExpressionState extends State<SelectExpression> {

  List searchedList = [];

  List expressionList =
  ["Happy", "Loved", "Lovely", "Excited", "Crazy", "Blessed", "Sad", "Thankful",
   "In love", "Fantastic", "Silly", "Amused", "Positive", "Hopeful", "Tired", "Motivated",
   "Jovial", "Chill", "Relax", "Cool", "Proud", "Thought", "Sick", "Angry", "Mad", "Ready",
   "Emotional", "Awesome", "Okay", "Annoyed", "Heartbroken", "Sleepy", "Pained", "Peaceful",
   "Annoyed", "Bored", "Disappointed", "Cold", "Bad", "Good", "Down", "Great", "Hopeless",
   "Cute", "Satisfied", "Strong", "Missing", "Calm", "Strong", "Depressed", "Healthy",
   "Rich", "Broke", "Betrayed", "Generous", "Smart", "Ignored", "Useless", "Hungover"
  ];

  TextEditingController textEditingController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    textEditingController.addListener(handleTextchange);
  }

  void handleTextchange() {
    if(textEditingController.text != "" || textEditingController != null){
      List result = expressionList.where((element) => element.toString().toLowerCase().contains(textEditingController.text.toLowerCase())).toSet().toList();
      setState(() {
        searchedList = result.toSet().toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverAppBar(
            systemOverlayStyle: SystemUiOverlayStyle.light,
            shadowColor: Colors.transparent,
            backgroundColor: Palette.kuungaaDefault,
            title: Text("Select an expression",
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
              padding: EdgeInsets.only(left: 12.0, right: 12.0, top: 5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("SELECT"),
                  AnimSearchBar(
                    width: MediaQuery.of(context).size.width * 0.65,
                    textController: textEditingController,
                    rtl: true,
                    onSuffixTap: () {
                      setState(() {
                        textEditingController.clear();
                        searchedList.clear();
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: searchedList.isNotEmpty?Container(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: searchedList.length,
                itemBuilder: (BuildContext context, int index){

                  return InkWell(
                    onTap: (){
                      Navigator.pop(context, searchedList[index]);
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 3.0),
                      decoration: BoxDecoration(
                        color: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.white,
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      child: ListTile(
                        title: Text(searchedList[index]),
                        trailing: const Icon(Icons.keyboard_arrow_right),
                      ),
                    ),
                  );
                },
              ),
            ):Container(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: expressionList.length,
                itemBuilder: (BuildContext context, int index){

                  return InkWell(
                    onTap: (){
                      Navigator.pop(context, expressionList[index]);
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 3.0),
                      decoration: BoxDecoration(
                        color: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.white,
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      child: ListTile(
                        title: Text(expressionList[index]),
                        trailing: const Icon(Icons.keyboard_arrow_right),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

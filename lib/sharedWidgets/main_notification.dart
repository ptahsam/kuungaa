import 'package:flutter/material.dart';
import 'package:kuungaa/config/palette.dart';
class MainNotification extends StatefulWidget {
  const MainNotification({Key? key}) : super(key: key);

  @override
  _MainNotificationState createState() => _MainNotificationState();
}

class _MainNotificationState extends State<MainNotification> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Palette.kuungaaDefault,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white,),
          //iconSize: 36.0,
          color: Colors.white,
          onPressed: (){
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "Your notifications",
          style: TextStyle(
            color: Colors.white,
            //fontSize: 22.0,
            //fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
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
      body: const CustomScrollView(
        slivers: [
          SliverToBoxAdapter(

          ),
        ],
      ),
    );
  }
}

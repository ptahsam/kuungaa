import 'package:flutter/material.dart';
import 'package:kuungaa/Models/media.dart';
class LoadingPage extends StatefulWidget {
  const LoadingPage({Key? key}) : super(key: key);

  static const String idScreen = "loadingPage";

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Align(
          alignment: Alignment.center,
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }
}

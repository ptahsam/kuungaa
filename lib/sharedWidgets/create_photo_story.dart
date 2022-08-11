import 'dart:io';

import 'package:flutter/material.dart';
class CreatePhotoStory extends StatefulWidget {
  const CreatePhotoStory({Key? key}) : super(key: key);

  @override
  _CreatePhotoStoryState createState() => _CreatePhotoStoryState();
}

class _CreatePhotoStoryState extends State<CreatePhotoStory> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      /*body: FutureBuilder(
        future: getUserPhoto(),
        builder: (BuildContext context, AsyncSnapshot<File?> snapshot){
          if(snapshot.hasData){
            return Container(
              decoration: BoxDecoration(
                  gradient: Palette.createStoryTextGradient
              ),
              alignment: Alignment.center,
              child: Image.file(snapshot.data!),
            );
            }else{
            return const SizedBox.shrink();
          }
        },
      ),*/
    );
  }

  Future<File?> getUserPhoto() async{

  }
}

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kuungaa/config/palette.dart';
import 'package:snippet_coder_utils/hex_color.dart';

class VideosMenu extends StatefulWidget {
  const VideosMenu({Key? key}) : super(key: key);

  @override
  _VideosMenuState createState() => _VideosMenuState();
}

class _VideosMenuState extends State<VideosMenu> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          OutlinedButton(
            onPressed: ()
            {

            },
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              backgroundColor: HexColor("#ced4da"),
              side: const BorderSide(
                width: 0.2,
                color: Color(0xFF2dce89),
              ),
              textStyle: TextStyle(
                color: Palette.kuungaaBlue,
              ),
            ),
            child: Row(
              children: [
                ShaderMask(
                  shaderCallback: (rect) => Palette.createIconGradient.createShader(rect),
                  child: const Icon(
                    FontAwesomeIcons.tv,
                    size: 18.0,
                    color: Color(0xFF2dce89),
                  ),
                ),
                const SizedBox(width: 8.0,),
                const Text(
                  'Watch',
                  style: TextStyle(
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8.0,),
          OutlinedButton(
            onPressed: (){

            },
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              backgroundColor: HexColor("#ced4da"),
              side: const BorderSide(
                width: 0.2,
                color: Color(0xFF2dce89),
              ),
              textStyle: TextStyle(
                color: Palette.kuungaaBlue,
              ),
            ),
            child: Row(
              children: [
                ShaderMask(
                  shaderCallback: (rect) => Palette.createIconGradient.createShader(rect),
                  child: const Icon(
                    FontAwesomeIcons.video,
                    size: 18.0,
                    color: Color(0xFF2dce89),
                  ),
                ),
                const SizedBox(width: 8.0,),
                const Text(
                  'Live',
                  style: TextStyle(
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8.0,),
          OutlinedButton(
            onPressed: (){

            },
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              backgroundColor: HexColor("#ced4da"),
              side: const BorderSide(
                width: 0.2,
                color: Color(0xFF2dce89),
              ),
              textStyle: TextStyle(
                color: Palette.kuungaaBlue,
              ),
            ),
            child: Row(
              children: [
                ShaderMask(
                  shaderCallback: (rect) => Palette.createIconGradient.createShader(rect),
                  child: const Icon(
                    FontAwesomeIcons.save,
                    size: 18.0,
                    color: Color(0xFF2dce89),
                  ),
                ),
                const SizedBox(width: 8.0,),
                const Text(
                  'Saved',
                  style: TextStyle(
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

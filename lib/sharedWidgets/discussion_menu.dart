import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kuungaa/config/palette.dart';
import 'package:snippet_coder_utils/hex_color.dart';
class DiscussionMenu extends StatefulWidget {
  const DiscussionMenu({Key? key}) : super(key: key);

  @override
  _DiscussionMenuState createState() => _DiscussionMenuState();
}

class _DiscussionMenuState extends State<DiscussionMenu> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0,vertical: 8.0),
      color: Colors.white,
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Card(
              shadowColor: HexColor("#ced4da"),
              elevation: 2.0,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Center(
                      child: ShaderMask(
                        shaderCallback: (rect) => Palette.createIconGradient.createShader(rect),
                        child: const Icon(
                          FontAwesomeIcons.userFriends,
                          color: Colors.green,
                          size: 18.0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6.0,),
                    const Center(
                      child: Text(
                        "Groups"
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8.0,),
          Expanded(
            child: Card(
              shadowColor: HexColor("#ced4da"),
              elevation: 2.0,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Center(
                      child: ShaderMask(
                        shaderCallback: (rect) => Palette.createIconGradient.createShader(rect),
                        child: const Icon(
                          FontAwesomeIcons.pager,
                          color: Colors.green,
                          size: 18.0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6.0,),
                    const Center(
                      child: Text(
                          "Pages"
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

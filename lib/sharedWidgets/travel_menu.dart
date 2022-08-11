import 'package:flutter/material.dart';
import 'package:kuungaa/config/palette.dart';

class TravelMenu extends StatefulWidget {
  const TravelMenu({Key? key}) : super(key: key);

  @override
  _TravelMenuState createState() => _TravelMenuState();
}

class _TravelMenuState extends State<TravelMenu> {
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
            child: Container(
              padding: const EdgeInsets.fromLTRB(6.0,8.0,0.0,8.0),
              decoration: BoxDecoration(

                border: Border.all(
                  width: 0.2,
                  color: const Color(0xFF2dce89),
                ),
                borderRadius: BorderRadius.circular(5.0),
              ),

              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ShaderMask(
                    shaderCallback: (rect) => Palette.createIconGradient.createShader(rect),
                    child: const Icon(
                      IconData(0xe91f, fontFamily: "icomoon"),
                      size: 18.0,
                      color: Color(0xFF2dce89),
                    ),
                  ),
                  const SizedBox(width: 12.0,),
                  const Text("Home"),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8.0,),
          Expanded(
            child: Container(
              padding: const EdgeInsets.fromLTRB(6.0,8.0,0.0,8.0),
              decoration: BoxDecoration(
                border: Border.all(
                  width: 0.2,
                  color: const Color(0xFF2dce89),
                ),
                borderRadius: BorderRadius.circular(5.0),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ShaderMask(
                    shaderCallback: (rect) => Palette.createIconGradient.createShader(rect),
                    child: const Icon(
                      IconData(0xe93c, fontFamily: "icomoon"),
                      size: 18.0,
                      color: Color(0xFF2dce89),
                    ),
                  ),
                  const SizedBox(width: 12.0,),
                  const Text("Explore"),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8.0,),
          Expanded(
            child: Container(
              padding: const EdgeInsets.fromLTRB(6.0,8.0,0.0,8.0),
              decoration: BoxDecoration(
                border: Border.all(
                  width: 0.2,
                  color: const Color(0xFF2dce89),
                ),
                borderRadius: BorderRadius.circular(5.0),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ShaderMask(
                    shaderCallback: (rect) => Palette.createIconGradient.createShader(rect),
                    child: const Icon(
                      IconData(0xe91e, fontFamily: "icomoon"),
                      size: 18.0,
                      color: Color(0xFF2dce89),
                    ),
                  ),
                  const SizedBox(width: 12.0,),
                  const Text("History"),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

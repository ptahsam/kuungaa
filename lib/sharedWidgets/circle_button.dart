import 'package:flutter/material.dart';
import 'package:kuungaa/DataHandler/appData.dart';
import 'package:kuungaa/config/palette.dart';
import 'package:provider/provider.dart';

class CircleButton extends StatelessWidget {
  final IconData icon;
  final double iconSize;
  final void Function() onPressed;
  final Color iconColor;

  const CircleButton(
      {Key? key,
        required this.icon,
        required this.iconSize,
        required this.onPressed,
        this.iconColor = Colors.grey
      }) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(6.0),
      decoration: BoxDecoration(
        color: Provider.of<AppData>(context).darkTheme?Palette.lessDarker:Colors.grey[200],
        shape: BoxShape.circle,
      ),
      child: ShaderMask(
        shaderCallback: (rect) => Palette.createStoryGradient.createShader(rect),
        child: IconButton(
          iconSize: iconSize,
          icon: Icon(
            icon,
            color: iconColor,
          ),
          color: Palette.kuungaaDefault,
          onPressed: onPressed,
        ),
      ),
    );
  }
}

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:kuungaa/DataHandler/appData.dart';
import 'package:kuungaa/config/palette.dart';
import 'package:provider/provider.dart';
import 'package:snippet_coder_utils/hex_color.dart';

class ProfileAvatar extends StatelessWidget {

  final String imageUrl;
  final bool isActive;
  final bool hasBorder;
  final double radius;
  final double borderWidth;
  final String backGroundColor;

  const ProfileAvatar({
    Key? key,
    required this.imageUrl,
    this.isActive = false,
    this.hasBorder = false,
    this.radius = 20.0,
    this.borderWidth = 17.0,
    this.backGroundColor = "#2dce89"
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CircleAvatar(
          radius: radius,
          backgroundColor: HexColor(backGroundColor),
          child: CircleAvatar(
            radius: hasBorder? borderWidth : radius,
            backgroundColor: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.grey[400],
            backgroundImage: ExtendedNetworkImageProvider(
              imageUrl,
              cache: true,
              cacheRawData: true
            ),
          ),
        ),
        isActive ? Positioned(
            bottom: 0.0,
            right: 0.0,
            child: Container(
              height: 15.0,
              width: 15.0,
              decoration: BoxDecoration(
                color: Palette.online,
                shape: BoxShape.circle,
                border: Border.all(
                  width: 2.0,
                  color: Colors.white,
                ),
              ),
            ),
        ) : const SizedBox.shrink(),
      ],
    );
  }
}

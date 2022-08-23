
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';

class BoxAvatar extends StatelessWidget {
  final String imageUrl;
  final bool isActive;
  final bool hasBorder;
  final double dimension;
  final double innerDimension;
  final String backGroundColor;

  const BoxAvatar({
    Key? key,
    required this.imageUrl,
    this.isActive = false,
    this.hasBorder = false,
    this.dimension = 30.0,
    this.innerDimension = 30.0,
    this.backGroundColor = "#2dce89"
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(5.0),
          child: ExtendedImage.network(
            imageUrl,
            height: dimension,
            width: dimension,
            fit: BoxFit.cover,
            cache: true,
            cacheRawData: true,
          ),
        ),
        Container(
          height: dimension,
          width: dimension,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(5.0),
          ),
        ),
      ],
    );
  }
}

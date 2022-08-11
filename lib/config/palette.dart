import 'package:flutter/material.dart';

class Palette {
  static const Color darker = Color(0xFF343434);
  static const Color mediumDarker = Color(0xFF424242);
  static const Color lessDarker = Color(0xFF505050);
  static const Color lessMediumDarker = Color(0xFF707070);
  static const Color scaffold = Color(0xFFF0F2F5);
  static const Color kuungaaAccent = Color(0xFFFEF9EB);
  static const Color kuungaaBlue = Color(0xFF1777F2);
  static const Color kuungaaDefault = Color(0xFF2dce89);
  static const LinearGradient createRoomGradient = LinearGradient(
      colors: [Color(0xFF496AE1), Color(0xFF2dce89)],
  );

  static const LinearGradient createStoryTextGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Colors.lightBlue, Color(0xFF2dce89)],
  );

  static const LinearGradient createStoryGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFffd600), Color(0xFF2dce89)],
  );

  static const LinearGradient createPhotoGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Colors.transparent, Colors.transparent, Colors.black12],
  );

  static const LinearGradient createLiveGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Colors.transparent, Colors.transparent, Colors.transparent, Colors.black45],
  );

  static const LinearGradient createIconGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF000000), Color(0xFF2dce89)],
  );

  static const Color online = Color(0xFF4BCB1F);
  static const LinearGradient storyGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Colors.transparent, Colors.black54]
  );
  static const LinearGradient storyDarkGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Colors.transparent, Color(0xFF343434)]
  );
  static const LinearGradient containerGradient = LinearGradient(
      begin: Alignment.bottomRight,
      end: Alignment.topRight,
      colors: [Colors.transparent, Colors.black87]
  );

  static const LinearGradient createTextGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFFffd600), Color(0xFF2dce89)],
  );

  static BoxDecoration kGradientBoxDecoration = BoxDecoration(
    gradient: LinearGradient(
        colors: [Colors.yellow.shade600, Colors.orange, Colors.red]),
    border: Border.all(
      color: Colors.amber, //kHintColor, so this should be changed?
    ),
    borderRadius: BorderRadius.circular(32),
  );
}
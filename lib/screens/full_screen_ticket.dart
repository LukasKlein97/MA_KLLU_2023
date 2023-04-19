import 'dart:io';

import 'package:flutter/material.dart';
import 'package:screen_brightness/screen_brightness.dart';

class FullScreenImage extends StatefulWidget {
  final String imagePath;

  FullScreenImage({required this.imagePath});

  @override
  _FullScreenImageState createState() => _FullScreenImageState();
}

class _FullScreenImageState extends State<FullScreenImage> {
  @override
  void initState() {
    super.initState();
    setBrightness(1.0);
  }

  Future<void> setBrightness(double brightness) async {
    try {
      await ScreenBrightness().setScreenBrightness(brightness);
    } catch (e) {
      print(e);
      throw 'Failed to set brightness';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: Center(
          child: Hero(
            tag: 'imageHero',
            child: Image.file(
              File(widget.imagePath),
              fit: BoxFit.cover,
              width: MediaQuery.of(context).size.width,
              //height: MediaQuery.of(context).size.height,
            ),
          ),
        ),
      ),
    );
  }
}

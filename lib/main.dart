import 'package:flutter/material.dart';

import 'animated_heart_icon_button.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isFavourite = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SafeArea(
        child: Center(
          child: AnimatedHeartIconButton(
            onTap: () {
              setState(() {
                isFavourite = !isFavourite;
              });
            },
            isFavourite: isFavourite,
          ),
        ),
      ),
    );
  }
}

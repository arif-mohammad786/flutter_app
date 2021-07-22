import 'package:audio_player_1/tracks.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Music Player',
      theme: ThemeData(
       
        primarySwatch: Colors.blue,
      ),
      home: Tracks(),
    );
  }
}


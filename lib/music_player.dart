import 'dart:async';
import 'dart:io';

import 'package:audio_player_1/tracks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:just_audio/just_audio.dart';
import 'package:marquee/marquee.dart';

class MusicPlayer extends StatefulWidget {

  SongInfo songInfo;
  Function changeTrack,createRecentSongsList,nextPlaylistSong;
  int index;
  String plName;
  final GlobalKey<MusicPlayerState> key;
  MusicPlayer({this.songInfo, this.changeTrack,this.plName,this.nextPlaylistSong,this.key});
  MusicPlayerState createState() => MusicPlayerState();
}

class MusicPlayerState extends State<MusicPlayer> {
  double minimumValue = 0.0, maximumValue = 0.0, currentValue = 0.0;
  String currentTime = '', endTime = '',audioUrl;
  bool isPlaying = false;
  final AudioPlayer player = AudioPlayer();
  Timer timer;

  @override
  void initState() {
    super.initState();
    setSong(widget.songInfo);
  }

  @override
  void dispose() {
    super.dispose();
    player.dispose();
  }


  void setSong(SongInfo songInfo) async {
      minimumValue = 0.0; maximumValue = 0.0;currentValue = 0.0;
      currentTime = ''; endTime = '';
    print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! 1");
    print(songInfo);
    print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! 2");

    widget.songInfo = songInfo;
    await player.setUrl(widget.songInfo.uri);
    currentValue = minimumValue;
    maximumValue = player.duration.inMilliseconds.toDouble();


    setState(() {
      currentTime = getDuration(currentValue);
      endTime = getDuration(maximumValue);
    });
    isPlaying = false;
    changeStatus();
    player.positionStream.listen((duration) {
      currentValue = duration.inMilliseconds.toDouble();
      
      setState(() {
        currentTime = getDuration(currentValue);
      });
      // condition to play next song after end of one song 

      if(currentTime==endTime){
        if(widget.plName!=null)
          widget.nextPlaylistSong(true);
        else
          widget.changeTrack(true);
      }
    });
  }

  void changeStatus() {
    setState(() {
      isPlaying = !isPlaying;
    });
    if (isPlaying) {
      player.play();
    } else {
      player.pause();
    }
  }

  String getDuration(double value) {
    Duration duration = Duration(milliseconds: value.round());

    return [duration.inMinutes, duration.inSeconds]
        .map((element) => element.remainder(60).toString().padLeft(2, '0'))
        .join(':');
  }

  Widget centerImage(){
      if(widget.songInfo.albumArtwork!=null){
      return Container(
            height: 300.0,
            width: 300.0,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              // borderRadius: BorderRadius.circular(50.0),
            ),
            child: Image.file(
              File(widget.songInfo.albumArtwork),
              fit: BoxFit.fill,
              errorBuilder: (
                BuildContext context,
                Object error,
                StackTrace stackTrace,
              ) {
                return Container(
                  height: 300.0,
                  width: 300.0,
                  decoration: BoxDecoration(color:Colors.grey),
                  child: Icon(Icons.music_note, color: Colors.white,size: 100.0),
                );
              },
          )
          );
    }else{
      return Container(
        height: 300.0,
        width: 300.0,
        decoration: BoxDecoration(color:Colors.grey),
        child: Icon(Icons.music_note, color: Colors.white,size: 100.0,),
      );
    }
    
  }

  
  Widget build(context) {
    try{
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xffEC7063),Colors.orangeAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight
            )
          ),
        ),
        leading: IconButton(
            onPressed: () {
              // Navigator.of(context).pop();
              Navigator.pushReplacement(context, MaterialPageRoute(
                builder: (context)=>Tracks()
              ));
            },
            icon: Icon(Icons.arrow_back_ios_sharp, color: Colors.white)),
        centerTitle: true,
        title: Text('Now Playing', style: TextStyle(color: Colors.white)),
      ),
      body: Container(
        margin: EdgeInsets.fromLTRB(5, 57, 5, 0),
        child: Column(children: <Widget>[

          // center image widget returning function 
          centerImage(),
          
          Expanded(
              child: Container(
              margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
              width: 230.0,
              child: Expanded(
                child: Marquee(
                  text: widget.songInfo.title,
                  blankSpace: 130.0,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600),
              ),
                  )
                  ),
          ),
          
          Container(
            margin: EdgeInsets.fromLTRB(0, 0, 0, 33),
            child: Text(
              widget.songInfo.artist,
              style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12.0,
                  fontWeight: FontWeight.w500),
            ),
          ),


          Spacer(),
        
          Slider(
            inactiveColor: Colors.grey,
            activeColor: Color(0xffEC7063),
            min: minimumValue,
            max: maximumValue,
            value: currentValue,
            onChanged: (value) {
              currentValue = value;
              player.seek(Duration(milliseconds: currentValue.round()));
              
            },
            
          ),
          Container(
            transform: Matrix4.translationValues(0, -15, 0),
            margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(currentTime,
                    style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500)),
                Text(endTime,
                    style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500))
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  child:
                      Icon(Icons.skip_previous, color: Colors.orangeAccent, size: 55),
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    if(widget.plName!=null)
                      widget.nextPlaylistSong(false);
                    else
                      widget.changeTrack(false);
                  },
                ),
                GestureDetector(
                  child: Icon(
                      isPlaying
                          ? Icons.pause_circle_filled_rounded
                          : Icons.play_circle_fill_rounded,
                      color: Colors.redAccent,
                      size: 85),
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    changeStatus();
                  },
                ),
                GestureDetector(
                  child: Icon(Icons.skip_next, color: Colors.orangeAccent, size: 55),
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    if(widget.plName!=null)
                      widget.nextPlaylistSong(true);
                    else
                      widget.changeTrack(true);
                  },
                ),
              ],
            ),
          ),
        ]),
      ),
    );
    }catch(e){
      return Center(child:CircularProgressIndicator());
    }
  }
}

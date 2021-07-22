import 'dart:convert';
import 'dart:io';

import 'package:audio_player_1/music_player.dart';
import 'package:audio_player_1/tracks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: must_be_immutable
class FavouriteSongs extends StatefulWidget {
  Function changeTrack,createRecentSongsList;
  List songs;
  final GlobalKey<MusicPlayerState> key;
  FavouriteSongs({this.changeTrack,this.createRecentSongsList , this.songs,this.key});

  @override
  _FavouriteSongsState createState() => _FavouriteSongsState();
}

class _FavouriteSongsState extends State<FavouriteSongs> {
  int currentIndex = 0;
  SharedPreferences prefs;
  Future<Map> s;
  List songs=[];
  Map m;
  int flag=0,i;

  DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");



  sortSongs(){
    songs.sort((a, b) => b["time"].compareTo(a["time"]));
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    for(int i=11;i<=20;i++){
        s=SharedPreferences.getInstance().then((value){
          prefs=value;
          return json.decode(prefs.getString(i.toString()));
        });
        getSongs(s);
    }

  }

  getSongs(s) async {
    var sn=await s;
    if(sn["subtitle"]==widget.songs[sn["index"]].artist && sn["title"]==widget.songs[sn["index"]].title)
      songs.add(await s);
    setState(() {
      
    });
    
  }


  bodyContent(){

    sortSongs();

    return ListView.separated(
                separatorBuilder: (context,index){return Divider();},
                shrinkWrap: true,
                physics: AlwaysScrollableScrollPhysics(),
                itemCount: songs.length,
                itemBuilder: (context, index){
                  return ListTile(
                    leading: songs[index]["albumArtwork"] != null
                        ? Image.file(
                            File(songs[index]["albumArtwork"]),
                            height: 40.0,
                            width: 40.0,
                            fit: BoxFit.fill,
                            errorBuilder: (
                              BuildContext context,
                              Object error,
                              StackTrace stackTrace,
                            ) {
                              return Container(
                                height: 40.0,
                                width: 40.0,
                                decoration: BoxDecoration(color: Colors.grey),
                                child: Icon(Icons.music_note, color: Colors.white),
                              );
                            },
                          )
                        : Container(
                            height: 40.0,
                            width: 40.0,
                            decoration: BoxDecoration(color: Colors.grey),
                            child: Icon(Icons.music_note, color: Colors.white),
                          ),
                    title: Text(songs[index]["title"]),
                    subtitle: Text(songs[index]["subtitle"]),
                    onTap: (){

                      widget.createRecentSongsList(songs[index]["index"],widget.songs[songs[index]["index"]]);

                      Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => MusicPlayer(
                          changeTrack: widget.changeTrack,
                          songInfo: widget.songs[songs[index]["index"]],
                          key: widget.key)));
                    },
                  );
                },
          );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [Color(0xffEC7063), Colors.orangeAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight)),
        ),
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Navigator.pushReplacement(
              //     context, MaterialPageRoute(builder: (context) => Tracks()));
            },
            icon: Icon(Icons.arrow_back_ios_sharp, color: Colors.white)),
        title: Text('Favourites', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: songs.length==0 ? Center(child:Text(
        "Nothing In Favourites",
        style: TextStyle(
          fontSize: 25.0,
          color: Colors.grey,
          fontWeight: FontWeight.bold
        ),
      )) : bodyContent(),
    );
  }
}

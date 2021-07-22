import 'dart:io';

import 'package:audio_player_1/music_player.dart';
import 'package:audio_player_1/playlist_songs.dart';
import 'package:audio_player_1/tracks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Playlist extends StatefulWidget {
  List<SongInfo> songs;
  final GlobalKey<MusicPlayerState> key;
  Function changeTrack, createRecentSongsList;
  Playlist(
      {this.songs, this.key, this.changeTrack, this.createRecentSongsList});
  @override
  _PlaylistState createState() => _PlaylistState();
}

class _PlaylistState extends State<Playlist> {
  String plName="";
  SharedPreferences prefs;
  Future<List<String>> plist;
  List<String> playLists = [];

  @override
  void initState() {
    super.initState();
    plist = SharedPreferences.getInstance().then((value) {
      prefs = value;
      return prefs.getStringList("playlists") ?? [];
    });

    getPlaylists();
  }

  getPlaylists() async {
    playLists = await plist;
    setState(() {});
  }

// start function to create new playlist

  createPlaylist() {
    if(plName!="")
    {
       List<String> l = prefs.getStringList("playlists") ?? [];
      if (!l.contains(plName)) l.add(plName);
      prefs.setStringList("playlists", l);
      print("created");
    }
    else{
      print("plName is emplty");
    }
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => Tracks()));
  }
// end function to create new playlist

// start function to create dislogbox

  getDialogBox() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Create Playlist"),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  TextField(
                    decoration: InputDecoration(hintText: 'Plalist Name'),
                    onChanged: (val) {
                      setState(() {
                        plName = val;
                      });
                    },
                  ),
                  SizedBox(
                    height: 15.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      ButtonTheme(
                        minWidth: 100.0,
                        child: ElevatedButton(
                          child: Text("Save"),
                          onPressed: () {
                            createPlaylist();
                          },
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          );
        });
  }

// end function to create dislogbox

// start function to get thumbnail of first song of playlist

  Widget getPlaylistThumbnail(String playlistName) {
    List<String> l = prefs.getStringList(playlistName) ?? [];
    if (l.length == 0) {
      return Container(
        height: 150.0,
        width: 150.0,
        decoration: BoxDecoration(color: Colors.grey),
        child: Icon(Icons.music_note, color: Colors.white, size: 100.0),
      );
    }
    var myInt = int.parse(l[0]);
    assert(myInt is int);

    if (widget.songs[myInt].albumArtwork != null) {
      return Image.file(
        File(widget.songs[myInt].albumArtwork),
        fit: BoxFit.fill,
        errorBuilder: (
          BuildContext context,
          Object error,
          StackTrace stackTrace,
        ) {
          return Container(
            height: 100.0,
            width: 100.0,
            decoration: BoxDecoration(color: Colors.grey),
            child: Icon(Icons.music_note, color: Colors.white, size: 100.0),
          );
        },
      );
    } else {
      return Container(
        height: 150.0,
        width: 150.0,
        decoration: BoxDecoration(color: Colors.grey),
        child: Icon(Icons.music_note, color: Colors.white, size: 100.0),
      );
    }
  }

// end function to get thumbnail of first song of playlist

// start function to get the number of songs in the playlist

  String getNumberOfSongsInPlaylist(String plName) {
    List<String> l = prefs.getStringList(plName) ?? [];
    return l.length.toString();
  }

// end function to get the number of songs in the playlist

  // start function to show playlists

  Widget showPlaylists() {
    print(playLists.length);
    if (playLists.length != 0) {
      return Container(
          margin: EdgeInsets.only(top: 15.0),
          child: GridView.builder(
              itemCount: playLists.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                // crossAxisSpacing: 4.0,
                // mainAxisExtent: 4.0
              ),
              itemBuilder: (BuildContext context, index) {
                return Column(
                  children: [
                    GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => PlaylistSongs(
                                      plname: playLists[index],
                                      songs1: widget.songs,
                                      changeTrack: widget.changeTrack,
                                      createRecentSongsList:
                                          widget.createRecentSongsList)));
                        },
                        onLongPress: () {
                          playLists.removeWhere(
                              (element) => element == playLists[index]);
                          prefs.setStringList("playlists", playLists);

                          setState(() {});
                        },
                        child: Container(
                          decoration: BoxDecoration(boxShadow: [
                            BoxShadow(
                                color: Colors.black,
                                blurRadius: 2.0,
                                spreadRadius: 0.0,
                                offset: Offset(2.0, 2.0))
                          ]),
                          alignment: Alignment.center,
                          margin: EdgeInsets.only(top: 3.0),
                          height: 140.0,
                          width: 143.0,
                          child: getPlaylistThumbnail(playLists[index]),
                        )),
                    Text(
                      playLists[index],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: 5.0,
                    ),
                    Text(
                        "${getNumberOfSongsInPlaylist(playLists[index])} Songs")
                  ],
                );
              }));
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "No Playlist Found !",
            style: TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.bold,
              fontSize: 25.0,
            ),
          )
        ],
      );
    }
  }

  // end function to show playlists

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
        title: Text('Playlists', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Container(
        child: Center(child: showPlaylists()),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          getDialogBox();
        },
        backgroundColor: Colors.orangeAccent,
      ),
    );
  }
}

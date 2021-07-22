import 'dart:io';

import 'package:audio_player_1/music_player.dart';
import 'package:audio_player_1/playlist.dart';
import 'package:audio_player_1/tracks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: must_be_immutable
class PlaylistSongs extends StatefulWidget {
  String plname;
  List<SongInfo> songs1;
  final GlobalKey<MusicPlayerState> key;
  Function changeTrack,createRecentSongsList;

  PlaylistSongs({this.plname,this.songs1,this.key,this.changeTrack,this.createRecentSongsList});
  @override
  _PlaylistSongsState createState() => _PlaylistSongsState();
}

class _PlaylistSongsState extends State<PlaylistSongs> {
  final GlobalKey<MusicPlayerState> key = GlobalKey<MusicPlayerState>();


  SharedPreferences prefs;
  Future<List<String>> plistsongs;
  List<String> playListSongs;
  int currentIndex=0,playlistSongIndex=0;

  List<SongInfo> songs;



  @override
  void initState(){
    super.initState();
    songs=widget.songs1;
     plistsongs=SharedPreferences.getInstance().then((value){
          prefs=value;
          return prefs.getStringList(widget.plname) ?? [];
    });
    getPlaylistSongs();
  }

  getPlaylistSongs() async {
    playListSongs=await plistsongs;
    playListSongs.removeWhere((element){
      var myInt=int.parse(element);
      assert(myInt is int);
      return myInt>songs.length;
    });
    setState(() {
      
    });
    print("-------");
    print(playListSongs);
    print("-------");

  }


  void selectedItem(context,item,index)
  {
    switch(item)
    {
      case 0:
            playListSongs.remove(index.toString());
            prefs.setStringList(widget.plname, playListSongs);
            print("removed");
    }
    setState(() {
      
    });
  }


  
  void nextPlaylistSong(bool isNext)
  {
    List<String> l=prefs.getStringList(widget.plname) ?? [];
   if(isNext)
   {
      if(playlistSongIndex==l.length-1)
      {
        playlistSongIndex=0;
      }else{
        playlistSongIndex++;
      }
   }
   else{
    if(playlistSongIndex==0)
      playlistSongIndex=l.length-1;
    else
      playlistSongIndex--;
    
   }

    var myInt = int.parse(l[playlistSongIndex]);
    assert(myInt is int);
    setState(() {
      
    });
    key.currentState.setSong(songs[myInt]);
  }


  Widget getSongTiles(index,ind)
  {
      return ListTile(
      leading: songs[index].albumArtwork != null
          ? Image.file(
              File(songs[index].albumArtwork),
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
      title: Text(songs[index].title),
      subtitle: Text(songs[index].artist),
      trailing: PopupMenuButton<int>(
        // color: Colors.grey,
        itemBuilder: (context)=>[
          PopupMenuItem<int>(value: 0,child: Text("Remove From Playlist")),
        ],
        onSelected: (item)=> selectedItem(context,item,index),
      ),
      onTap: () {
        currentIndex = index;
        widget.createRecentSongsList(currentIndex,songs[currentIndex]);
        playlistSongIndex=ind;

        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => MusicPlayer(
                plName:widget.plname,
                nextPlaylistSong:nextPlaylistSong,
                changeTrack: widget.changeTrack,
                songInfo: songs[currentIndex],
                key: key)));
      },
    );
  }


  Widget showPlaylistSongs()
  {
    if(playListSongs.length==0){
      return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: Text("Please Add Songs !",style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 25.0,
                    ),),
                )
              ],
      );
    }
    else{
      return ListView.separated(
        separatorBuilder: (context,index)=>Divider(), 
        shrinkWrap: true,
        physics: AlwaysScrollableScrollPhysics(),
        itemCount: playListSongs.length,
        itemBuilder: (context,index){
           var myInt=int.parse(playListSongs[index]);
            assert(myInt is int);
          return getSongTiles(myInt,index);
        }
        );
    }
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
        title: Text(widget.plname, style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body:showPlaylistSongs(),
      
    
    );
  }
}
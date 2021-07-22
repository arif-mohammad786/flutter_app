import 'dart:convert';
import 'dart:io';

import 'package:audio_player_1/favourites.dart';
import 'package:audio_player_1/playlist.dart';
import 'package:audio_player_1/recent.dart';
import 'package:audio_player_1/music_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:marquee/marquee.dart';
import 'music_player.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

class Tracks extends StatefulWidget {
  _TracksState createState() => _TracksState();
}

class _TracksState extends State<Tracks> {
  final FlutterAudioQuery audioQuery = FlutterAudioQuery();
  List<SongInfo> songs = [];
  int currentIndex = 0,i,k;
  final GlobalKey<MusicPlayerState> key = GlobalKey<MusicPlayerState>();
  // Icons 
  
  static const IconData clock = IconData(0xe800, fontFamily: 'MyFlutterApp');
  static const IconData heart_empty = IconData(0xe801, fontFamily: 'MyFlutterApp');
  static const IconData note_beamed = IconData(0xe802, fontFamily: 'MyFlutterApp');

  bool isRecentPressed=false,isFavouritesPressed=false,isPlaylistsPressed=false;

  SharedPreferences prefs;

  int recentFlag=0,favFlag=0,playlistLength;
  var songExists=true;
  Future<List<String>> plist;
  List<String> playLists=[];
  // for date time 

  DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");


  void initState() {
    super.initState();
    getTracks();
    plist=SharedPreferences.getInstance().then((value){
      prefs=value;
      return prefs.getStringList("playlists") ?? [];
    });
    getPlaylists();

  }


  getPlaylists() async {
    playLists=await plist;
    playlistLength=playLists.length;
    setState(() {
      
    });

  }


  void getTracks() async {
    songs = await audioQuery.getSongs();
    setState(() {
      songs = songs;
      songs.removeWhere((element) => !File(element.filePath).existsSync());
    });
  }

  // create recent song list start 

  void createRecentSongsList(int index,SongInfo song) async
  {
    // print("----------------------------------- create recent songs called 1");

    var temp;
    
    for(int j=0;j<=9;j++){
      var temp1=prefs.getString(j.toString());
      if(temp1 != null)
        {
          temp=json.decode(temp1);
          if(temp["title"] == song.title && temp["subtitle"] == song.artist){
          prefs.remove(j.toString());
          setState(() {
            recentFlag=1;
          });
          break;
        }
        }
    }

    if(recentFlag == 0){

      Map sng={"time":dateFormat.format(DateTime.now()),"index":index,"albumArtwork":song.albumArtwork,"title":song.title,"subtitle":song.artist};

      i=prefs.getInt("index") ?? 0;
    // print("----------------------------------- create recent songs called 2 ${i}");

      if(i>=10)
        i=0;
      i=i+1;
      prefs.setInt("index",i);
      prefs.setString(i.toString(), json.encode(sng));
    }
    else if(recentFlag == 1){
    // print("----------------------------------- create recent songs called 3");

       Map sng={"time":dateFormat.format(DateTime.now()),"index":temp["index"],"albumArtwork":temp["albumArtwork"],"title":temp["title"],"subtitle":temp["subtitle"]};

      i=prefs.getInt("index") ?? 0;
      if(i==10)
        i=0;
      else
        i=i+1;
      prefs.setInt("index",i);
      prefs.setString(i.toString(), json.encode(sng));
      setState(() {
        recentFlag=0;
      });
    }
    // Map sng={"index":index,"albumArtwork":song.albumArtwork,"title":song.title,"subtitle":song.artist};

    // i=prefs.getInt("index") ?? 0;
    // if(i==10)
    //   i=0;
    // i=i+1;
    // prefs.setInt("index",i);
    // prefs.setString(i.toString(), json.encode(sng));
  }

  // end create recent songs list 


  // start create favoirite songs list 

  void createFavouriteSongsList(int index,SongInfo song) async
  {

    var temp;
    
    for(int l=11;l<=20;l++){
      var temp1=prefs.getString(l.toString());
      if(temp1 != null)
        {
          temp=json.decode(temp1);
          if(temp["title"] == song.title && temp["subtitle"] == song.artist){
          prefs.remove(l.toString());
          setState(() {
            favFlag=1;
          });
          break;
        }
        }
    }

    if(favFlag == 0){
    // print("----------------------------------- create favourite songs called 2 ${k}");


      Map sng={"uri":song.uri,"time":dateFormat.format(DateTime.now()),"index":index,"albumArtwork":song.albumArtwork,"title":song.title,"subtitle":song.artist};

      k=prefs.getInt("favIndex") ?? 11;
      if(k>=20)
        k=11;
      else
        k=k+1;
      prefs.setInt("favIndex",k);
      prefs.setString(k.toString(), json.encode(sng));
    }
    else if(favFlag == 1){
       Map sng={"uri":song.uri,"time":dateFormat.format(DateTime.now()),"index":temp["index"],"albumArtwork":temp["albumArtwork"],"title":temp["title"],"subtitle":temp["subtitle"]};

      k=prefs.getInt("favIndex") ?? 11;
      if(k>=20)
        k=11;
      k=k+1;
      prefs.setInt("favIndex",k);
      prefs.setString(k.toString(), json.encode(sng));
      setState(() {
        favFlag=0;
      });
    }
  }

  // end create favoirite songs list 

  void changeTrack(bool isNext) {
    if (isNext) {
      // if (currentIndex != songs.length - 1) {
      //   currentIndex++;
      // }

      if (currentIndex == songs.length - 1) {
        currentIndex = 0;
      } else {
        currentIndex++;
      }
      createRecentSongsList(currentIndex,songs[currentIndex]);

    } else {
      // if (currentIndex != 0) {
      //   currentIndex--;
      // }
      if (currentIndex == 0) {
        currentIndex = songs.length - 1;
      } else {
        currentIndex--;
      }
    }
    setState(() {});

    key.currentState.setSong(songs[currentIndex]);
    
  }


// start function to maintain song indices in SharedPreferences 
  maintainSongIndicesInSharedPreferences(index)
  {
    var temp;
    
    for(int j=0;j<=21;j++){
      var temp1=prefs.getString(j.toString());
      if(temp1 != null)
        {
          temp=json.decode(temp1);
          if(temp["index"]>index)
          {
            temp["index"]=temp["index"]-1;
            prefs.setString(j.toString(), json.encode(temp));
          }
          if(temp["index"]==index)
          {
            prefs.remove(j.toString());
          }
        }
    }

    List<String> l=prefs.getStringList("playlists");
    for(int p=0;p<l.length;p++)
    {
      // var myInt=int.parse(l[p]);
      // assert(myInt is int);
      // if(myInt > index){
      //   l[p]=(myInt-1).toString();
      // }
      String playlistName=l[p];
      List<String> l1=prefs.getStringList(playlistName);
      String st=index.toString();
      if(l1.contains(st))
      {
        l1.remove(st);
        prefs.setStringList(l[p], l1);
      }

    }

  }

// end function to maintain song indices in SharedPreferences 



  // start function to delete songs 
  Future<void> deleteFile(File file,index) async {
    try 
    {
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        await Permission.storage.request();
      }

      maintainSongIndicesInSharedPreferences(index);
      
      return await file.delete();
    } 
    catch (e) {
        print("===========================");
          print(e);
        print("===========================");

      }
  
    }
  // end function to delete songs 
 


// Function for popup menu 
  void selectedItem(BuildContext context,item,songPath,index,song){
      switch(item)
        {
        case 0:print("add to favoirite");
              createFavouriteSongsList(index, song);
        break;
        case 1:print("deleted");
              deleteFile(File(songPath),index);
              getTracks();
        break;
      }
    }
  
  
  // start function to check if the songs exists at theit path or not 

  void checkFunc(index){
    if(File(songs[index].filePath).existsSync()){
      songExists=true;
    }
    else{
      songExists=false;
    }
  }

  // end function to check if the songs exists at theit path or not 



  // start function for selected playlist 
  void selectedPlaylistItem(BuildContext context,item,index,song)
  {
    switch(item){
      default:
              List<String> l=prefs.getStringList(playLists[item]) ?? [];
              if(!l.contains(index.toString()))
                l.add(index.toString());
              prefs.setStringList(playLists[item], l);
              print("################");
              print(prefs.getStringList(playLists[item]));
              print("################");

    }

  }

  // end function for selected playlist 


// start function to get all playlists name and add in submenu 

List<PopupMenuEntry<int>> availablePlaylists(){
  List<PopupMenuEntry<int>> l=[];
  for(int it=0;it<playlistLength;it++){
    l.add(PopupMenuItem<int>(value: it,child: Text(playLists[it])));
    l.add(PopupMenuDivider());
  }
  return l;
}

// end function to get all playlists name and add in submenu 



  Widget bodyContent(index){
    
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
          PopupMenuItem<int>(value: 0,child: Text("Add To Favourite")),
          PopupMenuDivider(),
          PopupMenuItem<int>(child: PopupMenuButton<int>(
                child: Text("Add To Playlist"),
                itemBuilder: (context)=>availablePlaylists(),
                onSelected: (item)=> selectedPlaylistItem(context,item,index,songs[index]),
              )
          
          ),
          PopupMenuDivider(),
          PopupMenuItem<int>(value: 1,child: Text("Delete")),
        ],
        onSelected: (item)=> selectedItem(context,item,songs[index].filePath,index,songs[index]),
      ),
      onTap: () {
        currentIndex = index;
        createRecentSongsList(index,songs[currentIndex]);

        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => MusicPlayer(
                changeTrack: changeTrack,
                songInfo: songs[currentIndex],
                key: key)));
      },
    );
  }

  Widget build(context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [Color(0xffEC7063), Colors.orangeAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight)),
        ),
        leading: Icon(Icons.music_note, color: Colors.white70),
        title: Text('Music App', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Material(
              elevation: 5.0,
              child: Container(  
              height: 70.0,
              child:Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                      onTapDown: (_){
                        setState(() {
                          isRecentPressed=true;
                        });
                      },

                      onTapUp: (_){
                        setState(() {
                          isRecentPressed=false;
                        });
                      },
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(
                          builder:(context)=>RecentSongs(
                            createRecentSongsList:createRecentSongsList,
                            changeTrack: changeTrack,
                            songs:songs,
                            key: key
                          )
                        ));
                      },
                      child: Container(
                        height: 70.0,
                        width: 80.0,
                        decoration: BoxDecoration(
                          color: Colors.white,
                        ),
                        child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(clock,color: isRecentPressed ? Colors.orangeAccent :  Colors.grey,),
                          SizedBox(height: 5.0,),
                          Text("Recent",style: TextStyle(color: isRecentPressed ? Colors.orangeAccent :  Colors.grey),)
                        ],
                    ),
                      ),
                  ),
                  GestureDetector(
                    onTapDown: (_){
                        setState(() {
                          isFavouritesPressed=true;
                        });
                      },
                      onTapUp: (_){
                        setState(() {
                          isFavouritesPressed=false;
                        });
                      },
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(
                          builder:(context)=>FavouriteSongs(
                            createRecentSongsList:createRecentSongsList,
                            changeTrack: changeTrack,
                            songs:songs,
                            key: key
                          )
                        ));
                      },
                      child: Container(
                         height: 70.0,
                        width: 80.0,
                        decoration: BoxDecoration(
                          color: Colors.white
                        ),
                        child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(heart_empty,color: isFavouritesPressed ? Colors.orangeAccent :  Colors.grey,),
                          SizedBox(height: 5.0,),
                          Text("Favourites",style: TextStyle(color: isFavouritesPressed ? Colors.orangeAccent :  Colors.grey),)
                        ],
                    ),
                      ),
                  ),
                  GestureDetector(
                    onTapDown: (_){
                        setState(() {
                          isPlaylistsPressed=true;
                        });
                      },
                      onTapUp: (_){
                        setState(() {
                          isPlaylistsPressed=false;
                        });
                      },
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(
                          builder:(context)=>Playlist(
                            songs:songs,
                            createRecentSongsList:createRecentSongsList,
                            changeTrack: changeTrack,
                            key:key
                            )
                        ));
                      },
                      child: Container(
                         height: 70.0,
                        width: 80.0,
                        decoration: BoxDecoration(
                          color: Colors.white,
                        ),
                        child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(note_beamed,color: isPlaylistsPressed ? Colors.orangeAccent :  Colors.grey,),
                          SizedBox(height: 5.0,),
                          Text("Playlists",style: TextStyle(color: isPlaylistsPressed ? Colors.orangeAccent :  Colors.grey),)
                        ],
                    ),
                      ),
                  ),
                ],
              )
            ),
          ),
          Expanded(
            child: ListView.separated(
                separatorBuilder: (context, index) => Divider(),
                shrinkWrap: true,
                physics: AlwaysScrollableScrollPhysics(),
                itemCount: songs.length,
                itemBuilder: (context, index) => bodyContent(index)
                // {
                //   checkFunc(index);
                //   if(songExists)
                //     return bodyContent(index);
                //   else
                //     return SizedBox.shrink();
                // }
                ),
          ),
        ],
      ),
    );
  }
}

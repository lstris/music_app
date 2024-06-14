import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:music_app/ui/discovery/discovery.dart';
import 'package:music_app/ui/home/viewmodel.dart';
import 'package:music_app/ui/now_playing/audio_player_manager.dart';
import 'package:music_app/ui/setting/Settings.dart';
import 'package:music_app/ui/user/user.dart';

import '../../data/model/song.dart';
import '../now_playing/playing.dart';




class MusicApp extends StatelessWidget {
  const MusicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "MusicApp",
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      home: const MusicHomePage(),
      debugShowCheckedModeBanner: false,//loại bỏ chữ debug
    );
  }
}

class MusicHomePage extends StatefulWidget {
  const MusicHomePage({super.key});

  @override
  State<MusicHomePage> createState() => _MusicHomePageState();
}

class _MusicHomePageState extends State<MusicHomePage> {
  final List<Widget> _tabs = [
    const HomeTab(),
    const DiscoveryTab(),
    const SettingsTab(),
    const AccountTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text("Music App"),
      ),
      child: CupertinoTabScaffold(
        tabBar: CupertinoTabBar(
          backgroundColor: Theme.of(context).colorScheme.onInverseSurface,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(
                icon: Icon(Icons.album), label: "Discovery"),
            BottomNavigationBarItem(
                icon: Icon(Icons.settings), label: "Settings"),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "User"),
          ],
        ),
        tabBuilder: (BuildContext context, int index) {
          return _tabs[index];
        },
      ),
    );
  }
}

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomeTabPage(); //Scaffold(
    //   body: Center(
    //     child: Text("Home Tab"),
    //   ),
    //
    // );
  }
}

class HomeTabPage extends StatefulWidget {
  const HomeTabPage({super.key});

  @override
  State<HomeTabPage> createState() => _HomeTabPageState();
}

class _HomeTabPageState extends State<HomeTabPage> {
  List<Song> songs = [];
  late MusicAppViewModel _viewModel = MusicAppViewModel();

  Widget get getProgressBar {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  ListView getListView() {
    return ListView.separated(
      itemBuilder: (context, position) {
        return getRow(position);
      },
      separatorBuilder: (context, position) {
        return const Divider(
          color: Colors.grey,
          thickness: 1,
          indent: 24,
        );
      },
      itemCount: songs.length,
      shrinkWrap: true,
    );
  }

  @override
  void initState() {
    super.initState();
    _viewModel = MusicAppViewModel();
    _viewModel.loadSong();
    observeData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: getBody(),
    );
  }

  @override
  void dispose() {
    _viewModel.songStream.close();
    AudioPlayerManager().dispose();
    super.dispose();
  }

  void observeData() {
    _viewModel.songStream.stream.listen((songList) {
      setState(() {
        songs.addAll(songList);
      });
    });
  }

  Widget getBody() {
    bool showLoading = songs.isEmpty;
    if (showLoading) {
      return getProgressBar;
    } else {
      return getListView();
    }
  }

  Widget getRow(int index) {
    // return Center(
    //   child: Text(song[index].title) ,
    // );//Text(song[index].title);
    return _SongItemSection(
      parent: this,
      song: songs[index],
    );
  }

  void showBottomSheet() {
    showModalBottomSheet(context: context, builder: (context){
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          child: Container(
            height: 400,
            color: Colors.grey,
            child: Center
            (child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children:<Widget> [
                const Text('Model Bottom Sheet'),
              ElevatedButton(
                onPressed: ()=>Navigator.pop(context),
                child: const Text('Close Bottom Sheet'),
              )
              ],
            ),)
          ),

        );
    });
  }

  void navigate(Song song) {
    Navigator.push(context,
        CupertinoPageRoute(builder: (context){
          return NowPlaying(
            songs: songs,
            playingSong: song,
          );
        })
    );
  }


}

class _SongItemSection extends StatelessWidget {
  final _HomeTabPageState parent;
  final Song song;

  const _SongItemSection({
    required this.parent,
    required this.song});


  // void navigate(Song song) {
  //   Navigator.push(parent.context,
  //       CupertinoPageRoute(builder: (context){
  //         return NowPlaying(
  //           playingSong: song,
  //           songs: parent.song,
  //         );
  //       })
  //   );
  // }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ListTile(
      contentPadding: const EdgeInsets.only(
        left: 24,
        right: 8,
      ),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: FadeInImage.assetNetwork(
          placeholder: "assets/img.png",
          image: song.image,
          imageErrorBuilder: (context, error, stackTrace) {
            return Image.asset(
              "assets/img.png",
              width: 48,
              height: 48,
            );
          },
        ),
      ),

      //   leading: FadeInImage.assetNetwork(
      //       placeholder: "assets/img.png",
      //       image: song.image,
      //       imageErrorBuilder: (context, error, stackTrace){
      //         return Image.asset(
      //         "assets/img.png",
      //         width: 48,
      //         height: 48,);
      // },
      //
      //   ),
      title: Text(song.title),
      subtitle: Text(song.artists),
      trailing: IconButton(
        icon: const Icon(Icons.more_horiz),
        onPressed: () {
          parent.showBottomSheet();
        },
      ),
      onTap: () {
        parent.navigate(song);
      },
    );
  }
}

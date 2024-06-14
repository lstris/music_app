import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:math';

import '../../data/model/song.dart';
import 'audio_player_manager.dart';

class NowPlaying extends StatelessWidget {
  const NowPlaying({super.key, required this.playingSong, required this.songs});

  final Song playingSong;
  final List<Song> songs;

  @override
  Widget build(BuildContext context) {
    return NowPlayingPage(
      songs: songs,
      playingSong: playingSong,
    );
  }
}

class NowPlayingPage extends StatefulWidget {
  const NowPlayingPage(
      {super.key, required this.songs, required this.playingSong});

  final Song playingSong;
  final List<Song> songs;

  @override
  State<NowPlayingPage> createState() => _NowPlayingPageState();
}

class _NowPlayingPageState extends State<NowPlayingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _imageAnimationController;
  late AudioPlayerManager _audioPlayerManager;
  late int _selectedItemIndex;
  late Song _song;

  // late double _currentAnimationPosition;
  double _currentAnimationPosition = 0.0;
  bool _isShuffle = false;
  late LoopMode _loopMode;

  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    // _currentAnimationPosition = 0.0;
    _song = widget.playingSong;
    _loopMode = LoopMode.off;
    _imageAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 12000),
    );
    _audioPlayerManager = AudioPlayerManager(  );
    // _audioPlayerManager.updateSongUrl(_song.source);
    // _audioPlayerManager.prepare();
    if(_audioPlayerManager.songUrl.compareTo(_song.source) != 0){
      _audioPlayerManager.updateSongUrl(_song.source);
      _audioPlayerManager.prepare(isNewSong: true);
    } else{
      _audioPlayerManager.prepare(isNewSong: false);

    }
    _selectedItemIndex = widget.songs.indexOf(widget.playingSong);
  }

  @override
  Widget build(BuildContext context) {
    //   return Scaffold(
    //     body: Center(
    //       child: Text('Now Playing'),
    //     ),
    //   );
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    const delta = 64;
    final radius = (screenWidth - delta) / 2;

    return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: const Text('Now Playing'),
          trailing: IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_horiz),
          ),
        ),
        child: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(_song.album),
                const SizedBox(
                  height: 16,
                ),
                const Text('- --- -'),
                const SizedBox(
                  height: 48,
                ),
                RotationTransition(
                  turns: Tween(begin: 0.0, end: 1.0).animate(
                    _imageAnimationController,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(radius),
                    child: FadeInImage.assetNetwork(
                        placeholder: ('assets/img.png'),
                        image: _song.image,
                        width: screenWidth - delta,
                        height: screenWidth - delta,
                        imageErrorBuilder: (context, error, stackTrace) {
                          return Image.asset('assets/img.png',
                              width: screenWidth - delta,
                              height: screenWidth - delta);
                        }),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 64, bottom: 16),
                  child: SizedBox(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.share_outlined),
                          color: Theme
                              .of(context)
                              .colorScheme
                              .primary,
                        ),
                        Column(
                          children: [
                            Text(
                              _song.title,
                              style: Theme
                                  .of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(
                                  color: Theme
                                      .of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .color),
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            Text(
                              _song.artists,
                              style: Theme
                                  .of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(
                                  color: Theme
                                      .of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .color),
                            )
                          ],
                        ),
                        IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.favorite_outline))
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    top: 32,
                    bottom: 16,
                    left: 24,
                    right: 24,
                  ),
                  child: _progressBar(),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    top: 0,
                    bottom: 16,
                    left: 24,
                    right: 24,
                  ),
                  child: _mediaButtons(),
                )
              ],
            ),
          ),
        ));
  }

  @override
  void dispose() {
    // _audioPlayerManager.dispose();
    _imageAnimationController.dispose();
    super.dispose();
  }

  Widget _mediaButtons() {
    return SizedBox(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          MediaButtonControl(
              function: _setShuffle,
              icon: Icons.shuffle,
              color: _getShuffleColor(),
              size: 24),
          MediaButtonControl(
              function: _setNextSong,
              icon: Icons.skip_previous,
              color: Colors.purple,
              size: 36),
          // MediaButtonControl(
          //     function: _setPrevSong,
          //     icon: Icons.play_arrow_sharp,
          //     color: Colors.deepPurple,
          //     size: 48),
          _playButton(),
          MediaButtonControl(
              function: _setPrevSong,
              icon: Icons.skip_next,
              color: Colors.deepPurple,
              size: 36),

          MediaButtonControl(
              function: _setRepeatOption,
              icon: _repeatingIcon(),
              color: _getRepeatingIconColor(),
              size: 24),
        ],
      ),
    );
  }

  StreamBuilder<DurationState> _progressBar() {
    return StreamBuilder<DurationState>(
        stream: _audioPlayerManager.durationState,
        builder: (context, snapshot) {
          final durationState = snapshot.data;
          final progress = durationState?.progress ?? Duration.zero;
          final buffered = durationState?.buffered ?? Duration.zero;
          final total = durationState?.total ?? Duration.zero;
          return ProgressBar(
            progress: progress,
            total: total,
            buffered: buffered,
            onSeek: _audioPlayerManager.player.seek,
            barHeight: 5.0,
            barCapShape: BarCapShape.round,
            baseBarColor: Colors.green.withOpacity(0.3),
            progressBarColor: Colors.lightBlue,
            //------------------
            bufferedBarColor: Colors.grey.withOpacity(0.3),
            thumbColor: Colors.deepPurple,
            thumbGlowColor: Colors.grey.withOpacity(0.3),
            thumbRadius: 10.0,
          );
        });
  }

  StreamBuilder<PlayerState> _playButton() {
    return StreamBuilder(
      stream: _audioPlayerManager.player.playerStateStream,
      builder: (context, snapshot) {
        final playState = snapshot.data;
        final processingState = playState?.processingState;
        final playing = playState?.playing;
        if (processingState == ProcessingState.loading ||
            processingState == ProcessingState.buffering) {
          _pauseRotationAnim();
          return Container(
            margin: const EdgeInsets.all(8),
            width: 48,
            height: 48,
            child: const CircularProgressIndicator(),
          );
        } else if (playing != true) {
          return MediaButtonControl(
              function: () {
                _audioPlayerManager.player.play();
                // _imageAnimationController.forward(from: _currentAnimationPosition);
                // _imageAnimationController.repeat();
              },
              icon: Icons.play_arrow,
              color: Colors.black12,
              size: 48);
        } else if (processingState != ProcessingState.completed) {
          _playRotationAnim();
          return MediaButtonControl(
            function: () {
              _audioPlayerManager.player.pause();
              // _imageAnimationController.stop();
              // _currentAnimationPosition = _imageAnimationController.value;
              _pauseRotationAnim();
            },
            icon: Icons.pause,
            color: Colors.black12,
            size: 48,
          );
        } else {
          if (processingState == ProcessingState.completed) {
            // _imageAnimationController.stop();
            // _currentAnimationPosition = 0.0;
            _stopRotationAnim();
            _resetRotationAnim();
          }
          return MediaButtonControl(
            function: () {
              // _currentAnimationPosition = 0.0;
              // _imageAnimationController.forward(from: _currentAnimationPosition);
              // _imageAnimationController.repeat();
              _audioPlayerManager.player.seek(Duration.zero);
              _resetRotationAnim();
              _playRotationAnim();
            },
            icon: Icons.replay,
            color: Colors.black12,
            size: 48,
          );
        }
      },
    );
  }

  void _setShuffle() {
    setState(() {
      _isShuffle = !_isShuffle;
    });
  }

  Color _getShuffleColor() {
    return _isShuffle ? Colors.deepPurple : Colors.grey;
  }

  void _setNextSong() {
    // ++_selectedItemIndex;
    if (_isShuffle) {
      _selectedItemIndex = _random.nextInt(widget.songs.length);
    } else if (_selectedItemIndex < widget.songs.length - 1) {
      ++_selectedItemIndex;
    } else if (_loopMode == LoopMode.all && _selectedItemIndex == widget.songs.length - 1) {
      _selectedItemIndex = 0;
    }
    if (_selectedItemIndex >= widget.songs.length) {
      _selectedItemIndex = _selectedItemIndex % widget.songs.length;
    }
    final nextSong = widget.songs[_selectedItemIndex];
    _audioPlayerManager.updateSongUrl(nextSong.source);

    _resetRotationAnim();
    setState(() {
      _song = nextSong;
    });
  }

  void _setPrevSong() {
    // --_selectedItemIndex;
    if (_isShuffle) {
      _selectedItemIndex = _random.nextInt(widget.songs.length);
    }
    else if(_selectedItemIndex > 0){
      --_selectedItemIndex;
    }else if(_loopMode == LoopMode.all && _selectedItemIndex == 0){
    _selectedItemIndex = widget.songs.length-1;
    }
    if(_selectedItemIndex<0){
    _selectedItemIndex = _selectedItemIndex%widget.songs.length;
    }

    final nextSong = widget.songs[_selectedItemIndex];
    _audioPlayerManager.updateSongUrl(nextSong.source);
    _resetRotationAnim();
    setState(() {
    _song = nextSong;
    });
  }

  IconData _repeatingIcon() {
    return switch(_loopMode){
      LoopMode.one => Icons.repeat_one,
      LoopMode.all => Icons.repeat_on,
      _ => Icons.repeat,
    };
  }

  void _setRepeatOption() {
    if (_loopMode == LoopMode.off) {
      _loopMode = LoopMode.one;
    } else if (_loopMode == LoopMode.one) {
      _loopMode = LoopMode.all;
    } else {
      _loopMode = LoopMode.off;
    }
    setState(() {
      _audioPlayerManager.player.setLoopMode(_loopMode);
    });
  }

  Color _getRepeatingIconColor() {
    return _loopMode == LoopMode.off
        ? Colors.grey
        : Colors.deepPurple;
  }

  void _playRotationAnim() {
    _imageAnimationController.forward(from: _currentAnimationPosition);
    _imageAnimationController.repeat();
  }

  void _pauseRotationAnim() {
    _stopRotationAnim();
    _currentAnimationPosition = _imageAnimationController.value;
  }

  void _stopRotationAnim() {
    _imageAnimationController.stop();
  }

  void _resetRotationAnim() {
    _currentAnimationPosition = 0.0;
    _imageAnimationController.value = _currentAnimationPosition;
  }
}


class MediaButtonControl extends StatefulWidget {
  const MediaButtonControl({
    super.key,
    required this.function,
    required this.icon,
    required this.color,
    required this.size,
  });

  final void Function()? function;
  final IconData icon;
  final double? size;
  final Color color;

  @override
  State<MediaButtonControl> createState() => _MediaButtonControlState();
}

class _MediaButtonControlState extends State<MediaButtonControl> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: widget.function,
      icon: Icon(widget.icon),
      // color: widget.color ?? Theme
      //     .of(context)
      //     .colorScheme
      //     .primary,
    );
  }
}

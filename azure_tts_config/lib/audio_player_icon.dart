import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class AudioPlayerIconWidget extends StatefulWidget {
   AudioPlayerIconWidget({super.key,
     required this.path,
     this.size = 30,
     this.playImmediately = false,
   });
   String path;
   double size;
   bool playImmediately;

  @override
  State<AudioPlayerIconWidget> createState() => _AudioPlayerIconWidgetState();
}

class _AudioPlayerIconWidgetState extends State<AudioPlayerIconWidget> {

  late AudioPlayer player ;


  @override
  void initState() {
    super.initState();
    player = AudioPlayer();
    /*player.onPlayerComplete.listen((event) {
      if(mounted){
        setState(() {

        });
      }
    });*/

    player.onPlayerStateChanged.listen((event) {
      if(mounted){
        setState(() {
        });
      }
    });
    if(widget.playImmediately){
       player.play(DeviceFileSource(widget.path));
    }
  }

  @override
  void dispose() {
    super.dispose();
    player.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: IconButton(onPressed: (){
        onPressed();
      },
          color: player.state == PlayerState.playing ? Colors.red:Colors.blue,
          icon: Icon(buildByPlayState())),
    );
  }

 IconData buildByPlayState() {
    debugPrint("PlayState1-->${player.state}");
    if(player.state == PlayerState.playing){
      return Icons.stop;
    }else if(player.state == PlayerState.paused){
      return Icons.pause;
    }else if(player.state == PlayerState.stopped){
      return Icons.play_arrow;
    }else{
      return Icons.play_arrow;
    }
  }

  Future<void> onPressed() async {
    debugPrint("PlayState0-->${player.state}");
    if(player.state == PlayerState.playing){
      await player.pause();
    }else if(player.state == PlayerState.paused){
      await player.resume();
    }else if(player.state == PlayerState.stopped){
     await player.play(DeviceFileSource(widget.path));
    }else{
      await player.play(DeviceFileSource(widget.path));
    }
    if(mounted){
      setState(() {

      });
    }

  }
}

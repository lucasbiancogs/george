import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:george/assets.dart';

class VolumeController extends StatefulWidget {
  @override
  State<VolumeController> createState() => _VolumeControllerState();
}

class _VolumeControllerState extends State<VolumeController> {
  @override
  void initState() {
    super.initState();
    //FlameAudio.bgm.stop();
  }

  bool isPlaying = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0x8F37474f),
      child: IconButton(
        onPressed: () {
          if (isPlaying) {
            FlameAudio.bgm.stop();
            setState(() {
              isPlaying = false;
            });
          } else {
            FlameAudio.bgm.play(Audios.ukulele);
            setState(() {
              isPlaying = true;
            });
          }
        },
        icon: Icon(
          isPlaying ? Icons.volume_up_rounded : Icons.volume_off_rounded,
          color: Colors.pink.shade200,
        ),
      ),
    );
  }
}

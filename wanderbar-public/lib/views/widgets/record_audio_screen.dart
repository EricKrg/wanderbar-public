// A screen that allows users to take a picture using a given camera.
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart' as sound;
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:hungry/views/utils/AppColor.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:audio_session/audio_session.dart';

class AudioSliderWidget extends StatefulWidget {
  final File audioFile;

  AudioSliderWidget({Key key, @required this.audioFile}) : super(key: key);

  @override
  State<StatefulWidget> createState() => AudioSliderWidgetState();
}

class AudioSliderWidgetState extends State<AudioSliderWidget> {
  final audioPlayer = AudioPlayer();
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();

    audioPlayer.onPlayerStateChanged.listen((event) {
      isPlaying = event == PlayerState.PLAYING;
    });

    audioPlayer.onDurationChanged.listen((event) {
      duration = event;
    });

    audioPlayer.onAudioPositionChanged.listen((event) {
      print(duration);
      print("event $event");
      if (duration == event) {
        setState(() {
          isPlaying = false;
        });
      }
      setState(() {
        position = event;
      });
    });
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    audioPlayer.dispose();
    print("dispose audio player!");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Expanded(
          flex: 0,
          child: GestureDetector(
            // style: ElevatedButton.styleFrom(
            //   primary: AppColor.primarySoft,
            // ),
            child: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
            onTap: () async {
              if (isPlaying) {
                await audioPlayer.pause();
                setState(() {
                  isPlaying = false;
                });
              } else {
                print(widget.audioFile.path);
                await audioPlayer.play(widget.audioFile.path, isLocal: true);
                setState(() {
                  isPlaying = true;
                });
              }
            },
          )),
      Expanded(
          child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Slider(
              thumbColor: AppColor.primary,
              activeColor: AppColor.primarySoft,
              inactiveColor: AppColor.primaryExtraSoft,
              min: 0,
              max: duration.inSeconds.toDouble(),
              value: position.inSeconds.toDouble(),
              onChanged: (value) async {
                final position = Duration(seconds: value.toInt());
                await audioPlayer.seek(position);
                await audioPlayer.resume();
              }),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(formatTime(position)),
                Text(formatTime(duration)),
              ],
            ),
          ),
        ],
      ))
    ]);
  }

  String formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    return [if (duration.inHours > 0) hours, minutes, seconds].join(":");
  }
}

class RecordAudioScreen extends StatefulWidget {
  final FlutterSoundRecorder recorder;

  RecordAudioScreen(
      {Key key, @required this.recorder, this.onFinishedRecording})
      : super(key: key);

  Function(String) onFinishedRecording;

  @override
  RecordAudioScreenState createState() => RecordAudioScreenState();
}

class RecordAudioScreenState extends State<RecordAudioScreen> {
  bool isReady = false;
  File audioFile;

  String audioString;

  sound.Codec _codec = sound.Codec.aacMP4;

  @override
  void initState() {
    super.initState();
    initRecorder();
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.transparent,
        child: Center(
            child: Column(
          children: [
            GestureDetector(
                onTap: () async {
                  if (widget.recorder.isRecording) {
                    await stop();
                  } else {
                    await record();
                  }
                  setState(() {});
                },
                child: Icon(
                  widget.recorder.isRecording ? Icons.stop : Icons.mic,
                )),
            StreamBuilder<RecordingDisposition>(
                stream: widget.recorder.onProgress,
                builder: (context, snapshot) {
                  final duration =
                      snapshot.hasData ? snapshot.data.duration : Duration.zero;
                  if (duration.inSeconds == 60) {
                    stop();
                  }
                  return Text("${duration.inSeconds} s of 60");
                }),
          ],
        )));
  }

  Future stop() async {
    if (!isReady) return;
    final path = await widget.recorder.stopRecorder();
    widget.onFinishedRecording(path);
    audioFile = File(path);
  }

  Future record() async {
    audioFile = null;
    if (!isReady) return;
    await widget.recorder.startRecorder(toFile: "audio");
  }

  Future initRecorder() async {
    print("init recorder");
    final status = await Permission.microphone.request();

    if (status != PermissionStatus.granted) {
      throw "Access not granted!";
    }

    await openTheRecorder();
    isReady = true;
    widget.recorder.setSubscriptionDuration(const Duration(milliseconds: 500));
  }

  Future<void> openTheRecorder() async {
    var status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw RecordingPermissionException('Microphone permission not granted');
    }

    await widget.recorder.openRecorder();
    if (!await widget.recorder.isEncoderSupported(_codec)) {
      _codec = sound.Codec.opusWebM;
      if (!await widget.recorder.isEncoderSupported(_codec)) {
        return;
      }
    }

    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
      avAudioSessionCategoryOptions:
          AVAudioSessionCategoryOptions.allowBluetooth |
              AVAudioSessionCategoryOptions.defaultToSpeaker,
      avAudioSessionMode: AVAudioSessionMode.spokenAudio,
      avAudioSessionRouteSharingPolicy:
          AVAudioSessionRouteSharingPolicy.defaultPolicy,
      avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
      androidAudioAttributes: const AndroidAudioAttributes(
        contentType: AndroidAudioContentType.speech,
        flags: AndroidAudioFlags.none,
        usage: AndroidAudioUsage.voiceCommunication,
      ),
      androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
      androidWillPauseWhenDucked: true,
    ));
  }

  Future<String> createTempFileFromUint8List(Uint8List decodedAudio) async {
    final tempDir = await getTemporaryDirectory();
    File file = await File('${tempDir.path}/tmp.mp3').create();
    file.writeAsBytesSync(decodedAudio);
    //return file.path
    return file.path;
  }
}

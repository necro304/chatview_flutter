
import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:chatview/src/extensions/extensions.dart';
import 'package:chatview/src/models/models.dart';
import 'package:video_player/video_player.dart';

import '../models/video_message.dart';
import 'share_icon.dart';
import 'reaction_widget.dart';

class VideoMessageView extends StatelessWidget {
  const VideoMessageView({
    Key? key,
    required this.message,
    required this.isMessageBySender,
    this.videoMessageConfig,
    this.messageReactionConfig,
    this.highlightMessage = false,
    this.highlightColor,
  }) : super(key: key);

  final Message message;
  final bool isMessageBySender;
  final VideoMessageConfiguration? videoMessageConfig;
  final MessageReactionConfiguration? messageReactionConfig;
  final bool highlightMessage;
  final Color? highlightColor;


  String get videoUrl => message.message;

  Widget get iconButton => ShareIcon(
        shareIconConfig: videoMessageConfig?.shareIconConfig,
        imageUrl: videoUrl,
      );

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment:
          isMessageBySender ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        if (isMessageBySender) iconButton,
        Stack(
          children: [
            Container(
              padding: videoMessageConfig?.padding ?? EdgeInsets.zero,
              margin: videoMessageConfig?.margin ??
                  EdgeInsets.only(
                    top: 6,
                    right: isMessageBySender ? 6 : 0,
                    left: isMessageBySender ? 0 : 6,
                    bottom: message.reaction.reactions.isNotEmpty ? 15 : 0,
                  ),
              height: videoMessageConfig?.height ?? 200,
              width: videoMessageConfig?.width ?? 200,
              child: ClipRRect(
                borderRadius: videoMessageConfig?.borderRadius ??
                    BorderRadius.circular(14),
                child: videoUrl.fromMemoryVideo
                    ? Image.memory(
                        base64Decode(videoUrl
                            .substring(videoUrl.indexOf('base64') + 7)),
                        fit: BoxFit.fill,
                      )
                    : VideoPlayerCustom(
                        videoUrl: videoUrl,
                        id: message.id,
                      ),
              ),
            ),
            if (message.reaction.reactions.isNotEmpty)
              ReactionWidget(
                key: key,
                isMessageBySender: isMessageBySender,
                reaction: message.reaction,
                messageReactionConfig: messageReactionConfig,
              ),
          ],
        ),
        if (!isMessageBySender) iconButton,
      ],
    );
  }
}


class VideoPlayerCustom extends StatefulWidget {
  const VideoPlayerCustom({Key? key, required this.videoUrl, required this.id}) : super(key: key);

  final String videoUrl;
  final String id;

  @override
  State<VideoPlayerCustom> createState() => _VideoPlayerCustomState();
}

class _VideoPlayerCustomState extends State<VideoPlayerCustom> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(
        widget.videoUrl)
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
      });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return  _controller.value.isInitialized
        ? Stack(
          fit: StackFit.expand,
          children: [
            Hero(
              tag: 'video_${widget.id}',
              child: AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
               child: VideoPlayer(_controller),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: IconButton(
                onPressed: () {
                  setState(() {
                    _controller.value.isPlaying
                        ? _controller.pause()
                        : _controller.play();
                  });
                },
                icon: Icon(
                  _controller.value.isPlaying
                      ? Icons.pause
                      : Icons.play_arrow,
                  color: Colors.white,
                  size: 50,
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: VideoProgressIndicator(
                _controller,
                colors: VideoProgressColors(
                  playedColor: Colors.white,
                  bufferedColor: Colors.white.withOpacity(0.5),
                  backgroundColor: Colors.white.withOpacity(0.2),
                ),
                allowScrubbing: true,
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 0),
              ),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                onPressed: () {
                  setState(() {
                    _controller.value.volume == 0
                        ? _controller.setVolume(1)
                        : _controller.setVolume(0);
                  });
                },
                icon: Icon(
                  _controller.value.volume == 0
                      ? Icons.volume_off
                      : Icons.volume_up,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                onPressed: () {
                  // full screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => VideoPlayerFullScreen(videoUrl: widget.videoUrl, id: widget.id,), fullscreenDialog: true),
                  );

                },
                icon: const Icon(
                  Icons.fullscreen,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
          ],
        )
        : Container();
  }
}


class VideoPlayerFullScreen extends StatefulWidget {
  const VideoPlayerFullScreen({Key? key, required this.videoUrl, required this.id}) : super(key: key);
  final String videoUrl;
  final String id;

  @override
  State<VideoPlayerFullScreen> createState() => _VideoPlayerFullScreenState();
}

class _VideoPlayerFullScreenState extends State<VideoPlayerFullScreen> {


  bool reload = false;
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(
        widget.videoUrl)
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
      });

    _controller.addListener(listener);
  }

  void listener() {
    if(_controller.value.position == _controller.value.duration){
      setState(() {
        reload = true;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    _controller.removeListener(listener);
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
      ),
      body:  Stack(
        children: [
          Center(
            child: Hero(
              tag: 'video_${widget.id}',
              child: _controller.value.isInitialized
                  ? AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
              )
                  : Container(),
            ),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              height: 80,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                 _videoPlayerControls(),

                  VideoProgressIndicator(
                    _controller,
                    colors: VideoProgressColors(
                      playedColor: Colors.white,
                      bufferedColor: Colors.white.withOpacity(0.5),
                      backgroundColor: Colors.white.withOpacity(0.2),
                    ),
                    allowScrubbing: true,
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }



  _videoPlayerControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          onPressed: () {
            setState(() {


              _controller.value.isPlaying
                  ? _controller.pause()
                  : _controller.play();

              if( !_controller.value.isPlaying ){
                setState(() {
                  reload = false;
                });
              }
            });
          },
          icon: Icon(
            _controller.value.isPlaying
                ?  Icons.pause
                : reload ? Icons.replay : Icons.play_arrow,
            color: Colors.white,
            size: 30,
          ),
        ),
        IconButton(
          onPressed: () {
            setState(() {
              _controller.value.volume == 0
                  ? _controller.setVolume(1)
                  : _controller.setVolume(0);
            });
          },
          icon: Icon(
            _controller.value.volume == 0
                ? Icons.volume_off
                : Icons.volume_up,
            color: Colors.white,
            size: 30,
          ),
        ),
        IconButton(
          onPressed: () {
            // full screen
            Navigator.pop(context);

          },
          icon: const Icon(
            Icons.fullscreen_exit,
            color: Colors.white,
            size: 30,
          ),
        ),
      ],
    );
  }
}



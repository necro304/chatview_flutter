import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:chatview/src/models/models.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'reaction_widget.dart';

class FileMessageView extends StatelessWidget {
  const FileMessageView({
    Key? key,
    required this.message,
    required this.isMessageBySender,
    this.imageMessageConfig,
    this.messageReactionConfig,
  }) : super(key: key);

  final Message message;
  final bool isMessageBySender;
  final ImageMessageConfiguration? imageMessageConfig;
  final MessageReactionConfiguration? messageReactionConfig;

  String get fileUrl => message.message;


  IconData _buildIcon(){
    switch(message.fileType){
      case "pdf":
        return  FontAwesomeIcons.filePdf;
      case "doc":
      case "docx":
        return  FontAwesomeIcons.fileWord;
      case "xls":
      case "xlsx":
        return  FontAwesomeIcons.fileExcel;
      case "ppt":
      case "pptx":
        return  FontAwesomeIcons.filePowerpoint;
      case "zip":
      case "rar":
        return  FontAwesomeIcons.fileZipper;
      case "txt":
        return  FontAwesomeIcons.fileLines;
      case "mp3":
      case "acc":
      case "wav":
      case "ogg":
      case "wma":
      case "flac":
        return  FontAwesomeIcons.fileAudio;
      case "mp4":
      case "avi":
      case "flv":
      case "wmv":
      case "mov":
      case "mkv":
      case "3gp":
      case "webm":
      case "mpeg":
      case "mpg":
      case "m4v":
      case "vob":
      case "ogv":
      case "ogg":
      case "rm":
      case "rmvb":
      case "m3u8":
        return  FontAwesomeIcons.fileVideo;
      case "jpg":
      case "jpeg":
      case "png":
      case "gif":
      case "bmp":
      case "webp":
      case "svg":
        return  FontAwesomeIcons.fileImage;
      default:
        return  FontAwesomeIcons.file;
    }
  }



  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment:
          isMessageBySender ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Stack(
          children: [
            GestureDetector(
              onTap: () => imageMessageConfig?.onTap != null
                  ? imageMessageConfig?.onTap!(fileUrl)
                  : null,
              child: Container(
                padding: imageMessageConfig?.padding ?? EdgeInsets.zero,
                margin: imageMessageConfig?.margin ??
                    EdgeInsets.only(
                      top: 6,
                      right: isMessageBySender ? 6 : 0,
                      left: isMessageBySender ? 0 : 6,
                      bottom: message.reaction.isNotEmpty ? 15 : 0,
                    ),
                child: ClipRRect(
                  borderRadius: imageMessageConfig?.borderRadius ??
                      BorderRadius.circular(14),
                  child:  Column(
                    children: [
                      SizedBox(
                        height: imageMessageConfig?.height ?? 200,
                        width: imageMessageConfig?.width ?? 150,
                        child: Card(
                          elevation: 2,
                          child: Center(
                            child: Icon(
                              _buildIcon(),
                              size: 50,
                            ),
                            )
                          ),
                      ),
                      SizedBox(
                        width: imageMessageConfig?.width ?? 150,
                        child: Text(
                          message.message,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  ),
                ),
              ),
            if (message.reaction.isNotEmpty)
              ReactionWidget(
                isMessageBySender: isMessageBySender,
                reaction: message.reaction.toString(),
                messageReactionConfig: messageReactionConfig,
              ),
          ],
        ),
      ],
    );
  }
}

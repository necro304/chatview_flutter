/*
 * Copyright (c) 2022 Simform Solutions
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */
import 'dart:io';

import 'package:chatview/src/controller/chat_controller.dart';
import 'package:chatview/src/values/enumaration.dart';
import 'package:flutter/material.dart';

import 'package:chatview/src/extensions/extensions.dart';
import 'package:chatview/src/models/models.dart';
import 'package:chatview/src/utils/package_strings.dart';
import 'package:video_compress/video_compress.dart';

import '../utils/constants.dart';
import 'vertical_line.dart';

class ReplyMessageWidget extends StatelessWidget {
  const ReplyMessageWidget({
    Key? key,
    required this.message,
    required this.currentUser,
    required this.chatController,
    this.repliedMessageConfig,
  }) : super(key: key);

  final Message message;
  final RepliedMessageConfiguration? repliedMessageConfig;
  final ChatUser currentUser;
  final ChatController chatController;

  bool get _replyBySender => message.replyMessage.replyBy == currentUser.id;

  ChatUser get messagedUser =>
      chatController.getUserFromId(message.replyMessage.replyBy);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final replyMessage = message.replyMessage.message;
    final replyMessageType = message.replyMessage.messageType;
    final replyBy = _replyBySender ? PackageStrings.you : messagedUser.name;
    return Container(
      margin: repliedMessageConfig?.margin ??
          const EdgeInsets.only(
            right: horizontalPadding,
            left: horizontalPadding,
            bottom: 4,
          ),
      constraints:
          BoxConstraints(maxWidth: repliedMessageConfig?.maxWidth ?? 280),
      child: Column(
        crossAxisAlignment:
            _replyBySender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            "${PackageStrings.repliedBy} $replyBy",
            style: repliedMessageConfig?.replyTitleTextStyle ??
                textTheme.bodyText2!.copyWith(fontSize: 14, letterSpacing: 0.3),
          ),
          const SizedBox(height: 6),
          IntrinsicHeight(
            child: Row(
              mainAxisAlignment: _replyBySender
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.start,
              children: [
                if (!_replyBySender)
                  VerticalLine(
                    verticalBarWidth: repliedMessageConfig?.verticalBarWidth,
                    verticalBarColor: repliedMessageConfig?.verticalBarColor,
                    rightPadding: 4,
                  ),
                Flexible(
                  child: Opacity(
                    opacity: repliedMessageConfig?.opacity ?? 0.8,
                    child: _replyBuild(replyMessage, textTheme, replyMessageType),
                  ),
                ),
                if (_replyBySender)
                  VerticalLine(
                    verticalBarWidth: repliedMessageConfig?.verticalBarWidth,
                    verticalBarColor: repliedMessageConfig?.verticalBarColor,
                    leftPadding: 4,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  BorderRadiusGeometry _borderRadius(String replyMessage) => _replyBySender
      ? repliedMessageConfig?.borderRadius ??
          (replyMessage.length < 37
              ? BorderRadius.circular(replyBorderRadius1)
              : BorderRadius.circular(replyBorderRadius2))
      : repliedMessageConfig?.borderRadius ??
          (replyMessage.length < 29
              ? BorderRadius.circular(replyBorderRadius1)
              : BorderRadius.circular(replyBorderRadius2));

  _replyBuild(String replyMessage, TextTheme textTheme, MessageType replyMessageType)  {
      if(replyMessage.isImageUrl){
        return Container(
          height: repliedMessageConfig
              ?.repliedImageMessageHeight ??
              100,
          width: repliedMessageConfig
              ?.repliedImageMessageWidth ??
              80,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(replyMessage),
              fit: BoxFit.fill,
            ),
            borderRadius:
            repliedMessageConfig?.borderRadius ??
                BorderRadius.circular(14),
          ),
        );
      } else if(replyMessageType == MessageType.file){
        return Card(
          child: Container(
            height: repliedMessageConfig
                ?.repliedImageMessageHeight ??
                60,
            width: repliedMessageConfig
                ?.repliedImageMessageWidth ??
                60,
            decoration: BoxDecoration(
              borderRadius:
              repliedMessageConfig?.borderRadius ??
                  BorderRadius.circular(14),
            ),
            child: const Center(
              child: Icon(
                Icons.attach_file,
                color: Colors.black87,
                size: 30,
              ),
            ),
          ),
        );
      } else if(replyMessage.isVideoUrl){
        return FutureBuilder<File>(
          future: VideoCompress.getFileThumbnail(replyMessage),
          builder: (context, snapshot) {
            if(snapshot.hasData){
              return Container(
                height: repliedMessageConfig
                    ?.repliedImageMessageHeight ??
                    100,
                width: repliedMessageConfig
                    ?.repliedImageMessageWidth ??
                    80,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: FileImage(snapshot.data!),
                    fit: BoxFit.fill,
                  ),
                  borderRadius:
                  repliedMessageConfig?.borderRadius ??
                      BorderRadius.circular(14),
                ),
              );
            }else if(snapshot.hasError){
              return const SizedBox();

            }
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        );
      } else {
        return Container(
          constraints: BoxConstraints(
              maxWidth:
              repliedMessageConfig?.maxWidth ?? 280),
          padding: repliedMessageConfig?.padding ??
              const EdgeInsets.symmetric(
                  vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: _borderRadius(replyMessage),
            color: repliedMessageConfig?.backgroundColor ??
                Colors.grey.shade500,
          ),
          child: Text(
            replyMessage,
            style: repliedMessageConfig?.textStyle ??
                textTheme.bodyText2!
                    .copyWith(color: Colors.black),
          ),
        );
      }

  }
}

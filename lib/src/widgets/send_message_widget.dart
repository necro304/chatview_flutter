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
import 'dart:async';
import 'dart:io' if (kIsWeb) 'dart:html';
import 'dart:ui';
import 'package:chat_composer/chat_composer.dart';
import 'package:chatview/src/widgets/chatui_textfield.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:chatview/chatview.dart';
import 'package:chatview/src/extensions/extensions.dart';
import 'package:chatview/src/utils/package_strings.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:image_picker/image_picker.dart';

import '../utils/constants.dart';

class SendMessageWidget extends StatefulWidget {
  const SendMessageWidget({
    Key? key,
    required this.onSendTap,
    required this.currentUser,
    required this.chatController,
    this.sendMessageConfig,
    this.backgroundColor,
    this.sendMessageBuilder,
    this.onReplyCallback,
    this.onReplyCloseCallback,
    required this.whatsappStyle,
  }) : super(key: key);
  final StringMessageCallBack onSendTap;
  final SendMessageConfiguration? sendMessageConfig;
  final Color? backgroundColor;
  final ReplyMessageWithReturnWidget? sendMessageBuilder;
  final ReplyMessageCallBack? onReplyCallback;
  final VoidCallBack? onReplyCloseCallback;
  final ChatUser currentUser;
  final ChatController chatController;
  final bool whatsappStyle;

  @override
  State<SendMessageWidget> createState() => SendMessageWidgetState();
}

class SendMessageWidgetState extends State<SendMessageWidget> {
  final _textEditingController = TextEditingController();
  ReplyMessage _replyMessage = ReplyMessage();
  final _focusNode = FocusNode();
  late StreamSubscription<bool> keyboardSubscription;

  bool emojiShowing = false;

  // 1. Create GlobalKey for EmojiPickerState
  final key = GlobalKey<EmojiPickerState>();


  ChatUser get repliedUser =>
      widget.chatController.getUserFromId(_replyMessage.replyTo);

  String get _replyTo => _replyMessage.replyTo == widget.currentUser.id
      ? PackageStrings.you
      : repliedUser.name;

  @override
  Widget build(BuildContext context) {
    return widget.sendMessageBuilder != null
        ? Positioned(
            right: 0,
            left: 0,
            bottom: 0,
            child: widget.sendMessageBuilder!(_replyMessage),
          )
        : widget.whatsappStyle ? _whastappSendMessageWidget(): _defaultSendMessageWidget();
  }

  void _onPressed() {
    if (_textEditingController.text.isNotEmpty &&
        !_textEditingController.text.startsWith('\n')) {
      widget.onSendTap(_textEditingController.text, _replyMessage);
      if (_replyMessage.message.isNotEmpty) {
        setState(() => _replyMessage = ReplyMessage());
      }
      _textEditingController.clear();
      setState(() {
        emojiShowing = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    var keyboardVisibilityController = KeyboardVisibilityController();
    keyboardSubscription = keyboardVisibilityController.onChange.listen((bool visible) {
      print('Keyboard visibility update. Is visible: $visible');
      if (visible) {
        setState(() {
          emojiShowing = false;
        });
      }
    });

  }

  void assignReplyMessage(Message message) {
    setState(() {
      _replyMessage = ReplyMessage(
        message: message.message,
        replyBy: widget.currentUser.id,
        replyTo: message.sendBy,
        messageType: message.messageType,
      );
    });
    FocusScope.of(context).requestFocus(_focusNode);
    if (widget.onReplyCallback != null) widget.onReplyCallback!(_replyMessage);
  }

  void _onCloseTap() {
    setState(() => _replyMessage = ReplyMessage());
    if (widget.onReplyCloseCallback != null) widget.onReplyCloseCallback!();
  }

  double get _bottomPadding => (!kIsWeb && Platform.isIOS)
      ? (_focusNode.hasFocus
          ? bottomPadding1
          : window.viewPadding.bottom > 0
              ? bottomPadding2
              : bottomPadding3)
      : bottomPadding3;

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  _defaultSendMessageWidget() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Stack(
          children: [
            Positioned(
              right: 0,
              left: 0,
              bottom: 0,
              child: Container(
                height: MediaQuery.of(context).size.height /
                    ((!kIsWeb && Platform.isIOS) ? 24 : 28),
                color: widget.backgroundColor ?? Colors.white,
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                bottomPadding4,
                bottomPadding4,
                bottomPadding4,
                _bottomPadding,
              ),
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  if (_replyMessage.message.isNotEmpty)
                    Container(
                      decoration: BoxDecoration(
                        color: widget.sendMessageConfig
                            ?.textFieldBackgroundColor ??
                            Colors.white,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(14)),
                      ),
                      margin: const EdgeInsets.only(
                        bottom: 17,
                        right: 0.4,
                        left: 0.4,
                      ),
                      padding: const EdgeInsets.fromLTRB(
                        leftPadding,
                        leftPadding,
                        leftPadding,
                        30,
                      ),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 2),
                        padding: const EdgeInsets.symmetric(
                          vertical: 4,
                          horizontal: 6,
                        ),
                        decoration: BoxDecoration(
                          color: widget
                              .sendMessageConfig?.replyDialogColor ??
                              Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "${PackageStrings.replyTo} $_replyTo",
                                  style: TextStyle(
                                    color: widget.sendMessageConfig
                                        ?.replyTitleColor ??
                                        Colors.deepPurple,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.25,
                                  ),
                                ),
                                IconButton(
                                  constraints: const BoxConstraints(),
                                  padding: EdgeInsets.zero,
                                  icon: Icon(
                                    Icons.close,
                                    color: widget.sendMessageConfig
                                        ?.closeIconColor ??
                                        Colors.black,
                                    size: 16,
                                  ),
                                  onPressed: _onCloseTap,
                                ),
                              ],
                            ),
                            _replyMessage.messageType.isImage
                                ? Row(
                              children: [
                                Icon(
                                  Icons.photo,
                                  size: 20,
                                  color: widget.sendMessageConfig
                                      ?.replyMessageColor ??
                                      Colors.grey.shade700,
                                ),
                                Text(
                                  PackageStrings.photo,
                                  style: TextStyle(
                                    color: widget.sendMessageConfig
                                        ?.replyMessageColor ??
                                        Colors.black,
                                  ),
                                ),
                              ],
                            )
                                : Text(
                              _replyMessage.message,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                color: widget.sendMessageConfig
                                    ?.replyMessageColor ??
                                    Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ChatUITextField(
                    focusNode: _focusNode,
                    textEditingController: _textEditingController,
                    onPressed: _onPressed,
                    sendMessageConfig: widget.sendMessageConfig,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _whastappSendMessageWidget() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Stack(
          children: [
            Positioned(
              right: 0,
              left: 0,
              bottom: 0,
              child: Container(
                height: MediaQuery.of(context).size.height /
                    ((!kIsWeb && Platform.isIOS) ? 24 : 28),
                color: widget.backgroundColor ?? Colors.white,
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                bottomPadding4,
                bottomPadding4,
                bottomPadding4,
                _bottomPadding,
              ),
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  if (_replyMessage.message.isNotEmpty)
                    Container(
                      decoration: BoxDecoration(
                        color: widget.sendMessageConfig
                            ?.textFieldBackgroundColor ??
                            Colors.white,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(14)),
                      ),
                      margin: const EdgeInsets.only(
                        bottom: 30,
                        right: 0.4,
                        left: 0.4,
                      ),
                      padding: const EdgeInsets.fromLTRB(
                        leftPadding,
                        leftPadding,
                        leftPadding,
                        30,
                      ),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 2),
                        padding: const EdgeInsets.symmetric(
                          vertical: 4,
                          horizontal: 6,
                        ),
                        decoration: BoxDecoration(
                          color: widget
                              .sendMessageConfig?.replyDialogColor ??
                              Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "${PackageStrings.replyTo} $_replyTo",
                                  style: TextStyle(
                                    color: widget.sendMessageConfig
                                        ?.replyTitleColor ??
                                        Colors.deepPurple,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.25,
                                  ),
                                ),
                                IconButton(
                                  constraints: const BoxConstraints(),
                                  padding: EdgeInsets.zero,
                                  icon: Icon(
                                    Icons.close,
                                    color: widget.sendMessageConfig
                                        ?.closeIconColor ??
                                        Colors.black,
                                    size: 16,
                                  ),
                                  onPressed: _onCloseTap,
                                ),
                              ],
                            ),
                            _replyMessage.messageType.isImage
                                ? Row(
                              children: [
                                Icon(
                                  Icons.photo,
                                  size: 20,
                                  color: widget.sendMessageConfig
                                      ?.replyMessageColor ??
                                      Colors.grey.shade700,
                                ),
                                Text(
                                  PackageStrings.photo,
                                  style: TextStyle(
                                    color: widget.sendMessageConfig
                                        ?.replyMessageColor ??
                                        Colors.black,
                                  ),
                                ),
                              ],
                            )
                                : Text(
                              _replyMessage.message,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                color: widget.sendMessageConfig
                                    ?.replyMessageColor ??
                                    Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  SizedBox(
                    height: 310,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SizedBox(
                          height: 60,
                          child: CustomChatUITextField(
                            focusNode: _focusNode,
                            textEditingController: _textEditingController,
                            onPressed: _onPressed,
                            sendMessageConfig: widget.sendMessageConfig,
                            onPressedEmoji: (){
                              setState(() {
                                emojiShowing = !emojiShowing;
                              });
                            },
                          ),
                        ),
                        Offstage(
                          offstage: !emojiShowing,
                          child: SizedBox(
                            height: 250,
                            child: EmojiPicker(
                              // 2. Set global key here
                              key: key,
                              textEditingController: _textEditingController,
                            ),
                          ),
                        ),

                      ],
                    ),
                  ),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

}


class CustomChatUITextField extends StatefulWidget {
  const CustomChatUITextField({
    Key? key,
    this.sendMessageConfig,
    required this.focusNode,
    required this.textEditingController,
    required this.onPressed,
    required this.onPressedEmoji,
  }) : super(key: key);
  final SendMessageConfiguration? sendMessageConfig;
  final FocusNode focusNode;
  final TextEditingController textEditingController;
  final VoidCallBack onPressed;
  final VoidCallBack onPressedEmoji;

  @override
  State<CustomChatUITextField> createState() => _CustomChatUITextFieldState();
}

class _CustomChatUITextFieldState extends State<CustomChatUITextField> {

  ImagePickerIconsConfiguration? get imagePickerIconsConfig =>
      widget.sendMessageConfig?.imagePickerIconsConfig;

  final ImagePicker _imagePicker = ImagePicker();

  void _onIconImagePressed(ImageSource imageSource) async {
    final onImageSelected = imagePickerIconsConfig?.onImageSelected;
    try {
      if (onImageSelected != null) {
        final XFile? image = await _imagePicker.pickImage(source: imageSource, imageQuality: 50);
        onImageSelected(image?.path ?? '', TypeMessage.IMAGE);
      }
    } catch (e) {
      if (onImageSelected != null) {
        onImageSelected(
          '',
          e.toString(),
        );
      }
    }
  }

  void _onIconFilePressed() async {
    final onImageSelected = imagePickerIconsConfig?.onImageSelected;
    try {
      if (onImageSelected != null) {
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: [
          'rar', 'pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx', 'txt', 'zip', 'svg', 'webp', 'bmp', 'ico', 'psd', 'tif', 'tiff', 'ai', 'eps', 'ps', 'indd', 'ttf', 'otf', 'fnt', 'fon', 'woff', 'woff2', 'eot', 'txt', 'rtf', 'odt', 'pages', 'wpd', 'ods', 'ppt', 'pptx', 'odp', 'pps', 'ppsx', 'pdf', 'csv'
          ]);

        if(result != null) {
          onImageSelected(result.files.single.path ?? '', TypeMessage.FILE);
        }
      }
    } catch (e) {
      if (onImageSelected != null) {
        onImageSelected(
          '',
          e.toString(),
        );
      }
    }
  }

  void _onIconVideoPressed(ImageSource imageSource) async {
    final onImageSelected = imagePickerIconsConfig?.onImageSelected;
    try {
      if (onImageSelected != null) {
        final XFile? video = await _imagePicker.pickVideo(source: imageSource, maxDuration: const Duration(minutes: 5));
        onImageSelected(video?.path ?? '', TypeMessage.VIDEO);
      }
    } catch (e) {
      if (onImageSelected != null) {
        onImageSelected(
          '',
          e.toString(),
        );
      }
    }
  }

  void _sendAudio(String path) {
    final onImageSelected = imagePickerIconsConfig?.onImageSelected;
    if (onImageSelected != null) {
      onImageSelected(
        path,
        TypeMessage.AUDIO,
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      margin:widget.sendMessageConfig?.textFieldConfig?.margin,
      height: 60,
      child: ChatComposer(
        borderRadius: widget.sendMessageConfig?.textFieldConfig?.borderRadius,
        padding: widget.sendMessageConfig?.textFieldConfig?.padding ?? const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
        focusNode: widget.focusNode,
        controller: widget.textEditingController,
        onRecordStart: () {
          print("onRecordStart");
        },
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: widget.onPressedEmoji,
          child: const Icon(
            Icons.insert_emoticon_outlined,
            size: 25,
            color: Colors.grey,
          ),
        ),
        actions: [
          CupertinoButton(
            padding: EdgeInsets.zero,
            child: const Icon(
              Icons.attach_file_rounded,
              size: 25,
              color: Colors.grey,
            ),
            onPressed: () {
              //open menu to select image or video

              showDialog(context: context, builder: (context) {
                return AlertDialog(
                  content:  Wrap(
                    runSpacing: 10,
                    spacing: 10,
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      CardItemMedia(
                        icon: Icons.camera_alt_outlined,
                        title: "Camara",
                        onTap: () {
                          Navigator.pop(context);
                          _onIconImagePressed(ImageSource.camera);
                        },
                      ),

                      CardItemMedia(
                        icon: Icons.image_outlined,
                        title: "Galeria",
                        onTap: () {
                          Navigator.pop(context);
                          _onIconImagePressed(ImageSource.gallery);
                        },
                      ),

                      CardItemMedia(
                        icon: Icons.video_call_outlined,
                        title: "Video",
                        onTap: () {
                          Navigator.pop(context);
                          _onIconVideoPressed(ImageSource.camera);
                        },
                      ),
                      CardItemMedia(
                        icon: Icons.video_camera_front_rounded,
                        title: "Video galeria",
                        onTap: () {
                          Navigator.pop(context);
                          _onIconVideoPressed(ImageSource.gallery);
                        },
                      ),

                      CardItemMedia(
                        icon: Icons.file_open_outlined,
                        title: "Archivo",
                        onTap: () {
                          Navigator.pop(context);
                          _onIconFilePressed();
                        },
                      ),


                    ],
                  ),
                );
              });


            },
          ),
          CupertinoButton(
            padding: EdgeInsets.zero,
            child: const Icon(
              Icons.camera_alt_rounded,
              size: 25,
              color: Colors.grey,
            ),
            onPressed:  () => _onIconImagePressed(ImageSource.camera),
          ),
        ],

        onReceiveText: (String? v) {
          widget.onPressed();
        },
        onRecordEnd: (String? v) {
          print(v);
          if(v != null){
            print("onRecordEnd");
            _sendAudio(v);
          }

        },
      ),
    );
  }
}


class CardItemMedia extends StatelessWidget {
  const CardItemMedia({Key? key, required this.icon, required this.title, this.onTap}) : super(key: key);
  final IconData icon;
  final String title;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children:  [
              Icon(icon),
              Text(title),
            ],
          )
      ),
    );
  }
}



class TypeMessage {
  static const String IMAGE = "IMAGE";
  static const String VIDEO = "VIDEO";
  static const String FILE = "FILE";
  static const String AUDIO = "AUDIO";

}

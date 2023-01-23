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
import 'package:chatview/src/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:chatview/src/extensions/extensions.dart';

import '../../chatview.dart';
import 'message_time_widget.dart';
import 'message_view.dart';
import 'profile_circle.dart';
import 'reply_message_widget.dart';
import 'swipe_to_reply.dart';

class ChatBubbleWidget extends StatefulWidget {
  const ChatBubbleWidget({
    required GlobalKey key,
    required this.message,
    required this.onLongPress,
    required this.showReceiverProfileCircle,
    required this.slideAnimation,
    required this.onSwipe,
    required this.currentUser,
    this.profileCircleConfig,
    this.chatBubbleConfig,
    this.repliedMessageConfig,
    this.swipeToReplyConfig,
    this.messageTimeTextStyle,
    this.messageTimeIconColor,
    this.messageConfig,
    this.onReplyTap,
    this.shouldHighlight = false,
  }) : super(key: key);

  final Message message;
  final DoubleCallBack onLongPress;
  final ProfileCircleConfiguration? profileCircleConfig;
  final bool showReceiverProfileCircle;
  final ChatBubbleConfiguration? chatBubbleConfig;
  final RepliedMessageConfiguration? repliedMessageConfig;
  final SwipeToReplyConfiguration? swipeToReplyConfig;
  final TextStyle? messageTimeTextStyle;
  final Color? messageTimeIconColor;
  final Animation<Offset>? slideAnimation;
  final MessageConfiguration? messageConfig;
  final MessageCallBack onSwipe;
  final ChatUser currentUser;
  final Function(String)? onReplyTap;
  final bool shouldHighlight;

  @override
  State<ChatBubbleWidget> createState() => _ChatBubbleWidgetState();
}

class _ChatBubbleWidgetState extends State<ChatBubbleWidget> {
  String get replyMessage => widget.message.replyMessage.message;

  bool get isMessageBySender => widget.message.sendBy == widget.currentUser.id;

  FeatureActiveConfig? featureActiveConfig;
  ChatController? chatController;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (provide != null) {
      featureActiveConfig = provide!.featureActiveConfig;
      chatController = provide!.chatController;
    }
  }

  @override
  Widget build(BuildContext context) {
    final messagedUser = chatController?.getUserFromId(widget.message.sendBy);
    return Stack(
      children: [
        if (featureActiveConfig?.enableSwipeToSeeTime ?? true) ...[
          Visibility(
            visible: widget.slideAnimation?.value.dx == 0.0 ? false : true,
            child: Positioned.fill(
              child: Align(
                alignment: Alignment.centerRight,
                child: MessageTimeWidget(
                  messageTime: widget.message.createdAt,
                  isCurrentUser: isMessageBySender,
                  messageTimeIconColor: widget.messageTimeIconColor,
                  messageTimeTextStyle: widget.messageTimeTextStyle,
                ),
              ),
            ),
          ),
          SlideTransition(
            position: widget.slideAnimation!,
            child: _chatBubbleWidget(messagedUser),
          ),
        ] else
          _chatBubbleWidget(messagedUser),
      ],
    );
  }

  Widget _chatBubbleWidget(ChatUser? messagedUser) {
    return Container(
      padding:
      widget.chatBubbleConfig?.padding ?? const EdgeInsets.only(left: 5.0),
      margin:
      widget.chatBubbleConfig?.margin ?? const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment:
        isMessageBySender ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMessageBySender &&
              (featureActiveConfig?.enableOtherUserProfileAvatar ?? true))
            ProfileCircle(
              bottomPadding: widget.message.reaction.reactions.isNotEmpty
                  ? widget.profileCircleConfig?.bottomPadding ?? 15
                  : widget.profileCircleConfig?.bottomPadding ?? 2,
              profileCirclePadding: widget.profileCircleConfig?.padding,
              imageUrl: messagedUser?.profilePhoto,
              circleRadius: widget.profileCircleConfig?.circleRadius,
            ),
          Expanded(
            child: isMessageBySender
                ? SwipeToReply(
              onLeftSwipe: featureActiveConfig?.enableSwipeToReply ?? true
                  ? () {
                if (widget.swipeToReplyConfig?.onLeftSwipe !=
                    null) {
                  widget.swipeToReplyConfig?.onLeftSwipe!(
                      widget.message.message,
                      widget.message.sendBy);
                }
                widget.onSwipe(widget.message);
              }
                  : null,
              replyIconColor: widget.swipeToReplyConfig?.replyIconColor,
              swipeToReplyAnimationDuration:
              widget.swipeToReplyConfig?.animationDuration,
              child: _messagesWidgetColumn(messagedUser),
            )
                : SwipeToReply(
              onRightSwipe:
              featureActiveConfig?.enableSwipeToReply ?? true
                  ? () {
                if (widget.swipeToReplyConfig?.onRightSwipe !=
                    null) {
                  widget.swipeToReplyConfig?.onRightSwipe!(
                      widget.message.message,
                      widget.message.sendBy);
                }
                widget.onSwipe(widget.message);
              }
                  : null,
              replyIconColor: widget.swipeToReplyConfig?.replyIconColor,
              swipeToReplyAnimationDuration:
              widget.swipeToReplyConfig?.animationDuration,
              child: _messagesWidgetColumn(messagedUser),
            ),
          ),
          if (isMessageBySender &&
              (featureActiveConfig?.enableCurrentUserProfileAvatar ?? true))
            ProfileCircle(
              bottomPadding: widget.message.reaction.reactions.isNotEmpty
                  ? widget.profileCircleConfig?.bottomPadding ?? 15
                  : widget.profileCircleConfig?.bottomPadding ?? 2,
              profileCirclePadding: widget.profileCircleConfig?.padding,
              imageUrl: widget.currentUser.profilePhoto,
              circleRadius: widget.profileCircleConfig?.circleRadius,
            ),
        ],
      ),
    );
  }

  Widget _messagesWidgetColumn(ChatUser? messagedUser) {
    return Column(
      crossAxisAlignment:
      isMessageBySender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        if ((chatController?.chatUsers.length ?? 0) > 1 && !isMessageBySender)
          Padding(
            padding:
            widget.chatBubbleConfig?.inComingChatBubbleConfig?.padding ??
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
              messagedUser?.name ?? '',
              style: widget.chatBubbleConfig?.inComingChatBubbleConfig
                  ?.senderNameTextStyle,
            ),
          ),
        if (replyMessage.isNotEmpty)
          widget.repliedMessageConfig?.repliedMessageWidgetBuilder != null
              ? widget.repliedMessageConfig!
              .repliedMessageWidgetBuilder!(widget.message.replyMessage)
              : ReplyMessageWidget(
            message: widget.message,
            repliedMessageConfig: widget.repliedMessageConfig,
            currentUser: widget.currentUser,
            onTap: () => widget.onReplyTap
                ?.call(widget.message.replyMessage.messageId),
          ),
        MessageView(
          outgoingChatBubbleConfig:
          widget.chatBubbleConfig?.outgoingChatBubbleConfig,
          isLongPressEnable:
          (featureActiveConfig?.enableReactionPopup ?? true) ||
              (featureActiveConfig?.enableReplySnackBar ?? true),
          inComingChatBubbleConfig:
          widget.chatBubbleConfig?.inComingChatBubbleConfig,
          message: widget.message,
          isMessageBySender: isMessageBySender,
          messageConfig: widget.messageConfig,
          onLongPress: widget.onLongPress,
          chatBubbleMaxWidth: widget.chatBubbleConfig?.maxWidth,
          longPressAnimationDuration:
          widget.chatBubbleConfig?.longPressAnimationDuration,
          onDoubleTap: featureActiveConfig?.enableDoubleTapToLike ?? false
              ? widget.chatBubbleConfig?.onDoubleTap ??
                  (message) => chatController?.setReaction(
                emoji: heart,
                messageId: message.id,
                userId: widget.currentUser.id,
              )
              : null,
          shouldHighlight: widget.shouldHighlight,
          highlightColor: widget.repliedMessageConfig
              ?.repliedMsgAutoScrollConfig.highlightColor ??
              Colors.grey,
          highlightScale: widget.repliedMessageConfig
              ?.repliedMsgAutoScrollConfig.highlightScale ??
              1.1,
        ),
      ],
    );
  }
}
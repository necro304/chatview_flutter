import 'package:chatview/src/models/replied_msg_auto_scroll_config.dart';
import 'package:flutter/material.dart';
import '../values/typedefs.dart';

class RepliedMessageConfiguration {
  final Color? verticalBarColor;
  final Color? backgroundColor;
  final TextStyle? textStyle;
  final TextStyle? replyTitleTextStyle;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final double? maxWidth;
  final BorderRadiusGeometry? borderRadius;
  final double? verticalBarWidth;
  final double? repliedImageMessageHeight;
  final double? repliedImageMessageWidth;
  final BorderRadiusGeometry? repliedImageMessageBorderRadius;
  final double? opacity;
  final ReplyMessageWithReturnWidget? repliedMessageWidgetBuilder;

  /// Configuration for auto scrolling and highlighting a message when
  /// tapping on the original message above the replied message.
  final RepliedMsgAutoScrollConfig repliedMsgAutoScrollConfig;

  RepliedMessageConfiguration({
    this.verticalBarColor,
    this.backgroundColor,
    this.textStyle,
    this.replyTitleTextStyle,
    this.margin,
    this.padding,
    this.maxWidth,
    this.borderRadius,
    this.verticalBarWidth,
    this.repliedImageMessageHeight,
    this.repliedImageMessageWidth,
    this.repliedImageMessageBorderRadius,
    this.repliedMessageWidgetBuilder,
    this.opacity,
    this.repliedMsgAutoScrollConfig = const RepliedMsgAutoScrollConfig(),
  });
}
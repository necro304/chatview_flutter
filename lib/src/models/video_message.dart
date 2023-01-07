import 'package:flutter/material.dart';

import '../../chatview.dart';

class VideoMessageConfiguration {
  final ShareIconConfiguration? shareIconConfig;
  final StringCallback? onTap; // Returns imageURL
  final double? height;
  final double? width;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;

  VideoMessageConfiguration({
    this.shareIconConfig,
    this.onTap,
    this.height,
    this.width,
    this.padding,
    this.margin,
    this.borderRadius,
  });
}



import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:miti_common/miti_common.dart';

enum BubbleType {
  send,
  receiver,
}

class ChatBubble extends StatelessWidget {
  const ChatBubble({
    super.key,
    this.margin,
    this.constraints,
    this.alignment = Alignment.center,
    this.backgroundColor,
    this.child,
    required this.bubbleType,
  });
  final EdgeInsetsGeometry? margin;
  final BoxConstraints? constraints;
  final AlignmentGeometry? alignment;
  final Color? backgroundColor;
  final Widget? child;
  final BubbleType bubbleType;

  bool get isISend => bubbleType == BubbleType.send;

  @override
  Widget build(BuildContext context) => TriangleContainer(
        top: 15.h,
        triangleDirection:
            isISend ? TriangleDirection.right : TriangleDirection.left,
        triangleColor:
            isISend ? StylesLibrary.c_8443F8 : StylesLibrary.c_FFFFFF,
        child: Container(
          constraints: constraints,
          margin: margin,
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          alignment: alignment,
          decoration: BoxDecoration(
            color: backgroundColor ??
                (isISend ? StylesLibrary.c_8443F8 : StylesLibrary.c_FFFFFF),
            borderRadius: borderRadius(isISend),
          ),
          child: child,
        ),
      );
}

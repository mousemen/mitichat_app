import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:miti_common/miti_common.dart';

class Button extends StatelessWidget {
  const Button({
    super.key,
    required this.text,
    this.enabled = true,
    this.enabledColor,
    this.disabledColor,
    this.borderColor,
    this.radius,
    this.textStyle,
    this.disabledTextStyle,
    this.onTap,
    this.height,
    this.width,
    this.margin,
    this.padding,
  });
  final Color? enabledColor;
  final Color? disabledColor;
  final Color? borderColor;
  final double? radius;
  final TextStyle? textStyle;
  final TextStyle? disabledTextStyle;
  final String text;
  final double? height;
  final double? width;
  final Function()? onTap;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: Material(
        type: MaterialType.transparency,
        child: GestureDetector(
          onTap: enabled ? onTap : null,
          behavior: HitTestBehavior.translucent,
          child: Container(
            height: height ?? 44.h,
            width: width,
            decoration: BoxDecoration(
              color: enabled
                  ? enabledColor ?? StylesLibrary.c_8443F8
                  : disabledColor ?? StylesLibrary.c_8443F8_opacity50,
              borderRadius: BorderRadius.circular(radius ?? 10.r),
              border: Border.all(color: borderColor ?? Colors.transparent),
            ),
            child: Container(
              alignment: Alignment.center,
              padding: padding,
              child: Text(
                text,
                style: enabled
                    ? textStyle ?? StylesLibrary.ts_FFFFFF_16sp
                    : disabledTextStyle ?? StylesLibrary.ts_FFFFFF_16sp,
                maxLines: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ImageTextButton extends StatelessWidget {
  ImageTextButton({
    Key? key,
    required this.icon,
    required this.text,
    double? iconWidth,
    double? iconHeight,
    double? radius,
    this.textStyle,
    this.color,
    this.height,
    this.onTap,
  })  : iconWidth = iconWidth ?? 20.w,
        iconHeight = iconHeight ?? 20.h,
        radius = radius ?? 6.r,
        super(key: key);

  final String icon;
  final String text;
  final TextStyle? textStyle;
  final Color? color;
  final double? height;
  final double? iconWidth;
  final double? iconHeight;
  final double? radius;
  final Function()? onTap;

  ImageTextButton.call({super.key, this.onTap})
      : icon = ImageLibrary.audioAndVideoCall,
        text = StrLibrary.audioAndVideoCall,
        color = StylesLibrary.c_FFFFFF,
        textStyle = null,
        iconWidth = null,
        iconHeight = null,
        radius = null,
        height = null;

  ImageTextButton.message({super.key, this.onTap})
      : icon = ImageLibrary.message,
        text = StrLibrary.sendMessage,
        color = StylesLibrary.c_8443F8,
        textStyle = StylesLibrary.ts_FFFFFF_16sp,
        iconWidth = null,
        iconHeight = null,
        radius = null,
        height = null;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: onTap,
        child: Container(
          height: height ?? 46.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius ?? 0),
            color: color,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon.toImage
                ..width = iconWidth
                ..height = iconHeight,
              7.horizontalSpace,
              text.toText..style = textStyle ?? StylesLibrary.ts_333333_16sp,
            ],
          ),
        ),
      ),
    );
  }
}

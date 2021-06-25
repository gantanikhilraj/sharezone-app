import 'dart:math';

import 'package:flutter/material.dart';

class Dimensions {
  final double height, width;

  const Dimensions(this.height, this.width);

  factory Dimensions.fromMediaQuery(BuildContext context) {
    final mediaQueryData = MediaQuery.of(context);
    return Dimensions(mediaQueryData.size.height, mediaQueryData.size.width);
  }

  bool get isDesktopModus {
    if (width < 700) {
      return false;
    } else if (width >= 700 && width <= 700) {
      if (height > 500)
        return true;
      else
        return false;
    } else {
      return true;
    }
  }

  EdgeInsets get dialogPaddingDimensions {
    if (isDesktopModus == false)
      return EdgeInsets.zero;
    else {
      return EdgeInsets.symmetric(
          horizontal: 32,
          vertical: sizeByPixels(
            height,
            min: 0,
            max: 64,
          ));
    }
  }

  double get dialogBorderRadiusDimensions {
    if (isDesktopModus == false)
      return 0;
    else {
      return 8;
    }
  }
}

double sizeByPixels(
  double pixels, {
  double min,
  double max,
  double factor,
  double breakpoint,
}) {
  double value = pow(100 * e, (pixels / 300) - 1);
  if (value < min) {
    return min;
  }
  if (value > max) {
    return max;
  }
  return value;
}
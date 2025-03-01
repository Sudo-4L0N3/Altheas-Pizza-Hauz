// lib/admin/utils/responsive_text.dart

import 'package:flutter/material.dart';

class ResponsiveText {
  static double getTitleSize(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (width >= 1200) {
      return 20;
    } else if (width >= 800) {
      return 16;
    } else {
      return 12;
    }
  }

  static double getSubtitleSize(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (width >= 1200) {
      return 16;
    } else if (width >= 800) {
      return 16;
    } else {
      return 12;
    }
  }

  static double getBodySize(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (width >= 1200) {
      return 16;
    } else if (width >= 800) {
      return 12;
    } else {
      return 12;
    }
  }
}

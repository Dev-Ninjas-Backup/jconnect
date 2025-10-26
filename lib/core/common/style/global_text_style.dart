import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

TextStyle getTextStyle({
  double fontsize = 14.0,
  FontWeight fontweight = FontWeight.w400,
  TextAlign textAlign = TextAlign.center,
  Color color = Colors.black,
}) {
  return GoogleFonts.inter(
    fontSize: sp(fontsize),
    fontWeight: fontweight,
    color: color,
  );
}


double sp(double baseSize) {
  double scale = ScreenUtil().screenWidth / 375;
  if (scale > 1.2) scale = 1.2;
  return baseSize * scale;
}

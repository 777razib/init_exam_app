import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Global globalTextStyle function
TextStyle globalTextStyle({
  double fontSize = 15.0,
  FontWeight fontWeight = FontWeight.normal,
  double lineHeight = 1.5,
  TextAlign textAlign = TextAlign.center,
  Color color = const Color(0xff2D2D2D),
}) {
  return GoogleFonts.inter(
    fontSize: fontSize,
    fontWeight: fontWeight,
    height: lineHeight,
    color: color,
  );
}

TextStyle globalHeadingTextStyle({
  double fontSize = 25.0,
  FontWeight fontWeight = FontWeight.w600,
  double lineHeight = 1.5,
  TextAlign textAlign = TextAlign.center,
  Color color = const Color(0xff2D2D2D),
}) {
  return GoogleFonts.inter(
    fontSize: fontSize,
    fontWeight: fontWeight,
    height: lineHeight,
    color: color,
  );
}

import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  static TextStyle display(Color c) => GoogleFonts.inter(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.20,
    color: c,
  );

  static TextStyle headline(Color c) => GoogleFonts.inter(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.25,
    color: c,
  );

  static TextStyle title(Color c) => GoogleFonts.inter(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.30,
    color: c,
  );

  static TextStyle subtitle(Color c) => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.35,
    color: c,
  );

  static TextStyle body(Color c) => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.50,
    color: c,
  );

  static TextStyle bodySmall(Color c) => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.45,
    color: c,
  );

  static TextStyle label(Color c) => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.20,
    color: c,
  );

  static TextStyle button(Color c) => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.20,
    color: c,
  );
}

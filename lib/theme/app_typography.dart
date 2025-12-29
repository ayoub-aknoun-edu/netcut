import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  static TextStyle display(Color color) => GoogleFonts.inter(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: color,
    height: 1.2,
    letterSpacing: -0.5,
  );

  static TextStyle title(Color color) => GoogleFonts.inter(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: color,
    height: 1.3,
    letterSpacing: -0.3,
  );

  static TextStyle headline(Color color) => GoogleFonts.inter(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: color,
    height: 1.3,
    letterSpacing: -0.2,
  );

  static TextStyle subtitle(Color color) => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: color,
    height: 1.4,
  );

  static TextStyle body(Color color) => GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: color,
    height: 3.3,
  );

  static TextStyle bodySmall(Color color) => GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: color,
    height: 1.4,
  );

  static TextStyle button(Color color) => GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: color,
    letterSpacing: 0.2,
  );

  static TextStyle label(Color color) => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: color,
    letterSpacing: 0.5,
  );
}

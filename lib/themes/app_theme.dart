import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primecolor = Color(0xff6C5CE7);
  static const Color secondrycolor = Color(0xff74B9FF);
  static const Color accentcolor = Color(0xfffD79AB);
  static const Color backgroundcolor = Color(0xffF8F9Fa);
  static const Color cardcolor = Color(0xFFFFFFFF);
  static const Color textprimarycolor = Color(0xff2D3436);
  static const Color textsecondrycolor = Color(0xff636E72);
  static const Color errorcolor = Color(0xffE17055);
  static const Color bordercolor = Color(0xffDDD6fe);
  static const Color succescolor = Color(0xff00B894);
  static ThemeData Lighttheam = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.light(
      primary: primecolor,
      secondary: secondrycolor,
      surface: backgroundcolor,
      onPrimary: Colors.white,

      onSecondary: Colors.white,
      error: errorcolor,

      onSurface: textprimarycolor,
      onBackground: textprimarycolor,
    ),
    textTheme: GoogleFonts.poppinsTextTheme().copyWith(
      headlineLarge: GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: textprimarycolor,
      ),
      headlineMedium: GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: textprimarycolor,
      ),
      headlineSmall: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: textprimarycolor,
      ),
      bodyLarge: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: textprimarycolor,
      ),
      bodyMedium: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: textprimarycolor,
      ),
      bodySmall: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: textprimarycolor,
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textprimarycolor,
      ),
      iconTheme: IconThemeData(color: textprimarycolor),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primecolor,
        foregroundColor: Colors.white,
        elevation: 0,
        textStyle: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      ),
    ),
    cardTheme: CardThemeData(
      color: cardcolor,
      elevation: 0,
      shape: BeveledRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      side: BorderSide(
color: bordercolor,
width: 1
      )
      ),

    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: cardcolor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: bordercolor)
      ),focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: bordercolor,width: 2)
      ),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: bordercolor)
      ),
      errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: bordercolor)
      ),
      contentPadding: EdgeInsets.symmetric(
        vertical: 16,
        horizontal: 16
      )
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primecolor,
      focusColor: Colors.white,
    elevation: 0
    )
  );
}

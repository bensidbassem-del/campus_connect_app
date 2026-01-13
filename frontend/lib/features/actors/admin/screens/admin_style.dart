import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminStyle {
  static const primary = Color(
    0xFF4F46E5,
  ); // Indigo 600 - distinct from standard blue
  static const secondary = Color(0xFF10B981); // Emerald 500
  static const bg = Color(0xFFF3F4F6); // Cool Gray 100
  static const surface = Colors.white;
  static const textPrimary = Color(0xFF111827); // Gray 900
  static const textSecondary = Color(0xFF6B7280); // Gray 500
  static const error = Color(0xFFEF4444); // Red 500

  static TextStyle get header => GoogleFonts.plusJakartaSans(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: textPrimary,
    letterSpacing: -0.5, // Tighter, more modern
  );

  static TextStyle get subHeader => GoogleFonts.plusJakartaSans(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    letterSpacing: -0.3,
  );

  static TextStyle get body =>
      GoogleFonts.plusJakartaSans(fontSize: 14, color: textSecondary);

  static TextStyle get button => GoogleFonts.plusJakartaSans(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static InputDecoration inputDec(String label, {IconData? icon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.plusJakartaSans(color: textSecondary),
      prefixIcon: icon != null
          ? Icon(icon, size: 20, color: textSecondary)
          : null,
      filled: true,
      fillColor: surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primary, width: 2),
      ),
    );
  }
}

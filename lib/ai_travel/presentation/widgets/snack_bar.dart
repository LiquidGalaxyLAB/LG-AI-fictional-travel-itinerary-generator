import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SnackBarWidget {
  void showSnackBar({
    required BuildContext context,
    required String message,
    int duration = 1,
    Color color = Colors.green,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.spaceGrotesk(
            textStyle:  TextStyle(
              color: Colors.grey[100],
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        backgroundColor: const Color(0xff222222),
        duration: Duration(seconds: duration),
        showCloseIcon: true,
      ),
    );
  }
}
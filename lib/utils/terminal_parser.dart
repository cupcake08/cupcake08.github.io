import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class TerminalParser {
  
  static TextSpan parse(String text) {
    List<TextSpan> spans = [];
    final lines = text.split('\n');
    
    for (var line in lines) {
      // 1. Boot Sequence Highlights
      if (line.contains("INITIALIZING SYSTEM") || line.contains("KERNEL LOADED")) {
        spans.add(TextSpan(text: "$line\n", style: _style(Colors.greenAccent, bold: true)));
        continue;
      }
      if (line.contains("WELCOME TO")) {
         spans.add(TextSpan(text: "$line\n", style: _style(Colors.cyanAccent, bold: true)));
         continue;
      }

      // 2. Headers (ALL CAPS ending with :)
      if (RegExp(r'^[A-Z\s]+:$').hasMatch(line.trim())) {
        spans.add(TextSpan(
          text: "$line\n",
          style: GoogleFonts.firaCode(
            color: Colors.amberAccent,
            fontWeight: FontWeight.bold,
            fontSize: 14,
            letterSpacing: 1.1,
          )
        ));
        continue;
      }

      // 3. Metadata [Blocks]
      if (line.trim().startsWith('[')) {
        spans.add(TextSpan(text: "$line\n", style: _style(Colors.cyanAccent)));
        continue;
      }

      // 4. Command Prompts (> Role:)
      if (line.trim().startsWith('>')) {
         final parts = line.split(':');
         if (parts.length > 1) {
           spans.add(TextSpan(children: [
             TextSpan(text: "${parts[0]}:", style: _style(Colors.pinkAccent[100]!, bold: true)),
             TextSpan(text: "${parts.sublist(1).join(':')}\n", style: _style(const Color(0xFFE0E0E0))),
           ]));
         } else {
           spans.add(TextSpan(text: "$line\n", style: _style(Colors.pinkAccent[100]!)));
         }
         continue;
      }

      // 5. Key-Value pairs (Role:, Location:)
      if (line.trim().startsWith('Role:') || line.trim().startsWith('Location:')) {
         final parts = line.split(':');
         spans.add(TextSpan(children: [
           TextSpan(text: "${parts[0]}:", style: _style(Colors.pinkAccent, bold: true)),
           TextSpan(text: "${parts.sublist(1).join(':')}\n", style: _style(Colors.white)),
         ]));
         continue;
      }

      // 6. Detect Links (http/https)
      // This regex splits the line into "text before url" and "url"
      final urlRegex = RegExp(r'(https?:\/\/[^\s]+)');
      if (urlRegex.hasMatch(line)) {
        final matches = urlRegex.allMatches(line);
        int lastMatchEnd = 0;
        List<TextSpan> lineSpans = [];

        for (var match in matches) {
          // Text before the link
          if (match.start > lastMatchEnd) {
            lineSpans.add(TextSpan(
              text: line.substring(lastMatchEnd, match.start),
              style: _style(const Color(0xFFB0BEC5))
            ));
          }
          
          // The Link itself
          String url = line.substring(match.start, match.end);
          lineSpans.add(TextSpan(
            text: url,
            style: _style(Colors.blueAccent).copyWith(decoration: TextDecoration.underline),
            recognizer: TapGestureRecognizer()
              ..onTap = () async {
                final uri = Uri.parse(url);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri);
                }
              },
          ));
          
          lastMatchEnd = match.end;
        }
        
        // Text after the last link
        if (lastMatchEnd < line.length) {
          lineSpans.add(TextSpan(
            text: line.substring(lastMatchEnd),
            style: _style(const Color(0xFFB0BEC5))
          ));
        }
        
        lineSpans.add(const TextSpan(text: "\n")); // Newline at end of line
        spans.add(TextSpan(children: lineSpans));
        continue;
      }

      // 7. Default Text (Bullet points or normal text)
      spans.add(TextSpan(
        text: "$line\n",
        style: _style(const Color(0xFFB0BEC5))
      ));
    }

    return TextSpan(children: spans);
  }

  static TextStyle _style(Color color, {bool bold = false}) {
    return GoogleFonts.firaCode(
      color: color,
      fontWeight: bold ? FontWeight.bold : FontWeight.normal,
      fontSize: 13,
      height: 1.4
    );
  }
}
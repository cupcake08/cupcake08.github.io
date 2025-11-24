import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class TerminalParser {
  static TextSpan parse(String text, {double baseFontSize = 14}) {
    List<TextSpan> spans = [];
    final lines = text.split('\n');

    for (var line in lines) {
      // 1. Boot Sequence Highlights
      if (line.contains("INITIALIZING SYSTEM") || line.contains("KERNEL LOADED")) {
        spans.add(TextSpan(text: "$line\n", style: _style(Colors.greenAccent, baseFontSize, bold: true)));
        continue;
      }

      // 2. SPECIFIC NAME HIGHLIGHTING (Name + Pronunciation)
      if (line.contains("ANKIT BHANKHARIA")) {
        final nameIndex = line.indexOf("ANKIT BHANKHARIA");
        final bracketIndex = line.indexOf("[");

        if (nameIndex != -1 && bracketIndex != -1) {
          spans.add(
            TextSpan(
              children: [
                // Text before name (if any)
                TextSpan(text: line.substring(0, nameIndex), style: _style(Colors.white, baseFontSize)),
                // THE NAME (High Vis)
                TextSpan(
                  text: "ANKIT BHANKHARIA ",
                  style: GoogleFonts.firaCode(
                    color: Colors.cyanAccent,
                    fontWeight: FontWeight.w900,
                    fontSize: baseFontSize + 1, // Slightly larger
                    letterSpacing: 1.1,
                  ),
                ),
                // THE PRONUNCIATION (Distinct style)
                TextSpan(
                  text: line.substring(bracketIndex), // Includes [un-KIT...]
                  style: GoogleFonts.firaCode(
                    color: Color(0xFFF25912),
                    fontWeight: FontWeight.normal,
                    fontStyle: FontStyle.italic,
                    fontSize: baseFontSize - 1,
                  ),
                ),
                const TextSpan(text: "\n"),
              ],
            ),
          );
          continue;
        }
      }

      if (line.contains("WELCOME TO")) {
        spans.add(TextSpan(text: "$line\n", style: _style(Colors.white, baseFontSize, bold: true)));
        continue;
      }

      // 3. Headers (ALL CAPS ending with :)
      if (RegExp(r'^[A-Z\s]+:$').hasMatch(line.trim())) {
        spans.add(
          TextSpan(
            text: "$line\n",
            style: GoogleFonts.firaCode(
              color: Colors.amberAccent,
              fontWeight: FontWeight.bold,
              fontSize: baseFontSize,
              letterSpacing: 1.1,
            ),
          ),
        );
        continue;
      }

      // 4. Metadata [Blocks]
      if (line.trim().startsWith('[')) {
        spans.add(TextSpan(text: "$line\n", style: _style(Colors.cyanAccent, baseFontSize)));
        continue;
      }

      // 5. Command Prompts (> Role:)
      if (line.trim().startsWith('>')) {
        final parts = line.split(':');
        if (parts.length > 1) {
          spans.add(
            TextSpan(
              children: [
                TextSpan(text: "${parts[0]}:", style: _style(Colors.pinkAccent[100]!, baseFontSize, bold: true)),
                TextSpan(text: "${parts.sublist(1).join(':')}\n", style: _style(const Color(0xFFE0E0E0), baseFontSize)),
              ],
            ),
          );
        } else {
          spans.add(TextSpan(text: "$line\n", style: _style(Colors.pinkAccent[100]!, baseFontSize)));
        }
        continue;
      }

      // 6. Key-Value pairs (About:, Location:)
      if (line.trim().startsWith('About:') || line.trim().startsWith('Location:')) {
        final parts = line.split(':');
        spans.add(
          TextSpan(
            children: [
              TextSpan(text: "${parts[0]}:", style: _style(Colors.pinkAccent, baseFontSize, bold: true)),
              TextSpan(text: "${parts.sublist(1).join(':')}\n", style: _style(Colors.white, baseFontSize)),
            ],
          ),
        );
        continue;
      }

      // 7. Detect Links (http/https)
      final urlRegex = RegExp(r'(https?:\/\/[^\s]+)');
      if (urlRegex.hasMatch(line)) {
        final matches = urlRegex.allMatches(line);
        int lastMatchEnd = 0;
        List<TextSpan> lineSpans = [];

        for (var match in matches) {
          if (match.start > lastMatchEnd) {
            lineSpans.add(
              TextSpan(text: line.substring(lastMatchEnd, match.start), style: _style(Colors.white, baseFontSize)),
            );
          }

          String url = line.substring(match.start, match.end);
          lineSpans.add(
            TextSpan(
              text: url,
              style: _style(Colors.blueAccent, baseFontSize).copyWith(decoration: TextDecoration.underline),
              recognizer: TapGestureRecognizer()
                ..onTap = () async {
                  final uri = Uri.parse(url);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri);
                  }
                },
            ),
          );

          lastMatchEnd = match.end;
        }

        if (lastMatchEnd < line.length) {
          lineSpans.add(
            TextSpan(text: line.substring(lastMatchEnd), style: _style(const Color(0xFFB0BEC5), baseFontSize)),
          );
        }

        lineSpans.add(const TextSpan(text: "\n"));
        spans.add(TextSpan(children: lineSpans));
        continue;
      }

      // 8. Default Text
      spans.add(TextSpan(text: "$line\n", style: _style(Colors.white, baseFontSize)));
    }

    return TextSpan(children: spans);
  }

  static TextStyle _style(Color color, double fontSize, {bool bold = false}) {
    return GoogleFonts.firaCode(
      color: color,
      fontWeight: bold ? FontWeight.bold : FontWeight.normal,
      fontSize: fontSize,
      height: 1.4,
    );
  }
}

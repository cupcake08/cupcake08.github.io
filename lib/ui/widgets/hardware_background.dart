// ignore_for_file: constant_identifier_names, non_constant_identifier_names

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HardwareBackgroundAnimation extends StatefulWidget {
  const HardwareBackgroundAnimation({super.key});

  @override
  State<HardwareBackgroundAnimation> createState() => _HardwareBackgroundAnimationState();
}

class _HardwareBackgroundAnimationState extends State<HardwareBackgroundAnimation> {
  late Timer _timer;
  String _frame = "";

  // Rotation angles
  double A = 0;
  double B = 0;

  @override
  void initState() {
    super.initState();
    // fast 50ms tick for smooth retro animation
    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (mounted) {
        setState(() {
          _frame = _renderDonut();
          A += 0.04;
          B += 0.02;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _renderDonut() {
    // Standard donut math logic
    final size = MediaQuery.of(context).size;
    final minSize = min(size.width * .07, size.height * .07);
    final width = minSize.toInt();
    final height = minSize.toInt();

    final List<double> zBuffer = List.filled(width * height, 0);
    final List<String> output = List.filled(width * height, ' ');

    const double thetaSpacing = 0.07;
    const double phiSpacing = 0.02;

    const double R1 = 1;
    const double R2 = 2;
    const double K2 = 5;
    final double K1 = width * K2 * 3 / (8 * (R1 + R2));

    for (double theta = 0; theta < 2 * pi; theta += thetaSpacing) {
      double costheta = cos(theta);
      double sintheta = sin(theta);

      for (double phi = 0; phi < 2 * pi; phi += phiSpacing) {
        double cosphi = cos(phi);
        double sinphi = sin(phi);

        double circlex = R2 + R1 * costheta;
        double circley = R1 * sintheta;

        double x = circlex * (cos(B) * cosphi + sin(A) * sin(B) * sinphi) - circley * cos(A) * sin(B);
        double y = circlex * (sin(B) * cosphi - sin(A) * cos(B) * sinphi) + circley * cos(A) * cos(B);
        double z = K2 + cos(A) * circlex * sinphi + circley * sin(A);
        double ooz = 1 / z;

        int xp = (width / 2 + K1 * ooz * x).toInt();
        int yp = (height / 2 - K1 * ooz * y).toInt();

        double L =
            cosphi * costheta * sin(B) -
            cos(A) * costheta * sinphi -
            sin(A) * sintheta +
            cos(B) * (cos(A) * sintheta - costheta * sin(A) * sinphi);

        if (L > 0) {
          if (xp >= 0 && xp < width && yp >= 0 && yp < height) {
            int idx = xp + yp * width;
            if (ooz > zBuffer[idx]) {
              zBuffer[idx] = ooz;
              int luminanceIndex = (L * 8).toInt();
              String chars = ".,-~:;=!*#\$@";
              output[idx] = chars[luminanceIndex.clamp(0, 11)];
            }
          }
        }
      }
    }

    StringBuffer sb = StringBuffer();
    for (int i = 0; i < height; i++) {
      sb.writeln(output.sublist(i * width, (i + 1) * width).join());
    }
    return sb.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FittedBox(
        fit: BoxFit.contain,
        child: Text(
          _frame,
          softWrap: false,
          style: GoogleFonts.robotoMono(
            textStyle: TextStyle(
              fontSize: 10,
              color: Colors.cyanAccent.withValues(alpha: 0.35),
              height: 1.1,
              fontWeight: FontWeight.bold,
              fontFamilyFallback: const ['Courier New', 'Courier', 'monospace'],
            ),
          ),
        ),
      ),
    );
  }
}

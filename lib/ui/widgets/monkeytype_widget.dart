import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:portfolio/models/monkeytype.dart';
import 'package:url_launcher/url_launcher.dart';

class MonkeytypeDashboard extends StatefulWidget {
  final MonkeytypeResponse? data;

  const MonkeytypeDashboard({super.key, required this.data});

  @override
  State<MonkeytypeDashboard> createState() => _MonkeytypeDashboardState();
}

class _MonkeytypeDashboardState extends State<MonkeytypeDashboard>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  bool _showValues = false;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    // Initialize Animation Controller
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _showValues = true;
        });
      }
      _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    // Show 10 words and 15 seconds
    final keys = ['words_10', 'time_15'];

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white.withOpacity(0.2)),
            borderRadius: BorderRadius.circular(12),
          ),
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Typing Speed",
                      style: GoogleFonts.spaceGrotesk(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    InkWell(
                      onTap: () => launchUrl(Uri.parse("https://monkeytype.com/profile/bhankhariaa")),
                      child: Row(
                        children: [
                          Text(
                            "Profile",
                            style: GoogleFonts.spaceGrotesk(
                              color: const Color(0xFFE2B714), // Monkeytype yellow
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.arrow_outward, size: 14, color: Color(0xFFE2B714)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  spacing: 20,
                  children: keys.map((key) {
                    double wpm = 0;
                    if (widget.data != null &&
                        widget.data!.data.containsKey(key) &&
                        widget.data!.data[key]!.isNotEmpty) {
                      wpm = widget.data!.data[key]!.first.wpm;
                    }

                    // Show 0 if not yet ready to show values
                    final displayWpm = _showValues ? wpm : 0.0;

                    return StatCard(mode: key, wpm: displayWpm);
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final String mode;
  final double wpm;

  const StatCard({super.key, required this.mode, required this.wpm});

  @override
  Widget build(BuildContext context) {
    String label = mode;
    if (mode.startsWith('time_')) {
      label = "${mode.replaceAll('time_', '')}s";
    } else if (mode.startsWith('words_')) {
      label = "${mode.replaceAll('words_', '')} words";
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: GoogleFonts.spaceGrotesk(
            color: Colors.white.withValues(alpha: .5),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        // Speed and Unit
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: wpm),
              duration: const Duration(seconds: 2),
              curve: Curves.easeOut,
              builder: (context, value, child) {
                return Text(
                  value.toStringAsFixed(0),
                  style: GoogleFonts.spaceGrotesk(
                    color: Colors.white, // Pure white
                    fontSize: 36, // Reduced from 48
                    fontWeight: FontWeight.bold,
                    height: 1.0,
                    fontFeatures: [const FontFeature.tabularFigures()],
                  ),
                );
              },
            ),
            const SizedBox(width: 6),
            Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: Text(
                "wpm",
                style: GoogleFonts.spaceGrotesk(
                  color: Colors.white.withValues(alpha: .5),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

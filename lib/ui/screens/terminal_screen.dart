import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:portfolio/data/resume_data.dart';
import 'package:portfolio/ui/widgets/typewriter_widget.dart';
import '../../controllers/terminal_controller.dart';
import '../../utils/terminal_parser.dart';
import '../widgets/hardware_background.dart';
import '../widgets/command_input.dart';

class TerminalScreen extends StatefulWidget {
  const TerminalScreen({super.key});

  @override
  State<TerminalScreen> createState() => _TerminalScreenState();
}

class _TerminalScreenState extends State<TerminalScreen> {
  final TerminalController _controller = TerminalController();
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  bool _hasIntroAnimRun = false;

  void _onSubmit(String value) {
    bool shouldClear = _controller.processCommand(value);

    setState(() {
      if (shouldClear) _inputController.clear();
    });

    _inputController.clear();
    _focusNode.requestFocus();

    // Scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final bool isMobile = screenSize.width < 600;
    final double horizontalPadding = isMobile ? 12.0 : 24.0;

    final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: Color(0xFF211832),
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // 1. Background
          const Positioned.fill(child: HardwareBackgroundAnimation()),

          // 2. Gradient Overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.0,
                  colors: [Color(0xFF211832).withValues(alpha: .3), Color(0xFF211832).withValues(alpha: .6)],
                ),
              ),
            ),
          ),

          // 3. Terminal Content
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: keyboardHeight,
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 10.0).copyWith(top: 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          if (_hasIntroAnimRun) _focusNode.requestFocus();
                        },
                        child: ScrollConfiguration(
                          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                          child: ListView.builder(
                            controller: _scrollController,
                            itemCount: _controller.history.length,
                            physics: const ClampingScrollPhysics(),
                            itemBuilder: (context, index) {
                              final entry = _controller.history[index];
                              final bool isIntro = index == 0;

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (entry.command.isNotEmpty)
                                      Row(
                                        children: [
                                          Text(
                                            isMobile ? "guest:~ " : ResumeData.promptSymbol,
                                            style: GoogleFonts.firaCode(
                                              color: Color(0xFFF25912),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                          Text(
                                            entry.command,
                                            style: GoogleFonts.firaCode(color: const Color(0xFFB0BEC5), fontSize: 14),
                                          ),
                                        ],
                                      ),
                                    const SizedBox(height: 6),

                                    isIntro
                                        ? RichTypewriter(
                                            text: entry.output,
                                            shouldAnimate: !_hasIntroAnimRun,
                                            onComplete: () {
                                              if (mounted && !_hasIntroAnimRun) {
                                                setState(() {
                                                  _hasIntroAnimRun = true;
                                                });
                                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                                  _focusNode.requestFocus();
                                                });
                                              }
                                            },
                                          )
                                        : SelectableText.rich(TerminalParser.parse(entry.output)),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (_hasIntroAnimRun)
                      CommandInput(controller: _inputController, focusNode: _focusNode, onSubmit: _onSubmit),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

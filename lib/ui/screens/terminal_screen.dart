import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:portfolio/data/resume_data.dart';
import 'package:portfolio/ui/monkeytype/monkeytype_section.dart';
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

class _TerminalScreenState extends State<TerminalScreen> with WidgetsBindingObserver {
  final TerminalController _controller = TerminalController();
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  bool _isKeyboardVisible = false;

  bool _hasIntroAnimRun = false;
  bool _hasSubmittedCommand = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkKeyboardVisibility();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    _checkKeyboardVisibility();
  }

  void _checkKeyboardVisibility() {
    final bool isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0.0;
    if (isKeyboardVisible != _isKeyboardVisible) {
      _isKeyboardVisible = isKeyboardVisible;
      if (!_isKeyboardVisible) _focusNode.unfocus();
    }
  }

  void _onSubmit(String value) {
    bool shouldClear = _controller.processCommand(value);
    _inputController.clear();

    if (shouldClear) {
      setState(() {
        if (!_hasSubmittedCommand) {
          _hasSubmittedCommand = true;
        }
      });
    } else {
      setState(() {
        if (!_hasSubmittedCommand) {
          _hasSubmittedCommand = true;
        }
      });
      // Scroll to bottom
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
    // Keep focus
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final bool isMobile = screenSize.width < 600;
    final double horizontalPadding = isMobile ? 12.0 : 24.0;

    double fontSize = 14;
    if (screenSize.width >= 1200) {
      fontSize = 18;
    } else if (screenSize.width >= 600) {
      fontSize = 16;
    }

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
                  colors: [Color(0xFF211832).withOpacity(.3), Color(0xFF211832).withOpacity(.6)],
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
                              final bool isIntro = entry.command.isEmpty;

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
                                              fontSize: fontSize,
                                            ),
                                          ),
                                          Text(
                                            entry.command,
                                            style: GoogleFonts.firaCode(
                                              color: const Color(0xFFB0BEC5),
                                              fontSize: fontSize,
                                            ),
                                          ),
                                        ],
                                      ),
                                    const SizedBox(height: 6),

                                    isIntro
                                        ? LayoutBuilder(
                                            builder: (context, constraints) {
                                              bool isWide = constraints.maxWidth > 1800;

                                              Widget introText = RichTypewriter(
                                                text: entry.output,
                                                fontSize: fontSize,
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
                                              );

                                              Widget monkeyWidget = _hasIntroAnimRun
                                                  ? MonkeytypePortfolioSection()
                                                  : const SizedBox.shrink();

                                              if (isWide) {
                                                return Row(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Expanded(flex: 3, child: introText),
                                                    if (_hasIntroAnimRun) Expanded(flex: 2, child: monkeyWidget),
                                                  ],
                                                );
                                              } else {
                                                return Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    introText,
                                                    if (_hasIntroAnimRun) const MonkeytypePortfolioSection(),
                                                  ],
                                                );
                                              }
                                            },
                                          )
                                        : Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              SelectableText.rich(
                                                TerminalParser.parse(entry.output, baseFontSize: fontSize),
                                              ),
                                              if (entry.widget != null) entry.widget!,
                                            ],
                                          ),
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
                      CommandInput(
                        controller: _inputController,
                        focusNode: _focusNode,
                        onSubmit: _onSubmit,
                        fontSize: fontSize,
                        hintText: _hasSubmittedCommand ? null : "help",
                      ),
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

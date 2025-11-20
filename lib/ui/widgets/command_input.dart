import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/resume_data.dart';

class CommandInput extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final Function(String) onSubmit;

  const CommandInput({super.key, required this.controller, required this.focusNode, required this.onSubmit});

  @override
  State<CommandInput> createState() => _CommandInputState();
}

class _CommandInputState extends State<CommandInput> {
  String _suggestion = "";

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onSearchChanged);
    super.dispose();
  }

  void _onSearchChanged() {
    final text = widget.controller.text.toLowerCase();
    if (text.isEmpty) {
      if (_suggestion.isNotEmpty) setState(() => _suggestion = "");
      return;
    }

    final match = ResumeData.knownCommands.firstWhere((cmd) => cmd.startsWith(text) && cmd != text, orElse: () => "");

    setState(() {
      _suggestion = match;
    });
  }

  void _acceptSuggestion() {
    if (_suggestion.isNotEmpty) {
      widget.controller.value = TextEditingValue(
        text: _suggestion,
        selection: TextSelection.collapsed(offset: _suggestion.length),
      );
      setState(() => _suggestion = "");
      widget.focusNode.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;
    final String promptText = isMobile ? "guest:~ " : ResumeData.promptSymbol;

    String ghostSuffix = "";
    if (_suggestion.isNotEmpty && widget.controller.text.isNotEmpty) {
      if (_suggestion.startsWith(widget.controller.text.toLowerCase())) {
        ghostSuffix = _suggestion.substring(widget.controller.text.length);
      }
    }

    final TextStyle commonStyle = GoogleFonts.firaCode(fontSize: 14, fontWeight: FontWeight.w500, height: 1.2);

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.tab): () {
          _acceptSuggestion();
        },
      },
      child: Row(
        children: [
          Text(
            promptText,
            style: GoogleFonts.firaCode(color: Colors.pinkAccent, fontWeight: FontWeight.bold, fontSize: 14),
          ),
          Expanded(
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                // Layer 1: Ghost Text (The Suggestion)
                // We render the user's text as invisible to push the ghost text to the right position
                if (ghostSuffix.isNotEmpty)
                  IgnorePointer(
                    child: RichText(
                      text: TextSpan(
                        children: [
                          // Invisible text matching user input to handle spacing
                          TextSpan(
                            text: widget.controller.text,
                            style: commonStyle.copyWith(color: Colors.transparent),
                          ),
                          // The visible "Ghost" suffix
                          TextSpan(
                            text: ghostSuffix,
                            style: commonStyle.copyWith(color: Colors.white.withValues(alpha: .3)),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Layer 2: The Actual Input Field
                TextField(
                  controller: widget.controller,
                  focusNode: widget.focusNode,
                  cursorColor: Colors.cyanAccent,
                  cursorOpacityAnimates: true,
                  cursorHeight: 14,
                  style: commonStyle.copyWith(color: Colors.cyanAccent),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero, // Critical for Stack alignment
                  ),
                  onSubmitted: (value) {
                    widget.onSubmit(value);
                    setState(() => _suggestion = "");
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

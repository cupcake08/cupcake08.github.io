import 'dart:async';
import 'package:flutter/material.dart';
import '../../utils/terminal_parser.dart';

class RichTypewriter extends StatefulWidget {
  final String text;
  final bool shouldAnimate;
  final VoidCallback? onComplete;
  final double fontSize;

  const RichTypewriter({super.key, required this.text, this.shouldAnimate = true, this.onComplete, this.fontSize = 14});

  @override
  State<RichTypewriter> createState() => _RichTypewriterState();
}

class _RichTypewriterState extends State<RichTypewriter> {
  late TextSpan _fullSpan;
  int _currentLength = 0;
  int _totalLength = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _fullSpan = TerminalParser.parse(widget.text, baseFontSize: widget.fontSize);
    _totalLength = _calculateLength(_fullSpan);

    if (widget.shouldAnimate) {
      _startTyping();
    } else {
      _currentLength = _totalLength;
    }
  }

  void _startTyping() {
    _timer = Timer.periodic(const Duration(milliseconds: 15), (timer) {
      if (_currentLength < _totalLength) {
        setState(() {
          _currentLength += 2;
        });
      } else {
        _timer?.cancel();
        widget.onComplete?.call();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_currentLength >= _totalLength) {
      return RichText(text: _fullSpan);
    }
    final visibleSpan = _truncateSpan(_fullSpan, _currentLength);
    return RichText(text: visibleSpan);
  }

  int _calculateLength(TextSpan span) {
    int count = span.text?.length ?? 0;
    if (span.children != null) {
      for (var child in span.children!) {
        if (child is TextSpan) {
          count += _calculateLength(child);
        }
      }
    }
    return count;
  }

  TextSpan _truncateSpan(TextSpan span, int limit) {
    if (limit <= 0) return const TextSpan(text: "");

    if (span.text != null) {
      final textLen = span.text!.length;
      if (limit >= textLen) {
        return span;
      } else {
        return TextSpan(
          text: span.text!.substring(0, limit),
          style: span.style,
          recognizer: span.recognizer, // Keep link gestures
        );
      }
    }

    if (span.children != null) {
      List<InlineSpan> newChildren = [];
      int consumed = 0;

      for (var child in span.children!) {
        if (child is TextSpan) {
          final childLen = _calculateLength(child);
          final remaining = limit - consumed;

          if (remaining > 0) {
            if (remaining >= childLen) {
              newChildren.add(child);
              consumed += childLen;
            } else {
              newChildren.add(_truncateSpan(child, remaining));
              consumed += remaining;
              break;
            }
          } else {
            break;
          }
        }
      }
      return TextSpan(children: newChildren, style: span.style);
    }

    return const TextSpan(text: "");
  }
}

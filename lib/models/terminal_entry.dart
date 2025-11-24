import 'package:flutter/material.dart';

class TerminalEntry {
  final String command;
  final String output;
  final Widget? widget;

  TerminalEntry({required this.command, required this.output, this.widget});
}

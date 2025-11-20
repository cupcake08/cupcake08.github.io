import '../models/terminal_entry.dart';
import '../data/resume_data.dart';

class TerminalController {
  final List<TerminalEntry> history = [
    TerminalEntry(command: '', output: ResumeData.intro),
  ];

  /// Processes the user input and updates history.
  /// Returns [true] if the screen needs to be cleared.
  bool processCommand(String input) {
    final cmd = input.trim().toLowerCase();
    
    if (cmd.isEmpty) return false;
    if (cmd == 'clear') {
      history.clear();
      return true;
    }

    String response;
    switch (cmd) {
      case 'help': response = ResumeData.help; break;
      case 'about': response = ResumeData.about; break;
      case 'experience': response = ResumeData.experience; break;
      case 'projects': response = ResumeData.projects; break;
      case 'skills': response = ResumeData.skills; break;
      case 'education': response = ResumeData.education; break;
      case 'contact': response = ResumeData.contact; break;
      default: response = "bash: $cmd: command not found. Type 'help'.";
    }

    history.add(TerminalEntry(command: input, output: response));
    return false;
  }
}
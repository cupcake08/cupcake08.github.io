import 'package:flutter/material.dart';
import 'package:portfolio/models/monkeytype.dart';
import 'package:portfolio/services/monkeytype_service.dart';
import 'package:portfolio/ui/widgets/monkeytype_widget.dart';

class MonkeytypePortfolioSection extends StatefulWidget {
  const MonkeytypePortfolioSection({super.key});

  @override
  State<MonkeytypePortfolioSection> createState() => _MonkeytypePortfolioSectionState();
}

class _MonkeytypePortfolioSectionState extends State<MonkeytypePortfolioSection> {
  late Future<MonkeytypeResponse?> _dataFuture;

  @override
  void initState() {
    super.initState();
    _dataFuture = MonkeytypeService.instance.getData();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<MonkeytypeResponse?>(
      future: _dataFuture,
      builder: (context, snapshot) {
        return MonkeytypeDashboard(data: snapshot.data);
      },
    );
  }
}

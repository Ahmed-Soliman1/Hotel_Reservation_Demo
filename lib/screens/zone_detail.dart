import 'package:flutter/material.dart';

class ZoneDetailScreen extends StatelessWidget {
  final String zoneName;

  const ZoneDetailScreen({required this.zoneName});

  @override
  Widget build(BuildContext context) {
    // Placeholder videos/images
    final media = List.generate(4, (index) => 'assets/${zoneName.toLowerCase()}_${index + 1}.jpg');

    return Scaffold(
      appBar: AppBar(
        title: Text(zoneName),
        backgroundColor: Color(0xFFFFBD59),
        leading: BackButton(),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: media
              .map((file) => Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Image.asset(file),
                  ))
              .toList(),
        ),
      ),
      backgroundColor: Color(0xFFFFF3E2),
    );
  }
}

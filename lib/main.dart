import 'package:flutter/material.dart';
import 'package:pkconverter/text.dart';

void main(List<String> args) {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Converter',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const TestPage(),
    );
  }
}

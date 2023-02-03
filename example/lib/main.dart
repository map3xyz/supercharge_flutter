import 'package:supercharge_flutter/supercharge.dart';
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late SuperchargeMain superchargeMain;

  @override
  void initState() {
    super.initState();

    superchargeMain = SuperchargeMain(
      anonKey: 'ANON_KEY',
      userId: 'USER_ID',
      // optional parameters with their default values
      theme: 'light',
      locale: 'en',
    );

    superchargeMain.setMessage("Hello world");
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          toolbarHeight: 0,
        ),
        body: SuperchargeView(
          superchargeMain: superchargeMain,
        ),
      ),
    );
  }
}

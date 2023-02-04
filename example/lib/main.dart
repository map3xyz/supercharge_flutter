import 'package:flutter/material.dart';
import 'package:supercharge_flutter/supercharge.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late SuperchargeConfig superchargeMain;

  @override
  void initState() {
    super.initState();

    superchargeMain = SuperchargeConfig(
      anonKey: 'ANON_KEY',
      userId: 'USER_ID',
      getDepositAddress: (coin, network) async {
        return 'ADDRESS';
      },
      // optional parameters with their default values
      theme: 'light',
      locale: 'en',
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          toolbarHeight: 0,
        ),
        body: SuperchargeView(
          superchargeConfig: superchargeMain,
        ),
      ),
    );
  }
}

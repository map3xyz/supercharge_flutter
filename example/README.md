# Documentation

 * [Project README](../README.md)
 * [Map3 Supercharge Documentation](https://map3.xyz/docs/supercharge)
 * [Map3 Website](https://map3.xyz)
 * [Flutter](https://docs.flutter.dev/)

# Usage Example

```dart
import 'package:supercharge_flutter/supercharge.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late SuperchargeConfig superchargeConfig;

  @override
  void initState() {
    super.initState();

    superchargeConfig = SuperchargeConfig(
      anonKey: 'YOUR_MAP3_ANON_KEY',
      userId: 'YOUR_END_USER_ID',
      getDepositAddress: (coin, network) async {
        return 'ADDRESS'; // e.g. 0xab5801a7d398351b8be11c439e05c5b3259aec9b
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SuperchargeView(
          superchargeConfig: superchargeConfig,
        ),
      ),
    );
  }
}
```
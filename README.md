<h1 align='center'>💸 Supercharge Flutter</h1>

<div align='center'>The Map3 Supercharge Flutter SDK connects<br/>Android and iOS crypto apps to Wallets, Exchanges & Bridges,
enabling<br/>cross-chain deposits and increasing volumes.</div>
<br/>
<span>
[![pub](https://img.shields.io/pub/v/supercharge_flutter.svg)](https://pub.dev/packages/supercharge_flutter)
[![points](https://img.shields.io/pub/points/supercharge_flutter)](https://pub.dev/packages/supercharge_flutter)
[![popularity](https://img.shields.io/pub/popularity/supercharge_flutter)](https://pub.dev/packages/supercharge_flutter)
[![likes](https://img.shields.io/pub/likes/supercharge_flutter)](https://pub.dev/packages/supercharge_flutter)
</span>
<br/>
<div align="center">
<a href="https://map3.xyz/docs/supercharge">Documentation</a> 
<span> · </span>
<a href="https://map3.xyz/supercharge">Website</a> 
<span> · </span>
<a href="https://github.com/map3xyz/supercharge_flutter">GitHub</a> 
<span> · </span>
<a href="https://cal.com/amadeo-map3/discovery">Contact</a>
</div>
<br/>

## Requirements

### 1. Generate an Anon Key

Visit <https://console.map3.xyz> to generate `YOUR_ANON_KEY`.

### 2. Enable assets and networks

Visit <https://console.map3.xyz/config> and enable assets and networks.

## Installation

```shell
flutter pub add supercharge_flutter
```

## Configuration

```typescript Dart
    superchargeConfig = SuperchargeConfig(
      anonKey: 'YOUR_MAP3_ANON_KEY',
      userId: 'YOUR_END_USER_ID',
      getDepositAddress: (coin, network) async {
        return 'ADDRESS'; // e.g. 0xab5801a7d398351b8be11c439e05c5b3259aec9b
      },
    );
```

### Initialization

```typescript Dart
@override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          toolbarHeight: 0,
        ),
        body: SuperchargeView(
          superchargeConfig: superchargeConfig,
        ),
      ),
    );
  }
```

## Detailed example

You can check out a detailed example in the [example](https://github.com/map3xyz/supercharge_flutter/tree/master/example) folder

### Other links

- [Map3 Supercharge Flutter SDK package](https://pub.dev/packages/supercharge_flutter)
- [Flutter Docs](https://docs.flutter.dev/)
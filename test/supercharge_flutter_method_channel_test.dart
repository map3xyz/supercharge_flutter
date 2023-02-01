import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supercharge_flutter/supercharge_flutter_method_channel.dart';

void main() {
  MethodChannelSuperchargeFlutter platform = MethodChannelSuperchargeFlutter();
  const MethodChannel channel = MethodChannel('supercharge_flutter');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}

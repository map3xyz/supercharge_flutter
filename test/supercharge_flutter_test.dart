import 'package:flutter_test/flutter_test.dart';
import 'package:supercharge_flutter/supercharge_flutter.dart';
import 'package:supercharge_flutter/supercharge_flutter_platform_interface.dart';
import 'package:supercharge_flutter/supercharge_flutter_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockSuperchargeFlutterPlatform
    with MockPlatformInterfaceMixin
    implements SuperchargeFlutterPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final SuperchargeFlutterPlatform initialPlatform = SuperchargeFlutterPlatform.instance;

  test('$MethodChannelSuperchargeFlutter is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelSuperchargeFlutter>());
  });

  test('getPlatformVersion', () async {
    SuperchargeFlutter superchargeFlutterPlugin = SuperchargeFlutter();
    MockSuperchargeFlutterPlatform fakePlatform = MockSuperchargeFlutterPlatform();
    SuperchargeFlutterPlatform.instance = fakePlatform;

    expect(await superchargeFlutterPlugin.getPlatformVersion(), '42');
  });
}

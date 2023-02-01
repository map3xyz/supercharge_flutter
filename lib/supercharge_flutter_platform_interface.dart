import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'supercharge_flutter_method_channel.dart';

abstract class SuperchargeFlutterPlatform extends PlatformInterface {
  /// Constructs a SuperchargeFlutterPlatform.
  SuperchargeFlutterPlatform() : super(token: _token);

  static final Object _token = Object();

  static SuperchargeFlutterPlatform _instance = MethodChannelSuperchargeFlutter();

  /// The default instance of [SuperchargeFlutterPlatform] to use.
  ///
  /// Defaults to [MethodChannelSuperchargeFlutter].
  static SuperchargeFlutterPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [SuperchargeFlutterPlatform] when
  /// they register themselves.
  static set instance(SuperchargeFlutterPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}

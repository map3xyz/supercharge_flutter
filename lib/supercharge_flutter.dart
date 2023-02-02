import 'supercharge_flutter_platform_interface.dart';

class SuperchargeFlutter {
  Future<String?> getPlatformVersion() {
    return SuperchargeFlutterPlatform.instance.getPlatformVersion();
  }
}

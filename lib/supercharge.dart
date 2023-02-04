import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

const map3BaseUrl = 'https://map3.xyz';

const String kLocalExamplePage = '''
<!DOCTYPE html>
<html lang="en">
<head>
  <script src="https://api.map3.xyz/console/relay/gh/supercharge/master/dist/global/index.js"></script>
  <link href="https://api.map3.xyz/console/relay/gh/supercharge/master/dist/index.css" rel="stylesheet"></link>
  <style>
    html, body {
    font-size: 54px;
    }
  </style>
</head>
<body>
</body>
</html>
''';

/// The supercharge widget handles deposits and payments
class SuperchargeView extends StatefulWidget {
  /// Model with config
  final SuperchargeConfig superchargeConfig;

  /// Set to true to make the background of the InAppWebView transparent.
  /// If your app has a dark theme,
  /// this can prevent a white flash on initialization. The default value is false.
  final bool transparentBackground;
  @override
  State<SuperchargeView> createState() => _SuperchargeViewState();

  const SuperchargeView({
    super.key,
    required this.superchargeConfig,
    this.transparentBackground = false,
  });
}

class _SuperchargeViewState extends State<SuperchargeView> {
  InAppWebViewController? _webViewController;
  String? _javascriptString;

  late InAppWebViewGroupOptions _options;

  @override
  void initState() {
    super.initState();
    _options = InAppWebViewGroupOptions(
      crossPlatform: InAppWebViewOptions(
        transparentBackground: widget.transparentBackground,
        // Nice for local testing
        // clearCache: true,
        useShouldOverrideUrlLoading: true,
        supportZoom: false,
      ),
    );

    var superchargeConfig = widget.superchargeConfig;
    _javascriptString = '''
      async function getDepositAddress(coin, network) {
        return window.flutter_inappwebview.callHandler('getDepositAddress', coin, network);
      }

      const supercharge = initMap3Supercharge({
        anonKey: '${superchargeConfig.anonKey}',
        userId: '${superchargeConfig.userId}',
        theme: '${superchargeConfig.theme}',
        
        generateDepositAddress: async (coin, network) => {
          const depositAddress = await getDepositAddress(coin, network);

          return { address: depositAddress };
        },
      });
      supercharge.open();
      ''';
  }

  @override
  Widget build(BuildContext context) {
    return InAppWebView(
      initialUrlRequest: URLRequest(
        url: Uri.dataFromString(kLocalExamplePage,
            mimeType: 'text/html', encoding: Encoding.getByName('utf-8')!),
      ),
      // initialUrlRequest: URLRequest(
      //   url: Uri.parse(
      //       'https://map3.xyz/hosted/84f0c666-7f22-4d2f-900d-dc90707e6cb0'),
      // ),
      initialOptions: _options,
      onWebViewCreated: (InAppWebViewController controller) {
        _webViewController = controller;
        controller.addJavaScriptHandler(
            handlerName: 'getDepositAddress',
            callback: (args) {
              return widget.superchargeConfig
                  .getDepositAddress(args[0], args[1]);
            });
      },
      onLoadStop: (InAppWebViewController controller, Uri? url) async {
        _webViewController?.evaluateJavascript(source: _javascriptString!);
      },
      shouldOverrideUrlLoading: (controller, navigationAction) async {
        var uri = navigationAction.request.url;

        await launchUrl(uri!, mode: LaunchMode.externalApplication);
        return NavigationActionPolicy.CANCEL;
      },
    );
  }
}

/// The main model for the [SuperchargeView]
class SuperchargeConfig {
  SuperchargeConfig({
    required this.anonKey,
    required this.userId,
    required this.getDepositAddress,
    this.theme = 'light',
    this.locale = 'en',
  });

  /// Your anonKey from the Map3 console
  final String anonKey;

  /// A user identifier (like an email or UUID)
  String userId;

  /// A function that returns a deposit address for a given coin and network
  final Future<String> Function(dynamic coin, dynamic network)
      getDepositAddress;

  /// Theme for the supercharge SDK, defaults to 'light'
  String theme = 'light';

  /// Locale to define in which language the supercharge SDK should appear
  String locale = 'en';
}

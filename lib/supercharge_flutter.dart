import 'dart:collection';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

const map3BaseUrl = 'https://map3.xyz';

const String kLocalExamplePage = '''
<!DOCTYPE html>
<html lang="en">
<head>
  <script src="https://cdn.jsdelivr.net/gh/map3xyz/supercharge@1.19.5/dist/global/index.js"></script>
  <link href="https://cdn.jsdelivr.net/gh/map3xyz/supercharge@1.19.5/dist/index.css" rel="stylesheet"></link>
  <script>
    const initialize = () => {
      const supercharge = initMap3Supercharge({
        anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJjb25zb2xlIiwib3JnX2lkIjoiMDFkNTNmNzEtZTI5OS00NTIxLWE0NWItNmE4OTA5ZDNjMGQ1Iiwicm9sZXMiOlsiYW5vbnltb3VzIl0sImlhdCI6MTY2ODk4NjIwMywiZXhwIjoxNzAwNTIyMjAzfQ.xvLZT4ZbJyGkt6t2ga2hf-0ZwpG3ag07Gp9pCPL96J8',
        generateDepositAddress: async (coin, network) => {
          // generate a deposit address to display to the user
          // we'll call this callback function before displaying
          // an address or generating a payment for the user to sign.
            const depositAddress = await getDepositAddress(coin, network);

          return { address: depositAddress };
        },
        userId: '<YOUR_END_USER_ID>' // a user identifier (like an email or UUID)
      });
      supercharge.open()
    }

    document.addEventListener('DOMContentLoaded', initialize);
  </script>
  <style>
    html, body {
    font-size: 84px;
    }
  </style>
</head>
<body>
// <a href="javascript:initialize()">Open Supercharge</a><br>
// <a href="https://link.trustwallet.com/send?asset=c60_t0x6B175474E89094C44Da98b954EedeAC495271d0F&address=0x650b5e446edabad7eba7fa7bb2f6119b2630bfbb&amount=13&memo=test">Send 1 DAI to 0x650b5e446edabad7eba7fa7bb2f6119b2630bfbb</a><br>
// https://app.binance.com/payment/secpay?_dp=xxx=&linkToken=xxx
// https://app.binance.com/payment/secpay?linkToken=05511085ea4d404c9d69da5c69acdf66&_dp=Ym5jOi8vYXBwLmJpbmFuY2UuY29tL3BheW1lbnQvc2VjcGF5P3RlbXBUb2tlbj1RcjJJdDVuR2ROaDF4RmFMMG1CQUJsdnpoTG9wcUxxRiZyZXR1cm5MaW5rPWh0dHBzOi8vbGl0dGlvLmlvJmNhbmNlbExpbms9aHR0cHM6Ly9saXR0aW8uaW8
</body>
</html>
''';

String _superchargeEmbedUrl({
  required String websiteId,
  required String locale,
  String? userToken,
}) {
  String url = '$map3BaseUrl/static?website_id=$websiteId';

  url += '&locale=$locale';
  if (userToken != null) url += '&token_id=$userToken';

  return url;
}

/// The main widget handles deposits and payments
class SuperchargeView extends StatefulWidget {
  /// Model with main settings
  final SuperchargeMain superchargeMain;

  final void Function(String url)? onLinkPressed;

  ///Set to true to make the background of the InAppWebView transparent.
  ///If your app has a dark theme,
  ///this can prevent a white flash on initialization. The default value is false.
  final bool transparentBackground;
  @override
  _SuperchargeViewState createState() => _SuperchargeViewState();

  const SuperchargeView({
    super.key,
    required this.superchargeMain,
    this.onLinkPressed,
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
      android: AndroidInAppWebViewOptions(
        useHybridComposition: true,
        cacheMode: AndroidCacheMode.LOAD_CACHE_ELSE_NETWORK,
      ),
      ios: IOSInAppWebViewOptions(
        allowsInlineMediaPlayback: true,
      ),
    );

    _javascriptString = """
      var a = setInterval(function(){
        if (typeof \$supercharge !== 'undefined'){
          ${widget.superchargeMain.commands.join(';\n')}
          clearInterval(a);
        }
      },500)
      """;

    widget.superchargeMain.commands.clear();
  }

  @override
  Widget build(BuildContext context) {
    return InAppWebView(
      // initialUrlRequest: URLRequest(
      //   url: Uri.parse(_superchargeEmbedUrl(
      //     websiteId: widget.superchargeMain.websiteId,
      //     locale: widget.superchargeMain.locale,
      //     userToken: widget.superchargeMain.userToken,
      //   )),
      // ),
      initialUrlRequest: URLRequest(
        url: Uri.dataFromString(kLocalExamplePage,
            mimeType: 'text/html', encoding: Encoding.getByName('utf-8')!),
      ),
      initialOptions: _options,
      onWebViewCreated: (InAppWebViewController controller) {
        _webViewController = controller;
      },
      onLoadStop: (InAppWebViewController controller, Uri? url) async {
        _webViewController?.evaluateJavascript(source: _javascriptString!);
      },
      shouldOverrideUrlLoading: (controller, navigationAction) async {
        var uri = navigationAction.request.url;

        if (uri?.host != 'map3.xyz') {
          if ([
            "http",
            "https",
            "tel",
            "mailto",
            "file",
            "chrome",
            "data",
            "javascript",
          ].contains(uri?.scheme)) {
            if (await canLaunchUrl(uri!)) {
              if (widget.onLinkPressed != null) {
                widget.onLinkPressed!(uri.toString());
              } else {
                await launchUrl(uri);
              }
              return NavigationActionPolicy.CANCEL;
            }
          }
        }

        return NavigationActionPolicy.ALLOW;
      },
    );
  }
}

/// The main model for the [SuperchargeView]
class SuperchargeMain {
  SuperchargeMain({
    required this.websiteId,
    this.locale = 'en',
    this.userToken,
  });

  /// The customer website id
  final String websiteId;

  /// Locale to define in which language the supercharge SDK should appear
  String locale = 'en';

  /// The token of the user
  String? userToken;

  /// Commands which are defined on [register] and executed on [SuperchargeView] initState
  Queue commands = Queue<String>();

  setMessage(String text) {
    appendScript(
        "window.\$supercharge.push([\"set\", \"message:text\", [\"$text\"]])");
  }

  void appendScript(String script) {
    commands.add(script);
  }
}

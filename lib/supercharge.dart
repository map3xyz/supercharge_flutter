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
  <script src="https://api.map3.xyz/console/relay/gh/supercharge/master/dist/global/index.js"></script>
  <link href="https://api.map3.xyz/console/relay/gh/supercharge/master/dist/index.css" rel="stylesheet"></link>
  <script>
    const initialize = () => {
      const supercharge = initMap3Supercharge({
        anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJjb25zb2xlIiwib3JnX2lkIjoiMDFkNTNmNzEtZTI5OS00NTIxLWE0NWItNmE4OTA5ZDNjMGQ1Iiwicm9sZXMiOlsiYW5vbnltb3VzIl0sImlhdCI6MTY2ODk4NjIwMywiZXhwIjoxNzAwNTIyMjAzfQ.xvLZT4ZbJyGkt6t2ga2hf-0ZwpG3ag07Gp9pCPL96J8',
        generateDepositAddress: async (coin, network) => {
            const depositAddress = await getDepositAddress(coin, network);

          return { address: depositAddress };
        },
        userId: '<YOUR_END_USER_ID>' // a user identifier (like an email or UUID)
      });
      supercharge.open()
    }

    document.addEventListener('DOMContentLoaded', initialize);
    }
  </script>
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

  ///Set to true to make the background of the InAppWebView transparent.
  ///If your app has a dark theme,
  ///this can prevent a white flash on initialization. The default value is false.
  final bool transparentBackground;
  @override
  _SuperchargeViewState createState() => _SuperchargeViewState();

  const SuperchargeView({
    super.key,
    required this.superchargeMain,
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

        await launchUrl(uri!, mode: LaunchMode.externalApplication);
        return NavigationActionPolicy.CANCEL;
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

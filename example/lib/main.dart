import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() => runApp(const MaterialApp(home: WebViewExample()));

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
    font-size: 42px;
    }
  </style>
</head>
<body>
</body>
</html>
''';

class WebViewExample extends StatefulWidget {
  const WebViewExample({super.key});

  @override
  State<WebViewExample> createState() => _WebViewExampleState();
}

class _WebViewExampleState extends State<WebViewExample> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();

    const PlatformWebViewControllerCreationParams params =
        PlatformWebViewControllerCreationParams();

    final WebViewController controller =
        WebViewController.fromPlatformCreationParams(params);

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            debugPrint('WebView is loading (progress : $progress%)');
          },
          onPageStarted: (String url) {
            debugPrint('Page started loading: $url');
          },
          onPageFinished: (String url) {
            debugPrint('Page finished loading: $url');
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('''
Page resource error:
  code: ${error.errorCode}
  description: ${error.description}
  errorType: ${error.errorType}
  isForMainFrame: ${error.isForMainFrame}
          ''');
          },
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              debugPrint('blocking navigation to ${request.url}');
              return NavigationDecision.prevent;
            }
            debugPrint('allowing navigation to ${request.url}');
            return NavigationDecision.navigate;
          },
        ),
      )
      ..addJavaScriptChannel(
        'Toaster',
        onMessageReceived: (JavaScriptMessage message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message.message)),
          );
        },
      )
      ..loadRequest(Uri.dataFromString(kLocalExamplePage,
          mimeType: 'text/html', encoding: Encoding.getByName('utf-8')!));

    _controller = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter WebView example'),
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}

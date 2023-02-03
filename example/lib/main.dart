import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
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
// <a href="javascript:initialize()">Open Supercharge</a><br>
// <a href="https://link.trustwallet.com/send?asset=c60_t0x6B175474E89094C44Da98b954EedeAC495271d0F&address=0x650b5e446edabad7eba7fa7bb2f6119b2630bfbb&amount=13&memo=test">Send 1 DAI to 0x650b5e446edabad7eba7fa7bb2f6119b2630bfbb</a><br>
// https://app.binance.com/payment/secpay?_dp=xxx=&linkToken=xxx
// https://app.binance.com/payment/secpay?linkToken=05511085ea4d404c9d69da5c69acdf66&_dp=Ym5jOi8vYXBwLmJpbmFuY2UuY29tL3BheW1lbnQvc2VjcGF5P3RlbXBUb2tlbj1RcjJJdDVuR2ROaDF4RmFMMG1CQUJsdnpoTG9wcUxxRiZyZXR1cm5MaW5rPWh0dHBzOi8vbGl0dGlvLmlvJmNhbmNlbExpbms9aHR0cHM6Ly9saXR0aW8uaW8
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
          onNavigationRequest: (NavigationRequest request) async {
            if (request.url.startsWith('https://link.trustwallet.com') ||
                request.url.startsWith('https://app.binance.com')) {
              debugPrint('intercepting navigation to ${request.url}');

              await _launchUrl(request.url);
              return NavigationDecision.prevent;
            }

            debugPrint('no external navigation allowed to ${request.url}');
            return NavigationDecision.prevent;
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

  _launchUrl(String url) async {
    if (!await launchUrl(Uri.parse(url),
        mode: LaunchMode.externalApplication)) {
      debugPrint('could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map3WebView example'),
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}

import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

const map3BaseUrl = 'https://map3.xyz';

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
        anonKey: ${json.encode(superchargeConfig.anonKey)},
        userId: ${json.encode(superchargeConfig.userId)},
        theme: ${json.encode(superchargeConfig.theme)},
        locale: ${json.encode(superchargeConfig.locale)},
        paymentMethod: ${json.encode(superchargeConfig.paymentMethod)},
        assetId: ${json.encode(superchargeConfig.assetId)},
        networkCode: ${json.encode(superchargeConfig.networkCode)},
        address: ${json.encode(superchargeConfig.address)},
        fiat: ${json.encode(superchargeConfig.fiat)},
        amount: ${json.encode(superchargeConfig.amount)},
        appName: ${json.encode(superchargeConfig.appName)},
        colors: ${json.encode(superchargeConfig.colors)},

        generateDepositAddress: async (coin, network) => {
          const depositAddress = await getDepositAddress(coin, network);

          return { address: depositAddress };
        },

        authorizeTransaction: async (fromAddress, network, amount) => {
          return await window.flutter_inappwebview.callHandler('authorizeTransaction', fromAddress, network, amount);
        },

        onSuccess: async (txHash, networkCode, address) => {
          await window.flutter_inappwebview.callHandler('onSuccess', txHash, networkCode, address);
        },

        onFailure: async (error, networkCode, address) => {
          await window.flutter_inappwebview.callHandler('onFailure', error, networkCode, address);
        },
      });
      supercharge.open();
      ''';
  }

  @override
  Widget build(BuildContext context) {
    return InAppWebView(
      initialUrlRequest: URLRequest(
        url: Uri.parse(
            'https://map3.xyz/hosted/84f0c666-7f22-4d2f-900d-dc90707e6cb0'),
      ),
      // initialUrlRequest: URLRequest(
      //     url: Uri.parse(
      //         '$map3BaseUrl/hosted/${getOrgIdFromJwt(widget.superchargeConfig.anonKey)}')),
      initialOptions: _options,
      onWebViewCreated: (InAppWebViewController controller) {
        _webViewController = controller;

        if (widget.superchargeConfig.getDepositAddress != null) {
          controller.addJavaScriptHandler(
              handlerName: 'getDepositAddress',
              callback: (args) {
                return widget.superchargeConfig.getDepositAddress!(
                    args[0], args[1]);
              });
        }

        if (widget.superchargeConfig.authorizeTransaction != null) {
          controller.addJavaScriptHandler(
              handlerName: 'authorizeTransaction',
              callback: (args) {
                return widget.superchargeConfig.authorizeTransaction!(
                    args[0], args[1], args[2]);
              });
        }

        if (widget.superchargeConfig.onSuccess != null) {
          controller.addJavaScriptHandler(
              handlerName: 'onSuccess',
              callback: (args) {
                return widget.superchargeConfig.onSuccess!(
                    args[0], args[1], args[2]);
              });
        }

        if (widget.superchargeConfig.onFailure != null) {
          controller.addJavaScriptHandler(
              handlerName: 'onFailure',
              callback: (args) {
                return widget.superchargeConfig.onFailure!(
                    args[0], args[1], args[2]);
              });
        }
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

/// Config for the [SuperchargeView]
// See https://map3.xyz/docs/supercharge for more information
// Not needed in mobile context: embed, onClose
class SuperchargeConfig {
  /// Generated via the [console](https://console.map3.xyz/). Anon keys are public and can be safely used and exposed in a browser environment.
  /// They encode your organization ID and a role (anon). Anon key allows read access, but not write.
  final String anonKey;

  /// A user identifier (like an email or UUID)
  String userId;

  /// A function that returns a deposit address for a given coin and network, optional if paymentMethod=binance-pay
  final Future<String> Function(dynamic coin, dynamic network)?
      getDepositAddress;

  /// Theme for the supercharge SDK, defaults to 'light'
  String theme;

  /// Locale to define in which language the supercharge SDK should appear
  String locale;

  /// 'binance-pay' | 'show-address' - if not set, then getDepositAddress is required
  String? paymentMethod;

  // Either networkCode and address or just networkCode or just assetId or nothing (which means users selects)

  /// If you know the Map3 assetId (e.g [fe2bf2f8-3ddc-4ccc-8f34-8fdd9be03884](https://map3.xyz/network/polygon/0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174) USDC on Polygon) you can pass in the assetId and
  /// skip directly to payment method selection. If you have more questions about the Map3 assetId please review [Metadata Documentation](https://dash.readme.com/project/map3/v1.0/refs/getting-started-with-your-api).
  String? assetId;

  /// Pre-select a network
  String? networkCode;

  /// The address of the ERC-20 token for the user to deposit. Must be used with networkCode or defaults to undefined.
  String? address;

  /// Fiat currency for conversion, defaults to USD
  String? fiat;

  /// The amount of crypto in minor units you require the user to deposit.
  String? amount;

  /// Document title: shown when connecting to user's wallet via metamask or walletconnect
  String? appName;

  /// A function that returns a boolean if a transaction is authorized
  final Future<Bool> Function(
          dynamic fromAddress, dynamic network, dynamic amount)?
      authorizeTransaction;

  /// Colors for the supercharge SDK, e.g. {primary: '#ffffff', accent: '#000000'}
  Map<String, String>? colors;

  /// A function that is called when the payment succeeds
  final Future<void> Function(
      dynamic txHash, dynamic networkCode, dynamic address)? onSuccess;

  /// A function that is called when the payment fails
  final Future<void> Function(
      dynamic error, dynamic networkCode, dynamic address)? onFailure;

  SuperchargeConfig({
    required this.anonKey,
    required this.userId,
    this.getDepositAddress,
    this.theme = 'light',
    this.locale = 'en',
    this.paymentMethod,
    this.assetId,
    this.networkCode,
    this.address,
    this.fiat,
    this.amount,
    this.appName,
    this.authorizeTransaction,
    this.colors,
    this.onSuccess,
    this.onFailure,
  });
}

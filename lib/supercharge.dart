import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:supercharge_flutter/util/jwt.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

const map3BaseUrl = 'https://map3.xyz';

/// The supercharge widget handles deposits and payments
class SuperchargeView extends StatefulWidget {
  /// Model with config
  final SuperchargeConfig superchargeConfig;

  @override
  State<SuperchargeView> createState() => _SuperchargeViewState();

  const SuperchargeView({
    super.key,
    required this.superchargeConfig,
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
        transparentBackground: true,
        // Nice for local testing
        // clearCache: true,
        useShouldOverrideUrlLoading: true,
        supportZoom: false,
      ),
    );

    var superchargeConfig = widget.superchargeConfig;
    _javascriptString = '''
      async function handleAuthorizeTransaction(fromAddress, networkCode, amount) {
        return await window.flutter_inappwebview.callHandler('handleAuthorizeTransaction', fromAddress, networkCode, amount);
      }

      async function handleOrderFeeCalculation(asset, networkCode, amount) {
        return await window.flutter_inappwebview.callHandler('handleOrderFeeCalculation', asset, networkCode, amount);
      }

      async function onAddressRequested(asset, network) {
        return await window.flutter_inappwebview.callHandler('onAddressRequested', asset, network);
      }

      async function onFailure(error, networkCode, address) {
        return await window.flutter_inappwebview.callHandler('onFailure', error, networkCode, address);
      }

      async function onOrderCreated(orderId, type) {
        return await window.flutter_inappwebview.callHandler('onOrderCreated', orderId, type);
      }

      async function onSuccess(txHash, networkCode, address) {
        return await window.flutter_inappwebview.callHandler('onSuccess', txHash, networkCode, address);
      }

      const supercharge = initMap3Supercharge({
        anonKey: ${json.encode(superchargeConfig.anonKey)},
        userId: ${json.encode(superchargeConfig.userId)},
        options: {
          callbacks: {
            handleAuthorizeTransaction: handleAuthorizeTransaction,
            handleOrderFeeCalculation: handleOrderFeeCalculation,
            onAddressRequested: onAddressRequested,
            onFailure: onFailure,
            onOrderCreated: onOrderCreated,
            onSuccess: onSuccess,
          },
          selection: ${json.encode(superchargeConfig.options?.selection)},
          style: ${json.encode(superchargeConfig.options?.style)},
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
              '$map3BaseUrl/hosted/${getOrgIdFromJwt(widget.superchargeConfig.anonKey)}')),
      initialOptions: _options,
      onWebViewCreated: (InAppWebViewController controller) {
        _webViewController = controller;

        if (widget.superchargeConfig.options?.callbacks
                ?.handleAuthorizeTransaction !=
            null) {
          controller.addJavaScriptHandler(
              handlerName: 'handleAuthorizeTransaction',
              callback: (args) {
                return widget.superchargeConfig.options?.callbacks
                    ?.handleAuthorizeTransaction!(args[0], args[1], args[2]);
              });
        }

        if (widget.superchargeConfig.options?.callbacks
                ?.handleOrderFeeCalculation !=
            null) {
          controller.addJavaScriptHandler(
              handlerName: 'handleOrderFeeCalculation',
              callback: (args) {
                return widget.superchargeConfig.options?.callbacks
                    ?.handleOrderFeeCalculation!(args[0], args[1], args[2]);
              });
        }

        if (widget.superchargeConfig.options?.callbacks?.onAddressRequested !=
            null) {
          controller.addJavaScriptHandler(
              handlerName: 'onAddressRequested',
              callback: (args) {
                return widget.superchargeConfig.options!.callbacks!
                    .onAddressRequested!(args[0], args[1]);
              });
        }

        if (widget.superchargeConfig.options?.callbacks?.onFailure != null) {
          controller.addJavaScriptHandler(
              handlerName: 'onFailure',
              callback: (args) {
                return widget.superchargeConfig.options?.callbacks?.onFailure!(
                    args[0], args[1], args[2]);
              });
        }

        if (widget.superchargeConfig.options?.callbacks?.onOrderCreated !=
            null) {
          controller.addJavaScriptHandler(
              handlerName: 'onOrderCreated',
              callback: (args) {
                return widget.superchargeConfig.options?.callbacks
                    ?.onOrderCreated!(args[0], args[1]);
              });
        }

        if (widget.superchargeConfig.options?.callbacks?.onSuccess != null) {
          controller.addJavaScriptHandler(
              handlerName: 'onSuccess',
              callback: (args) {
                return widget.superchargeConfig.options?.callbacks?.onSuccess!(
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
/// Full Documentation: https://map3.xyz/docs/supercharge
class SuperchargeConfig {
  /// Generated via the [console](https://console.map3.xyz/). Anon keys are public and can be safely used and exposed in a browser environment.
  /// They encode your organization ID and a role (anon). Anon key allows read access, but not write.
  final String anonKey;

  /// A unique identifier for the active user. An email, uuid, or any other unique identifier is required.
  final String userId;

  /// Optional configuration for the supercharge SDK
  final SuperchargeConfigOptions? options;

  SuperchargeConfig({
    required this.anonKey,
    required this.userId,
    this.options,
  });
}

class SuperchargeConfigOptions {
  /// Callback functions: handleAuthorizeTransaction, handleOrderFeeCalculation, onAddressRequested, onFailure, onOrderCreated, onSuccess
  final SuperchargeConfigOptionsCallbacks? callbacks;

  /// Selection options: address, amount, assetId, fiat, networkCode, paymentMethod
  final SuperchargeConfigOptionsSelection? selection;

  /// Style options: appName, colors, locale, theme
  final SuperchargeConfigOptionsStyle? style;

  SuperchargeConfigOptions({
    this.callbacks,
    this.selection,
    this.style,
  });
}

class SuperchargeConfigOptionsCallbacks {
  /// An optional callback that gets called before the user is allowed to submit a transaction via their wallet.
  final Future<Bool> Function(
          String fromAddress, String networkCode, String amount)?
      handleAuthorizeTransaction;

  final Future<Map<String, dynamic>> Function(
          String asset, String networkCode, String amount)?
      handleOrderFeeCalculation;

  /// A function that returns a deposit address for a given coin and network, optional if paymentMethod=binance-pay
  final Future<Map<String, String>> Function(String asset, String network)?
      onAddressRequested;

  /// A function that is called when the payment fails
  final Future<void> Function(
      String error, String networkCode, String? address)? onFailure;

  /// Called once your end-user has confirmed intention to deposit via one of our merchant integrations.
  final Future<void> Function(String orderId, String type)? onOrderCreated;

  /// A function that is called when the payment succeeds
  final Future<void> Function(
      String txHash, String networkCode, String? address)? onSuccess;

  SuperchargeConfigOptionsCallbacks({
    this.handleAuthorizeTransaction,
    this.handleOrderFeeCalculation,
    this.onAddressRequested,
    this.onFailure,
    this.onOrderCreated,
    this.onSuccess,
  });
}

class SuperchargeConfigOptionsSelection {
  /// The address of the ERC-20 token for the user to deposit. Must be used with networkCode or defaults to undefined.
  final String? address;

  /// The amount of crypto in minor units you require the user to deposit.
  final String? amount;

  /// If you know the Map3 assetId (e.g [fe2bf2f8-3ddc-4ccc-8f34-8fdd9be03884](https://map3.xyz/network/polygon/0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174)
  /// USDC on Polygon) you can pass in the assetId and skip directly to payment method selection. If you have more questions about the Map3
  /// assetId please review [Metadata Documentation](https://dash.readme.com/project/map3/v1.0/refs/getting-started-with-your-api).
  final String? assetId;

  /// Fiat currency of your user's preference. Default value is USD.
  final String? fiat;

  /// If the user wants to deposit the native token (e.g Ether on Ethereum) you can pass in a networkCode to skip asset
  /// and network selection and jump directly to payment method selection.
  final String? networkCode;

  /// Pass in 'binance-pay' or 'show-address' payment methods to auto-select that method for your user.
  /// If not set, then the onAddressRequested callback is required.
  final String? paymentMethod;

  SuperchargeConfigOptionsSelection({
    this.address,
    this.amount,
    this.assetId,
    this.fiat = 'USD',
    this.networkCode,
    this.paymentMethod,
  });

  Map toJson() => {
        'address': address,
        'amount': amount,
        'assetId': assetId,
        'fiat': fiat,
        'networkCode': networkCode,
        'paymentMethod': paymentMethod,
      };
}

class SuperchargeConfigOptionsStyle {
  /// Document title: shown when connecting to user's wallet via metamask or walletconnect
  final String? appName;

  /// Change the primary and accent colors, e.g. {primary: '#ffffff', accent: '#000000'}
  final Map<String, String>? colors;

  /// Locale to define in which language the supercharge SDK should appear. Defaults to 'en'.
  final String? locale;

  /// 'light' or 'dark' mode is supported. 'light' by default.
  final String? theme;

  SuperchargeConfigOptionsStyle({
    this.appName,
    this.colors,
    this.locale = 'en',
    this.theme = 'light',
  });

  Map toJson() => {
        'appName': appName,
        'colors': colors,
        'locale': locale,
        'theme': theme,
      };
}

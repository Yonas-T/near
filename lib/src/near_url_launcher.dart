import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/platform_interface.dart';
import 'package:webview_flutter/webview_flutter.dart';

class NearUrlLauncher extends StatefulWidget {
  final String initialUrl;
  final dynamic requestTransactionOption;
  final dynamic walletBaseUrl;

  const NearUrlLauncher(
      {Key? key, required this.initialUrl, this.requestTransactionOption, this.walletBaseUrl})
      : super(key: key);

  @override
  _NearUrlLauncherState createState() => _NearUrlLauncherState();
}

class _NearUrlLauncherState extends State<NearUrlLauncher> {
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();
  final GlobalKey webViewKey = GlobalKey();
  InAppWebViewController? webViewController;
  InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
      crossPlatform: InAppWebViewOptions(
        useShouldOverrideUrlLoading: true,
        mediaPlaybackRequiresUserGesture: false,
      ),
      android: AndroidInAppWebViewOptions(
        useHybridComposition: true,
      ),
      ios: IOSInAppWebViewOptions(
        allowsInlineMediaPlayback: true,
      ));

  PullToRefreshController pullToRefreshController = PullToRefreshController();
  late ContextMenu contextMenu;
  String url = "";
  double progress = 0;
  final urlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // if (Platform.isAndroid) {
    //   WebView.platform = AndroidWebView();
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: InAppWebView(
        key: webViewKey,
        initialUrlRequest: URLRequest(url: Uri.parse(widget.initialUrl)),
        initialUserScripts: UnmodifiableListView<UserScript>([]),
        initialOptions: options,
        pullToRefreshController: pullToRefreshController,
        onWebViewCreated: (controller) {
          webViewController = controller;
        },
        onLoadStart: (controller, url) {
          setState(() {
            this.url = url.toString();
            urlController.text = this.url;
          });
        },
        androidOnPermissionRequest: (controller, origin, resources) async {
          return PermissionRequestResponse(
              resources: resources,
              action: PermissionRequestResponseAction.GRANT);
        },
        // shouldOverrideUrlLoading: (controller, navigationAction) async {
        //   var uri = navigationAction.request.url!;

        //   if (![
        //     "http",
        //     "https",
        //     "file",
        //     "chrome",
        //     "data",
        //     "javascript",
        //     "about"
        //   ].contains(uri.scheme)) {
        //     if (await canLaunch(url)) {
        //       // Launch the App
        //       await launch(
        //         url,
        //       );
        //       // and cancel the request
        //       return NavigationActionPolicy.CANCEL;
        //     }
        //   }

        //   return NavigationActionPolicy.ALLOW;
        // },
        onLoadStop: (controller, url) async {
          pullToRefreshController.endRefreshing();
          Map<String, dynamic> walletValue = {};
          // controller.webStorage.localStorage.clear();
          // SharedPreferences prefs = await SharedPreferences.getInstance();
          // prefs.clear();
          if (widget.requestTransactionOption != null) {
            var newUrl = widget.walletBaseUrl;
            Map<String, String> queryParams = {
              'transactions': widget.requestTransactionOption['transactions']
                  .map((transaction) => jsonEncode(transaction.toJson()))
                  .map((serialized) => base64.encode(serialized))
                  .join(','),
            };

            var queryString =
                Uri.parse(newUrl).replace(queryParameters: queryParams);

            // newUrl.searchParams.set('transactions', widget.requestTransactionOption['transactions']
            //     .map((transaction) => jsonEncode(transaction.toJson()))
            //     .map((serialized) => base64.encode(serialized))
            //     .join(','));

            webViewController!
                .loadUrl(urlRequest: URLRequest(url: queryString));
            var callBackQuery;
            callBackQuery = Uri.parse(newUrl).replace(queryParameters: {
              'callback': widget.requestTransactionOption['callbackUrl'] ??
                  widget.initialUrl,
            });
            if (widget.requestTransactionOption['meta'] != null) {
              callBackQuery = Uri.parse(newUrl).replace(queryParameters: {
                'meta': widget.requestTransactionOption['meta'],
              });
            }

            // newUrl.searchParams.set('callbackUrl', widget.requestTransactionOption['callbackUrl'] ?? widget.initialUrl);
            // if (widget.requestTransactionOption['meta'] != null)
            //   newUrl.searchParams
            //       .set('meta', widget.requestTransactionOption['meta']);
            webViewController!
                .loadUrl(urlRequest: URLRequest(url: callBackQuery));
            // window.location.assign(newUrl.toString());
          }

          controller.webStorage.localStorage
              .getItem(key: '_4:wallet:accounts_v2')
              .then((value) {
            walletValue = value;
            log(value.toString());

            var t = value != null ? walletValue.keys.toList() : [];
            var accountName = t.isNotEmpty ? t[0].split('.')[0] : [];

            controller.webStorage.localStorage
                .getItem(key: 'nearlib:keystore:$accountName.testnet:default')
                .then((value) async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              if (value != null) {
                prefs.setString('stored_key', value);
              }
              log(value.toString());
            });

            // print('oooooooooooooooooooooo' + t[0].split('.')[0]);
          });
// pact moment achieve giggle chapter involve dog cupboard army wonder salon sock
          controller.webStorage.localStorage.getItems().then((items) {
            log(items.toString());
          });
          setState(() {
            this.url = url.toString();
            urlController.text = this.url;
          });
        },
        onLoadError: (controller, url, code, message) {
          pullToRefreshController.endRefreshing();
        },
        onProgressChanged: (controller, progress) {
          if (progress == 100) {
            pullToRefreshController.endRefreshing();
          }
          setState(() {
            this.progress = progress / 100;
            urlController.text = this.url;
          });
        },
        onUpdateVisitedHistory: (controller, url, androidIsReload) {
          setState(() {
            this.url = url.toString();
            urlController.text = this.url;
          });
        },
        onConsoleMessage: (controller, consoleMessage) {
          controller.webStorage.localStorage.getItems().then((items) {
            log(items.toString());
          });
          print('======');
          print(consoleMessage);
        },
      ),
      // WebView(
      //       initialUrl: widget.initialUrl,
      //       javascriptMode: JavascriptMode.unrestricted,
      //       onWebViewCreated: (WebViewController webViewController) {
      //         _controller.complete(webViewController);
      //       },

      //       onProgress: (int progress) {
      //         print('WebView is loading (progress : $progress%)');
      //       },
      //      zoomEnabled: true,

      //       javascriptChannels: <JavascriptChannel>{
      //         _toasterJavascriptChannel(context),
      //       },
      //       navigationDelegate: (NavigationRequest request) {
      //         if (request.url.startsWith('https://www.youtube.com/')) {
      //           if (kDebugMode) {
      //             print('blocking navigation to $request}');
      //           }
      //           return NavigationDecision.prevent;
      //         }
      //         if (kDebugMode) {
      //           log('allowing navigation to $request');
      //         }
      //         return NavigationDecision.navigate;
      //       },
      //       onPageStarted: (String url) {
      //         if (kDebugMode) {
      //           print('Page started loading: $url');
      //         }
      //       },
      //       onPageFinished: (String url) {
      //         if (kDebugMode) {
      //           print('Page finished loading: $url');
      //         }

      //       },
      //       // gestureNavigationEnabled: true,
      //       backgroundColor: const Color(0x00000000),
      //     ),
    );
  }

  JavascriptChannel _toasterJavascriptChannel(BuildContext context) {
    return JavascriptChannel(
        name: 'ToasterNear',
        onMessageReceived: (JavascriptMessage message) {
          // ignore: deprecated_member_use
          Scaffold.of(context).showSnackBar(
            SnackBar(content: Text(message.message)),
          );
        });
  }
}

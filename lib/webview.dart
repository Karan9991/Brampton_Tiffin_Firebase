import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class MyInAppWebView extends StatefulWidget {
  @override
  _MyInAppWebViewState createState() => _MyInAppWebViewState();
}

class _MyInAppWebViewState extends State<MyInAppWebView> {
  InAppWebViewController? _webViewController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Brampton Tiffin'),
      ),
      body: WillPopScope(
        onWillPop: () async {
          if (await _webViewController?.canGoBack() ?? false) {
            _webViewController?.goBack();
            return false;
          }
          return true;
        },
        child: InAppWebView(
          initialUrlRequest: URLRequest(
              url: Uri.parse("http://bramptontiff.x10.mx/account/deleted")),
          initialOptions: InAppWebViewGroupOptions(
            crossPlatform: InAppWebViewOptions(
              javaScriptEnabled: true,
            ),
          ),
          onWebViewCreated: (controller) {
            _webViewController = controller;
          },
        ),
      ),
    );
  }
}

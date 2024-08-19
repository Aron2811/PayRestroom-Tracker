import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class StreetViewPage extends StatelessWidget {
  final LatLng location;

  const StreetViewPage({Key? key, required this.location}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final streetViewUrl = 'https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=${location.latitude},${location.longitude}';

    return Scaffold(
      appBar: AppBar(
        title: Text('Street View'),
        backgroundColor: Color.fromARGB(255, 115, 99, 183),
      ),
      body: WebView(
        initialUrl: streetViewUrl,
        javascriptMode: JavascriptMode.unrestricted,
        onWebViewCreated: (WebViewController webViewController) {
          webViewController.loadUrl(streetViewUrl);
        },
      ),
    );
  }
}
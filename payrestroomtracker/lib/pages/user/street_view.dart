import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class StreetViewPage extends StatefulWidget {
  final LatLng location;
  final String locationGuide;

  const StreetViewPage(
      {Key? key, required this.location, required this.locationGuide})
      : super(key: key);

  @override
  _StreetViewPageState createState() => _StreetViewPageState();
}

class _StreetViewPageState extends State<StreetViewPage> {
  late WebViewController _controller;
  final String streetViewUrlTemplate =
      'https://www.google.com/maps?layer=c&cbll=';

  @override
  Widget build(BuildContext context) {
    // Generates a Google Maps Street View URL for the given location
    final streetViewUrl =
        '$streetViewUrlTemplate${widget.location.latitude},${widget.location.longitude}';

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 149, 134, 225),
          centerTitle: true,
          title: const Text(
            'Street View',
            style: TextStyle(
              color: Colors.white,
              letterSpacing: 2,
              fontSize: 18,
            ),
          ),
        ),
        body: Stack(
          children: [
            WebView(
              initialUrl: streetViewUrl,
              javascriptMode: JavascriptMode.unrestricted,
              onWebViewCreated: (WebViewController webViewController) {
                _controller = webViewController;
              },
              navigationDelegate: (NavigationRequest request) {
                // Check if the URL contains the Google Maps "open app" redirect
                if (request.url.startsWith('intent://')) {
                  // Intercept the intent scheme and reload the Street View URL
                  _controller.loadUrl(streetViewUrl);
                  return NavigationDecision.prevent;
                } else if (request.url.contains('maps/about')) {
                  // Intercept and reload the Street View URL
                  _controller.loadUrl(streetViewUrl);
                  return NavigationDecision.prevent;
                }
                return NavigationDecision.navigate;
              },
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: FractionallySizedBox(
                widthFactor: 5,
                child: Container(
                  height: 46,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 149, 134, 225),
                    borderRadius: BorderRadius.circular(0),
                    border: Border.all(
                      color: const Color.fromARGB(111, 255, 255, 255),
                      width: 2,
                    ),
                  ),
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      widget.locationGuide,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

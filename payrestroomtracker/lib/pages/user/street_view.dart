import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class StreetViewPage extends StatelessWidget {
  final LatLng location;
  final String locationGuide;

  const StreetViewPage(
      {Key? key, required this.location, required this.locationGuide})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Generates a Google Maps Street View URL for the given location
    final streetViewUrl =
        'https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=${location.latitude},${location.longitude}';

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar( // AppBar configuration for the Street View page
          backgroundColor: Color.fromARGB(255, 149, 134, 225),
          centerTitle: true,
          title: Text(
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
            WebView(  // Displays a WebView with Google Maps Street View for the specified URL
              initialUrl: streetViewUrl,
              javascriptMode: JavascriptMode.unrestricted,
              onWebViewCreated: (WebViewController webViewController) {
                webViewController.loadUrl(streetViewUrl);
              },
            ),
            Positioned(
              top: 0, // Adjust the position as needed
              left: 0,
              right: 0,
              child: FractionallySizedBox(
                widthFactor: 5, // Adjust the factor for different widths
                child: Container(
                  height: 46,
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 149, 134, 225),
                    borderRadius: BorderRadius.circular(0), // Optional rounded corners
                    border: Border.all(
                      color: const Color.fromARGB(111, 255, 255, 255),
                      width: 2,
                    ),
                  ),
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      locationGuide,
                      textAlign: TextAlign.center,
                      style: TextStyle(
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
import 'package:another_carousel_pro/another_carousel_pro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_button/pages/dialog/admin_edit_info.dart';
import 'package:full_screen_image/full_screen_image.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminTagInformation extends StatefulWidget {
  final MarkerId markerId;
  final Future<void> Function(MarkerId) deleteMarker;

  const AdminTagInformation({
    Key? key,
    required this.markerId,
    required this.deleteMarker,
  }) : super(key: key);

  @override
  _AdminTagInformationState createState() => _AdminTagInformationState();
}

class _AdminTagInformationState extends State<AdminTagInformation> {
  List<String> imageUrls = [];

  @override
  void initState() {
    super.initState();
    fetchImageUrls();
  }

Future<void> fetchImageUrls() async {
  try {
    DocumentSnapshot tagSnapshot = await FirebaseFirestore.instance
        .collection('Tags')
        .doc(widget.markerId.value)
        .get();

    if (tagSnapshot.exists) {
      // Explicitly cast data() to Map<String, dynamic>
      Map<String, dynamic>? data = tagSnapshot.data() as Map<String, dynamic>?;

      // Check if 'ImageUrls' field exists
      if (data != null && data.containsKey('ImageUrls')) {
        List<dynamic> urls = data['ImageUrls'];
        // Process the URLs as needed
        print('Image URLs: $urls');
      } else {
        print('ImageUrls field does not exist in the document');
        // Handle case where ImageUrls field is missing
      }
    } else {
      print('Document does not exist');
      // Handle case where document doesn't exist
    }
  } catch (e) {
    print('Error fetching image URLs: $e');
    // Handle error appropriately
  }
}



  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
      actions: [
        SizedBox(height: 30),
        TextField(
          textAlign: TextAlign.center,
          enabled: false,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: 'Paid Restroom Name',
            hintStyle: TextStyle(
              fontSize: 20,
              color: Color.fromARGB(255, 115, 99, 183),
            ),
          ),
        ),
        SizedBox(height: 2),
        TextField(
          textAlign: TextAlign.center,
          enabled: false,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: 'Location',
            hintStyle: TextStyle(
              fontSize: 17,
              color: Color.fromARGB(255, 115, 99, 183),
            ),
          ),
        ),
        SizedBox(height: 2),
        TextField(
          textAlign: TextAlign.center,
          enabled: false,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: 'Cost',
            hintStyle: TextStyle(
              fontSize: 17,
              color: Color.fromARGB(255, 115, 99, 183),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Column(
          children: [
            FullScreenWidget(
                disposeLevel: DisposeLevel.High,
                child: Center(
                    child: SizedBox(
                  height: 250,
                  width: 300,
                  child: AnotherCarousel(
                    borderRadius: true,
                    boxFit: BoxFit.cover,
                    radius: Radius.circular(10),
                    images: imageUrls.map((url) => NetworkImage(url)).toList(),
                    showIndicator: false,
                  ),
                ))),
          ],
        ),
        SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              onPressed: () {
                Navigator.of(context).pop(true);
                showDialog(
                    context: context,
                    builder: (context) =>
                        ChangeInfoDialog(markerId: widget.markerId));
              },
              icon: Icon(Icons.edit_location_alt_outlined),
              color: Color.fromARGB(255, 115, 99, 183),
              iconSize: 30,
            ),
            IconButton(
              onPressed: () {
                Navigator.of(context).pop(true);
                widget.deleteMarker(widget.markerId);
              },
              icon: Icon(Icons.remove_circle_outline_rounded),
              color: Color.fromARGB(255, 115, 99, 183),
              iconSize: 30,
            ),
          ],
        ),
      ],
    );
  }
}

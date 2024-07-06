import 'package:flutter/material.dart';
import 'package:another_carousel_pro/another_carousel_pro.dart';
import 'package:full_screen_image/full_screen_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ChangeInfoDialog extends StatefulWidget {
  final MarkerId markerId;

  const ChangeInfoDialog({
    Key? key,
    required this.markerId,
  }) : super(key: key);

  @override
  State<ChangeInfoDialog> createState() => _ChangeInfoDialogState();
}

class _ChangeInfoDialogState extends State<ChangeInfoDialog> {
  List<String> imageUrls = [];

  @override
  void initState() {
    super.initState();
    fetchImageUrls();
  }

  Future<void> fetchImageUrls() async {
    DocumentSnapshot tagSnapshot = await FirebaseFirestore.instance
        .collection('Tags')
        .doc(widget.markerId.value)
        .get();

    if (tagSnapshot.exists) {
      List<dynamic> urls = tagSnapshot.get('ImageUrls') ?? [];
      setState(() {
        imageUrls = List<String>.from(urls);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(actions: [
      const SizedBox(
        height: 30,
      ),
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.0),
        child: Text(
          "Update Paid Restroom Information",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 97, 84, 158),
          ),
        ),
      ),
      SizedBox(
        height: 10,
      ),
      const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.0),
          child: TextField(
            minLines: 1,
            maxLines: 3,
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              labelText: 'Paid Restroom Name',
              enabledBorder: UnderlineInputBorder(
                borderSide:
                    BorderSide(color: Color.fromARGB(255, 115, 99, 183)),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide:
                    BorderSide(color: Color.fromARGB(255, 115, 99, 183)),
              ),
              labelStyle: TextStyle(
                fontSize: 15,
                color: Color.fromARGB(255, 115, 99, 183),
              ),
              floatingLabelStyle: TextStyle(
                  fontSize: 15, color: Color.fromARGB(255, 115, 99, 183)
                  // Change this color to the desired color,
                  ),
              fillColor: Colors.white10,
              filled: true,
            ),
          )),
      const SizedBox(height: 10),
      const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.0),
          child: TextField(
            minLines: 1,
            maxLines: 3,
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              labelText: 'Location',
              enabledBorder: UnderlineInputBorder(
                borderSide:
                    BorderSide(color: Color.fromARGB(255, 115, 99, 183)),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide:
                    BorderSide(color: Color.fromARGB(255, 115, 99, 183)),
              ),
              labelStyle: TextStyle(
                fontSize: 15,
                color: Color.fromARGB(255, 115, 99, 183),
              ),
              floatingLabelStyle: TextStyle(
                  fontSize: 15, color: Color.fromARGB(255, 115, 99, 183)
                  // Change this color to the desired color,
                  ),
              fillColor: Colors.white10,
              filled: true,
            ),
          )),
      const SizedBox(height: 10),
      const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.0),
          child: TextField(
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              labelText: 'Cost',
              enabledBorder: UnderlineInputBorder(
                borderSide:
                    BorderSide(color: Color.fromARGB(255, 115, 99, 183)),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide:
                    BorderSide(color: Color.fromARGB(255, 115, 99, 183)),
              ),
              labelStyle: TextStyle(
                fontSize: 15,
                color: Color.fromARGB(255, 115, 99, 183),
              ),
              floatingLabelStyle: TextStyle(
                  fontSize: 15, color: Color.fromARGB(255, 115, 99, 183)
                  // Change this color to the desired color,
                  ),
              fillColor: Colors.white10,
              filled: true,
            ),
          )),
      const SizedBox(height: 15),
      Column(
        children: imageUrls.map((url) {
          return Dismissible(
              key: Key(url), // Provide a unique key
              direction:
                  DismissDirection.down, // Set the direction of dismissal
              onDismissed: (direction) {
                setState(() {
                  imageUrls.remove(url);
                });
              },
              child: FullScreenWidget(
                  disposeLevel: DisposeLevel.High,
                  child: Center(
                      child: SizedBox(
                    height: 250,
                    width: 300,
                    child: AnotherCarousel(
                      borderRadius: true,
                      boxFit: BoxFit.cover,
                      radius: Radius.circular(10),
                      images:
                          imageUrls.map((url) => NetworkImage(url)).toList(),
                      showIndicator: false,
                    ),
                  ))));
        }).toList(),
      ),
      const SizedBox(height: 15),
      Align(
          alignment: Alignment.center,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
                enableFeedback: false,
                backgroundColor: Colors.white,
                minimumSize: const Size(100, 40),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50)),
                side: BorderSide(
                  color:
                      Color.fromARGB(255, 149, 134, 225), //Set the border color
                  width: 2.0,
                ),
                textStyle: const TextStyle(fontSize: 16)),
            onPressed: () {},
            icon: Icon(Icons.upload_rounded,
                color: Color.fromARGB(255, 149, 134, 225)),
            label: const Text("Upload"),
          )),
      const SizedBox(height: 15),
      Align(
          alignment: Alignment.center,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              enableFeedback: false,
              backgroundColor: Colors.white,
              minimumSize: const Size(150, 40),
              alignment: Alignment.center,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
                side: const BorderSide(
                  color: Color.fromARGB(
                      255, 149, 134, 225), // Set the border color
                  width: 2.0, // Set the border width
                ),
              ),
              foregroundColor: Color.fromARGB(255, 149, 134, 225),
              textStyle:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            child: const Text(
              "Confirm",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ))
    ]);
  }
}

import 'package:flutter/material.dart';
import 'package:custom_rating_bar/custom_rating_bar.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PaidRestroomRecommendationList extends StatelessWidget {
  final Function(LatLng, String) drawRouteToDestination;
  final LatLng destination;
  final Function toggleVisibility;

  const PaidRestroomRecommendationList(
      {super.key,
      required this.drawRouteToDestination,
      required this.destination,
      required this.toggleVisibility});

  @override
  Widget build(BuildContext context) {
    return InkWell(
        child: Container(
          padding: const EdgeInsets.only(left: 20, right: 30),
          child: Column(
            children: [
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      const Text(
                        "Paid Restroom Name",
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        "Location",
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontSize: 17,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "3.1",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 17,
                                color: Colors.white,
                              ),
                            ),
                            RatingBar(
                              size: 20,
                              alignment: Alignment.center,
                              filledIcon: Icons.star,
                              emptyIcon: Icons.star_border,
                              emptyColor: Colors.white24,
                              filledColor:
                                  const Color.fromARGB(255, 85, 70, 152),
                              halfFilledColor:
                                  const Color.fromARGB(255, 186, 176, 228),
                              onRatingChanged: (value) => debugPrint(''),
                              // onRatingChanged: (value) => debugPrint('$value'),
                              initialRating: 3,
                              maxRating: 5,
                            )
                          ]),
                    ],
                  ),
                  const SizedBox(width: 65),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      enableFeedback: false,
                      backgroundColor: Colors.white,
                      minimumSize: const Size(60, 60),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100)),
                    ),
                    onPressed: () {
                      toggleVisibility();
                      drawRouteToDestination(destination, 'commute');
                      Navigator.pop(context);
                    },
                    child: const Icon(Icons.directions,
                        color: Color.fromARGB(255, 85, 70, 152)),
                  ),
                ],
              ),
              const Divider(),
            ],
          ),
        ),
        onTap: () {
          //scratch
          showDialog(
              context: context,
              builder: (context) => const AlertDialog(
                      actionsAlignment: MainAxisAlignment.center,
                      actions: [
                        SizedBox(height: 20),
                        Text(
                          "Paid Restroom Information",
                          textAlign: TextAlign.justify,
                          style: TextStyle(
                            fontSize: 17,
                            color: Color.fromARGB(255, 115, 99, 183),
                          ),
                        ),
                      ]));
        });
  }
}

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_button/pages/bottomsheet/paidrestroom_info.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class SamplePaidRestroomRecommendationList extends StatefulWidget {
  const SamplePaidRestroomRecommendationList({
    super.key,
  });

  @override
  _SamplePaidRestroomRecommendationListState createState() =>
      _SamplePaidRestroomRecommendationListState();
}

class _SamplePaidRestroomRecommendationListState
    extends State<SamplePaidRestroomRecommendationList> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        padding: const EdgeInsets.only(left: 20, right: 20),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      Text(
                        "Sample PaidRestroom Name",
                        maxLines: 3,
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontSize: 18,
                          color: Color.fromARGB(255, 64, 55, 107),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "Sample Location Guide",
                        maxLines: 3,
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "Sample Guide",
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              '0.0',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                            RatingBarIndicator(
                              rating: 0.0,
                              itemBuilder: (context, index) => Icon(
                                Icons.star,
                                color: const Color.fromARGB(255, 97, 84, 158),
                              ),
                              itemCount: 5,
                              itemSize: 18.0,
                              unratedColor: Colors.white24,
                              direction: Axis.horizontal,
                            ),
                          ]),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(2.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      enableFeedback: false,
                      backgroundColor: Colors.white,
                      minimumSize: const Size(60, 60),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                    onPressed: () {
                    
                      Navigator.pop(context);
                    },
                    child: const Icon(
                      Icons.directions,
                      color: Color.fromARGB(255, 85, 70, 152),
                    ),
                  ),
                ),
              ],
            ),
            const Divider(),
          ],
        ),
      ),
      onTap: () {
        
      },
    );
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:custom_rating_bar/custom_rating_bar.dart' as custom_rating_bar;
import 'package:another_carousel_pro/another_carousel_pro.dart';

import 'package:flutter_button/pages/bottomsheet/draggablesheet.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class SamplePaidRestroomInfo extends StatefulWidget {
  final Function toggleVisibility;
  final GlobalKey directionKey;
  final GlobalKey reportKey;

  

  const SamplePaidRestroomInfo({
    Key? key,
    required this.toggleVisibility,
    required this.directionKey,
    required this.reportKey,
  }) : super(key: key);

  @override
  _SamplePaidRestroomInfoState createState() => _SamplePaidRestroomInfoState();
}

class _SamplePaidRestroomInfoState extends State<SamplePaidRestroomInfo> {
  @override
  void initState() {
    super.initState();
  }

  Widget build(BuildContext context) {
    return MyDraggableSheet(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Padding(
            padding: EdgeInsets.only(left: 10, right: 10),
            child: Text(
              "Sample Paid Restroom Name",
              maxLines: 3,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                color: Color.fromARGB(255, 64, 55, 107),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: EdgeInsets.only(left: 20, right: 20),
            child: Text(
              "Sample Paid Restroom Location Guide",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Sample Paid Restroom Cost",
            textAlign: TextAlign.start,
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '0.0',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 5),
              RatingBarIndicator(
                rating: 0.0,
                itemBuilder: (context, index) => Icon(
                  Icons.star,
                  color: const Color.fromARGB(255, 97, 84, 158),
                ),
                itemCount: 5,
                itemSize: 20.0,
                unratedColor: Colors.white24,
                direction: Axis.horizontal,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  key: widget.directionKey,
                  style: ElevatedButton.styleFrom(
                    enableFeedback: false,
                    backgroundColor: const Color.fromARGB(255, 226, 223, 229),
                    minimumSize: const Size(150, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    side: const BorderSide(
                      color: Color.fromARGB(255, 97, 84, 158),
                      width: 2.0,
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context); // Close bottom sheet
                    widget.toggleVisibility();
                  },
                  label: const Text(
                    'Directions',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  icon: const Icon(
                    Icons.directions,
                    color: Color.fromARGB(255, 97, 84, 158),
                  ),
                ),
                const SizedBox(width: 20),
                ElevatedButton.icon(
                  key: widget.reportKey,
                  style: ElevatedButton.styleFrom(
                    enableFeedback: false,
                    backgroundColor: const Color.fromARGB(255, 226, 223, 229),
                    minimumSize: const Size(130, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    side: const BorderSide(
                      color: Color.fromARGB(255, 97, 84, 158),
                      width: 2.0,
                    ),
                  ),
                  onPressed: () {
                  },
                  label: const Text(
                    'Report',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  icon: const Icon(
                    Icons.report_problem_outlined,
                    color: Color.fromARGB(255, 97, 84, 158),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          SizedBox(
                  height: 250,
                  width: 300,
                  child: AnotherCarousel(
                    borderRadius: true,
                    boxFit: BoxFit.cover,
                    radius: const Radius.circular(10),
                    images: [],
                        
                    showIndicator: false,
                  ),
                ),
              
            
          
          const SizedBox(height: 30),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(width: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  enableFeedback: false,
                  backgroundColor: const Color.fromARGB(255, 148, 139, 192),
                  minimumSize: const Size(250, 45),
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(
                      color: Color.fromARGB(255, 115, 99, 183),
                      width: 2.0,
                    ),
                  ),
                ),
                onPressed: () {
                  
                },
                label: const Text(
                  'Add a Review',
                  style: TextStyle(
                      fontSize: 17, color: Colors.white, letterSpacing: 3),
                ),
                icon: const Icon(
                  Icons.person_2_rounded,
                  color: Color.fromARGB(255, 97, 84, 158),
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                child: const Text(
                  "View All Reviews",
                  style: TextStyle(
                    fontSize: 17,
                    color: Color.fromARGB(255, 97, 84, 158),
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                onTap: () {
                 
                  
                },
              ),
              const SizedBox(height: 20),
              const Text(
                "Share your experience to help others",
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(width: 15),
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage(
                      FirebaseAuth.instance.currentUser?.photoURL ?? '',
                    ),
                  ),
                  const SizedBox(width: 10),
                 custom_rating_bar.RatingBar(
                          size: 30,
                          alignment: Alignment.center,
                          filledIcon: Icons.star,
                          emptyIcon: Icons.star_border,
                          emptyColor: Colors.white24,
                          filledColor: const Color.fromARGB(255, 97, 84, 158),
                          halfFilledColor:
                              const Color.fromARGB(255, 186, 176, 228),
                          onRatingChanged: (p0) {
                            
                          },
                          initialRating: 0.0,
                          maxRating: 5,
                        ),
                      
                    
                ]
                
              ),
              SizedBox(height: 20),
            ],
          ),
        ],
      ),
    );
  }
}

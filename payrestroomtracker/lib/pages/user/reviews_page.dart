import 'package:custom_rating_bar/custom_rating_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:readmore/readmore.dart';

class ReviewsPage extends StatefulWidget {
  @override
  State<ReviewsPage> createState() => _ReviewsPageState();
}

class _ReviewsPageState extends State<ReviewsPage> {
  List<int> _reviews = List<int>.generate(10, (int index) => index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          color: Colors.white,
          onPressed: () {
            Navigator.pushNamed(context, '/mappage');
          },
        ),
        title: const Text(
          'Reviews',
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 97, 84, 158),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
                itemCount: _reviews.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(children: [
                      Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundImage: NetworkImage(
                                  FirebaseAuth.instance.currentUser?.photoURL ??
                                      ''),
                            ),
                            const SizedBox(width: 20),
                            const Text(
                              "Username",
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                fontSize: 17,
                                color: Color.fromARGB(255, 97, 84, 158),
                              ),
                            ),
                          ]),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          RatingBar.readOnly(
                            size: 20,
                            alignment: Alignment.center,
                            filledIcon: Icons.star,
                            emptyIcon: Icons.star_border,
                            emptyColor: Colors.grey,
                            filledColor: const Color.fromARGB(255, 97, 84, 158),
                            halfFilledColor:
                                const Color.fromARGB(255, 186, 176, 228),
                            initialRating:
                                0.0, // Update this to snapshot.data if needed
                            maxRating: 5,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            "07 July, 2024",
                            style: Theme.of(context).textTheme.bodyMedium,
                          )
                        ],
                      ),
                      SizedBox(height: 10),
                      ReadMoreText(
                        "Please, please, please Don't prove I'm right And please, please, please Don't bring me to tears when I just did my makeup so nice Heartbreak is one thing My ego's another I beg you: Don't embarrass me, motherfucker, ah-oh Please, please, please (ah-ah-ah)",
                        textAlign: TextAlign.justify,
                        trimLines: 2,
                        trimMode: TrimMode.Line,
                        trimExpandedText: ' Show less',
                        moreStyle: TextStyle(
                          color: const Color.fromARGB(255, 97, 84, 158),
                          fontWeight: FontWeight.bold,
                        ),
                        trimCollapsedText: ' Show more',
                        lessStyle: TextStyle(
                            color: const Color.fromARGB(255, 97, 84, 158),
                            fontWeight: FontWeight.bold),
                      ),
                    ]),
                  );
                }),
          ),
        ],
      ),
    );
  }
}

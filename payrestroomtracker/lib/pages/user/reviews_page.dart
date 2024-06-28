import 'package:flutter/material.dart';

class ReviewsPage extends StatelessWidget {
  final List _reviews = [
    'reviews 1',
    'reviews 2',
    'reviews 3',
    'reviews 4',
    'reviews 5',
    'reviews 6',
    'reviews 7',
    'reviews 8',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            Navigator.pushNamed(context, '/mappage');
          },
        ),
        title: const Text(
          'Reviews',
          style: TextStyle(fontSize: 20, color: Colors.white, letterSpacing: 4),
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
                  return AllReviews(child: _reviews[index]);
                }),
          ),
        ],
      ),
    );
  }
}

class AllReviews extends StatelessWidget {
  AllReviews({required this.child});

  final String child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        height: 150,
        color: Colors.deepPurple[100],
        child: Row(children: [
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const SizedBox(width: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(70),
              child: Container(
                child: const Icon(
                  Icons.person_2_rounded,
                  color: Color.fromARGB(255, 97, 84, 158),
                  size: 30,
                ),
                color: Colors.white,
                height: 40,
                width: 40,
              ),
            ),
            const SizedBox(width: 20),
            Column(
              children: [
                const SizedBox(height: 50),
                const Text(
                  "Username",
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontSize: 17,
                    color: Color.fromARGB(255, 97, 84, 158),
                  ),
                ),
                const SizedBox(height: 3),
                const Text(
                  "Reviews",
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontSize: 17,
                    color: Color.fromARGB(255, 97, 84, 158),
                  ),
                ),
                const SizedBox(height: 3),
                const Text(
                  "Reviews",
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontSize: 17,
                    color: Color.fromARGB(255, 97, 84, 158),
                  ),
                ),
              ],
            ),
          ]),
        ]),
      ),
    );
  }
}

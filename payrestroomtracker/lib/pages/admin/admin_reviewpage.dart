import 'package:custom_rating_bar/custom_rating_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_button/pages/admin/adminMap.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:readmore/readmore.dart';

class AdminReviewsPage extends StatefulWidget {
  @override
  State<AdminReviewsPage> createState() => _AdminReviewsPageState();
}

class _AdminReviewsPageState extends State<AdminReviewsPage> {
  List<int> _reviews = List<int>.generate(10, (int index) => index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          color: Colors.white,
          onPressed: () {
            Navigator.push(context, _createRoute(AdminMap(username: "")));
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
                return Slidable(
                  endActionPane: ActionPane(
                    motion: const BehindMotion(),
                    children: [
                      SlidableAction(
                        foregroundColor:
                            const Color.fromARGB(255, 255, 255, 255),
                        backgroundColor:
                            const Color.fromARGB(255, 162, 151, 211),
                        icon: Icons.delete_outline_rounded,
                        onPressed: (context) {
                          _showDeleteDialog(index);
                        },
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
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
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            RatingBar.readOnly(
                              size: 20,
                              alignment: Alignment.center,
                              filledIcon: Icons.star,
                              emptyIcon: Icons.star_border,
                              emptyColor: Colors.grey,
                              filledColor:
                                  const Color.fromARGB(255, 97, 84, 158),
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
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
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
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          "Are you sure you want to delete this review?",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color.fromARGB(255, 115, 99, 183),
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _reviews.removeAt(index);
              });
              Navigator.of(context).pop(true);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Review has been deleted'),
                  backgroundColor: Color.fromARGB(255, 115, 99, 183),
                ),
              );
            },
            child: const Text("Yes"),
          ),
        ],
      ),
    );
  }

  Route _createRoute(Widget child) {
    return PageRouteBuilder(
      pageBuilder: (BuildContext context, Animation<double> animation,
              Animation<double> secondaryAnimation) =>
          child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        var offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
  }
}

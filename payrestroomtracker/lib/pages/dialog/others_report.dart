import 'package:flutter/material.dart';
import 'package:flutter_button/pages/user/report_page.dart';

class OthersReportDialog extends StatelessWidget {
  const OthersReportDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(actions: [
      Center(
          child: Column(
        children: [
          SizedBox(
            height: 20,
          ),
          Icon(Icons.check_circle_rounded,
              color: Color.fromARGB(255, 97, 84, 158), size: 50),
          SizedBox(
            height: 30,
          ),
          Text(
            "You Selected",
            style: TextStyle(
                color: Color.fromARGB(255, 97, 84, 158),
                fontSize: 17,
                fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 10,
          ),
          Text("Others report",
              style: TextStyle(
                  color: Color.fromARGB(255, 97, 84, 158),
                  fontSize: 17,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.justify),
          SizedBox(
            height: 10,
          ),
          Text(
            "We use your feedback to help our systems learn when something isn't right",
            style: TextStyle(
                color: Color.fromARGB(255, 97, 84, 158), fontSize: 17),
            textAlign: TextAlign.justify,
          ),
          SizedBox(
            height: 20,
          ),
          RichText(
              textAlign: TextAlign.justify,
              text: TextSpan(
                  style: TextStyle(
                      color: Color.fromARGB(255, 97, 84, 158), fontSize: 13),
                  children: <TextSpan>[
                    TextSpan(
                      text: 'Note: ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text:
                          'We may inform the Paid Restroom to address this report',
                    )
                  ])),
          SizedBox(
            height: 20,
          ),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50.0),
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
                  foregroundColor: Color.fromARGB(255, 135, 125, 186),
                  textStyle: const TextStyle(
                    fontSize: 16,
                  ),
                ),
                child: const Text(
                  "Confirm",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                   Navigator.push(context, _createRoute(ReportPage()));

                },
              ))
        ],
      ))
    ]);
  }
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

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      });
}
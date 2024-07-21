import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_button/firebase_options.dart';
import 'package:flutter_button/pages/admin/adminMap.dart';
import 'package:flutter_button/pages/loading_page.dart';
import 'package:flutter_button/pages/intro_page.dart';
import 'package:flutter_button/pages/user/map_page.dart';
import 'package:flutter_button/pages/user/userlogin_page.dart';
import 'package:flutter_button/pages/admin/adminlogin_page.dart';
import 'package:flutter_button/pages/user/user_loggedin_page.dart';
import 'package:flutter_button/pages/user/add_review_page.dart';
import 'package:flutter_button/pages/user/reviews_page.dart';
import 'package:flutter_button/pages/user/report_page.dart';
import 'package:flutter_button/pages/user/others_report_page.dart';
import 'package:flutter_button/pages/dialog/privacy_dialog.dart';
import 'package:flutter_button/pages/dialog/user_profile_dialog.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(Main());
}

class Main extends StatelessWidget {
  const Main({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const LoadingPage(),
        routes: {
          '/Loadingpage': (context) => const LoadingPage(),
          '/intropage': (context) => const IntroPage(report: '',),
          '/userloginpage': (context) => const UserLoginPage(),
          '/userloggedinpage': (context) => const UserLoggedInPage(),
          '/adminloginpage': (context) => const AdminLoginPage(report: '',),
          '/mappage': (context) => const MapPage(),
          '/adminmappage' : (context) => const AdminMap(username: '', report: '',),
          //'/addreviewpage': (context) => AddReviewPage(destination: null,),
          //'/reviewspage': (context) => ReviewsPage(),
          //'/reportpage': (context) => ReportPage(destination: destination,),
          '/othersreportpage': (context) => OthersReportPage(),
          '/privacydialog': (context) => const PrivacyDialog(),
          '/userprofiledialog': (context) => const UserProfileDialog(),
        });
  }
}
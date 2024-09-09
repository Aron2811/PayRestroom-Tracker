import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';


List<TargetFocus> components({
  required GlobalKey findKey,
  required GlobalKey tagKey,
  required GlobalKey directionKey,
  required GlobalKey reportKey,
  required GlobalKey profileKey,
  required GlobalKey apptourKey,
}) {
  List<TargetFocus> targets = [];



// Tag tutorial
  targets.add(TargetFocus(
    keyTarget: tagKey,
    alignSkip: Alignment.topRight,
    radius: 10,
    shape: ShapeLightFocus.RRect,
    contents: [
      TargetContent(
        align: ContentAlign.top,
        builder: (context, controller) {
          // Call the _showSamplePayToiletInformation function

          return Container(
            alignment: Alignment.center,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  "This is a sample paid restroom tag. You can click it to view the restroom details.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
              ],
            ),
          );
        },
      ),
    ],
  ));
// find nearest button
  targets.add(TargetFocus(
      keyTarget: findKey,
      alignSkip: Alignment.topRight,
      radius: 10,
      shape: ShapeLightFocus.RRect,
      contents: [
        TargetContent(
            align: ContentAlign.top,
            builder: (content, controller) {
              return Container(
                  alignment: Alignment.center,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          "You can click this to view the nearest paid restroom.",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 20, color: Colors.white),
                        ),
                      ]));
            })
      ]));

// User profile tutorial
  targets.add(TargetFocus(
      keyTarget: profileKey,
      alignSkip: Alignment.topLeft,
      radius: 10,
      shape: ShapeLightFocus.RRect,
      contents: [
        TargetContent(
            align: ContentAlign.bottom,
            builder: (content, controller) {
              return Container(
                  alignment: Alignment.center,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          "You can click this to view your user profile and change your username.",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 20, color: Colors.white),
                        ),
                      ]));
            })
      ]));

  // App tour tutorial
  targets.add(TargetFocus(
      keyTarget: apptourKey,
      alignSkip: Alignment.topRight,
      radius: 10,
      shape: ShapeLightFocus.RRect,
      contents: [
        TargetContent(
            align: ContentAlign.bottom,
            builder: (content, controller) {
              return Container(
                  alignment: Alignment.center,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          "You can click this to show all the app features as part of the app tour.",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 20, color: Colors.white),
                        ),
                      ]));
            })
      ]));

  return targets;
}
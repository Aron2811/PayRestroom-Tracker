import 'package:flutter/material.dart';

class MyDraggableSheet extends StatefulWidget {
  final Widget child;
  const MyDraggableSheet({super.key, required this.child});

  @override
  State<MyDraggableSheet> createState() => _MyDraggableSheetState();
}

class _MyDraggableSheetState extends State<MyDraggableSheet> {
  final sheet = GlobalKey();
  final controller = DraggableScrollableController();

  @override
  void initState() {
    super.initState();
    controller.addListener(onChanged); //Listen for sheet size changes
  }
  // Called when the sheet size changes
  void onChanged() {
    final currentSize = controller.size;
    if (currentSize <= 0.05) collapse(); // Collapse if too small
  }
  // Collapse the sheet to the first snap size
  void collapse() => animateSheet(getSheet.snapSizes!.first);
  // Move sheet to its anchored position
  void anchor() => animateSheet(getSheet.snapSizes!.last);
  // Fully expand the sheet
  void expand() => animateSheet(getSheet.maxChildSize);
  // Hide the sheet
  void hide() => animateSheet(getSheet.minChildSize);
  // Animate the sheet to the given size
  void animateSheet(double size) {
    controller.animateTo(
      size,
      duration: const Duration(milliseconds: 50),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose(); 
  }
  // Get the current DraggableScrollableSheet widget
  DraggableScrollableSheet get getSheet =>
      (sheet.currentWidget as DraggableScrollableSheet);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return DraggableScrollableSheet(
        key: sheet,
        initialChildSize: 0.5,
        maxChildSize: 0.95,
        minChildSize: 0,
        expand: true,
        snap: true,
        snapSizes: [
          60 / constraints.maxHeight,
          0.5,
        ],
        controller: controller,
        builder: (BuildContext context, ScrollController scrollController) {
          return DecoratedBox(
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 148, 139, 192),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(22),
                topRight: Radius.circular(22),
              ),
            ),
            child: CustomScrollView(
              controller: scrollController,
              slivers: [
                topButtonIndicator(),
                SliverToBoxAdapter(
                  child: widget.child,
                ),
              ],
            ),
          );
        },
      );
    });
  }
  // Widget for top drag indicator and close button
  SliverToBoxAdapter topButtonIndicator() {
    return SliverToBoxAdapter(
      child: Container(
        child: Stack(
          children: [
            // Centered indicator
            Align(
              alignment: Alignment.center,
              child: Container(
                width: 100,
                margin: const EdgeInsets.only(top: 10, bottom: 10),
                height: 5,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                ),
              ),
            ),
            // Close button at the top right
            Padding(
                padding: EdgeInsets.only(top: 5, right: 5),
                child: Align(
                    alignment: Alignment.topRight,
                    child: FloatingActionButton.small(
                      onPressed: () {
                        Navigator.pop(context); 
                      },
                      child: Icon(Icons.close_rounded),
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50)),
                    ))),
          ],
        ),
      ),
    );
  }
}

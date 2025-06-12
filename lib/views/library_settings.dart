
import 'package:flutter/material.dart';

import '../utils/utils.dart';

//Treatment Section
Widget libraryView(BuildContext context) {
  double screenWidth = MediaQuery.of(context).size.width;
  double screenHeight = MediaQuery.of(context).size.height;
  return Container(
      color: Colors.white,
      width: screenWidth * 0.799,
      height: screenHeight * 0.85,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(children: [
          Row(
            children: [
              SizedBox(
                  height: screenHeight * 0.025,
                  width: screenWidth * 0.44,
                  child: settext(
                      context,
                      "LIBRARY CATEGORIES",
                      FontWeight.w700,
                      const Color(0xFF3C5771),
                      screenHeight * 0.017,
                      TextAlign.left)),
              SizedBox(
                  height: screenHeight * 0.025,
                  width: screenWidth * 0.1,
                  child: settext(
                      context,
                      "DEFAULT?",
                      FontWeight.w700,
                      const Color(0xFF3C5771),
                      screenHeight * 0.017,
                      TextAlign.center)),
              SizedBox(
                  height: screenHeight * 0.025,
                  width: screenWidth * 0.1,
                  child: settext(
                      context,
                      "EDIT",
                      FontWeight.w700,
                      const Color(0xFF3C5771),
                      screenHeight * 0.017,
                      TextAlign.center)),
              SizedBox(
                  height: screenHeight * 0.025,
                  width: screenWidth * 0.1,
                  child: settext(
                      context,
                      "DELETE",
                      FontWeight.w700,
                      const Color(0xFF3C5771),
                      screenHeight * 0.017,
                      TextAlign.center)),
            ],
          ),
          Container(
              width: screenWidth * 0.799,
              alignment: Alignment.centerLeft,
              child: SizedBox(
                  width: screenWidth * 0.72,
                  child: const Divider(color: Color(0xFF7373C7)))),
          Row(
            children: [
              Container(
                width: screenWidth * 0.74,
                height: screenHeight * 0.5,
                color: Colors.white,
                margin: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                child: Column(
                  children: [
                    // List View Library category
                    SizedBox(
                      height: screenHeight * 0.26,
                      width: screenWidth * 0.74,
                      //  margin: const EdgeInsets.fromLTRB(0, 15, 0, 0),
                      child: ListView.builder(
                          itemCount: 6,
                          shrinkWrap: true,
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemBuilder: (BuildContext context, int index) {
                            return librarylistitem(index, context);
                          }),
                    ),

                    // + Add category
                    Container(
                      height: screenHeight * 0.05,
                      margin: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                      alignment: Alignment.topLeft,
                      child: TextButton.icon(
                        icon: Icon(
                          Icons.add_circle,
                          size: screenHeight * 0.029,
                          color: const Color(0xFF99acc9),
                        ),
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.transparent),
                          alignment: Alignment.centerRight,
                        ),
                        label: settext(
                            context,
                            "ADD CATEGORY",
                            FontWeight.w700,
                            const Color(0xFF3C5771),
                            screenHeight * 0.017,
                            TextAlign.left),
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ]),
      ));
}

// body treatment Listing item //
Widget librarylistitem(int index, BuildContext context) {
  double screenWidth = MediaQuery.of(context).size.width;
  double screenHeight = MediaQuery.of(context).size.height;

  return SizedBox(
    height: screenHeight * 0.062,
    width: screenWidth * 0.74,

    //margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
    child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
                height: screenHeight * 0.025,
                width: screenWidth * 0.44,
                padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                child: settext(
                    context,
                    "Exercises",
                    FontWeight.w400,
                    const Color(0xFF3C5771),
                    screenHeight * 0.022,
                    TextAlign.left)),
            SizedBox(
                height: screenHeight * 0.018,
                width: screenWidth * 0.1,
                child: Image.asset("assets/images/circlechecksolid.png",
                    width: screenWidth * 0.018,
                    height: screenHeight * 0.018,
                    fit: BoxFit.fitHeight,
                    filterQuality: FilterQuality.high)),
            SizedBox(
                height: screenHeight * 0.020,
                width: screenWidth * 0.1,
                child: Image.asset("assets/images/librarycatgryedit.png",
                    width: screenWidth * 0.020,
                    height: screenHeight * 0.020,
                    fit: BoxFit.fitHeight,
                    filterQuality: FilterQuality.high)),
            SizedBox(
                height: screenHeight * 0.020,
                width: screenWidth * 0.1,
                child: Image.asset("assets/images/librarycatgrydelete.png",
                    width: screenWidth * 0.020,
                    height: screenHeight * 0.020,
                    fit: BoxFit.fitHeight,
                    filterQuality: FilterQuality.high)
          ],
        ),

        SizedBox(height: screenHeight * 0.005),

        Container(
            alignment: Alignment.centerLeft,
            child: SizedBox(
                width: screenWidth * 0.72,
                child: const Divider(color: Color(0xFFc5cdd8))))
      ],
    ),
  );
}

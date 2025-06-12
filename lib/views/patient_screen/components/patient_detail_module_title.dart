/*
   This class is representing the section with title ,datetime and doctor name like Graph 9/27/20215:48:37PM - Dr. Debra Jones for patient detail screen.
*/
import 'package:flutter/material.dart';

import '../../../utils/constants.dart';
import '../../../utils/sizes_helpers.dart';
import '../../../utils/utils.dart';

class PatientDetailModuleTitle extends StatelessWidget {
  //Variable used to show the title like graph, location etc.
  final String moduleTitle;
  //Variable used to show the datetime, on the basis of it detail of particular section will show.
  final String moduleDateTime;
  //Variable used to show the doctor name.
  final String doctorName;
  const PatientDetailModuleTitle(
      {Key? key,
        required this.moduleTitle,
        required this.moduleDateTime,
        required this.doctorName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.only(top: 10, bottom: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            //Title
            Text(
              moduleTitle,
              textAlign: TextAlign.left,
              style: getTextTheme(
                  textColor: kDarkGreyBold,
                  fontSize: screenHeight(
                      context) *
                      0.021,
                  fontWeight: FontWeight.w700),
            ),
            //For Horizontal Spacing
            SizedBox(
              width: screenWidth(context) * 0.01,
            ),
            //Date Time and Last Edited By Doctor Name
            Text(
              "$moduleDateTime $doctorName",
              textAlign: TextAlign.left,
              style: getTextTheme(
                  textColor: kDarkBlue,
                  fontSize: screenHeight(context) * 0.018,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ));
  }
}

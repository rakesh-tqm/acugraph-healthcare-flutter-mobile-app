/*This class display the Treatment Plan Points header fields, this is using in TreatmentPlanPoint view
 This class is commonly using for both patient detail and Treatment drawer point view */

import 'package:flutter/material.dart';
import '../../../utils/constants.dart';
import '../../../utils/sizes_helpers.dart';
import '../../../utils/utils.dart';

class TreatmentPlanHeaderFields extends StatelessWidget {
  //isEdit specify this class is in edit view or not for patient detail screen and Treatment Drawer points view.
  final bool isEdit;
  const TreatmentPlanHeaderFields({Key? key, required this.isEdit})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment.centerLeft,
        height: screenHeight(context) * .06,
        margin: const EdgeInsets.fromLTRB(25, 0, 25, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            //Point title text
            Expanded(
              child: Text(
                "POINT",
                style: getTextTheme(
                    fontWeight: FontWeight.bold,
                    textColor: kDarkBlue,
                    fontSize: screenHeight(context) * 0.0165),
                textAlign: TextAlign.left,
              ),
            ),
            //Auricular title text
            Expanded(
              child: Text(
                "AURICULAR",
                style: getTextTheme(
                    fontWeight: FontWeight.bold,
                    textColor: kDarkBlue,
                    fontSize: screenHeight(context) * 0.0165),
                textAlign: TextAlign.center,
              ),
              flex: 1,
            ),
            //Side title text
            Expanded(
              child: Text(
                "SIDE",
                style: getTextTheme(
                    fontWeight: FontWeight.bold,
                    textColor: kDarkBlue,
                    fontSize: screenHeight(context) * 0.0165),
                textAlign: TextAlign.center,
              ),
              flex: 1,
            ),
            //Office title text
            Expanded(
              child: Text(
                "OFFICE",
                style: getTextTheme(
                    fontWeight: FontWeight.bold,
                    textColor: kDarkBlue,
                    fontSize: screenHeight(context) * 0.0165),
                textAlign: TextAlign.center,
              ),
              flex: 1,
            ),
            //Home title text
            Expanded(
              child: Text(
                "HOME",
                style: getTextTheme(
                    fontWeight: FontWeight.bold,
                    textColor: kDarkBlue,
                    fontSize: screenHeight(context) * 0.0165),
                textAlign: TextAlign.center,
              ),
              flex: 1,
            ),
            //If it is in edit view then it will show the extra space field
            isEdit
                ? Expanded(
                    child: SizedBox(
                        width: screenHeight(context) * 0.020,
                        height: screenHeight(context) * 0.020),
                  )
                :
                //else it will show blank container without space
                Container()
          ],
        ));
  }
}

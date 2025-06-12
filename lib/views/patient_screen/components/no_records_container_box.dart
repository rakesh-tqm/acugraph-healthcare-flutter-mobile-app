/*
This class is representing the small part of patient detail screen in which if we don't have any data under any section like
graph, location, treatmentplan etc then 'No records available' will show.
*/

import 'package:flutter/material.dart';
import 'package:progress_indicators/progress_indicators.dart';

import '../../../utils/constants.dart';
import '../../../utils/sizes_helpers.dart';
import '../../../utils/utils.dart';

class NoRecordsContainerBox extends StatelessWidget {
  //Initializing bool variable to show the indicator if it will be true.
  final bool isJumpingLoadingIndicator;

  const NoRecordsContainerBox({Key? key, required this.isJumpingLoadingIndicator}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return  Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Container(
          height: screenHeight(context) * 0.34,
          alignment: Alignment.center,
          width: screenWidth(context)*0.85,
          decoration: BoxDecoration(
              color: Colors.transparent,
              border:
              Border.all(color: kLightGrey)),
          child:
          //Jumping Loading Indicator
          (isJumpingLoadingIndicator)
              ? JumpingDotsProgressIndicator(
            fontSize: 60.0,
          ):

          //No Records Available
          Text("No Records Available.",textAlign: TextAlign.center,
            style: getTextTheme(textColor:kLightGrey,fontWeight:FontWeight.w400,fontSize:screenHeight(context) * 0.030   ),)

      ),
    );

  }
}


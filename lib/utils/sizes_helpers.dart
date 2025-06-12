//Defining the size of Current Screen in a common_widgets place. It can simply be accessed by all over the application screens.

import 'package:flutter/material.dart';

Size screenSize(BuildContext context) {
  return MediaQuery.of(context).size;
}
//Returning screen height
double screenHeight(BuildContext context) {
  return screenSize(context).height;
}

//Returning screen width
double screenWidth(BuildContext context) {
  //This debugPrint line makes the console INCREDIBLY noisy. I'm commenting it out, but leaving it
  //here in case someone actually needs it for something...
  // -- EKL
  //debugPrint('Width = ' + screenSize(context).width.toString());
  return screenSize(context).width;
}
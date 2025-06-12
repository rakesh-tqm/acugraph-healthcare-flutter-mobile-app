/*
Sometimes in Xojo it was necessary to have a wrapper around a MeridiansAndTreatments object, to allow extra stuff
like prioritizing different sets of potential treatment options before ever even presenting them to the user.

This class is just a simple wrapper around Meridians and Treatments.
 */

import 'meridians_and_treatments.dart';

class MeridiansAndTreatmentsWrapper
{
  //priority for comparison against other meridians and treatments objects.
  int _priority = 0;

  //The MeridiansAndTreatments object this wraps.
  MeridiansAndTreatments mt = MeridiansAndTreatments();

  //Simple getter/setter to access and adjust the priority.
  int get priority => _priority;
  set priority(int value) {
    _priority = value;
  }

  //convenience setter to set the type of the wrapped Meridians and Treatments object.
  set type(String s)
  {
    mt.type = s;
  }
}
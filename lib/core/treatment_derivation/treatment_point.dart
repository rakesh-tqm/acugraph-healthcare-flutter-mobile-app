/*
A TreatmentPoint represents an actual location on the human body, that usually lies on an acupuncture meridian.
Treatment points come with lots of metadata, such as if they are meant to tonify, sedate, whether it's a part
of a larger group of points, why it was suggested, which meridians it affects, what treatment modality should
be used, etc. This class holds all that info, and provides simple accessors for it all.

 */
class TreatmentPoint
{
  //Xojo uses ALL_CAPS for constants/static/final fields in classes. I know this is not in line with how
  //Dart does things, so I've changd them here. This may cause problems elsewhere in the port, as the original
  //xojo code used ALL_CAPS for this kind of thing.
  static const String sedate = "sedate";
  static const String tonify = "tonify";
  static const String treat = "treat";

  //tracks whether this treatment point is a "group point", which has to do with how the decision
  //to use this point was made.
  bool _isGroupPoint = false;

  //_right and _left are used to indicate whether this point should be treated on the left and/or
  //right hand side of the body
  bool _right = true;
  bool _left = true;

  //Tracks which meridians are affected - just as a list of meridian abbreviations - LU, PC, HT, etc.
  List<String> _meridiansAffected = [];

  //All points have a full name as well as an an abbreviation.
  String _pointAbbreviation = "";
  String _pointName = "";

  //Why was this point recommended?
  String _pointReason = "";

  //Points can be on the full body, or only on the ear. All points default to body when constructed.
  //If this is to be treated on the ear, whatever is constructing this TreatmenPoint will know that and
  //should change this to "ear".
  String _pointType = "body";

  //There are several different treatment modalities. It defaults to just "treat", but sometimes
  //we specifically want to "tonify", or "sedate". This tracks which one we are doing with this point.
  String _treatmentModality = "treat";

  //Priority ranking so that point groups can be sorted within a given treatment.
  int _priority = 0;

  //the meridians affected by this treatment point sometimes need to be accessed as the full list,
  //and sometimes we just want to grab 1 of the items at a certain index in the list, so there are 2
  //different styles of getters.
  String getMeridiansAffected(int i)
  {
    //make sure i is a valid index.
    if(i < _meridiansAffected.length)
    {
      return _meridiansAffected[i];
    }
    //not a valid index, just return a blank string.
    return "";
  }

  List<String> get meridiansAffected => _meridiansAffected;
  set meridiansAffected(List<String> value) {
    _meridiansAffected = value;
  }


  /*
  Everything below are just auto-generated Dart-style getter/setter pairs for all the private fields in this class.
   */
  bool get isGroupPoint => _isGroupPoint;

  set isGroupPoint(bool value) {
    _isGroupPoint = value;
  }

  bool get right => _right;
  set right(bool value) {
    _right = value;
  }

  bool get left => _left;
  set left(bool value) {
    _left = value;
  }

  String get pointAbbreviation => _pointAbbreviation;
  set pointAbbreviation(String value) {
    _pointAbbreviation = value;
  }

  String get pointName => _pointName;
  set pointName(String value) {
    _pointName = value;
  }

  String get pointReason => _pointReason;
  set pointReason(String value) {
    _pointReason = value;
  }

  String get pointType => _pointType;
  set pointType(String value) {
    _pointType = value;
  }

  String get treatmentModality => _treatmentModality;
  set treatmentModality(String value) {
    _treatmentModality = value;
  }

  int get priority => _priority;
  set priority(int value) {
    _priority = value;
  }
}
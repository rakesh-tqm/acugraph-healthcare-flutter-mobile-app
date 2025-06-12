/*
This class is used by some of the treatment methods (not Expert, for example) to hold onto an association
between meridians and their treatments.
 */
import 'meridian.dart';
import 'treatment_point.dart';

class MeridiansAndTreatments
{
  //list of the meridians, which will include things like their current state (high, low, split, etc)
  List<Meridian> meridians = [];
  //Meridians are typically indexed via their English abbreviation, so this is the official list of abbreviations
  //to use. There is likely something in Dart like an enumeration that really should be used for this, but as I'm
  //directly porting from Xojo, I'm going to lean towards following the paradigms from there for most of this
  //implementation.
  List<String> _meridianIndex = ["LU", "PC", "HT", "SI", "TE", "LI", "SP", "LR", "KI", "BL", "GB", "ST"];
  //List of treatment points that will be associated with these meridians.
  List<TreatmentPoint> treatments = [];
  //What type of treatment is this? (Basic, advanced, back shu, etc)
  String _type = "";

  //default constructor, sets up a few basic things every instance will need.
  MeridiansAndTreatments ()
  {
    for (int i = 0; i<12; i++)
      {
        Meridian m = Meridian();
        m.name = _meridianIndex[i];
        meridians.add(m);
      }
  }

  /*
  An accessor for the "type" class variable. Not sure if this is still needed, but again, porting
  from Xojo, so following the paradigm from there.
   */
  String get type => _type;
  set type(String value) {
    _type = value;
  }

  //meridianIndex accessors
  List<String> get meridianIndex => _meridianIndex;
  set meridianIndex(List<String> value) {
    _meridianIndex = value;
  }
}
/*
An instance of Meridian holds all the stuff we need to know in the treatment derivation about a meridian:
What are the values on the left and right side?
What was the measured state (high, low, split, etc)
Was that measured state overridden by the user?
Has this meridian already been addressed by the current treatment type?
What is the name of this meridian?
Are we treating it with an anatomical or priority approach?
Etc...
 */

class Meridian
{
  //Flag to track whether this meridian has had an anatomical or priority treatment given to it, or just a basic one.
  bool anatomicalOrPriorityTreated = false;
  //what is the value of the left side of this meridian?
  int leftValue = 0;
  //value on the right side
  int rightValue = 0;
  //what was the default measured stated (high, low, split, etc)
  String measuredState = "";
  //what is the *current* state of the meridian? (i.e., if the user has overridden
  //the state for this meridian, this state will differ from measuredState
  String state = "";
  //the abbreviation of the meridian
  String name = "";
  //flag to store whether this meridian has been treated yet or not.
  bool treated = false;
}
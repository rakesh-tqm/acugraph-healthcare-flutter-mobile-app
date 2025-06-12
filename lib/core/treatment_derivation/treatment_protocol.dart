/*
This class represents a single treatment protocol. AcuGraph may have multiple treatment protocol options to consider
while viewing a graph, so a new TreatmentProtocol object needs to be used for each of the treatment options. Treatment
protocols consist of acupuncture points to treat (on the body, on the ears), whether those points are treated on the
left or right or bilaterally, which meridians those points affect, why the points were added to the protocol, and a whole
bunch of other information. This class both holds all that information for a given treatment protocol and provides the
means to do some derivation of some of the underlying logic for selecting points in the treatment protocol.
 */

import '../../data_layer/drivers/logger.dart';
import 'constants.dart';
import 'meridians_and_treatments.dart';
import 'meridians_and_treatments_wrapper.dart';
import 'treatment_point.dart';

class TreatmentProtocol {
  //used to track whether this patient should treat the jing-well points at home.
  bool _tsingAtHome = false;

  //the meridians and treatments collection that this treatment protocol object will use and manipulate.
  List<MeridiansAndTreatmentsWrapper> _meridiansAndTreatments = [];

  //default constructor
  TreatmentProtocol() {
    //our treatment protocols can sometimes propose up to 7 different options for a single protocol, so this pre-populates
    //the _meridiansAndTreatments list with a bunch of empty wrappers. This paradigm of needing to pre-construct stuff
    //instead of just adding things to arrays on-the-fly is due to older xojo paradigms, but as I'm porting this I'll need
    //to keep some of the paradigms intact. This is one of them.
    for (int i = 0; i <= 6; i++) {
      _meridiansAndTreatments.add(MeridiansAndTreatmentsWrapper());
    }
  }

  //Meridians are "indexed" in Xojo with both a name and a corresponding number. The
  //meridianIndex holds this index, so that names are always associated with a number.
  //I know that a simple Map could have been used for this in Dart, but there are SO
  //many places that refer to this meridianIndex that I decided to stay with the Xojo
  //paradigm. (Note: Modern Xojo could have used a dictionary, but this was originally
  //written a LONG time ago before dictionaries were supported.

  //This method gets the index for a meridian by name.
  getMeridianIndex(String name) {
    for (int i = 0; i < 12; i++) {
      if (name.trim() == meridianIndex[i].trim()) {
        return i;
      }
    }
    // TODO: How are we handling errors? Here's the original Xojo source line:
    // app.alertUser (translate("SORRY_AN_UNEXPECTED_ERROR_OCCURRED__ACUGRAPH_II_MUST_NOW_QUIT_ERROR_1010"), false, GenericAlert.STOP)
  }

  //If a meridian has not yet been treated, what was it's original state? (high, low, split, etc)
  getUntreatedState(String point, MeridiansAndTreatments mt) {
    if (mt.meridians[getMeridianIndex(point)].treated == false) {
      return mt.meridians[getMeridianIndex(point)].state;
    }
    return "";
  }

  //Grab the calculated basic protocol
  getBasic() {
    return _meridiansAndTreatments[0].mt;
  }

  // Basic protocol in plain english:
  // 1.  After measurement, assign each meridian as high (+), low(-),
  // or split (s).  As each item is treated, in the following order, they
  // need to be marked as treated (t) so they will not be considered
  // or treated in the following steps.
  // 2.  If there are 4 or more (s) meridians, treat SP21.
  // 3.  If there are 1-3 (s) meridians, treat the luo point on each split
  // meridian according to treatment protocol lines 13-25. (spreadsheet)
  // 4.  Sedate the highs and tonify the lows, according to lines 27-41 (spreadsheet).
  void deriveBasic() {
    //do the common stuff
    //pull out a local reference to the meridiansAndTreatments object we want to affect.
    MeridiansAndTreatments mt = _meridiansAndTreatments[0].mt;
    mt = commonTreatment(mt);
    //ok, by now, all the splits are taken care of.. so sedate the highs and
    //tonify lows
    for (int i = 0; i < 12; i++) {
      if (mt.meridians[i].state == HIGH) {
        mt = addTreatmentPoint(sedationPoints[mt.meridians[i].name], mt.meridians[i].name + " Excessive", mt,
            [mt.meridians[i].name], false);
      } else if (mt.meridians[i].state == LOW) {
        mt = addTreatmentPoint(tonificationPoints[mt.meridians[i].name], mt.meridians[i].name + " Deficient", mt,
            [mt.meridians[i].name], false);
      }
    }
    //mark the treatment type as "basic"
    mt.type = "basic";
    //store our result back in the original meridiansAndTreatmentsWrapper
    _meridiansAndTreatments[0].mt = mt;
  }

  //Different treatments have a lot of common sort of "baseline" things they all do. This function takes care of handling
  //all the basic parts of treatments that are common to several of the specific treatment types.
  MeridiansAndTreatments commonTreatment(MeridiansAndTreatments mt) {
    int splitCount = 0;
    mt = clearTreated(mt);
    mt = resetTreatment(mt);
    splitCount = countSplits(mt);
    List<String> splitMeridians = getSplitMeridians(mt);
    if (splitCount > 3) {
      //Just treat SP21, because there are 4 or more splits.
      mt = addTreatmentPoint(SPLEEN + " 21", "4 or More Splits", mt, splitMeridians, true);
      for (int i = 0; i < 12; i++) {
        if (mt.meridians[i].state == SPLIT) {
          mt.meridians[i].treated = true;
        }
      }
    } else if (splitCount > 0) {
      //splitcount is between 0 and 3. Treat the luo points for these meridians first.
      for (int i = 0; i < 12; i++) {
        if (mt.meridians[i].state == SPLIT) {
          //Each meridian has its own luo point, so pull that point name out of the _luoPoints map and stuff it into the
          //list of treatment points, with the reason that this meridian is split.
          mt = addTreatmentPoint(
              luoPoints[mt.meridians[i].name], mt.meridians[i].name + " Split", mt, [mt.meridians[i].name], false);
          //mark this meridian has having been treated
          mt.meridians[i].treated = true;
        }
      }
    }
    //return the now updated MeridiansAndTreatments object
    return mt;
  }

  //just walk through the meridians and see how many are marked as split.
  int countSplits(MeridiansAndTreatments mt) {
    int splitCount = 0;
    for (int i = 0; i < 12; i++) {
      if (mt.meridians[i].state == SPLIT) {
        splitCount++;
      }
    }
    //Logger.info("SplitCount was calculated to be: " + splitCount.toString());
    return splitCount;
  }

  //walk through the meridians and figure out which ones are split. Returns a List<String> of split meridians
  List<String> getSplitMeridians(MeridiansAndTreatments mt) {
    List<String> splits = [];
    for (int i = 0; i < 12; i++) {
      if (mt.meridians[i].state == SPLIT) {
        splits.add(mt.meridians[i].name);
      }
    }
    return splits;
  }

  //asks the treatmentProtocol if type1 is identical to type2.  Order of the points being treated does not matter, but
  //points treated and reasons why do.
  isTreatmentEqual(int type1, int type2) {
    bool found = false;
    if (_meridiansAndTreatments[type1].mt.treatments.length != _meridiansAndTreatments[type2].mt.treatments.length) {
      return false;
    } else {
      for (int i = 0; i < _meridiansAndTreatments[type1].mt.treatments.length; i++) {
        found = false;
        for (int j = 0; j < _meridiansAndTreatments[type2].mt.treatments.length; j++) {
          if ((_meridiansAndTreatments[type1].mt.treatments[i].pointName ==
                  _meridiansAndTreatments[type2].mt.treatments[j].pointName) &&
              (_meridiansAndTreatments[type1].mt.treatments[i].pointReason ==
                  _meridiansAndTreatments[type2].mt.treatments[j].pointReason)) {
            found = true;
          }
        }
        if (found == false) {
          return false;
        }
      }
      return true;
    }
  }

  //removes all the treatment points previously added to this treatment protocol.
  MeridiansAndTreatments resetTreatment(MeridiansAndTreatments mt) {
    mt.treatments.clear();
    return mt;
  }

  //Add a treatment point to this treatment protocol, along with all the associated metadata it needs. Return the new list of Meridians and Treatments
  MeridiansAndTreatments addTreatmentPoint(String pointName, String pointReason, MeridiansAndTreatments mt,
      List<String> meridiansAffected, bool isGroupPoint) {
    TreatmentPoint tp = TreatmentPoint();
    tp.pointName = pointName;
    tp.pointReason = pointReason;
    tp.meridiansAffected = meridiansAffected;
    tp.isGroupPoint = isGroupPoint;
    mt.treatments.add(tp);
    return mt;
  }

  //clear out all the treated indicators for all the points in this protocol. Return the updated Meridians and Treatments list.
  MeridiansAndTreatments clearTreated(MeridiansAndTreatments mt) {
    for (int i = 0; i < mt.meridians.length; i++) {
      mt.meridians[i].treated = false;
    }
    return mt;
  }

  needTsing(MeridiansAndTreatments mt, num scale) {
    //tsing points are used when all the unsplit points are either excessively
    //high or low (ie, above 150 or below 50)
    int neededTreatment = 0;
    int lowCount = 0;
    int highCount = 0;
    int localMax = 0;
    int localMin = 0;

    //check if all the untreated points are high or low
    if (scale == 210) {
      localMin = 50;
      localMax = 150;
    } else {
      localMin = 25;
      localMax = 75;
    }
    for (int i = 0; i < 12; i++) {
      if (mt.meridians[i].treated == false) {
        neededTreatment = neededTreatment + 1;
      }
      if (mt.meridians[i].leftValue < localMin && mt.meridians[i].rightValue < localMin) {
        lowCount = lowCount + 1;
      } else if (mt.meridians[i].leftValue > localMax && mt.meridians[i].rightValue > localMax) {
        highCount = highCount + 1;
      }
    }
    _tsingAtHome = false;
    if (neededTreatment > 0) {
      if (lowCount == neededTreatment) {
        _tsingAtHome = true;
        return LOW;
      }
    } else if (highCount == neededTreatment) {
      _tsingAtHome = true;
      return HIGH;
    }
    return "";
  }

  //When deriving advanced treatments, several alternatives will be calculated first, and then the best alternative
  //will be promoted to the final solution. This method is just here to set the first advanced option.
  setAdvanced1(MeridiansAndTreatmentsWrapper mt) {
    _meridiansAndTreatments[1] = mt;
  }

  //getter for the first advanced option
  getAdvanced1() {
    return _meridiansAndTreatments[1].mt;
  }

  //getter for the first advanced option type.
  getAdvancedTreatment1Type() {
    return _meridiansAndTreatments[1].mt.type;
  }

  //When deriving advanced treatments, several alternatives will be calculated first, and then the best alternative
  //will be promoted to the final solution. This method is just here to set the second advanced option.
  setAdvanced2(MeridiansAndTreatmentsWrapper mt) {
    _meridiansAndTreatments[2] = mt;
  }

  //getter for the second advanced option.
  getAdvanced2() {
    return _meridiansAndTreatments[2].mt;
  }

  //getter for the second advanced option type.
  getAdvancedTreatment2Type() {
    return _meridiansAndTreatments[2].mt.type;
  }

  /*
  The Sheng, Luo, Ko cycles are specific ways to look at moving energy between multiple disparate meridians. If you look
  at the 5 elements chart, you'll see that the shen (or sheng) cycle runs around the elements in a clockwise circle - so ST
  flows into LI, BL into GB, LR into HT, etc. The Ko cycle forms a 5 pointed star between the elements - so LU flows into LR,
  LR then flows into SP, etc. As I recall, Luo moves energy across an element, so SP flows into ST, etc or vice-versa.

  The sheng, luo, and ko functions in this class are used to explore which point combinations can be the most effective
  at moving energy from where there is too much to where there is too little, and by comparing the options presented
  we can determine which combination of shen, luo, and ko cycles can be used to both maximize energy transfer and
  minimize the number of points which require treatment.
   */

  //utility function to compare the untreated state of 2 meridians, and if the proper combination is found to be true
  // then the given treatment meridian and point is added to the MeridiansAndTreatments wrapper. Returns the wrapper.
  firstIsLowSecondIsHigh(
      String first, String second, MeridiansAndTreatmentsWrapper mtw, String txMeridian, String pointNumber) {
    if (getUntreatedState(first, mtw.mt) == LOW && getUntreatedState(second, mtw.mt) == HIGH) {
      List<String> affectedMeridians = [first, second];
      mtw.mt = addTreatmentPoint(txMeridian + " " + pointNumber, first + " Deficient, " + second + " Excessive", mtw.mt,
          affectedMeridians, false);
      mtw.mt.meridians[getMeridianIndex(first)].treated = true;
      mtw.mt.meridians[getMeridianIndex(second)].treated = true;
    }
    return mtw;
  }

  //investigates the combinations that may work best for moving energy along the ko cycle.
  ko(MeridiansAndTreatmentsWrapper mtw) {
    List<String> affectedMeridians = [];
    //if heart is low, pericardium is low, and kidney is high
    //treat HT 3 and PC 9
    if (getUntreatedState(HEART, mtw.mt) == LOW &&
        getUntreatedState(PERICARDIUM, mtw.mt) == LOW &&
        getUntreatedState(KIDNEY, mtw.mt) == HIGH) {
      affectedMeridians = [HEART, KIDNEY];
      mtw.mt = addTreatmentPoint(
          HEART + " 3", HEART + " Deficient, " + KIDNEY + " Excessive", mtw.mt, affectedMeridians, false);
      affectedMeridians = [PERICARDIUM];
      mtw.mt = addTreatmentPoint(
          PERICARDIUM + " 9", PERICARDIUM + " Deficient, " + KIDNEY + " Excessive", mtw.mt, affectedMeridians, false);
      mtw.mt.meridians[getMeridianIndex(HEART)].treated = true;
      mtw.mt.meridians[getMeridianIndex(PERICARDIUM)].treated = true;
      mtw.mt.meridians[getMeridianIndex(KIDNEY)].treated = true;
    }
    //If liver is low and lung is high, treat Liver 4.
    mtw = firstIsLowSecondIsHigh(LIVER, LUNG, mtw, LIVER, "4");
    //if lung is low and pericardium is high, treat lung 10.
    mtw = firstIsLowSecondIsHigh(LUNG, PERICARDIUM, mtw, LUNG, "10");
    //if lung is low and heart is high, treat lung 10.
    mtw = firstIsLowSecondIsHigh(LUNG, HEART, mtw, LUNG, "10");
    //if spleen is low and liver is high, treat spleen 1
    mtw = firstIsLowSecondIsHigh(SPLEEN, LIVER, mtw, SPLEEN, "1");
    //if heart is low and kidney is high, treat heart 3
    mtw = firstIsLowSecondIsHigh(HEART, KIDNEY, mtw, HEART, "3");
    //if pericardium is low and kidney is high, treat pericardium 3
    mtw = firstIsLowSecondIsHigh(PERICARDIUM, KIDNEY, mtw, PERICARDIUM, "3");
    //return the meridians and treatments wrapper that this method adjusted.
    return mtw;
  }

  //looks for pairs in the yin-yang cycle and uses luo points for balancing
  luo(MeridiansAndTreatmentsWrapper mtw) {
    //if lung is low and large intestine is high, treat LU 7
    mtw = firstIsLowSecondIsHigh(LUNG, LARGE_INTESTINE, mtw, LUNG, "7");
    //if pericardium is low and triple energizer is high, treat PC 6
    mtw = firstIsLowSecondIsHigh(PERICARDIUM, TRIPLE_ENERGIZER, mtw, PERICARDIUM, "6");
    //if heart is low and small intestine is high, treat HT 5
    mtw = firstIsLowSecondIsHigh(HEART, SMALL_INTESTINE, mtw, HEART, "5");
    //if small intestine is low and heart is high, treat SI 7
    mtw = firstIsLowSecondIsHigh(SMALL_INTESTINE, HEART, mtw, SMALL_INTESTINE, "7");
    //if triple energizer is low and pericardium is high, treat TE 5
    mtw = firstIsLowSecondIsHigh(TRIPLE_ENERGIZER, PERICARDIUM, mtw, TRIPLE_ENERGIZER, "5");
    //if large intestine is low and lung is high, treat LI 6
    mtw = firstIsLowSecondIsHigh(LARGE_INTESTINE, LUNG, mtw, LARGE_INTESTINE, "6");
    //if spleen is low and stomach is high, treat SP 4
    mtw = firstIsLowSecondIsHigh(SPLEEN, STOMACH, mtw, SPLEEN, "4");
    //if liver is low and gall bladder is high treat LR 5
    mtw = firstIsLowSecondIsHigh(LIVER, GALL_BLADDER, mtw, LIVER, "5");
    //if kidney is low and bladder is high, treat KI 4
    mtw = firstIsLowSecondIsHigh(KIDNEY, BLADDER, mtw, KIDNEY, "4");
    //if bladder is high and kidney is low, treat BL 58
    mtw = firstIsLowSecondIsHigh(BLADDER, KIDNEY, mtw, BLADDER, "58");
    //if gall bladder is high and liver is low, treat GB 37
    mtw = firstIsLowSecondIsHigh(GALL_BLADDER, LIVER, mtw, GALL_BLADDER, "37");
    //if stomach is low and spleen is high, treat ST 40
    mtw = firstIsLowSecondIsHigh(STOMACH, SPLEEN, mtw, STOMACH, "40");

    //return the meridians and treatments wrapper that this method adjusted.
    return mtw;
  }

  //checks for imbalances that can be treated along the shen cycle
  sheng(MeridiansAndTreatmentsWrapper mtw) {
    //KI low, LU high, treat KI 7
    mtw = firstIsLowSecondIsHigh(KIDNEY, LUNG, mtw, KIDNEY, "7");
    //SP low, P high, treat SP 2
    mtw = firstIsLowSecondIsHigh(SPLEEN, PERICARDIUM, mtw, SPLEEN, "2");
    //SP low, HT high, treat SP 2
    mtw = firstIsLowSecondIsHigh(SPLEEN, HEART, mtw, SPLEEN, "2");
    //ST low, SI high, treat ST 41
    mtw = firstIsLowSecondIsHigh(STOMACH, SMALL_INTESTINE, mtw, STOMACH, "41");
    //ST low, TE high, treat ST 41
    mtw = firstIsLowSecondIsHigh(STOMACH, TRIPLE_ENERGIZER, mtw, STOMACH, "41");
    //BL low, LI high, treat BL 67
    mtw = firstIsLowSecondIsHigh(BLADDER, LARGE_INTESTINE, mtw, BLADDER, "67");
    //LU low, SP high, treat LU 9
    mtw = firstIsLowSecondIsHigh(LUNG, SPLEEN, mtw, LUNG, "9");
    //HT low, LR high, treat HT 9
    mtw = firstIsLowSecondIsHigh(HEART, LIVER, mtw, HEART, "9");
    //PC low, LR high, treat PC 9
    mtw = firstIsLowSecondIsHigh(PERICARDIUM, LIVER, mtw, PERICARDIUM, "9");
    //LR low, KI high, treat LR 8
    mtw = firstIsLowSecondIsHigh(LIVER, KIDNEY, mtw, LIVER, "8");
    //GB low, BL high, treat GB 43
    mtw = firstIsLowSecondIsHigh(GALL_BLADDER, BLADDER, mtw, GALL_BLADDER, "43");
    //SI low, GB high, treat SI 3
    mtw = firstIsLowSecondIsHigh(SMALL_INTESTINE, GALL_BLADDER, mtw, SMALL_INTESTINE, "3");
    //TE low, GB high, treat TE 3
    mtw = firstIsLowSecondIsHigh(TRIPLE_ENERGIZER, GALL_BLADDER, mtw, TRIPLE_ENERGIZER, "3");
    //LI low, ST high, treat LI 11
    mtw = firstIsLowSecondIsHigh(LARGE_INTESTINE, STOMACH, mtw, LARGE_INTESTINE, "11");
    return mtw;
  }

  //All the advanced treatment options have a common set of treatments that they apply first, before going on to
  //the other specific advanced tx steps.
  commonAdvancedTreatment(MeridiansAndTreatmentsWrapper mtw, num scale) {
    //Declare a bunch of variables we'll need later on.
    String tsingState = "";
    List<String> upperStates = [];
    List<String> lowerStates = [];
    int upperLow = 0;
    int upperHigh = 0;
    int upperSplit = 0;
    int upperNormal = 0;
    int lowerLow = 0;
    int lowerHigh = 0;
    int lowerSplit = 0;
    int lowerNormal = 0;

    //perform the base common treatment.
    mtw.mt = commonTreatment(mtw.mt);
    //check for all high or all low (tsing points)
    tsingState = needTsing(mtw.mt, scale);

    if (tsingState != "") {
      //just treat the tsing points
      mtw.mt = addTreatmentPoint(LUNG + " 11", QI_LEVEL, mtw.mt, allMeridians, true);
      mtw.mt = addTreatmentPoint(PERICARDIUM, QI_LEVEL, mtw.mt, allMeridians, true);
      mtw.mt = addTreatmentPoint(HEART + " 9", QI_LEVEL, mtw.mt, allMeridians, true);
      mtw.mt = addTreatmentPoint(SMALL_INTESTINE + " 1", QI_LEVEL, mtw.mt, allMeridians, true);
      mtw.mt = addTreatmentPoint(TRIPLE_ENERGIZER + " 1", QI_LEVEL, mtw.mt, allMeridians, true);
      mtw.mt = addTreatmentPoint(LARGE_INTESTINE + " 1", QI_LEVEL, mtw.mt, allMeridians, true);
      mtw.mt = addTreatmentPoint(SPLEEN + " 1", QI_LEVEL, mtw.mt, allMeridians, true);
      mtw.mt = addTreatmentPoint(LIVER + " 1", QI_LEVEL, mtw.mt, allMeridians, true);
      mtw.mt = addTreatmentPoint(KIDNEY, QI_LEVEL, mtw.mt, allMeridians, true);
      mtw.mt = addTreatmentPoint(BLADDER + " 67", QI_LEVEL, mtw.mt, allMeridians, true);
      mtw.mt = addTreatmentPoint(GALL_BLADDER + " 44", QI_LEVEL, mtw.mt, allMeridians, true);
      mtw.mt = addTreatmentPoint(STOMACH + " 45", QI_LEVEL, mtw.mt, allMeridians, true);

      for (int i = 0; i < 12; i++) {
        mtw.mt.meridians[i].treated = true;
      }
    }

    //look for belt blocks
    //belt blocks should be as follows:
    //The meridians are divided into upper and lower.  When there is a sharp energy difference between the upper and lower
    //meridians, this is a belt block.
    //We determine a sharp difference by checking that of the 6 meridians in upper or lower, 4 are high or low, and the other
    //two are either normal or split, but not low or high, respectively.
    //for example:
    //Upper Meridians:
    //LU = low
    //P = split
    //HT = low
    //SI = low
    //TH = normal
    //LI = low
    //
    //Lower:
    //SP = normal
    //LV = high
    //K= high
    //BL = normal
    //GB= high
    //ST= high
    //
    //this is a belt block, as 4 of the upper meridians are low, and the other 2 are not high.  4 of the lower meridians are high,
    //and the other 2 are not low.

    upperStates.add(getUntreatedState(LUNG, mtw.mt));
    upperStates.add(getUntreatedState(PERICARDIUM, mtw.mt));
    upperStates.add(getUntreatedState(HEART, mtw.mt));
    upperStates.add(getUntreatedState(SMALL_INTESTINE, mtw.mt));
    upperStates.add(getUntreatedState(TRIPLE_ENERGIZER, mtw.mt));
    upperStates.add(getUntreatedState(LARGE_INTESTINE, mtw.mt));

    lowerStates.add(getUntreatedState(SPLEEN, mtw.mt));
    lowerStates.add(getUntreatedState(LIVER, mtw.mt));
    lowerStates.add(getUntreatedState(KIDNEY, mtw.mt));
    lowerStates.add(getUntreatedState(BLADDER, mtw.mt));
    lowerStates.add(getUntreatedState(GALL_BLADDER, mtw.mt));
    lowerStates.add(getUntreatedState(STOMACH, mtw.mt));

    //count up how many highs and lows there are in the uppers and lowers
    for (int i = 0; i < upperStates.length; i++) {
      switch (upperStates[i]) {
        case LOW:
          {
            upperLow++;
          }
          break;
        case HIGH:
          {
            upperHigh++;
          }
          break;
        case SPLIT:
          {
            upperSplit++;
          }
          break;
        case NORMAL:
          {
            upperNormal++;
          }
          break;
      }
    }

//lowers
    for (int i = 0; i < lowerStates.length; i++) {
      switch (lowerStates[i]) {
        case LOW:
          {
            lowerLow++;
          }
          break;
        case HIGH:
          {
            lowerHigh++;
          }
          break;
        case SPLIT:
          {
            lowerSplit++;
          }
          break;
        case NORMAL:
          {
            lowerNormal++;
          }
          break;
      }
    }
    //ok, now decide if this is a belt block or not
    if ((lowerLow >= 4 && upperHigh >= 4 && lowerHigh == 0 && upperLow == 0) ||
        (lowerHigh >= 4 && upperLow >= 4 && lowerLow == 0 && upperHigh == 0)) {
      //this is a belt block!
      mtw.mt.meridians[getMeridianIndex(GALL_BLADDER)].treated = true;
      mtw.mt.meridians[getMeridianIndex(STOMACH)].treated = true;
      mtw.mt.meridians[getMeridianIndex(BLADDER)].treated = true;
      mtw.mt.meridians[getMeridianIndex(KIDNEY)].treated = true;
      mtw.mt.meridians[getMeridianIndex(SPLEEN)].treated = true;
      mtw.mt.meridians[getMeridianIndex(LIVER)].treated = true;
      mtw.mt.meridians[getMeridianIndex(LUNG)].treated = true;
      mtw.mt.meridians[getMeridianIndex(PERICARDIUM)].treated = true;
      mtw.mt.meridians[getMeridianIndex(HEART)].treated = true;
      mtw.mt.meridians[getMeridianIndex(LARGE_INTESTINE)].treated = true;
      mtw.mt.meridians[getMeridianIndex(TRIPLE_ENERGIZER)].treated = true;
      mtw.mt.meridians[getMeridianIndex(SMALL_INTESTINE)].treated = true;
      mtw.mt = addTreatmentPoint(TRIPLE_ENERGIZER + " 5", "Belt Block", mtw.mt, allMeridians, true);
      mtw.mt = addTreatmentPoint(GALL_BLADDER + " 41", "Belt Block", mtw.mt, allMeridians, true);
    }

    //finally we'll look for "group point" combinations
    if ((getUntreatedState(LUNG, mtw.mt) == LOW &&
            getUntreatedState(PERICARDIUM, mtw.mt) == LOW &&
            getUntreatedState(HEART, mtw.mt) == LOW) ||
        (getUntreatedState(LUNG, mtw.mt) == HIGH &&
            getUntreatedState(PERICARDIUM, mtw.mt) == HIGH &&
            getUntreatedState(HEART, mtw.mt) == HIGH)) {
      //just treat GB22
      List<String> meridiansAffected = [];
      meridiansAffected.add(LUNG);
      meridiansAffected.add(PERICARDIUM);
      meridiansAffected.add(HEART);
      mtw.mt = addTreatmentPoint(GALL_BLADDER + " 22", "LU, PC, HT Group", mtw.mt, meridiansAffected, true);
      mtw.mt.meridians[getMeridianIndex(LUNG)].treated = true;
      mtw.mt.meridians[getMeridianIndex(PERICARDIUM)].treated = true;
      mtw.mt.meridians[getMeridianIndex(HEART)].treated = true;
    }

    if ((getUntreatedState(LARGE_INTESTINE, mtw.mt) == LOW &&
            getUntreatedState(TRIPLE_ENERGIZER, mtw.mt) == LOW &&
            getUntreatedState(SMALL_INTESTINE, mtw.mt) == LOW) ||
        (getUntreatedState(LARGE_INTESTINE, mtw.mt) == HIGH &&
            getUntreatedState(TRIPLE_ENERGIZER, mtw.mt) == HIGH &&
            getUntreatedState(SMALL_INTESTINE, mtw.mt) == HIGH)) {
      //just treat GB13
      List<String> meridiansAffected = [];
      meridiansAffected.add(LARGE_INTESTINE);
      meridiansAffected.add(TRIPLE_ENERGIZER);
      meridiansAffected.add(SMALL_INTESTINE);
      mtw.mt = addTreatmentPoint(GALL_BLADDER + " 13", "LI, TE, SI Group", mtw.mt, meridiansAffected, true);
      mtw.mt.meridians[getMeridianIndex(LARGE_INTESTINE)].treated = true;
      mtw.mt.meridians[getMeridianIndex(TRIPLE_ENERGIZER)].treated = true;
      mtw.mt.meridians[getMeridianIndex(SMALL_INTESTINE)].treated = true;
    }

    if ((getUntreatedState(STOMACH, mtw.mt) == LOW &&
            getUntreatedState(BLADDER, mtw.mt) == LOW &&
            getUntreatedState(GALL_BLADDER, mtw.mt) == LOW) ||
        (getUntreatedState(STOMACH, mtw.mt) == HIGH &&
            getUntreatedState(BLADDER, mtw.mt) == HIGH &&
            getUntreatedState(GALL_BLADDER, mtw.mt) == HIGH)) {
      //just treat ST3
      List<String> meridiansAffected = [];
      meridiansAffected.add(STOMACH);
      meridiansAffected.add(GALL_BLADDER);
      meridiansAffected.add(BLADDER);
      mtw.mt = addTreatmentPoint(STOMACH + " 3", "ST, GB, BL Group", mtw.mt, meridiansAffected, true);
      mtw.mt.meridians[getMeridianIndex(STOMACH)].treated = true;
      mtw.mt.meridians[getMeridianIndex(GALL_BLADDER)].treated = true;
      mtw.mt.meridians[getMeridianIndex(BLADDER)].treated = true;
    }

    if ((getUntreatedState(KIDNEY, mtw.mt) == LOW &&
            getUntreatedState(PERICARDIUM, mtw.mt) == LOW &&
            getUntreatedState(LIVER, mtw.mt) == LOW) ||
        (getUntreatedState(KIDNEY, mtw.mt) == HIGH &&
            getUntreatedState(PERICARDIUM, mtw.mt) == HIGH &&
            getUntreatedState(LIVER, mtw.mt) == HIGH)) {
      //just treat CV3
      List<String> meridiansAffected = [];
      meridiansAffected.add(KIDNEY);
      meridiansAffected.add(PERICARDIUM);
      meridiansAffected.add(LIVER);
      mtw.mt = addTreatmentPoint(CONCEPTION_VESSEL + " 3", "KI, SP, LV Group", mtw.mt, meridiansAffected, true);
      mtw.mt.meridians[getMeridianIndex(KIDNEY)].treated = true;
      mtw.mt.meridians[getMeridianIndex(PERICARDIUM)].treated = true;
      mtw.mt.meridians[getMeridianIndex(LIVER)].treated = true;
    }
    return mtw;
  }

  //derives all 6 permutations of advanced, and assigns the best advanced and second best advanced options to their respective arrays.
  deriveAdvanced(num scale) {
    for (int i = 0; i < 6; i++) {
      MeridiansAndTreatmentsWrapper mtw = _meridiansAndTreatments[i];
      mtw = commonAdvancedTreatment(mtw, scale);
      switch (i) {
        case 0:
          {
            mtw.type = "lsk";
            mtw.priority = 6;
            mtw = luo(mtw);
            mtw = sheng(mtw);
            mtw = ko(mtw);
          }
          break;
        case 1:
          {
            mtw.type = "lks";
            mtw.priority = 5;
            mtw = luo(mtw);
            mtw = ko(mtw);
            mtw = sheng(mtw);
          }
          break;
        case 2:
          {
            mtw.type = "slk";
            mtw.priority = 5;
            mtw = sheng(mtw);
            mtw = luo(mtw);
            mtw = ko(mtw);
          }
          break;
        case 3:
          {
            mtw.type = "skl";
            mtw.priority = 5;
            mtw = sheng(mtw);
            mtw = ko(mtw);
            mtw = luo(mtw);
          }
          break;
        case 4:
          {
            mtw.type = "kls";
            mtw.priority = 5;
            mtw = ko(mtw);
            mtw = luo(mtw);
            mtw = sheng(mtw);
          }
          break;
        case 5:
          {
            mtw.type = "ksl";
            mtw.priority = 5;
            mtw = ko(mtw);
            mtw = sheng(mtw);
            mtw = luo(mtw);
          }
          break;
      }
      //ok, by now, all the splits are taken care of.. so sedate the highs and tonify lows
      for (int j = 0; j < 12; j++) {
        //if the meridian is HIGH and still untreated, add the sedation point for that meridian.
        if (mtw.mt.meridians[j].state == HIGH && mtw.mt.meridians[j].treated == false) {
          mtw = addSedationPoint(mtw, j);
          mtw.mt.meridians[j].treated = true;
        }
        //if the meridian is LOW and still untreated, add the tonification point for that meridian.
        if (mtw.mt.meridians[j].state == LOW && mtw.mt.meridians[j].treated == false) {
          mtw = addTonificationPoint(mtw, j);
          mtw.mt.meridians[j].treated = true;
        }
      }
      _meridiansAndTreatments[i] = mtw;
    }

    //at this point, we now have all the advanced treatments calculated, and are ready to figure out which one has the fewest points,
    //and break ties.

    //Bubblesort on the number of treatment points..cheap and dirty, but should work - also sorts on priority
    for (int i = 0; i < _meridiansAndTreatments.length - 2; i++) {
      for (int j = i + 1; j < _meridiansAndTreatments.length - 2; j++) {
        if (_meridiansAndTreatments[i].mt.treatments.length > _meridiansAndTreatments[j].mt.treatments.length) {
          //swap due to length
          MeridiansAndTreatmentsWrapper tmp = _meridiansAndTreatments[j];
          _meridiansAndTreatments[j] = _meridiansAndTreatments[i];
          _meridiansAndTreatments[i] = tmp;
        } else if (_meridiansAndTreatments[j].mt.treatments.length == _meridiansAndTreatments[i].mt.treatments.length) {
          //sort on priority
          if (_meridiansAndTreatments[i].priority < _meridiansAndTreatments[j].priority) {
            //swap them
            MeridiansAndTreatmentsWrapper tmp = _meridiansAndTreatments[j];
            _meridiansAndTreatments[j] = _meridiansAndTreatments[i];
            _meridiansAndTreatments[i] = tmp;
          }
        }
      }
    }
  }
  
  //receives a MeridiansAndTreatments wrapper, along with an index for a meridian which needs the
  //sedation point added. Looks up and adds the point for that meridian to the wrapper, then returns
  //the modified wrapper.
  addSedationPoint(MeridiansAndTreatmentsWrapper mtw, int meridianIndex) {
    List<String> sedationPoints = [
      LUNG + " 5",
      PERICARDIUM + " 7",
      HEART + " 7",
      SMALL_INTESTINE + " 8",
      TRIPLE_ENERGIZER + " 10",
      LARGE_INTESTINE + " 2",
      SPLEEN + " 5",
      LIVER + " 2",
      KIDNEY + " 1",
      BLADDER + " 65",
      GALL_BLADDER + " 38",
      STOMACH + " 45"
    ];
    mtw.mt = addTreatmentPoint(sedationPoints[meridianIndex], allMeridians[meridianIndex] + " Excessive", mtw.mt,
        [allMeridians[meridianIndex]], false);
    return mtw;
  }

  //receives a MeridiansAndTreatments wrapper, along with an index for a meridian which needs the
  //tonification point added. Looks up and adds the point for that meridian to the wrapper, then returns
  //the modified wrapper.
  addTonificationPoint(MeridiansAndTreatmentsWrapper mtw, int meridianIndex) {
    List<String> tonificationPoints = [
      LUNG + " 9",
      PERICARDIUM + " 9",
      HEART + " 9",
      SMALL_INTESTINE + " 3",
      TRIPLE_ENERGIZER + " 3",
      LARGE_INTESTINE + " 11",
      SPLEEN + " 2",
      LIVER + " 8",
      KIDNEY + " 7",
      BLADDER + " 67",
      GALL_BLADDER + " 43",
      STOMACH + " 41"
    ];
    mtw.mt = addTreatmentPoint(tonificationPoints[meridianIndex], allMeridians[meridianIndex] + " Deficient", mtw.mt,
        [allMeridians[meridianIndex]], false);
    return mtw;
  }

  //When deriving advanced treatments, several alternatives will be calculated first, and then the best alternative
  //will be promoted to the final solution. This method just sets the basic option (which may be the best option even
  //when compared with the other advanced options.
  setBasic(MeridiansAndTreatmentsWrapper mt) {
    _meridiansAndTreatments[0] = mt;
  }

  //wholesale replace all the meridians and treatments options.
  setMeridians(MeridiansAndTreatments newMT) {
    for (int i = 0; i < 6; i++) {
      for (int j = 0; j < 12; j++) {
        _meridiansAndTreatments[i].mt.meridians[j] = newMT.meridians[j];
      }
    }
  }

  /*
  Generated getters and setters
   */
  bool get tsingAtHome => _tsingAtHome;
  set tsingAtHome(bool value) {
    _tsingAtHome = value;
  }

  List<MeridiansAndTreatmentsWrapper> get meridiansAndTreatments => _meridiansAndTreatments;
  set meridiansAndTreatments(List<MeridiansAndTreatmentsWrapper> value) {
    _meridiansAndTreatments = value;
  }
}

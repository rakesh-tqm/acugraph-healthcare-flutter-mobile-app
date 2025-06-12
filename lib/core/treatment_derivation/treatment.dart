/*
  The Treatment class is *the* way that treatment derivation and all graph calculations occur. When graph calculations
  are needed, a new Treater instance should be created, loaded with the information for the exam you need to deal with,
  then the various methods it provides called to run the calculations, etc.

  This was designed with a pretty tight coupling to the UI in Xojo (UI components would directly reach into the Treater
  to run calculations and retrieve information) so there may need to be some additional refactoring once we get this
  integrated into the Flutter app. In Xojo, there is a class called "ChartPart" which is a child of a Canvas. ChartPart
  is responsible for actually doing all the drawing of the graphs in AcuGraph 5, so it has an instance of Treater that it
  uses for all the calculations. I imagine we'll need to do something similar in Flutter so that the data needed to draw
  graphs is available wherever graph drawing occurs.
 */

import 'dart:math';
import 'dart:ui';

import 'package:acugraph6/core/treatment_derivation/expert_tx.dart';
import 'package:acugraph6/data_layer/models/exam.dart';
import 'package:acugraph6/data_layer/models/exam_imbalance_override.dart';
import 'package:acugraph6/utils/utils.dart';

import '../../data_layer/custom/search_result.dart';
import '../../data_layer/drivers/logger.dart';
import '../../data_layer/models/patient.dart';
import '../../data_layer/models/preference.dart';
import '../../utils/preferences.dart';
import "constants.dart";
import 'intelligraph.dart';
import 'meridian.dart';
import 'meridians_and_treatments.dart';
import 'treatment_point.dart';
import 'treatment_protocol.dart';
import 'treatment_utils.dart';
import 'upper_lower_level_data.dart';
import 'treatment_recommendation.dart';

class Treatment {
  String currExamId = "";
  DateTime examDateTime = DateTime.now();
  String examType = "";
  String fiveElements1PointCount = "";
  String fiveElements2PointCount = "";
  num mean = -1;
  List<Meridian> meridians = [];
  num patientAge = 0;
  String patientGender = "";
  TreatmentProtocol tp = TreatmentProtocol();
  bool fiveElementsMatchesBasic = false;
  bool isScreeningMode = false;

  //Public factory, which calls the private constructor then finishes any async work required to finish initialization
  static Future<Treatment> create(String examUUID) async {
    Treatment t = Treatment._create(examUUID);
    await t.populate();
    return t;
  }

  //private constructor used to set up the list of Meridians with the correct names, populate the values for this treater
  // from a specific exam, and finish up any other async initialization that is required.
  Treatment._create(String examUUID) {
    currExamId = examUUID;
  }

  /*
  This function is used to populate this treater for use with the currently-set examUUID. Clears out the existing
  Meridians (in case we are re-using this treater) and re-calculates the intelligraph numbers for the baseline readings

   */
  populate() async {
    meridians =
        []; //clear out any meridians that may have already been populated.
    //Set up new blank meridians to operate on.
    for (int i = 0; i < 12; i++) {
      Meridian m = Meridian();
      m.name = meridianIndex[i];
      meridians.add(m);
    }
    //pull out the exam record
    Exam e = await Exam()
        .fetchById(currExamId, include: ['patient', 'imbalance-overrides']);

    Map chartValues = Map();
    chartValues[LEFT_ABBREV + "-" + LUNG] = e.llu;
    chartValues[RIGHT_ABBREV + "-" + LUNG] = e.rlu;
    chartValues[LEFT_ABBREV + "-" + PERICARDIUM] = e.lp;
    chartValues[RIGHT_ABBREV + "-" + PERICARDIUM] = e.rp;
    chartValues[LEFT_ABBREV + "-" + HEART] = e.lht;
    chartValues[RIGHT_ABBREV + "-" + HEART] = e.rht;
    chartValues[LEFT_ABBREV + "-" + SMALL_INTESTINE] = e.lsi;
    chartValues[RIGHT_ABBREV + "-" + SMALL_INTESTINE] = e.rsi;
    chartValues[LEFT_ABBREV + "-" + TRIPLE_ENERGIZER] = e.lth;
    chartValues[RIGHT_ABBREV + "-" + TRIPLE_ENERGIZER] = e.rth;
    chartValues[LEFT_ABBREV + "-" + LARGE_INTESTINE] = e.lli;
    chartValues[RIGHT_ABBREV + "-" + LARGE_INTESTINE] = e.rli;
    chartValues[LEFT_ABBREV + "-" + SPLEEN] = e.lsp;
    chartValues[RIGHT_ABBREV + "-" + SPLEEN] = e.rsp;
    chartValues[LEFT_ABBREV + "-" + LIVER] = e.llv;
    chartValues[RIGHT_ABBREV + "-" + LIVER] = e.rlv;
    chartValues[LEFT_ABBREV + "-" + KIDNEY] = e.lk;
    chartValues[RIGHT_ABBREV + "-" + KIDNEY] = e.rk;
    chartValues[LEFT_ABBREV + "-" + BLADDER] = e.lbl;
    chartValues[RIGHT_ABBREV + "-" + BLADDER] = e.rbl;
    chartValues[LEFT_ABBREV + "-" + GALL_BLADDER] = e.lgb;
    chartValues[RIGHT_ABBREV + "-" + GALL_BLADDER] = e.rgb;
    chartValues[LEFT_ABBREV + "-" + STOMACH] = e.lst;
    chartValues[RIGHT_ABBREV + "-" + STOMACH] = e.rst;

    //is this a screening exam? If there is no definitive value set in the db, default to false.
    isScreeningMode = e.screeningMode ??= false;

    //set the exam method and date created
    examType = e.method ??=
        SOURCE_POINTS; //default to source points if there is something wonky.
    examDateTime = e.createdAt!;
    //pull out the patient from the exam
    Patient p = e.patient!;
    //run the intelligraph calculations on the chartValues from the exam
    Intelligraph ig = Intelligraph();
    chartValues = await ig.processExamValues(
        chartValues, p.ageAtDate(e.createdAt!).toString(), p.gender!);
    //Assign the new intelligraph'd values to the left and right sides of each meridian
    for (int i = 0; i < meridianIndex.length; i++) {
      //since meridianIndex is in the same order as meridians, we can just loop through them to assign all the
      //values we need in the treater.
      meridians[i].leftValue =
          chartValues[LEFT_ABBREV + "-" + meridianIndex[i]];
      meridians[i].rightValue =
          chartValues[RIGHT_ABBREV + "-" + meridianIndex[i]];
    }
    //calculate this graph's mean
    num mean = calcMean();

    //calculate the color of each leg of the meridian

    //Calculate the split and normal ranges.
    num splitRange = await calcSplitRange();
    num normalOffset = await calcNormalOffset();

    //Look at exam imbalance overrides to pass to calcColor
    for (int i = 0; i < 12; i++) {
      calcColor(mean, i, meridians[i].name, false, splitRange, normalOffset,
          e.imbalanceOverrides);
    }
    //Logger.debug("Treatment.populate complete for exam with ID: " + currExamId);
  }

  //Add up the left and right values of both meridians, then divide by 2 to ascertain the "average" value of the 2
  //meridians.
  calcAvg(Meridian m1, Meridian m2) {
    return (m1.leftValue + m2.leftValue + m1.rightValue + m2.rightValue) / 2;
  }

  // Calculate the "difference" between 2 meridians.
  calcDifference(Meridian m1, Meridian m2) {
    return ((m1.leftValue + m1.rightValue) - (m2.leftValue + m2.rightValue))
        .abs();
  }

  //Calculate the mean of the graph. This is basically "add all 24 measurements together, then divide by 24" - but there
  //are some rules - the math is different when it's a screening exam. We throw out outliers, etc.
  calcMean() {
    List<int> values = [];
    for (int i = 0; i < 12; i++) {
      values.add(meridians[i].leftValue);
      values.add(meridians[i].rightValue);
    }

    num total = 0;
    for (int v in values) {
      total += v;
    }

    num result = total / 24;
    //for AG5 and later, we are *always* calculating the mean with outliers removed. But we are not updating the UI to
    //reflect this at all. In AG4 and older, there was a "normalize" button, but for 5 and newer we are making this
    //the standard and only behavior.

    //now have the raw mean, so re-calculate with outliers tossed out
    //reset total.
    total = 0;
    int count =
        0; //to keep track of how many measurements we actually wind up using after tossing out outliers.
    //loop through the values of the graph again
    for (int i = 0; i < values.length; i++) {
      //find out if this value is more than 50 away from the original mean
      if ((result - values[i]).abs() < 50) {
        //this is close enough to the mean that I will include it.
        total += values[i];
        count++;
      }
    }

    //calculate the new mean by taking the sum of the values that are not outliers (calculated above and stored in the variable "result") and dividing by the number of values that were not considered outliers. ("j")
    result = (total / count).toInt();
    mean = result.round();
    return mean;
  }

  //calculate the average of an entire element, by taking a simple average of the individual readings for both sides of
  //each meridian.
  //elements are as follows:
  //0: fire
  //1: earth
  //2: metal
  //3: water
  //4: wood
  calcElementAverage(int elementID) {
    num average = 0;
    switch (elementID) {
      case 0:
        {
          //Fire
          //PC, TE, HT, SI
          Meridian m1 = meridians[meridianIndex.indexOf(PERICARDIUM)];
          Meridian m2 = meridians[meridianIndex.indexOf(TRIPLE_ENERGIZER)];
          Meridian m3 = meridians[meridianIndex.indexOf(HEART)];
          Meridian m4 = meridians[meridianIndex.indexOf(SMALL_INTESTINE)];
          average = avgOfFour(
              m1.leftValue, m1.rightValue, m2.leftValue, m2.rightValue);
          average = (average +
                  avgOfFour(m3.leftValue, m3.rightValue, m4.leftValue,
                      m4.rightValue)) /
              2 as int;
        }
        break;
      case 1:
        {
          //Earth
          //SP, ST
          Meridian m1 = meridians[meridianIndex.indexOf(SPLEEN)];
          Meridian m2 = meridians[meridianIndex.indexOf(STOMACH)];
          average = avgOfFour(
              m1.leftValue, m1.rightValue, m2.leftValue, m2.rightValue);
        }
        break;
      case 2:
        {
          //Metal
          //LU, LI
          Meridian m1 = meridians[meridianIndex.indexOf(LUNG)];
          Meridian m2 = meridians[meridianIndex.indexOf(LARGE_INTESTINE)];
          average = avgOfFour(
              m1.leftValue, m1.rightValue, m2.leftValue, m2.rightValue);
        }
        break;
      case 3:
        {
          //Water
          //KI, BL
          Meridian m1 = meridians[meridianIndex.indexOf(KIDNEY)];
          Meridian m2 = meridians[meridianIndex.indexOf(BLADDER)];
          average = avgOfFour(
              m1.leftValue, m1.rightValue, m2.leftValue, m2.rightValue);
        }
        break;
      case 4:
        {
          //Wood
          //LR, GB
          Meridian m1 = meridians[meridianIndex.indexOf(LIVER)];
          Meridian m2 = meridians[meridianIndex.indexOf(GALL_BLADDER)];
          average = avgOfFour(
              m1.leftValue, m1.rightValue, m2.leftValue, m2.rightValue);
        }
        break;
    }
    return average;
  }

  deriveAssociatedTXPoints() {
    List<TreatmentPoint> txPoints = [];
    for (int i = 0; i < meridians.length; i++) {
      if (meridians[i].state == HIGH || meridians[i].state == LOW) {
        TreatmentPoint p = TreatmentPoint();
        p.pointName = getAssociatedTXPointFromMeridianName(meridians[i].name);
        if (meridians[i].state == LOW) {
          p.pointReason = meridians[i].name + DEFICIENT;
        } else {
          p.pointReason = meridians[i].name + EXCESSIVE;
        }
        p.isGroupPoint = false;
        p.meridiansAffected = [meridians[i].name];
        txPoints.add(p);
      }
    }
    return txPoints;
  }

  //Normal offsets (i.e., what constitutes the "normal" range) can be set at the exam-type level. So you can have a different
  //normal offset for Source vs Jing-well vs Ryodoraku exam types.
  calcNormalOffset() async {
    if (examType == SOURCE_POINTS) {
      examType = "source";
    } else if (examType == TSING_POINTS) {
      examType = "tsing";
    } else if (examType == RYODORAKU_POINTS) {
      examType = "ryodoraku";
    }
    int normalOffset = 0;
    //we need to dip into the preferences to see what they have chosen - fixed or proportional.
    Preference p =
        await Preference().fetchByName(examType + "_measurement_calculations");
    String offsetType = p.value!;
    if (offsetType == "fixed") {
      Preference p = await Preference()
          .fetchByName(examType + "_measurement_calculations_normal_range");
      int normalOffset = int.parse(p.value!);
    } else {
      //if it's not fixed, it's proportional.
      // y = -0.0003x2 + 0.13x + 4.5838
      // y=normal range
      // x=mean
      // Note that this equation is only valid for means from 25-175. Below mean 25,
      // the normal range is 8. Above mean 175, the normal range is 20.
      if (mean < 25) {
        normalOffset = 8;
      } else if (mean > 175) {
        normalOffset = 20;
      } else {
        normalOffset =
            ((-0.0003 * pow(mean, 2)) + (0.13 * mean) + 4.5838).toInt();
      }
    }
    return normalOffset;
  }

  //Split ranges can be either a fixed value (anything more than X is considered a split), or it can be calculated
  //in a proportional way. Look up the user's preference, and return the split range as an int.
  //NOTE: The mean must have already been calculated for this exam (and stored in the local mean var) or this will fail.
  calcSplitRange() async {
    if (examType == SOURCE_POINTS) {
      examType = "source";
    } else if (examType == TSING_POINTS) {
      examType = "tsing";
    } else if (examType == RYODORAKU_POINTS) {
      examType = "ryodoraku";
    }

    Preference p =
        await Preference().fetchByName(examType + "_measurement_calculations");
    String calcType = p.value!;
    if (calcType == "fixed") {
      Preference p = await Preference()
          .fetchByName(examType + "_measurement_calculations_split_value");
      return num.parse(p.value!);
    } else {
      return (-0.0003 * pow(mean, 2)) + (0.175 * mean) + 10;
    }
  }

  //Reset the state (i.e., has it been treated?) for all meridians.
  clearMeridians() {
    for (int i = 0; i < meridians.length; i++) {
      meridians[i].state = "";
    }
  }

  //simple lookup of the associated or "Back Shu" points for each meridian.
  getAssociatedTXPointFromMeridianName(String meridianName) {
    return associatedPoints[meridianName];
  }

  //Each associated point has a "reason" attached to it. Simple lookup of that reason by associated point name.
  getAssociatedReasonStringFromPointName(String pointName) {
    return associatedPointReasons[pointName];
  }

  //Treatments can be ordered in various ways, including anatomically (i.e., list the points on the hands first,
  // then on the feet, etc. This returns where the point is located, anatomically.
  getAnatomicalLocationForPointName(String pointName) {
    return anatomicalPointLocations[pointName];
  }

  //Channel divergence points have special reasons for recommendation. Retrieve the reason for the given point name.
  getChannelDivergencesReasonStringFromPointName(String pointName) {
    return channelDivergencesPointReasons[pointName];
  }

  //Pull out the point used for EV treatments based on the meridian name.
  getEvTXPointFromMeridianName(String name) {
    return evMeridianTxPoints[name];
  }

  getAuricularTonificationPointFromMeridianName(String name) {
    return auricularTonificationPoints[name];
  }

  getAuricularLuoPointFromMeridianName(String name) {
    return auricularLuoPoints[name];
  }

  //this will inspect the excessive and deficient meridian, and decide which one gets treated on which side.
  // Returns the side indicated by mode - either excessive or deficient.
  getEvTxSideForMeridian(String excessive, String deficient, String mode) {
    String eTXSide = "";
    String dTXSide = "";
    bool eTXSideEqual = false;
    if (getMeridian(excessive).leftValue > getMeridian(excessive).rightValue) {
      //treat on the left side
      eTXSide = "L";
    } else if (getMeridian(excessive).leftValue <
        getMeridian(excessive).rightValue) {
      //treat on the right side
      eTXSide = "R";
    } else {
      //they are equal. Default to left.
      eTXSide = "L";
      eTXSideEqual = true;
    }
    if (getMeridian(deficient).leftValue > getMeridian(deficient).rightValue) {
      //treat on the left side
      dTXSide = "R";
      if (eTXSideEqual) {
        dTXSide = "L";
      } else if (getMeridian(deficient).leftValue <
          getMeridian(deficient).rightValue) {
        //treat on the right side
        dTXSide = "L";
        if (eTXSideEqual) {
          eTXSide = "R";
        }
      } else {
        //treat on the side opposite the right side
        if (eTXSide == "L") {
          dTXSide = "R";
        } else {
          dTXSide = "L";
        }
      }
    }

    if (mode == "deficient") {
      return dTXSide;
    }
    return eTXSide;
  }

  //Look through all the values of the exam (left and right side) and return the single highest measurement.
  findHighestExamValue() {
    num curr = 0;
    num mymax = 0;
    for (int i = 0; i < meridians.length; i++) {
      curr = meridians[i].leftValue;
      if (curr > mymax) {
        mymax = curr;
      }
      curr = meridians[i].rightValue;
      if (curr > mymax) {
        mymax = curr;
      }
    }
    return mymax;
  }

  //simple accessor - only putting it in because it is used in a bunch of places in Xojo. In Dart, it's probably just
  //simpler to access the public property directly.
  setCurrExamId(String id) {
    currExamId = id;
  }

  //Just like findHighestExamValue, this method finds the single lowest measured value of a given exam.
  findLowestExamValue() {
    num curr = 0;
    num mymin = 200;
    for (int i = 0; i < meridians.length; i++) {
      curr = meridians[i].leftValue;
      if (curr < mymin) {
        mymin = curr;
      }
      curr = meridians[i].rightValue;
      if (curr < mymin) {
        mymin = curr;
      }
    }
    return mymin;
  }

  // gives you the range that your graph fits.
  // This will be a vertical bar with scale and carat. Text label is “Energy Variablity: xx%”.
  //  Will have demarcations of high, moderate, low, based on percentages.Percentages will
  // be figured out by Adrian. This bar will be nearly identical to the energy level bar except
  // the demarcations will be different values, and actually shown as percentages not static
  // numbers.
  // Calculations:
  // 1.0-(((max-min)-(0.3*mean))/Max)
  //
  // In english, this is 1 minus a fraction.
  //
  // That fraction has a numerator and a denominator.
  //
  // The numerator is this: (max-min)-(.3*mean)
  // The denominator the max reading from the exam.
  //
  //  August 1, 2005
  // After much tribulation, here is the best formula I can come up with for
  // the energy balance equation:
  //
  // 1.0-(((max-min)-(0.3*mean))/range)
  //
  // This equation is a bit better than the one we were using. And, as
  // always, the result needs to max out at 100%.
  getEnergyStability() {
    num max = 0.0;
    num min = 0.0;
    num range = 0.0;
    num mean = 0.0;
    num result = 0.0;

    max = findHighestExamValue();
    min = findLowestExamValue();
    range = 200.0;
    mean = calcMean();

    result = (1.0 - (((max - min) - (0.3 * mean)) / range)) * 100;
    if (result > 100) {
      result = 100;
    }
    return result;
  }

  //Meridians have all different kinds (or types) of points. Give this method the meridian and type of point you are
  //interested in, and it'll return the exact point you have requested. Leverages all the arrays/dictionaries/lists of
  //points from the constants in the treatment_derivation library.
  getPointTypeForMeridian(String meridian, String type) {
    switch (type) {
      case POINT_TYPE_SOURCE:
        {
          return sourcePoints[meridian];
        }
      case POINT_TYPE_JING_WELL:
        {
          return jingWellPoints[meridian];
        }
      case POINT_TYPE_LUO:
        {
          return luoPoints[meridian];
        }
      case POINT_TYPE_TONIFICATION:
        {
          return tonificationPoints[meridian];
        }
      case POINT_TYPE_SEDATION:
        {
          return sedationPoints[meridian];
        }
      case POINT_TYPE_ALARM:
        {
          return alarmPoints[meridian];
        }
      case POINT_TYPE_HORARY:
        {
          return horaryPoints[meridian];
        }
      case POINT_TYPE_SPRING:
        {
          return springPoints[meridian];
        }
      case POINT_TYPE_STREAM:
        {
          return streamPoints[meridian];
        }
      case POINT_TYPE_RIVER:
        {
          return riverPoints[meridian];
        }
      case POINT_TYPE_SEA:
        {
          return seaPoints[meridian];
        }
      case POINT_TYPE_FIRE:
        {
          return firePoints[meridian];
        }
      case POINT_TYPE_EARTH:
        {
          return earthPoints[meridian];
        }
      case POINT_TYPE_METAL:
        {
          return metalPoints[meridian];
        }
      case POINT_TYPE_WATER:
        {
          return waterPoints[meridian];
        }
      case POINT_TYPE_WOOD:
        {
          return woodPoints[meridian];
        }
      case POINT_TYPE_RYODORAKU:
        {
          return ryodorakuPoints[meridian];
        }
      case POINT_TYPE_ASSOCIATED:
        {
          return associatedPoints[meridian];
        }
      case POINT_TYPE_XI:
        {
          return xiPoints[meridian];
        }
      case POINT_TYPE_LOWER_HE_SEA:
        {
          return heSeaPoints[meridian];
        }
      case POINT_TYPE_ENTRY:
        {
          return entryPoints[meridian];
        }
      case POINT_TYPE_EXIT:
        {
          return exitPoints[meridian];
        }
    }
  }

  //We want the splits to always be arranged in the following order:
  //Left hand, right hand, left foot, right foot, where we decide to measure them based on which hand or foot has the
  // "low" side.
  //So, low sides on the left hand, then low sides on the right hand, then low sides on the left foot, then low sides
  // on the right foot.
  getSplits() {
    List<Meridian> leftHand = [];
    List<Meridian> rightHand = [];
    List<Meridian> leftFoot = [];
    List<Meridian> rightFoot = [];

    List<String> handMeridians = [
      LUNG,
      LARGE_INTESTINE,
      HEART,
      SMALL_INTESTINE,
      PERICARDIUM,
      TRIPLE_ENERGIZER
    ];
    //List<String> footMeridians = [STOMACH, SPLEEN, BLADDER, KIDNEY, GALL_BLADDER, LIVER];

    List<Meridian> splits = [];
    for (int i = 0; i < meridians.length; i++) {
      if (meridians[i].state == SPLIT) {
        if (handMeridians.contains(meridians[i].name)) {
          if (meridians[i].leftValue < meridians[i].rightValue) {
            leftHand.add(meridians[i]);
          } else {
            rightHand.add(meridians[i]);
          }
        } else {
          //this must be a foot meridian
          if (meridians[i].leftValue < meridians[i].rightValue) {
            leftFoot.add(meridians[i]);
          } else {
            rightFoot.add(meridians[i]);
          }
        }
      }
    }

    //now put them in order of left hand,  right hand, left foot, right foot.
    splits.addAll(leftHand);
    splits.addAll(rightHand);
    splits.addAll(leftFoot);
    splits.addAll(rightFoot);

    return splits;
  }

  //Calculates the average value of all the left sides of the measured meridians
  getLeftLevel() {
    int denom = 12;
    if (isScreeningMode) {
      denom = 6;
    }
    int total = 0;
    for (int i = 0; i < 12; i++) {
      total += meridians[i].leftValue;
    }
    return total / denom;
  }

  //Calculates the average value of all the right sides of the measured meridians
  getRightLevel() {
    int denom = 12;
    if (isScreeningMode) {
      denom = 6;
    }
    int total = 0;
    for (int i = 0; i < 12; i++) {
      total += meridians[i].rightValue;
    }
    return total / denom;
  }

  //get the average of all the 'lower' meridians - i.e., all the meridians on the lower torso, legs, and feet.
  getLowerLevel() {
    int denom = 12;
    if (isScreeningMode) {
      denom = 6;
    }
    int total = 0;
    for (int i = 6; i < 12; i++) {
      total += meridians[i].leftValue + meridians[i].rightValue;
    }
    return total / denom;
  }

  //get the average of all the 'upper' meridians - i.e., all the meridians on the upper torso, arms and hands
  getUpperLevel() {
    int denom = 12;
    if (isScreeningMode) {
      denom = 6;
    }
    int total = 0;
    for (int i = 0; i < 6; i++) {
      total += meridians[i].leftValue + meridians[i].rightValue;
    }
    return total / denom;
  }

  getUpperLowerLevel() {
    num upperLevel = 0.0;
    num lowerLevel = 0.0;
    UpperLowerLevelData ulld = UpperLowerLevelData();
    upperLevel = getUpperLevel();
    lowerLevel = getLowerLevel();
    if (upperLevel < lowerLevel) {
      ulld.upperLowerLevel = (1 - (upperLevel / lowerLevel)) * 100;
      ulld.upperLowerString = "⬇";
      //In Xojo, Windows and Mac were different in how they supported unicode characters. For Windows, we had to do this:
      //ulld.upperLowerString = &u2193
      //hopefully Flutter just deals with the down arrow glyph without any issues on all platforms.
    } else if (lowerLevel < upperLevel) {
      ulld.upperLowerLevel = (1 - (lowerLevel / upperLevel)) * 100;
      ulld.upperLowerString = "⬆";
      //again, if the up-facing arrow causes any problems, we did this on Windows in Xojo:
      //ulld.upperLowerString = &u2191
    } else {
      //don't divide by zero!
      ulld.upperLowerLevel = 0;
    }
    return ulld;
  }

  //simple accessor to pull out the meridian with a given name
  getMeridian(String name) {
    return meridians[meridianIndex.indexOf(name)];
  }

  //quick way to get the index of a meridian from the meridianIndex array
  getMeridianIndex(String name) {
    return meridianIndex.indexOf(name);
  }

  //Looking at a specific element, compare the 2 meridians, and return the name of the higher average valued meridian.
  getBestMeridian(String elementName) {
    switch (elementName) {
      case EMPEROR_FIRE:
        {
          //HT, SI
          if ((mean -
                      avgOfTwo(
                          meridians[meridianIndex.indexOf(HEART)].leftValue,
                          meridians[meridianIndex.indexOf(HEART)].rightValue))
                  .abs() <
              (mean -
                      avgOfTwo(
                          meridians[meridianIndex.indexOf(SMALL_INTESTINE)]
                              .leftValue,
                          meridians[meridianIndex.indexOf(SMALL_INTESTINE)]
                              .rightValue))
                  .abs()) {
            return HEART;
          }
          return SMALL_INTESTINE;
        }
      case MINISTER_FIRE:
        {
          //P, TH
          if ((mean -
                      avgOfTwo(
                          meridians[meridianIndex.indexOf(PERICARDIUM)]
                              .leftValue,
                          meridians[meridianIndex.indexOf(PERICARDIUM)]
                              .rightValue))
                  .abs() <
              (mean -
                      avgOfTwo(
                          meridians[meridianIndex.indexOf(TRIPLE_ENERGIZER)]
                              .leftValue,
                          meridians[meridianIndex.indexOf(TRIPLE_ENERGIZER)]
                              .rightValue))
                  .abs()) {
            return PERICARDIUM;
          }
          return TRIPLE_ENERGIZER;
        }
      case METAL:
        {
          //LU, LI
          if ((mean -
                      avgOfTwo(meridians[meridianIndex.indexOf(LUNG)].leftValue,
                          meridians[meridianIndex.indexOf(LUNG)].rightValue))
                  .abs() <
              (mean -
                      avgOfTwo(
                          meridians[meridianIndex.indexOf(LARGE_INTESTINE)]
                              .leftValue,
                          meridians[meridianIndex.indexOf(LARGE_INTESTINE)]
                              .rightValue))
                  .abs()) {
            return LUNG;
          }
          return LARGE_INTESTINE;
        }
      case WATER:
        {
          //K, BL
          if ((mean -
                      avgOfTwo(
                          meridians[meridianIndex.indexOf(KIDNEY)].leftValue,
                          meridians[meridianIndex.indexOf(KIDNEY)].rightValue))
                  .abs() <
              (mean -
                      avgOfTwo(
                          meridians[meridianIndex.indexOf(BLADDER)].leftValue,
                          meridians[meridianIndex.indexOf(BLADDER)].rightValue))
                  .abs()) {
            return KIDNEY;
          }
          return BLADDER;
        }
      case WOOD:
        {
          //LV, GB
          if ((mean -
                      avgOfTwo(
                          meridians[meridianIndex.indexOf(LIVER)].leftValue,
                          meridians[meridianIndex.indexOf(LIVER)].rightValue))
                  .abs() <
              (mean -
                      avgOfTwo(
                          meridians[meridianIndex.indexOf(GALL_BLADDER)]
                              .leftValue,
                          meridians[meridianIndex.indexOf(GALL_BLADDER)]
                              .rightValue))
                  .abs()) {
            return LIVER;
          }
          return GALL_BLADDER;
        }
      case EARTH:
        {
          //SP, ST
          if ((mean -
                      avgOfTwo(
                          meridians[meridianIndex.indexOf(SPLEEN)].leftValue,
                          meridians[meridianIndex.indexOf(SPLEEN)].rightValue))
                  .abs() <
              (mean -
                      avgOfTwo(
                          meridians[meridianIndex.indexOf(STOMACH)].leftValue,
                          meridians[meridianIndex.indexOf(STOMACH)].rightValue))
                  .abs()) {
            return SPLEEN;
          }
          return STOMACH;
        }
    }
  }

  //Looking at a specific element, compare the 2 meridians, and return the name of the lower average valued meridian.
  //This method logic is *exactly* the same as getBestMeridian, but looks for the worst one instead.
  getWorstMeridian(String elementName) {
    switch (elementName) {
      case EMPEROR_FIRE:
        {
          //HT, SI
          if ((mean -
                      avgOfTwo(
                          meridians[meridianIndex.indexOf(HEART)].leftValue,
                          meridians[meridianIndex.indexOf(HEART)].rightValue))
                  .abs() >=
              (mean -
                      avgOfTwo(
                          meridians[meridianIndex.indexOf(SMALL_INTESTINE)]
                              .leftValue,
                          meridians[meridianIndex.indexOf(SMALL_INTESTINE)]
                              .rightValue))
                  .abs()) {
            return HEART;
          }
          return SMALL_INTESTINE;
        }
      case MINISTER_FIRE:
        {
          //P, TH
          if ((mean -
                      avgOfTwo(
                          meridians[meridianIndex.indexOf(PERICARDIUM)]
                              .leftValue,
                          meridians[meridianIndex.indexOf(PERICARDIUM)]
                              .rightValue))
                  .abs() >=
              (mean -
                      avgOfTwo(
                          meridians[meridianIndex.indexOf(TRIPLE_ENERGIZER)]
                              .leftValue,
                          meridians[meridianIndex.indexOf(TRIPLE_ENERGIZER)]
                              .rightValue))
                  .abs()) {
            return PERICARDIUM;
          }
          return TRIPLE_ENERGIZER;
        }
      case METAL:
        {
          //LU, LI
          if ((mean -
                      avgOfTwo(meridians[meridianIndex.indexOf(LUNG)].leftValue,
                          meridians[meridianIndex.indexOf(LUNG)].rightValue))
                  .abs() >=
              (mean -
                      avgOfTwo(
                          meridians[meridianIndex.indexOf(LARGE_INTESTINE)]
                              .leftValue,
                          meridians[meridianIndex.indexOf(LARGE_INTESTINE)]
                              .rightValue))
                  .abs()) {
            return LUNG;
          }
          return LARGE_INTESTINE;
        }
      case WATER:
        {
          //K, BL
          if ((mean -
                      avgOfTwo(
                          meridians[meridianIndex.indexOf(KIDNEY)].leftValue,
                          meridians[meridianIndex.indexOf(KIDNEY)].rightValue))
                  .abs() >=
              (mean -
                      avgOfTwo(
                          meridians[meridianIndex.indexOf(BLADDER)].leftValue,
                          meridians[meridianIndex.indexOf(BLADDER)].rightValue))
                  .abs()) {
            return KIDNEY;
          }
          return BLADDER;
        }
      case WOOD:
        {
          //LV, GB
          if ((mean -
                      avgOfTwo(
                          meridians[meridianIndex.indexOf(LIVER)].leftValue,
                          meridians[meridianIndex.indexOf(LIVER)].rightValue))
                  .abs() >=
              (mean -
                      avgOfTwo(
                          meridians[meridianIndex.indexOf(GALL_BLADDER)]
                              .leftValue,
                          meridians[meridianIndex.indexOf(GALL_BLADDER)]
                              .rightValue))
                  .abs()) {
            return LIVER;
          }
          return GALL_BLADDER;
        }
      case EARTH:
        {
          //SP, ST
          if ((mean -
                      avgOfTwo(
                          meridians[meridianIndex.indexOf(SPLEEN)].leftValue,
                          meridians[meridianIndex.indexOf(SPLEEN)].rightValue))
                  .abs() >=
              (mean -
                      avgOfTwo(
                          meridians[meridianIndex.indexOf(STOMACH)].leftValue,
                          meridians[meridianIndex.indexOf(STOMACH)].rightValue))
                  .abs()) {
            return SPLEEN;
          }
          return STOMACH;
        }
    }
  }

  //When a left/right divergence is detected on a given meridian, we need to show a specific point to treat, and
  //to do so on a specific side, based on the condition of the meridian.
  getLeftRightDivergencesTxPointForMeridian(String name, String side) {
    TreatmentPoint tp = TreatmentPoint();
    tp.right = false;
    tp.left = false;
    Meridian m = getMeridian(name);
    // if I'm checking the right side, and right is +, sedate
    // else tonify
    // if I'm checking the left side and left is +, sedate
    // else tonify
    if (side == "R") {
      tp.right = true;
      if (m.leftValue < m.rightValue) {
        tp.treatmentModality = TreatmentPoint.sedate;
      } else if (m.rightValue < m.leftValue) {
        tp.treatmentModality = TreatmentPoint.tonify;
      }
    } else {
      tp.left = true;
      if (m.leftValue < m.rightValue) {
        tp.treatmentModality = TreatmentPoint.tonify;
      } else if (m.rightValue < m.leftValue) {
        tp.treatmentModality = TreatmentPoint.sedate;
      }
    }
    side += " ";
    tp.pointName = leftRightDivergencesTxPoints[name];
    tp.meridiansAffected = [name];
    tp.pointReason = LEFT_RIGHT_DIVERGENCE;
    return tp;
  }

  //compute the average reading across all the yang meridians: LI, ST, SI, BL, TE, GB
  getYangLevel() {
    int denom = 12;
    if (isScreeningMode) {
      denom = 6;
    }
    int total = meridians[meridianIndex.indexOf(LARGE_INTESTINE)].leftValue +
        meridians[meridianIndex.indexOf(LARGE_INTESTINE)].rightValue +
        meridians[meridianIndex.indexOf(STOMACH)].leftValue +
        meridians[meridianIndex.indexOf(STOMACH)].rightValue +
        meridians[meridianIndex.indexOf(SMALL_INTESTINE)].leftValue +
        meridians[meridianIndex.indexOf(SMALL_INTESTINE)].rightValue +
        meridians[meridianIndex.indexOf(BLADDER)].leftValue +
        meridians[meridianIndex.indexOf(BLADDER)].rightValue +
        meridians[meridianIndex.indexOf(TRIPLE_ENERGIZER)].leftValue +
        meridians[meridianIndex.indexOf(TRIPLE_ENERGIZER)].rightValue +
        meridians[meridianIndex.indexOf(GALL_BLADDER)].leftValue +
        meridians[meridianIndex.indexOf(GALL_BLADDER)].rightValue;
    return total / denom;
  }

  //compute the average reading across all the yin meridians: LU, SP, HT, KI, PC, LR
  getYinLevel() {
    int denom = 12;
    if (isScreeningMode) {
      denom = 6;
    }
    int total = meridians[meridianIndex.indexOf(LUNG)].leftValue +
        meridians[meridianIndex.indexOf(LUNG)].rightValue +
        meridians[meridianIndex.indexOf(SPLEEN)].leftValue +
        meridians[meridianIndex.indexOf(SPLEEN)].rightValue +
        meridians[meridianIndex.indexOf(HEART)].leftValue +
        meridians[meridianIndex.indexOf(HEART)].rightValue +
        meridians[meridianIndex.indexOf(KIDNEY)].leftValue +
        meridians[meridianIndex.indexOf(KIDNEY)].rightValue +
        meridians[meridianIndex.indexOf(PERICARDIUM)].leftValue +
        meridians[meridianIndex.indexOf(PERICARDIUM)].rightValue +
        meridians[meridianIndex.indexOf(LIVER)].leftValue +
        meridians[meridianIndex.indexOf(LIVER)].rightValue;
    return total / denom;
  }

  //figure out which side needs to be treated, then go pull out the heSea tx point for the given meridian.
  getYyHeSeaTXPoint(String name) {
    Meridian m = getMeridian(name);
    TreatmentPoint tp = TreatmentPoint();
    tp.left = false;
    tp.right = false;
    if (m.leftValue > m.rightValue) {
      tp.right = true;
    } else if (m.leftValue < m.rightValue) {
      tp.left = true;
    } else {
      //they are equal, so treat them both.
      tp.left = true;
      tp.right = true;
    }

    tp.isGroupPoint = true;
    tp.pointReason = YY_DIVERGENCE;
    tp.pointName = yyHeSeaTxPoints[name];
    tp.treatmentModality = TreatmentPoint.sedate;
    tp.meridiansAffected = [name];

    return [tp]; //needs to be returned as an array
  }

  //figure out which side needs to be treated, then go look up the yyMasterPoint for the given meridian.
  getYYMasterTxPoint(String name) {
    Meridian m = getMeridian(name);
    TreatmentPoint tp = TreatmentPoint();
    tp.left = false;
    tp.right = false;
    if (m.leftValue > m.rightValue) {
      tp.right = true;
    } else if (m.leftValue < m.rightValue) {
      tp.left = true;
    } else {
      //they are equal, so treat them both.
      tp.left = true;
      tp.right = true;
    }

    tp.isGroupPoint = true;
    tp.pointReason = YY_DIVERGENCE;
    tp.pointName = yyMasterTxPoints[name];
    tp.treatmentModality = TreatmentPoint.tonify;
    tp.meridiansAffected = [name];

    return [tp]; //needs to be returned as an array
  }

  reorderMandT(MeridiansAndTreatments mt, List<String> meridianOrder) {
    //ok, we have to sort this mt.t array so that it will treat the meridians in the order they are listed in the meridianOrder.
    //once sorted, return mt.
    List<TreatmentPoint> treatmentPoints = [];
    //clear out all the tx flags for the anatomical and priority tx goop
    for (int i = 0; i < meridians.length; i++) {
      meridians[i].anatomicalOrPriorityTreated = false;
    }

    for (int i = 0; i < meridianOrder.length; i++) {
      //if this meridian has not already been treated
      if (meridians[meridianIndex.indexOf(meridianOrder[i])]
              .anatomicalOrPriorityTreated ==
          false) {
        //find the treatment point that addresses this meridian, and add it as the next tx point to hit.
        for (int j = 0; j < mt.treatments.length; j++) {
          if (mt.treatments[j].pointReason == QI_LEVEL) {
            return mt; //special case: we don't change the order if the reason is Qi Level.
          }
          if (mt.treatments[j].meridiansAffected.indexOf(meridianOrder[i]) >
                  -1 ||
              (meridians[meridianIndex.indexOf(meridianOrder[i])].state ==
                      SPLIT &&
                  mt.treatments[j].pointName == SPLEEN + " 21") ||
              mt.treatments[j].pointReason.contains(BELT_BLOCK)) {
            //great, this treatment is treating meridianOrder(i), so add it to the list of points to treat, in order
            treatmentPoints.add(mt.treatments[j]);
            //now mark the other affected points as treated as well.
            if (mt.treatments[j].pointName == SPLEEN + " 21") {
              //I am treating SP21, which will take care of all my splits.  So lets go find them and mark them as treated.
              for (int k = 0; k < meridians.length; k++) {
                if (meridians[k].state == SPLIT) {
                  meridians[k].anatomicalOrPriorityTreated = true;
                }
              }
            }
            if (mt.treatments[j].pointReason.contains(BELT_BLOCK)) {
              // if there was a belt block, currently that means all the meridians will be treated by 2 points
              // so we don't need to look for anything else here and can just return
              // since it is already putting the points in in the correct order (CV first then GB)
              return mt;
            }
            //add the 5 elements comma separated list of other meridians treated by this point.
            for (int l = 0; l < meridianOrder.length; l++) {
              if (mt.treatments[j].meridiansAffected.indexOf(meridianOrder[l]) >
                  0) {
                //mark this meridian as treated
                meridians[meridianIndex.indexOf(meridianOrder[l])]
                    .anatomicalOrPriorityTreated = true;
                j = mt.treatments.length + 1;
              }
            }
          }
        }
      }
    }
    mt.treatments = treatmentPoints;
    return mt;
  }

  reorderMandTforAnatomical(MeridiansAndTreatments mt) {
    //starting with the hands and moving to the arms, head, trunk, legs, feet, in that order
    // loop through the treatments and gather all hands, arms, head, trunk, legs, feet and add them to the treatmentPoints
    // list.
    List<TreatmentPoint> treatmentPoints = [];
    for (int i = 0; i < mt.treatments.length; i++) {
      if (getAnatomicalLocationForPointName(mt.treatments[i].pointName) ==
          HAND) {
        //add it.
        treatmentPoints.add(mt.treatments[i]);
      }
    }
    for (int i = 0; i < mt.treatments.length; i++) {
      if (getAnatomicalLocationForPointName(mt.treatments[i].pointName) ==
          ARM) {
        treatmentPoints.add(mt.treatments[i]);
      }
    }
    for (int i = 0; i < mt.treatments.length; i++) {
      if (getAnatomicalLocationForPointName(mt.treatments[i].pointName) ==
          HEAD) {
        treatmentPoints.add(mt.treatments[i]);
      }
    }
    for (int i = 0; i < mt.treatments.length; i++) {
      if (getAnatomicalLocationForPointName(mt.treatments[i].pointName) ==
          TORSO) {
        treatmentPoints.add(mt.treatments[i]);
      }
    }
    for (int i = 0; i < mt.treatments.length; i++) {
      if (getAnatomicalLocationForPointName(mt.treatments[i].pointName) ==
          LEG) {
        treatmentPoints.add(mt.treatments[i]);
      }
    }
    for (int i = 0; i < mt.treatments.length; i++) {
      if (getAnatomicalLocationForPointName(mt.treatments[i].pointName) ==
          FEET) {
        treatmentPoints.add(mt.treatments[i]);
      }
    }
    mt.treatments = treatmentPoints;
    return mt;
  }

  reorderTreatmentForAnatomical() {
    //This used to actually do something, but I believe the treatments now default to the correct priority order
    //earlier on in the treatment point decision-making, so this just essentially creates the treatment options
    //which has some side effects on calculating a bunch of other stuff in the tp.
    MeridiansAndTreatments basicTX = tp.getBasic();
    MeridiansAndTreatments advanced1TX = tp.getAdvanced1();
    MeridiansAndTreatments advanced2TX = tp.getAdvanced2();
  }

  //just twiddles the goop in tp to match the priority method of doing a treatment.
  reorderTreatmentForPriority() {
    // 1.Take the element averages (as calculated for the “by element” graph.) Determine which element average is farthest
    // from the mean. In the event of a tie, the priority order is as follows:
    // a.Emperor Fire
    // b.Minister Fire
    // c.Wood
    // d.Water
    // e.Earth
    // f.Metal
    // 2.Using this priority order will determine which element to balance takes precedence in the event of any tie.
    Map elements = Map();
    Map chartValues = Map();
    List<String> elementsSorted = [];
    List<String> meridiansSorted = [];
    MeridiansAndTreatments basicTX = MeridiansAndTreatments();
    MeridiansAndTreatments advanced1TX = MeridiansAndTreatments();
    MeridiansAndTreatments advanced2TX = MeridiansAndTreatments();

    //clear out all the tx flags for the anatomical and priority tx goop
    for (int i = 0; i < meridians.length; i++) {
      meridians[i].anatomicalOrPriorityTreated = false;
    }

    //Emperor Fire
    elements[EMPEROR_FIRE] = (mean -
            avgOfFour(
                meridians[meridianIndex.indexOf(SMALL_INTESTINE)].leftValue,
                meridians[meridianIndex.indexOf(SMALL_INTESTINE)].rightValue,
                meridians[meridianIndex.indexOf(HEART)].leftValue,
                meridians[meridianIndex.indexOf(HEART)].rightValue))
        .abs();
    elementsSorted.add(EMPEROR_FIRE);

    //Minister Fire
    elements[MINISTER_FIRE] = (mean -
            avgOfFour(
                meridians[meridianIndex.indexOf(TRIPLE_ENERGIZER)].leftValue,
                meridians[meridianIndex.indexOf(TRIPLE_ENERGIZER)].rightValue,
                meridians[meridianIndex.indexOf(PERICARDIUM)].leftValue,
                meridians[meridianIndex.indexOf(PERICARDIUM)].rightValue))
        .abs();

    for (int i = 0; i < elementsSorted.length; i++) {
      if (elements[MINISTER_FIRE] > elements.values.elementAt(i)) {
        elementsSorted.insert(i, MINISTER_FIRE);
      }
    }
    //check to make sure it was sorted in somewhere. If not, add it to the end of the list.
    if (!elementsSorted.contains(MINISTER_FIRE)) {
      elementsSorted.add(MINISTER_FIRE);
    }

    //Wood
    elements[WOOD] = (mean -
            avgOfFour(
                meridians[meridianIndex.indexOf(GALL_BLADDER)].leftValue,
                meridians[meridianIndex.indexOf(GALL_BLADDER)].rightValue,
                meridians[meridianIndex.indexOf(LIVER)].leftValue,
                meridians[meridianIndex.indexOf(LIVER)].rightValue))
        .abs();

    for (int i = 0; i < elementsSorted.length; i++) {
      if (elements[WOOD] > elements.values.elementAt(i)) {
        elementsSorted.insert(i, WOOD);
      }
    }
    //check to make sure it was sorted in somewhere. If not, add it to the end of the list.
    if (!elementsSorted.contains(WOOD)) {
      elementsSorted.add(WOOD);
    }

    //Water
    elements[WATER] = (mean -
            avgOfFour(
                meridians[meridianIndex.indexOf(KIDNEY)].leftValue,
                meridians[meridianIndex.indexOf(KIDNEY)].rightValue,
                meridians[meridianIndex.indexOf(BLADDER)].leftValue,
                meridians[meridianIndex.indexOf(BLADDER)].rightValue))
        .abs();

    for (int i = 0; i < elementsSorted.length; i++) {
      if (elements[WATER] > elements.values.elementAt(i)) {
        elementsSorted.insert(i, WATER);
      }
    }
    //check to make sure it was sorted in somewhere. If not, add it to the end of the list.
    if (!elementsSorted.contains(WATER)) {
      elementsSorted.add(WATER);
    }

    //Earth
    elements[EARTH] = (mean -
            avgOfFour(
                meridians[meridianIndex.indexOf(SPLEEN)].leftValue,
                meridians[meridianIndex.indexOf(SPLEEN)].rightValue,
                meridians[meridianIndex.indexOf(STOMACH)].leftValue,
                meridians[meridianIndex.indexOf(STOMACH)].rightValue))
        .abs();

    for (int i = 0; i < elementsSorted.length; i++) {
      if (elements[EARTH] > elements.values.elementAt(i)) {
        elementsSorted.insert(i, EARTH);
      }
    }
    //check to make sure it was sorted in somewhere. If not, add it to the end of the list.
    if (!elementsSorted.contains(EARTH)) {
      elementsSorted.add(EARTH);
    }

    //Metal
    elements[METAL] = (mean -
            avgOfFour(
                meridians[meridianIndex.indexOf(LUNG)].leftValue,
                meridians[meridianIndex.indexOf(LUNG)].rightValue,
                meridians[meridianIndex.indexOf(LARGE_INTESTINE)].leftValue,
                meridians[meridianIndex.indexOf(LARGE_INTESTINE)].rightValue))
        .abs();

    for (int i = 0; i < elementsSorted.length; i++) {
      if (elements[METAL] > elements.values.elementAt(i)) {
        elementsSorted.insert(i, METAL);
      }
    }
    //check to make sure it was sorted in somewhere. If not, add it to the end of the list.
    if (!elementsSorted.contains(METAL)) {
      elementsSorted.add(METAL);
    }

    //3.Once the “most imbalanced element” is determined, the next determination is the “most imbalanced meridian.” Again, it
    // is simply the meridian WITHIN the most imbalanced element that has the meridian average (average of the two measurements
    // for that meridian) furthest from the mean.
    for (int i = 0; i < elementsSorted.length; i++) {
      meridiansSorted.add(getWorstMeridian(elementsSorted[i]));
      meridiansSorted.add(getBestMeridian(elementsSorted[i]));
    }

    // 4.This is the meridian to address first. In the event of a tie, Do the yin meridian first. Yin meridians are those on the
    // inside of the 5-elements chart, easily remembered by thinking, “Yin is In.” These are HT, P, SP, LU, K, LV.
    // Once this meridian has been treated, the other meridian in the most imbalanced element should be treated. In the event that
    // the first treatment already addressed both meridians in the most imbalanced element, then start again and determine the
    // next-most-imbalanced meridian.
    //
    // At this point, I have an array of Strings called meridiansSorted.  This array has all the meridians sorted in priority order,
    // and I am now ready to begin matching up the treatment protocol recommendation with these sorted meridians.

    basicTX = tp.getBasic();
    advanced1TX = tp.getAdvanced1();
    advanced2TX = tp.getAdvanced2();

    basicTX = reorderMandT(basicTX, meridiansSorted);
    advanced1TX = reorderMandT(advanced1TX, meridiansSorted);
    advanced2TX = reorderMandT(advanced2TX, meridiansSorted);

    //Now, here's a big ol' hairy example:
    //
    // Suppose you have the following averages:
    //
    // Wood: 122
    // Water: 111
    // Earth: 140
    // E. Fire: 100
    // M. Fire: 102
    // Metal: 80
    //
    // Mean: 109
    //
    // Earth is the most imbalanced element.
    //
    // Now, within earth, suppose the following measurements:
    // RST 119
    // LST 151
    // RSP 138
    // LSP 151
    //
    // Stomach has a mean of 135, vs. spleen of 145. Therefore, spleen will be addressed first. So, whichever treatment point is
    // called for to address spleen will be treated first. Chances are, this point will also address another meridian or meridians,
    // but not always. In the event that it does address another meridian, that meridian is taken out of the running for TREATMENT,
    // but not for CALCULATION of the next most imbalanced meridian.
    //
    // So, if the treatment point happens to address stomach and spleen both, then the earth element is done, and it is time to move
    // on to the next most imbalanced element. But if the point selected addresses, say, spleen and lung, then, stomach will be
    // addressed next (together with whatever other meridians are affected by correcting the stomach.)
    // Let's assume the first point did spleen and lung, and the next point did only stomach. Earth element is now completed. Metal
    // is indeed the next most imbalanced element, only the LI meridian is eligible for treatment (if it needs treatment. It may not.).
    // So correct LI (and whatever else that point also happens to affect) then move on to the wood element, which is now the next
    // most imbalanced.
  }

  calcColor(
      num mean,
      int i,
      String meridianName,
      bool normalize,
      num splitRange,
      num normalOffset,
      List<ExamImbalanceOverride>? eiol) async {
    Color c;
    //These are hard-coded from AcuGraph 5. They need to change for AGCS, but I don't have rgb values for the new colors
    //on hand.
    Color highColor = rgbToColor(186, 53, 53);
    Color lowColor = rgbToColor(45, 77, 156);
    Color splitColor = rgbToColor(132, 95, 153);
    Color goodColor = rgbToColor(44, 154, 44);
    Color outlierColor = rgbToColor(102, 102, 102);

    // any pair with a difference >= splitRange (formerly hardcoded to 25) points is a split, which trumps
    // any pair both above the mean + normalOffset (formerly hardcoded to 15) are high
    // any pair both below the mean -normalOffset (formerly hardcoded to 15) are low
    // any pair with one near the mean, one below the mean is considered normal
    // ie, if the average of the 2 for this meridian falls within the mean, then they are both normal
    // UPDATE - Dr. Baker wants this changed to be normal if either of the 2 bars are in the normal range, as
    // long as it is not a split..

    // any pair with both in the mean range is normal
    // finally, any point that lies outside the 50 above and below the mean is considered an outlier.  If they
    // have selected a normalized graph, these should be set to the outlier color/greyed out/dimmer or whatever

    num leftValue = meridians[meridianIndex.indexOf(meridianName)].leftValue;
    num rightValue = meridians[meridianIndex.indexOf(meridianName)].rightValue;

    //A long time ago in a galaxy far, far away… This method used to need to consider the left and the right sides of
    // the meridians separately. That is no longer the case, so I've re-factored it but I've left the original code in
    // case we ever need to come back

    // if (i % 2 == 0) {
    //   //I am looking at the right side value for the meridian
    //   //set the value in the meridians
    //   //split trumps, so calculate that first
    //   if ((leftValue - rightValue).abs() >= splitRange) {
    //     meridians[meridianIndex.indexOf(meridianName)].state = SPLIT;
    //     if ((rightValue - mean).abs() > 50 && normalize) {
    //       c = outlierColor;
    //     } else {
    //       c = splitColor;
    //     }
    //   } else if ((rightValue - mean).abs() > 50 && normalize) {
    //     c = outlierColor;
    //     if (rightValue - mean > 0) {
    //       //this is actually high
    //       meridians[meridianIndex.indexOf(meridianName)].state = HIGH;
    //     } else {
    //       //this is actually low
    //       meridians[meridianIndex.indexOf(meridianName)].state = LOW;
    //     }
    //   } else {
    //     // this is not a split... so see if it is high, low, or normal
    //     if (leftValue > mean + normalOffset && rightValue > mean + normalOffset) {
    //       //this is a high meridian.
    //       meridians[meridianIndex.indexOf(meridianName)].state = HIGH;
    //       c = highColor;
    //     } else if (leftValue < mean - normalOffset && rightValue < mean - normalOffset) {
    //       //this is a low meridian.
    //       meridians[meridianIndex.indexOf(meridianName)].state = LOW;
    //       c = lowColor;
    //     } else {
    //       //we are not high, low, or split. Must be a normal meridian.
    //       meridians[meridianIndex.indexOf(meridianName)].state = NORMAL;
    //       c = goodColor;
    //     }
    //   }
    // } else {
    //I am looking at the left side value for the meridian
    //split trumps, so calculate that first
    if ((rightValue - leftValue).abs() >= splitRange) {
      meridians[meridianIndex.indexOf(meridianName)].state = SPLIT;
      if ((leftValue - mean).abs() > 50 && normalize) {
        c = outlierColor;
      } else {
        c = splitColor;
      }
    } else if ((leftValue - mean).abs() > 50 && normalize) {
      c = outlierColor;
      if (leftValue - mean > 0) {
        //this is actually high
        meridians[meridianIndex.indexOf(meridianName)].state = HIGH;
      } else {
        //this is actually low
        meridians[meridianIndex.indexOf(meridianName)].state = LOW;
      }
    } else {
      // this is not a split... so see if it is high, low, or normal
      if (leftValue > mean + normalOffset && rightValue > mean + normalOffset) {
        //this is a high meridian.
        meridians[meridianIndex.indexOf(meridianName)].state = HIGH;
        c = highColor;
      } else if (leftValue < mean - normalOffset &&
          rightValue < mean - normalOffset) {
        //this is a low meridian.
        meridians[meridianIndex.indexOf(meridianName)].state = LOW;
        c = lowColor;
      } else {
        //we are not high, low, or split. Must be a normal meridian.
        meridians[meridianIndex.indexOf(meridianName)].state = NORMAL;
        c = goodColor;
      }
    }
    //}

    //set the measuredState to whatever state I just derived. Then hop in to deal with overridden states
    meridians[meridianIndex.indexOf(meridianName)].measuredState =
        meridians[meridianIndex.indexOf(meridianName)].state;

    ////check for state overrides
    if (eiol != null && eiol.isNotEmpty) {
      // dim sql as String = "select state from ExamImbalanceOverride where exam_uuid = '" + currExamID + "' and meridian = '" + meridianName.trim + "' and is_deleted = 0 and state != original_state"
      // dim rs as RecordSet = db.selectQuery(sql)
      // if rs <> nil and not rs.eof and rs.RecordCount > 0 then
      for (ExamImbalanceOverride eio in eiol) {
        if (eio.meridian == meridianName && eio.state != eio.originalState) {
          switch (eio.state) {
            case LOW:
              {
                meridians[getMeridianIndex(meridianName)].state = LOW;
                c = lowColor;
                break;
              }
            case HIGH:
              {
                meridians[getMeridianIndex(meridianName)].state = HIGH;
                c = highColor;
                break;
              }
            case SPLIT:
              {
                meridians[getMeridianIndex(meridianName)].state = SPLIT;
                c = splitColor;
                break;
              }
            case NORMAL:
              {
                meridians[getMeridianIndex(meridianName)].state = NORMAL;
                c = goodColor;
                break;
              }
          }
        }
      }
    }
    return c;
  }

  //Calculates the "P.I.E." score for the current exam.
  calcPieNumber(num globalMean, num splitRange, num normalOffset) {
    //The approach with this is to start with a perfect score, and deduct points for various things found in the graph.
    num perfectMean = 100;
    //the "perfect" mean will change based on the age and gender of the patient.
    //so will the upper/lower balance base.
    num ulBalanceBase = 0.0;
    //I would prefer a switch here, but Dart does not support integer range matching with switch (yet):
    if (patientAge < 11) {
      //age is 0 - 10
      if (patientGender == "M") {
        perfectMean = 108.254;
        ulBalanceBase = 5.450918112;
      } else if (patientGender == "F") {
        perfectMean = 103.234;
        ulBalanceBase = 4.582193447;
      }
    } else if (patientAge < 21) {
      //age is 11 - 20
      if (patientGender == "M") {
        perfectMean = 101.291;
        ulBalanceBase = -3.407311845;
      } else if (patientGender == "F") {
        perfectMean = 98.383;
        ulBalanceBase = 1.032318931;
      }
    } else if (patientAge < 33) {
      //age is 22 - 32
      if (patientGender == "M") {
        perfectMean = 96.854;
        ulBalanceBase = -1.497727;
      } else if (patientGender == "F") {
        perfectMean = 92.582;
        ulBalanceBase = 3.742027817;
      }
    } else if (patientAge < 44) {
      //age is 33 - 43
      if (patientGender == "M") {
        perfectMean = 95.388;
        ulBalanceBase = -0.159757095;
      } else if (patientGender == "F") {
        perfectMean = 87.512;
        ulBalanceBase = 4.929128658;
      }
    } else if (patientAge < 53) {
      //age is 44 - 52
      if (patientGender == "M") {
        perfectMean = 90.903;
        ulBalanceBase = -0.653398508;
      } else if (patientGender == "F") {
        perfectMean = 81.701;
        ulBalanceBase = 6.073295647;
      }
    } else if (patientAge < 63) {
      //age is 53 - 62
      if (patientGender == "M") {
        perfectMean = 88.243;
        ulBalanceBase = 1.390300859;
      } else if (patientGender == "F") {
        perfectMean = 79.426;
        ulBalanceBase = 11.37197254;
      }
    } else {
      //age is 63 - ♾️
      if (patientGender == "M") {
        perfectMean = 84.634;
        ulBalanceBase = 1.635379022;
      } else if (patientGender == "F") {
        perfectMean = 75.753;
        ulBalanceBase = 16.2902869;
      }
    }

    // ok, this thing attempts to take a look at all the meridians of an exam and distill all the measurements down to a single
    // number from 0 (you are dead) to 100 (fit as a fiddle)
    // The details of how to do this were provided in a spreadsheet from Adrian called PIE.xls, which uses all sorts of spiffy
    // pivot tables and such to figure everything out.
    // In english, here are the rules
    // 1.  Everyone starts with a PIE score of 100.  Imbalances of any sort always subtract from this initial 100.
    // 2.  Splits:  Splits take priority, and should be examined first.  The size of the penatly for splits is dependant on how severe the split is:
    //     Split Size                                 Penalty
    //       Any Split                                   4
    //       10-24 worse than split threshold            5
    //       25+ worse than split threshold              6
    num splitPenalty = 0;
    num highLowPenalty = 0;
    num meanPenalty = 0;
    num stabilityPenalty = 0;
    num yinYangPenalty = 0;
    num leftRightPenalty = 0;
    num upperLowerPenalty = 0;
    num splitThreshold = splitRange;
    int meridianCount = 12;
    if (isScreeningMode) {
      meridianCount = 6;
    }

    for (int i = 0; i < meridianCount; i++) {
      if (meridians[i].state == SPLIT) {
        //assess a penalty
        //figure out the difference between left and right sides
        num diff = 0;
        diff = (splitThreshold -
                (meridians[i].leftValue - meridians[i].rightValue).abs())
            .abs();
        if (diff < 10) {
          splitPenalty += 4;
        } else if (diff < 25) {
          splitPenalty += 5;
        } else {
          splitPenalty += 6;
        }
      }
    }

    //3.  Highs/Lows:  Similar to splits, the penalty varies based upon the severity of the high/low as determined by the distance from the normal range
    //    of the worst side of the meridian (this does not take into account that if one leg is in the normal range, the meridian is normal.  Rather, if either
    //    leg is outside the normal range, this penalty applies.
    //    Value                      Penalty
    //    1-9 above normal range       1
    //    10-14 above normal range     2
    //    15-19 above normal range     3
    //    20-29 above normal range     4
    //    30+ above normal range       5
    for (int i = 0; i < meridianCount; i++) {
      Meridian m = meridians[i];
      //This used to re-calculate the difference between this meridian's left and right value and the mean, then assess a penalty based on how far from the mean the worst
      //leg is, regardless of whether the meridian was high, low, normal, etc. Now that people can override meridian states, this has been updated to assess a penalty
      //*even if the math says it's a normal meridian*.
      //It looks at the meridian state (which is initially set by the treater, but can be overridden by the user) to see if it was normal but is now something else.
      //and assesses a corresponding penalty.
      //This change was requested by Adrian in-person conversation with Kimball after a user asked why sometimes the PIE score changes with overridden meridians and sometimes
      //it does not (it changed with splits, but not high/low)
      if ((m.state == HIGH || m.state == LOW) && m.measuredState == NORMAL) {
        //this *measured* as normal, but the user has overridden it. Ding the meridian by 1 point in the pie score, then proceed with the rest of the pie calculations.
        highLowPenalty += 1;
      }
      if (m.state == NORMAL &&
          (m.measuredState == LOW || m.measuredState == HIGH)) {
        //this *measured* as high or low, but the user has overridden it to be normal. Pump up the pie score by 1 point, then proceed with the rest of the pie calculations.
        highLowPenalty -= 1;
      }
      //Now calculate penalty for high/low based on the measurement of the legs, regardless of meridian balance state.
      if ((m.leftValue > globalMean + normalOffset ||
              m.rightValue > globalMean + normalOffset) &&
          m.state != SPLIT) {
        //assess a penalty
        num diff = 0;
        if (m.leftValue > globalMean + normalOffset) {
          diff = (globalMean + normalOffset - m.leftValue).abs();
        }
        if (m.rightValue > globalMean + normalOffset) {
          if (diff < (globalMean + normalOffset - m.rightValue).abs()) {
            diff = (globalMean + normalOffset - m.rightValue).abs();
          }
        }
        if (diff < 10) {
          highLowPenalty += 1;
        } else if (diff < 15) {
          highLowPenalty += 2;
        } else if (diff < 20) {
          highLowPenalty += 3;
        } else if (diff < 30) {
          highLowPenalty += 4;
        } else {
          highLowPenalty += 5;
        }
      } else if ((m.leftValue < globalMean - normalOffset ||
              m.rightValue < globalMean - normalOffset) &&
          m.state != SPLIT) {
        //assess a penalty
        num diff = 0;
        if (m.leftValue < globalMean - normalOffset) {
          diff = (globalMean - normalOffset - m.leftValue).abs();
        }
        if (m.rightValue < globalMean - normalOffset) {
          if (diff < (globalMean - normalOffset - m.rightValue).abs()) {
            diff = (globalMean - normalOffset - m.rightValue).abs();
          }
        }
        if (diff < 10) {
          highLowPenalty += 1;
        } else if (diff < 15) {
          highLowPenalty += 2;
        } else if (diff < 20) {
          highLowPenalty += 3;
        } else if (diff < 30) {
          highLowPenalty += 4;
        } else {
          highLowPenalty += 5;
        }
      }
    }
    //4.  Mean Value:  Penalties are given for means that are too high or too low.  A perfect mean is 100 (or TBD).
    //    Value                                               Penalty
    //    1-9 away from normal range around perfect mean         1
    //    10-14 away from normal range around perfect mean       2
    //    15+ away from normal range around perfect mean         4
    if (globalMean < perfectMean - normalOffset) {
      if ((globalMean - (perfectMean - normalOffset)).abs() < 10) {
        meanPenalty = 1;
      } else if (globalMean - (perfectMean - normalOffset).abs() < 15) {
        meanPenalty = 2;
      } else {
        meanPenalty = 4;
      }
    } else if (globalMean > perfectMean + normalOffset) {
      if ((globalMean - (perfectMean + normalOffset)).abs() < 10) {
        meanPenalty = 1;
      } else if ((globalMean - (perfectMean + normalOffset)).abs() < 15) {
        meanPenalty = 2;
      } else {
        meanPenalty = 4;
      }
    }
    //5.  Stability:  Using the energy stability calculations, penalties are assessed as follows:
    //     Stability Level        Penalty
    //       0-49                    8
    //       50-59                   6
    //       60-69                   5
    //       70-79                   4
    //       80-89                   3
    //       90-94                   1
    //       95+                     0
    num energyStability = getEnergyStability();
    if (energyStability < 50) {
      stabilityPenalty = 8;
    } else if (energyStability < 60) {
      stabilityPenalty = 6;
    } else if (energyStability < 70) {
      stabilityPenalty = 5;
    } else if (energyStability < 80) {
      stabilityPenalty = 4;
    } else if (energyStability < 90) {
      stabilityPenalty = 3;
    } else if (energyStability < 95) {
      stabilityPenalty = 1;
    }

    //6.  Yin/Yang Balance.  If the Yin/Yang value is too far Yin or too far Yang, penalties are assessed
    //     Yin/Yang Level          Penalty
    //         0-9                    0
    //         10-14                  3
    //         15-19                  6
    //         20-24                  7
    //         25+                    8
    num yinVal = getYinLevel();
    num yangVal = getYangLevel();
    if ((yinVal - yangVal).abs() < 10) {
      yinYangPenalty = 0;
    } else if ((yinVal - yangVal).abs() < 15) {
      yinYangPenalty = 3;
    } else if ((yinVal - yangVal).abs() < 20) {
      yinYangPenalty = 6;
    } else if ((yinVal - yangVal).abs() < 25) {
      yinYangPenalty = 7;
    } else {
      yinYangPenalty = 8;
    }

    //7.  Upper/Lower Balance.  Works the same as Yin/Yang, but uses Upper/Lower calculations
    //     Upper/Lower Level          Penalty
    //         0-9                       0
    //         10-14                     3
    //         15-19                     6
    //         20-24                     7
    //         25+                       8
    UpperLowerLevelData ulld = getUpperLowerLevel();
    if (ulld.upperLowerLevel + ulBalanceBase < 10) {
      upperLowerPenalty = 0;
    } else if (ulld.upperLowerLevel + ulBalanceBase < 15) {
      upperLowerPenalty = 3;
    } else if (ulld.upperLowerLevel + ulBalanceBase < 20) {
      upperLowerPenalty = 6;
    } else if (ulld.upperLowerLevel + ulBalanceBase < 25) {
      upperLowerPenalty = 7;
    } else {
      upperLowerPenalty = 8;
    }
    if (isScreeningMode) {
      upperLowerPenalty = 0;
    }

    //8.  Left/Right Balance.  Works the same as Yin/Yang, but uses Left/Right calculations
    //     Left/Right Level          Penalty
    //         0-9                      0
    //         10-14                    3
    //         15-19                    6
    //         20-24                    7
    //         25+                      8
    //
    num leftRightLevel = 0;
    if (getLeftLevel() < getRightLevel()) {
      leftRightLevel = (1 - (getLeftLevel() / getRightLevel())) * 100;
    } else if (getRightLevel() < getLeftLevel()) {
      leftRightLevel = (1 - (getRightLevel() / getLeftLevel())) * 100;
    } else {
      //don't divide by zero!
      leftRightLevel = 0;
    }

    if (leftRightLevel < 10) {
      leftRightPenalty = 0;
    } else if (leftRightLevel < 15) {
      leftRightPenalty = 4;
    } else if (leftRightLevel < 20) {
      leftRightPenalty = 6;
    } else if (leftRightLevel < 25) {
      leftRightPenalty = 7;
    } else {
      leftRightPenalty = 8;
    }

    //All the penalty points are calculated and added up, then subtracted from 100 to produce the total PIE number for this graph.
    num totalPenalty = 0;
    if (isScreeningMode) {
      splitPenalty /= 2;
      highLowPenalty /= 2;
    }
    totalPenalty = splitPenalty +
        highLowPenalty +
        meanPenalty +
        upperLowerPenalty +
        leftRightPenalty +
        yinYangPenalty +
        stabilityPenalty;

    //if this is supposed to be the "perfect" screening graph, then isScreeningMode will be true, and the values of all
    //the meridians 0 - 5 both left and right will be 100.  When this happens, just return 100.
    if (isScreeningMode) {
      if (meridians[0].leftValue == 100 &&
          meridians[0].rightValue == 100 &&
          meridians[1].leftValue == 100 &&
          meridians[1].rightValue == 100 &&
          meridians[2].leftValue == 100 &&
          meridians[2].rightValue == 100 &&
          meridians[3].leftValue == 100 &&
          meridians[3].rightValue == 100 &&
          meridians[4].leftValue == 100 &&
          meridians[4].rightValue == 100 &&
          meridians[5].leftValue == 100 &&
          meridians[5].rightValue == 100) {
        return 100;
      }
    }
    Logger.info(
        "PIE number calculated to be: " + (100 - totalPenalty).toString());
    return 100 - totalPenalty;
  }

  //calculate which points should be treated on the ear for the currExamID
  deriveAuriculotherapy() {
    int nonNormalCount = 0;
    num leftLevel = 0.0;
    num rightLevel = 0.0;
    num leftRightLevel = 0.0;
    List<TreatmentPoint> points = [];

    //Some treatment options affect all meridians, so we'll just create a convenient list of meridian names
    //to use for meridiansAffected in those cases.
    List<String> allMeridians = [];
    for (int i = 0; i < meridians.length; i++) {
      allMeridians.add(meridians[i].name);
    }

    // First: Treat the following master points if necessary: (These are treated bilaterally.)
    // Point Zero: When the patient has 3 or more imbalanced meridians of any type. This will be most patients.
    for (int i = 0; i < meridians.length; i++) {
      if (meridians[i].state != NORMAL) {
        nonNormalCount++;
      }
    }
    if (nonNormalCount > 2) {
      TreatmentPoint p = TreatmentPoint();
      p.pointAbbreviation = PZ_POINT_ABBREV;
      p.pointName = POINTZERO;
      p.pointReason = "High Number of Imbalances";
      p.isGroupPoint = true;
      p.pointType = "ear";
      p.meridiansAffected = allMeridians;
      points.add(p);
    }

    // Autonomic Point: When "Energy Stability" is classified as "Extremely Low" or "Low" in the ratios graph. Do this
    // based on classification, rather than on percentage, because the percentages are likely to change.
    if (getEnergyStability() <= 45) {
      TreatmentPoint p = TreatmentPoint();
      p.pointAbbreviation = AP_POINT_ABBREV;
      p.pointName = AUTONOMICPOINT;
      p.pointReason = "Energy Stability is Low";
      p.isGroupPoint = true;
      p.pointType = "ear";
      p.meridiansAffected = allMeridians;
      points.add(p);
    }

    // Master Oscillation Point: When there is a left/right imbalance that exceeds 10%. In other words, if the patient's
    // left/right balance is 10.1% or more on either side.
    leftLevel = getLeftLevel();
    rightLevel = getRightLevel();
    if (leftLevel < rightLevel) {
      leftRightLevel = (1 - (leftLevel / rightLevel)) * 100;
    } else if (rightLevel < leftLevel) {
      leftRightLevel = (1 - (rightLevel / leftLevel)) * 100;
    } else {
      leftRightLevel = 0;
    }

    if (leftRightLevel > 10) {
      TreatmentPoint p = TreatmentPoint();
      p.pointAbbreviation = MO_POINT_ABBREV;
      p.pointName = MASTEROSCILLATION;
      p.pointReason = LEFT_RIGHT_IMBALANCE;
      p.isGroupPoint = true;
      p.pointType = "ear";
      p.meridiansAffected = allMeridians;
      points.add(p);
    }

    // Then:
    // Treat the following for Tonification of deficient meridians or balancing of splits only. The ear is not used for sedation.
    //
    // All of the points below have the same names as body meridian points. But these are on the ear and should be
    // designated as such in the database.
    //
    // Meridian          LU   P    HT   SI   TH   LI   SP   LV   K    BL   GB   ST
    // Tonification      LU9  P9   HT9  SI3  TH3  LI11 SP2  LV8  K7   BL67 GB43 ST41
    // Luo (for splits)  LU7  P6   HT5  SI7  TH5  LI6  SP4  LV5  K4   BL60 GB37 ST40
    //
    // These are all to be treated bilaterally, with the following exceptions: Gallbladder (GB) is only treated on
    // the Right, and Spleen (SP) is only treated on the left.
    //
    for (int i = 0; i < meridians.length; i++) {
      if (meridians[i].state == LOW) {
        TreatmentPoint p = TreatmentPoint();
        p.pointName =
            getAuricularTonificationPointFromMeridianName(meridians[i].name);
        p.pointReason = meridians[i].name + " Deficient";
        p.isGroupPoint = false;
        p.pointType = "ear";
        p.meridiansAffected = [meridians[i].name];
        points.add(p);
      } else if (meridians[i].state == SPLIT) {
        TreatmentPoint p = TreatmentPoint();
        p.pointName = getAuricularLuoPointFromMeridianName(meridians[i].name);
        p.pointReason = meridians[i].name + " Split";
        p.isGroupPoint = false;
        p.pointType = "ear";
        p.meridiansAffected = [meridians[i].name];
        points.add(p);
      }
    }

    //In the treatment of bilateral ear points, display the right ear and ALL its points (one at a time), followed by
    //the left ear and ALL its points (one at a time). This includes master points. So the ears are treated in anatomical order.
    //
    //The order of points to be displayed can be just as it is above: Master points first, in the order listed,
    //followed by general points going from left to right.
    return points;
  }

  deriveChannelDivergences() {
    //Channel Divergences are calculated as follows:
    //
    // Channel Divergences: This protocol has three parts as defined below:
    // Part 1: Left-Right Divergences: the 24 readings are tallied as follows:
    // First the left and right readings for each channel are added together to obtain a sum for each channel.
    // Next, the left and right readings for each channel are subtracted to obtain a channel difference (“divergence” or split value.)
    // The lowest is subtracted from the highest, giving the absolute value of the difference, expressed as a positive number.
    // Next, the average reading for each meridian is determined by adding the left and right sides and dividing by two.
    // Next,  the number in the difference column is divided by the average to obtain a percent difference, expressing the
    // difference as a percentage of the mean for each meridian.
    //
    // Divergences    Left    Right    Sum    Difference         Average      %Difference
    // LU             100      90      190      10                 95            10.5%
    // PC             120      100     220      20  (yellow)      110            18.2%
    // HT             90       90      180      0                  90            0.0%
    // SI             95       80      175      15               87.5            17.1%
    // TE             80       80      160      0                  80            0.0%
    // LI             70       75      145      5                72.5            6.9%
    // SP             80       80      160      0                  80            0.0%
    // LR             90       80      170      10                 85            11.8%
    // K              90       100     190      10                 95            10.5%
    // BL             125      90      215      35  (yellow)    107.5            32.6% (green)
    // GB             75       85      160      10                 80            12.5%
    // ST             80       95      175      15               72.5            20.7% (green)
    //
    //
    //
    //
    // T1.1.1he two highest divergences (% differences--highlighted in green above, NOT the absolute differences,
    // highlighted in yellow) are treated as follows: The back Shu point is treated on the side of greatest deficiency
    // for each divergence. It is treated with tonification (+). The opposite side shu point is treated with sedation at
    // the same time (-). The chart of shu points is shown below:
    //
    // LU    BL13
    // PC    BL14
    // HT    BL15
    // SI    BL27
    // TE    BL22
    // LI    BL25
    // SP    BL20
    // LR    BL18
    // K     BL23
    // BL    BL28
    // GB    BL19
    // ST    BL21
    //
    // Therefore, for the above example readings, BL28 would be tonified on the right and sedated on the left, and BL21 would
    // be tonified on the left and sedated on the right.
    // In the event of a tie producing more than two “Highest” % differences, all three will be addressed. Similarly, only
    // differences of 10% or more are treated. If there are not two differences over 10% then one or none are treated.

    List<TreatmentPoint> divergentTXPoints = [];
    List<Meridian> tmpMeridians = [];
    for (int i = 0; i < meridians.length; i++) {
      tmpMeridians.add(meridians[i]);
    }

    //now we have a copy of meridians to work on.
    //sort them by their % difference as described above
    Meridian tmp;
    num val1 = 0.0;
    num val2 = 0.0;
    for (int i = 0; i < tmpMeridians.length - 1; i++) {
      for (int j = i + 1; j < tmpMeridians.length; j++) {
        val1 = (tmpMeridians[i].leftValue - tmpMeridians[i].rightValue).abs() /
            ((tmpMeridians[i].leftValue + tmpMeridians[i].rightValue) / 2);
        val2 = (tmpMeridians[j].leftValue - tmpMeridians[j].rightValue).abs() /
            ((tmpMeridians[j].leftValue + tmpMeridians[j].rightValue) / 2);
        if (val1 < val2) {
          tmp = tmpMeridians[j];
          tmpMeridians[j] = tmpMeridians[i];
          tmpMeridians[i] = tmp;
        }
      }
    }

    //ok, tmpMeridians should now be sorted with the largest differences at the top of the array.
    //the rules say that I need to take the 2 highest differences that are above 10%
    //remember last one for ties.
    List<TreatmentPoint> leftRightDivergences = [];
    for (int i = 0; i < tmpMeridians.length - 1; i++) {
      if ((tmpMeridians[i].leftValue - tmpMeridians[i].rightValue).abs() /
              ((tmpMeridians[i].leftValue + tmpMeridians[i].rightValue) / 2) >=
          .1) {
        if (leftRightDivergences.length >= 3) {
          if ((tmpMeridians[i - 1].leftValue - tmpMeridians[i - 1].rightValue)
                      .abs() /
                  ((tmpMeridians[i - 1].leftValue +
                          tmpMeridians[i - 1].rightValue) /
                      2) ==
              (tmpMeridians[i].leftValue - tmpMeridians[i].rightValue).abs() /
                  ((tmpMeridians[i].leftValue + tmpMeridians[i].rightValue) /
                      2)) {
            leftRightDivergences.add(getLeftRightDivergencesTxPointForMeridian(
                tmpMeridians[i].name, "L"));
            leftRightDivergences.add(getLeftRightDivergencesTxPointForMeridian(
                tmpMeridians[i].name, "R"));
          } else {
            //we are done
            i = tmpMeridians.length;
          }
        } else {
          leftRightDivergences.add(getLeftRightDivergencesTxPointForMeridian(
              tmpMeridians[i].name, "L"));
          leftRightDivergences.add(getLeftRightDivergencesTxPointForMeridian(
              tmpMeridians[i].name, "R"));
        }
      }
    }
    for (int i = 0; i < leftRightDivergences.length; i++) {
      divergentTXPoints.add(leftRightDivergences[i]);
    }

    //Part 2: Extraordinary Vessel Divergences: The sums, as calculated above, are compared as pairs, and divergences are again calculated,
    // as follows (ignore the point numbers in the left column. When you see SI3, think, SI):
    // Extraordinary Vessel Divergences
    // SUM    Difference          Average         %Difference
    // SI3     175    40                    195                20.5%
    // BL62    215
    //
    // GB41    160    0                     160                 0.0%
    // TE5     160
    //
    // LI5     145    30                    145                 0.0%
    // ST40    175
    //
    // LU7     190    0                     190                 0.0%
    // K6      190
    //
    // PC6     220    60  (purple)          190                31.6%  (purple)
    // SP4     160
    //
    // PC6     220    50  (purple)          195                25.6%  (purple)
    // LR4     170
    //
    // LU7     190    30                    175                17.1%
    // SP4     160
    //
    // HT5     180    10                    185                 5.4%
    // K6      190
    //
    // The two highest divergences are noted, in this case, PC-SP and PC-LR (Shown in Purple). These are the ones that will be addressed.
    // These points are addressed using the point numbers in the left column above, with treatment applied to tonify (+) the most deficient
    // of the pair, on the most deficient side, and sedate (-) the most excessive of the pair on the most excessive side. In the case above,
    // pair one's treatment is to sedate PC6 on the left, while tonifying SP4 on the right (in this case the right was chosen because it was
    // opposite the PC6 on the left. This is the default when there is a tie between left and right, as in spleen. Choose the one that crosses
    // the body from the side where the paired meridian is being treated.) Pair two's treatment is to sedate PC6 on the left (which has
    // already been done, and does not need to be done again) and tonify LR4 on the right (because the right side is the most deficient side
    // of the liver channel.)
    // In the event of a tie producing more than two “Highest” divergences, all three will be addressed. Similarly, only differences of 10%
    // or more are treated. If there are not two differences over 10% then one or none are treated.

    List<Map> keysAndValues = [];
    keysAndValues.add({
      SMALL_INTESTINE + " - " + BLADDER:
          (calcDifference(getMeridian(SMALL_INTESTINE), getMeridian(BLADDER))) /
              calcAvg(getMeridian(SMALL_INTESTINE), getMeridian(BLADDER))
    });
    keysAndValues.add({
      GALL_BLADDER + " - " + TRIPLE_ENERGIZER: (calcDifference(
              getMeridian(GALL_BLADDER), getMeridian(TRIPLE_ENERGIZER))) /
          calcAvg(getMeridian(GALL_BLADDER), getMeridian(TRIPLE_ENERGIZER))
    });
    keysAndValues.add({
      LARGE_INTESTINE + " - " + STOMACH:
          (calcDifference(getMeridian(LARGE_INTESTINE), getMeridian(STOMACH))) /
              calcAvg(getMeridian(LARGE_INTESTINE), getMeridian(STOMACH))
    });
    keysAndValues.add({
      LUNG + " - " + KIDNEY:
          (calcDifference(getMeridian(LUNG), getMeridian(KIDNEY))) /
              calcAvg(getMeridian(LUNG), getMeridian(KIDNEY))
    });
    keysAndValues.add({
      PERICARDIUM + " - " + SPLEEN:
          (calcDifference(getMeridian(PERICARDIUM), getMeridian(SPLEEN))) /
              calcAvg(getMeridian(PERICARDIUM), getMeridian(SPLEEN))
    });
    keysAndValues.add({
      PERICARDIUM + " - " + LIVER:
          (calcDifference(getMeridian(PERICARDIUM), getMeridian(LIVER))) /
              calcAvg(getMeridian(PERICARDIUM), getMeridian(LIVER))
    });
    keysAndValues.add({
      LUNG + " - " + SPLEEN:
          (calcDifference(getMeridian(LUNG), getMeridian(SPLEEN))) /
              calcAvg(getMeridian(LUNG), getMeridian(SPLEEN))
    });
    keysAndValues.add({
      HEART + " - " + KIDNEY:
          (calcDifference(getMeridian(HEART), getMeridian(KIDNEY))) /
              calcAvg(getMeridian(HEART), getMeridian(KIDNEY))
    });

    //now I have all the values, so let's sort them.
    Map tmpKeyValue;
    for (int i = 0; i < keysAndValues.length - 1; i++) {
      for (int j = i + 1; j < keysAndValues.length; j++) {
        if (keysAndValues[i].values.first < keysAndValues[j].values.first) {
          tmpKeyValue = keysAndValues[j];
          keysAndValues[j] = keysAndValues[i];
          keysAndValues[i] = tmpKeyValue;
        }
      }
    }

    //now that they are sorted, take the top 2 divergences (more if there are splits).
    List<String> evDivergences = [];
    for (int i = 0; i < keysAndValues.length; i++) {
      if (keysAndValues[i].values.first >= .1) {
        if (evDivergences.length >= 2) {
          if (keysAndValues[i - 1].values.first ==
              keysAndValues[i].values.first) {
            evDivergences.add(keysAndValues[i].keys.first);
          } else {
            //we are done
            i = keysAndValues.length;
          }
        } else {
          evDivergences.add(keysAndValues[i].keys.first);
        }
      }
    }

    //at this point we have evDivergences populated with the divergences that need to be treated.  This array just contains a string like "SI-BL",
    //where the - separates the 2 meridians to be treated we need to break the meridian names apart at the -, and see which one is higher.  Tonify
    //the deficient side of the deficient meridian, sedate the excessive side of the excessive meridian.  Cross the body on ties.
    String excessive = "";
    String deficient = "";
    String excessiveTXSide = "";
    String deficientTXSide = "";
    for (int i = 0; i < evDivergences.length; i++) {
      //we are not being particularly safe here - but evDivergences should only ever be full of stuff like "LV - HT" etc.
      List<String> fields = evDivergences[i].split(" - ");
      String first = fields[0];
      String second = fields[1];
      if ((getMeridian(first).leftValue + getMeridian(first).rightValue) >
          getMeridian(second).leftValue + getMeridian(second).rightValue) {
        //the first meridian is the more excessive one, so sedate on the more excessive side, and tonify the other meridian on the more deficient side
        excessive = first;
        deficient = second;
      } else {
        excessive = second;
        deficient = first;
      }

      TreatmentPoint excessiveTP = TreatmentPoint();
      TreatmentPoint deficientTP = TreatmentPoint();
      excessiveTP.left = false;
      excessiveTP.right = false;
      deficientTP.left = false;
      deficientTP.right = false;

      excessiveTXSide =
          getEvTxSideForMeridian(excessive, deficient, "excessive");
      deficientTXSide =
          getEvTxSideForMeridian(excessive, deficient, "deficient");

      if (excessiveTXSide == "L") {
        excessiveTP.left = true;
      } else {
        excessiveTP.right = true;
      }
      if (deficientTXSide == "L") {
        deficientTP.left = true;
      } else {
        deficientTP.right = true;
      }
      excessiveTP.pointName = getEvTXPointFromMeridianName(excessive);
      excessiveTP.treatmentModality = TreatmentPoint.sedate;
      excessiveTP.isGroupPoint = true;
      excessiveTP.meridiansAffected = [excessive];

      deficientTP.pointName = getEvTXPointFromMeridianName(deficient);
      deficientTP.treatmentModality = TreatmentPoint.tonify;
      deficientTP.isGroupPoint = true;
      deficientTP.meridiansAffected = [deficient];

      //for 5.2.0.5 we are exposing the point selection rationales, so we needed to provide better information about WHY
      //these points have been chosen than just "EV Divergence".
      //Adrian provided a document named Divergent Channel Balancing 2018.pages that I used to determine what reason
      //strings to use based on the divergences treated.
      //The reason strings are selected based on which divergence is being treated in the table. See the named
      // pages doc for details, as duplicating the layout etc here would be too much trouble.
      String theReason = "";
      switch (evDivergences[i]) {
        case SMALL_INTESTINE + " - " + BLADDER:
          {
            theReason = "Du / Yang Qiao Divergence (Taiyang)";
          }
          break;
        case GALL_BLADDER + " - " + TRIPLE_ENERGIZER:
          {
            theReason = "Dai / Yang Wei Divergence (Shaoyang)";
          }
          break;
        case LARGE_INTESTINE + " - " + STOMACH:
          {
            theReason = "Wei / Da Chang Divergence (Yangming)";
          }
          break;
        case LUNG + " - " + KIDNEY:
          {
            theReason = "Ren / Yin Qiao Divergence";
          }
          break;
        case PERICARDIUM + " - " + SPLEEN:
          {
            theReason = "Yin Wei / Chong Divergence";
          }
          break;
        case PERICARDIUM + " - " + LIVER:
          {
            theReason = "Yin Wei / Gan Divergence (Jueyin)";
          }
          break;
        case LUNG + " - " + SPLEEN:
          {
            theReason = "Ren / Chong Divergence (Taiyin)";
          }
          break;
        case HEART + " - " + KIDNEY:
          {
            theReason = "Shen / Xin Divergence (Shaoyin)";
          }
          break;
      }
      excessiveTP.pointReason = theReason;
      deficientTP.pointReason = theReason;

      divergentTXPoints.add(excessiveTP);
      divergentTXPoints.add(deficientTP);
    }

    //Part 3: Yin-Yang Divergences: The Sums from above are again compared and differences are determined, as below in the chart. As before,
    // the two largest differences are treated. In the event of a tie producing more than two “largest” divergences, all three will be
    // addressed, and only differences of 10% or greater will be addressed. The treatment is to treat the He-Sea point of the most deficient
    // of the two meridians on the most deficient side of its meridian. In this case, LI11 on the left and TE 10 on the right. (TE10 is
    // treated on the right because it could be treated on either side, but the left side is already being treated—LI11—so TE10 is treated on
    // the right in the name of balance. Such a tie will be very rare.) The Master point is also treated on the same side as the He-Sea point.
    // In this case, ST12 on the left and GB12 on the right. Polarity for this treatment is shown in the chart. Blue boxes are treated with
    // (-) polarity and red boxes are treated with (+) polarity.
    //
    // Yin-Yang Divergences
    // Channel    He-Sea    Master         Sum    Difference
    // (blue)     (blue)
    // K            10      BL1(+)         190       25
    // BL           40                     215
    // LR            8      GB1(+)         170       10
    // GB           34                     160
    // SP            9      ST1(+)         160       15
    // ST           36                     175
    // (red)     (blue)
    // HT            3      BL2, BL11(-)   180        5
    // SI            8                     175
    // PC            3      GB12(-)        220       60
    // TE           10                     160
    // LU            5      ST12(-)        190       45
    // LI           11                     145

    keysAndValues = []; //we'll just re-use this List<Map>
    keysAndValues.add({
      KIDNEY + " - " + BLADDER:
          (calcDifference(getMeridian(KIDNEY), getMeridian(BLADDER))) /
              calcAvg(getMeridian(KIDNEY), getMeridian(BLADDER))
    });
    keysAndValues.add({
      LIVER + " - " + GALL_BLADDER:
          (calcDifference(getMeridian(LIVER), getMeridian(GALL_BLADDER))) /
              calcAvg(getMeridian(LIVER), getMeridian(GALL_BLADDER))
    });
    keysAndValues.add({
      SPLEEN + " - " + STOMACH:
          (calcDifference(getMeridian(SPLEEN), getMeridian(STOMACH))) /
              calcAvg(getMeridian(SPLEEN), getMeridian(STOMACH))
    });
    keysAndValues.add({
      HEART + " - " + SMALL_INTESTINE:
          (calcDifference(getMeridian(HEART), getMeridian(SMALL_INTESTINE))) /
              calcAvg(getMeridian(HEART), getMeridian(SMALL_INTESTINE))
    });
    keysAndValues.add({
      PERICARDIUM + " - " + TRIPLE_ENERGIZER: (calcDifference(
              getMeridian(PERICARDIUM), getMeridian(TRIPLE_ENERGIZER))) /
          calcAvg(getMeridian(PERICARDIUM), getMeridian(TRIPLE_ENERGIZER))
    });
    keysAndValues.add({
      LUNG + " - " + LARGE_INTESTINE:
          (calcDifference(getMeridian(LUNG), getMeridian(LARGE_INTESTINE))) /
              calcAvg(getMeridian(LUNG), getMeridian(LARGE_INTESTINE))
    });
    //now I have all the values, so let's sort them.
    tmpKeyValue = Map();
    for (int i = 0; i < keysAndValues.length - 1; i++) {
      for (int j = i + 1; j < keysAndValues.length; j++) {
        if (keysAndValues[i].values.first < keysAndValues[j].values.first) {
          tmpKeyValue = keysAndValues[j];
          keysAndValues[j] = keysAndValues[i];
          keysAndValues[i] = tmpKeyValue;
        }
      }
    }
    //now that they are sorted, take the top 2 divergences (more if there are splits).
    List<String> yyDivergences = [];
    for (int i = 0; i < keysAndValues.length; i++) {
      if (keysAndValues[i].values.first >= .1) {
        if (yyDivergences.length >= 2) {
          if (keysAndValues[i - 1].values.first ==
              keysAndValues[i].values.first) {
            yyDivergences.add(keysAndValues[i].keys.first);
          } else {
            //we are done
            i = keysAndValues.length;
          }
        } else {
          yyDivergences.add(keysAndValues[i].keys.first);
        }
      }
    }

    //at this point we have yyDivergences populated with the divergences that need to be treated.  This array just contains a string like "SI-BL", where the - separates the 2 meridians to be treated
    //we need to break the meridian names apart at the -, and see which one needs to be treated.  Treatment is to treat the He-Sea point of the most deficient of the 2 meridians, on the deficient
    //side of that meridian.  The Master point is also treated.  Refer to the chart above to see if the He-Sea and Master are tonified or sedated.
    String yyMasterTXPoint = "";
    for (int i = 0; i < yyDivergences.length; i++) {
      List<String> fields = evDivergences[i].split(" - ");
      String first = fields[0];
      String second = fields[1];
      if ((getMeridian(first).leftValue + getMeridian(first).rightValue) >
          getMeridian(second).leftValue + getMeridian(second).rightValue) {
        //the first meridian is the more excessive one, so sedate on the more excessive side, and tonify the other meridian on the more deficient side
        excessive = first;
        deficient = second;
      } else {
        //the second meridian is the more excessive one, so sedate on the more excessive side, and tonify the other meridian on the more deficient side
        excessive = second;
        deficient = first;
      }
      List<TreatmentPoint> divTXPoints = getYyHeSeaTXPoint(deficient);
      for (int j = 0; j < divTXPoints.length; j++) {
        divergentTXPoints.add(divTXPoints[j]);
      }
      List<TreatmentPoint> yyMasterPoints = getYYMasterTxPoint(deficient);
      for (int j = 0; j < yyMasterPoints.length; j++) {
        divergentTXPoints.add(yyMasterPoints[j]);
      }
    }
    //return all the collected divergent treatment points.
    return divergentTXPoints;
  }

  //This is one of the earliest functions ever written in AcuGraph - it kicked off the treatment derivation of basic,
  //advanced 1, and advanced 2. Advanced 1 and 2 have been combined to simply be "Advanced", but some old stuff
  //still remains - like the string comparison for whether the 2 advanced treatments are actually the same, etc.
  deriveTreatment(num scale) async {
    MeridiansAndTreatments mt = MeridiansAndTreatments();
    for (int i = 0; i < meridians.length; i++) {
      mt.meridians[i] = meridians[
          i]; //populate out the meridians in the mt, as we'll use those in the tp in just a sec.
    }
    tp.setMeridians(mt);
    tp.deriveAdvanced(scale);
    tp.deriveBasic();

    //At this point, we have all the points listed that need to be treated, along with all the reaons for the treatment.
    //Since I don't want to go anywhere close to changing anything in the treatment derivation methods, but I have to fulfill
    //the requirement in AG 2 for Anatomical and Priority treatments, I will take this information and pass it to
    //some new methods, which will re-order the treatment points so that they are either in anatomical or priority order.
    String? txOrder = await Preference().fetchValueByName("treatment_order");
    if (txOrder == "anatomical") {
      reorderTreatmentForAnatomical();
    } else if (txOrder == "priority") {
      reorderTreatmentForPriority();
    } else {
      //do nothing, default back to the old AG 1 way of doing things.
    }

    //determine if basic and advanced are the same. This matters in the expert treatment, if the user tries that one as well.
    if (tp.isTreatmentEqual(0, 1)) {
      fiveElementsMatchesBasic = true;
    }
  }

  getEnergyLevel() {
    if (mean <= 0) {
      return calcMean();
    }
    return mean; //the energy level number is just the mean.
  }

  //get a Map that shows the Yin/Yang balance, as well as the value of that balance.
  getYinYangLevel() {
    num yinLevel = getYinLevel();
    num yangLevel = getYangLevel();
    num yinYangLevel = 0;
    String yinYangString = "";
    if (yinLevel < yangLevel) {
      yinYangLevel = (1 - (yinLevel / yangLevel)) * 100;
      yinYangString = YANG;
    } else if (yangLevel < yinLevel) {
      yinYangLevel = (1 - (yangLevel / yinLevel)) * 100;
      yinYangString = YIN;
    } else {
      //don't divide by zero!
      yinYangLevel = 0;
    }
    return {
      yinYangString: yinYangLevel
    }; //returns a map that shows something like: "Yang":12.345
  }

  //get a Map that shows the Left/Right balance, as well as the value of that balance (i.e, how far to the left are you?)
  getLeftRightBalance() {
    num leftLevel = getLeftLevel();
    num rightLevel = getRightLevel();
    num leftRightLevel = 0;
    String leftRightString = "";
    if (leftLevel < rightLevel) {
      leftRightLevel = (1 - (leftLevel / rightLevel)) * 100;
      leftRightString = RIGHT;
    } else if (rightLevel < leftLevel) {
      leftRightLevel = (1 - (rightLevel / leftLevel)) * 100;
      leftRightString = LEFT;
    } else {
      //don't divide by zero!
      leftRightLevel = 0;
      leftRightString = BALANCED;
    }
    return {
      leftRightString: leftRightLevel
    }; //returns a map that shows something like: "Right":9.32
  }

  //get a Map that shows the upper/lower balance, as well as the value of that balance (i.e, how far to the upper are you?)
  getUpperLowerBalance() {
    num upperLevel = getUpperLevel();
    num lowerLevel = getLowerLevel();
    num upperlowerLevel = 0;
    String upperlowerString = "";
    if (upperLevel < lowerLevel) {
      upperlowerLevel = (1 - (upperLevel / lowerLevel)) * 100;
      upperlowerString = LOWER;
    } else if (lowerLevel < upperLevel) {
      upperlowerLevel = (1 - (lowerLevel / upperLevel)) * 100;
      upperlowerString = UPPER;
    } else {
      //don't divide by zero!
      upperlowerLevel = 0;
      upperlowerString = BALANCED;
    }
    return {
      upperlowerString: upperlowerLevel
    }; //returns a map that shows something like: "lower":9.32
  }

  //Retrieve a TreatmentRecommendation for this graph using the "Basic" treatment protocol.
  getBasicTreatmentPoints() {
    //declare a treatment recommendation to hold our results.
    TreatmentRecommendation rec = TreatmentRecommendation();
    //pull out the meridians and treatments object for the basic treatment plan.
    MeridiansAndTreatments mt = tp.meridiansAndTreatments[0].mt;
    //loop through all the points in this treatment, and add them to the primary, secondary, and group points as needed.
    //Primary points first.
    for (int i = 0; i < mt.treatments.length; i++) {
      if (mt.treatments[i] != null &&
          mt.treatments[i].meridiansAffected.length > 0 &&
          !mt.treatments[i].isGroupPoint) {
        //This treatment point is for a specific meridian or meridians, and is not a group point.
        rec.primaryPoints.add(mt.treatments[i]);
      }
      if (mt.treatments[i] != null && mt.treatments[i].isGroupPoint) {
        //This treatment point is a group point.
        rec.groupPoints.add(mt.treatments[i]);
      }
    }
    return rec;
  }

  //Retrieve a TreatmentRecommendation for this graph using the "Advanced" treatment protocol.
  getAdvancedTreatmentPoints() {
    //declare a treatment recommendation to hold our results.
    TreatmentRecommendation rec = TreatmentRecommendation();
    //pull out the meridians and treatments object for the basic treatment plan.
    MeridiansAndTreatments mt = tp.meridiansAndTreatments[1]
        .mt; //the only difference between basic and advanced is which MT object
    //we reference in the treatmentProtocol object.
    //loop through all the points in this treatment, and add them to the primary, secondary, and group points as needed.
    //Primary points first.
    for (int i = 0; i < mt.treatments.length; i++) {
      if (mt.treatments[i] != null &&
          mt.treatments[i].meridiansAffected.length > 0 &&
          !mt.treatments[i].isGroupPoint) {
        //This treatment point is for a specific meridian or meridians, and is not a group point.
        rec.primaryPoints.add(mt.treatments[i]);
      }
      if (mt.treatments[i] != null && mt.treatments[i].isGroupPoint) {
        //This treatment point is a group point.
        rec.groupPoints.add(mt.treatments[i]);
      }
    }
    return rec;
  }

  //Retrieve a TreatmentRecommendation for this graph using the "Auricular" treatment protocol.
  getAuriculoTreatmentPoints() {
    //declare a treatment recommendation to hold our results.
    TreatmentRecommendation rec = TreatmentRecommendation();
    //get the auricular points.
    List<TreatmentPoint> points = deriveAuriculotherapy();
    for (int i = 0; i < points.length; i++) {
      //add the primary points
      if (points[i].meridiansAffected.length > 0 && !points[i].isGroupPoint) {
        rec.primaryPoints.add(points[i]);
      }
      //take care of group points.
      if (points[i].isGroupPoint) {
        rec.groupPoints.add(points[i]);
      }
    }
    return rec;
  }

  //Retrieve a TreatmentRecommendation for this graph using the "Associated (Back-Shu)" treatment protocol.
  getAssociatedBackShuTreatmentPoints() {
    //declare a treatment recommendation to hold our results.
    TreatmentRecommendation rec = TreatmentRecommendation();
    //get the associated (Back-Shu) points.
    List<TreatmentPoint> points = deriveAssociatedTXPoints();
    for (int i = 0; i < points.length; i++) {
      //add the primary points
      if (points[i].meridiansAffected.length > 0 && !points[i].isGroupPoint) {
        rec.primaryPoints.add(points[i]);
      }
      //there should not be any secondary or group points for this tx type.
    }
    return rec;
  }

  //Retrieve a TreatmentRecommendation for this graph using the "Channel Divergences" treatment protocol.
  getDivergentChannelTreatmentPoints() {
    //declare a treatment recommendation to hold our results.
    TreatmentRecommendation rec = TreatmentRecommendation();
    //get the divergent treatment points.
    List<TreatmentPoint> points = deriveChannelDivergences();
    for (int i = 0; i < points.length; i++) {
      //add the primary points
      if (points[i].meridiansAffected.length > 0 && !points[i].isGroupPoint) {
        rec.primaryPoints.add(points[i]);
      }
      //take care of group points.
      if (points[i].isGroupPoint) {
        rec.groupPoints.add(points[i]);
      }
    }
    return rec;
  }

  //Retrieve a TreatmentRecommendation for this graph using the "Expert" treatment protocol. This one is pretty involved
  //and is heavily documented inline below.
  getExpertTreatmentPoints() async {
    List<TreatmentPoint> txPoints = [];

    //go grab the exam object we'll be working on.
    Exam e = await Exam().fetchById(currExamId, include: ['patient']);
    //Create an expert treater object with that exam.
    ExpertTx extx = ExpertTx(e);
    await extx.populateList();
    //Create a TreatmentRecommendation that will be used to capture the final treatment after we get things all set up below.
    TreatmentRecommendation rec = TreatmentRecommendation();

    /*
    Each meridian can have a MAXIMUM of 2 treatment points selected for it. The highest priority point goes on the
    top line of the treater. The next highest point goes on the top line of the lower section.
    Any points that affect all meridians will be shown on the lower line of the lower section, in a group centered,
    not lined up with any meridian.

    In order to make this work, we have to keep track of treatment points per meridian as we add them. For every point
    in the primaryPoints and groupPoints arrays, we should first look to see if there are already any points assigned
    for that meridian. If not, add it to the top row. If there are, then if the point I'm considering has a higher priority
    than the one that is already there. If it does, then swap the point that is there for the point I am considering.
    Then repeat the process, checking to see if there is a second point already assigned for the meridian. If there is not,
    put the point in that I just took out. If there is, consider which point has the highest priority and bump anything with
    a lower priority in favor of the higher priority.

    Ick.
    */

    Map firstMeridianPoints = new Map();
    Map secondMeridianPoints = new Map();

    /*
    Loop through the treatment points, and assign points to either the firstMeridianPoints (which will populate
    rec.primaryPoints List), secondMeridianPoints (which are used to populate the rec.groupPoints List), or
    just put it directly into rec.groupPoints List.

    NOTE:
    SP 21 should ALWAYS be treated as an groupPoints item - it treats more than 4 splits.
    Points which treat 3 meridians should also be treated as groupPoints
    */

    txPoints = extx.bodyPoints;
    for (int i = 0; i < txPoints.length; i++) {
      if (txPoints[i].pointName == "SP 21" ||
          txPoints[i].meridiansAffected.length >= 3) {
        //this is something that should always be a point for the full graph, not specific meridians. Put it into
        //group points.
        rec.groupPoints.add(txPoints[i]);
      } else if (txPoints[i].priority == 1) {
        //this is the highest priority, and should immediately be put into the firstMeridianPoints List
        if (txPoints[i].meridiansAffected.length > 0) {
          for (int j = 0; j < txPoints[i].meridiansAffected.length; j++) {
            if (firstMeridianPoints
                .containsKey(txPoints[i].meridiansAffected[j])) {
              //There was already a point for this meridian, so move it to the second tx point slot, and replace it
              //with this point, as this one has a higher priority.
              //demote existing point from first to second.
              secondMeridianPoints[txPoints[i].meridiansAffected[j]] =
                  firstMeridianPoints[txPoints[i].meridiansAffected[j]];
              //add new point to first.
              firstMeridianPoints[txPoints[i].meridiansAffected[j]] =
                  txPoints[i];
            } else {
              //this meridian does not have any points yet, so give it one.
              firstMeridianPoints[txPoints[i].meridiansAffected[j]] =
                  txPoints[i];
            }
          }
        }
      } else {
        //this was not a priority 1 point, so let's see where else it may fit.
        if (txPoints[i].priority == 2) {
          /*
          priority 2 will try to be placed into the firstMeridianPoints, unless there is already a priority 1 point for
          this meridian there. Then it gets put into secondMeridianPoints unless there is already a priority 1 point in
          both the first and second arrays. If there was a priority 3 or lower in firstMeridianPoints, that point is just
          pushed into secondMeridianPoints. i.e., put this into the highest priority array where it will fit, pushing lower
          priority points out of the tx completely as needed.
          */
          if (txPoints[i].meridiansAffected.length > 0) {
            for (int j = 0; j < txPoints[i].meridiansAffected.length; j++) {
              if (firstMeridianPoints
                  .containsKey(txPoints[i].meridiansAffected[j])) {
                TreatmentPoint existingTp =
                    firstMeridianPoints[txPoints[i].meridiansAffected[j]];
                if (existingTp.priority == 1) {
                  //simply put the point we are considering into the second tx point list. Replace whatever was there.
                  secondMeridianPoints[txPoints[i].meridiansAffected[j]] =
                      txPoints[i];
                } else {
                  //replace the one that was in firstMeridianPoints with this one, pushing the one from first to second.
                  firstMeridianPoints[txPoints[i].meridiansAffected[j]] =
                      txPoints[i];
                  secondMeridianPoints[txPoints[i].meridiansAffected[j]] =
                      existingTp;
                }
              }
            }
          }
        } else if (txPoints[i].priority >= 3 || txPoints[i].priority == 0) {
          //this only gets added to firstMeridianPoints if there are no other points in that array for htis meridian.
          //If there are, then try secondMeridianPoints. If that is also already full, then discard this point.
          if (txPoints[i].meridiansAffected.length > 0) {
            for (int j = 0; j < txPoints[i].meridiansAffected.length; j++) {
              if (!firstMeridianPoints
                  .containsKey(txPoints[i].meridiansAffected[j])) {
                firstMeridianPoints[txPoints[i].meridiansAffected[j]] =
                    txPoints[i];
              } else if (!secondMeridianPoints
                  .containsKey(txPoints[i].meridiansAffected[j])) {
                secondMeridianPoints[txPoints[i].meridiansAffected[j]] =
                    txPoints[i];
              }
            }
          }
        }
      }
    }

    //populate our rec and return
    //NOTE: I pulled these comments and rough syntax/logic right out of the Xojo project for AcuGraph 5. I'm not sure
    //the logic actually does what the comments say... but it works the way we want in AG5, so I'm leaving it as-is
    //unless and until we find a problem with the port to Dart. (some of the maniuplations of List and Map are different
    //from the approach to Array and Dictionary that are used in xojo... so some wonkiness may occur).
    for (int i = 0; i < secondMeridianPoints.length; i++) {
      //only add this point if it is not already in this array. Sometimes we get duplicate attempts because a point
      //addresses more than 1 meridian.
      if (!rec.groupPoints.contains(
          secondMeridianPoints[secondMeridianPoints.keys.elementAt(i)])) {
        //if(rec.groupPoints.indexOf(secondMeridianPoints[i]) < 0){
        rec.groupPoints
            .add(secondMeridianPoints[secondMeridianPoints.keys.elementAt(i)]);
      }
    }
    //only add points to the primary if the secondary does NOT already have them. There are odd situations where you'll
    // see a point that treats 2 meridians show up as both a primary and secondary point on the same meridian, because
    // it is the primary on one and secondary on the other.
    for (int i = 0; i < firstMeridianPoints.length; i++) {
      if (!rec.groupPoints.contains(
          firstMeridianPoints[firstMeridianPoints.keys.elementAt(i)])) {
        //if(rec.groupPoints.indexOf(firstMeridianPoints[i]) != null){
        rec.primaryPoints
            .add(firstMeridianPoints[firstMeridianPoints.keys.elementAt(i)]);
      }
    }
    //Spit back the (now populated) recommendation.
    return rec;
  }
}

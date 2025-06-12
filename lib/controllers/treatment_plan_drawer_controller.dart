/*This class control the TreatmentPlan Drawer's top bar tabs functionality and change the Drawer content based on Selected tabs
like Points, Expanded Care, Home Care and Diet
*/

import 'package:acugraph6/controllers/common_controller.dart';
import 'package:acugraph6/utils/constants.dart';
import 'package:flutter/material.dart';

import '../views/common_widgets/side_drawers/modules/treatment_plan_drawer/add_edit_diet.dart';
import '../views/common_widgets/side_drawers/modules/treatment_plan_drawer/add_edit_treatmentRecommendation.dart';
import '../views/common_widgets/side_drawers/modules/treatment_plan_drawer/add_edit_point_view.dart';

class TreatmentPlanDrawerController extends CommonController {
//Initializing treatment plan drawer top bar date
//   DateTime currentTreatmentPlanDate = DateTime.now();

  //Initializing current tab of Treatment Plan drawer
  TreatmentPlanDrawerTabEnum treatmentPlanDrawerTabEnum =
      TreatmentPlanDrawerTabEnum.points;

  //Initializing current content of TreatmentPlan top bar tabs
  Widget currentDrawerContent = const AddEditPointView();

  /*This function is used to update the TreatmentPlan Drawer content, based on selected tab*/
  changeCurrentTreatmentPlanDrawerContent(TreatmentPlanDrawerTabEnum content) {
    treatmentPlanDrawerTabEnum = content;
    switch (treatmentPlanDrawerTabEnum) {
      case TreatmentPlanDrawerTabEnum.points:
        currentDrawerContent = const AddEditPointView();
        break;
      case TreatmentPlanDrawerTabEnum.expandedCare:
        currentDrawerContent = const AddEditTreatmentRecommendation();
        break;
      case TreatmentPlanDrawerTabEnum.homeCare:
        currentDrawerContent = const AddEditTreatmentRecommendation();
        break;
      case TreatmentPlanDrawerTabEnum.diet:
        currentDrawerContent = const AddEditDiet();
        break;
      default:
        currentDrawerContent = const AddEditPointView();
        break;
    }
    notifyListeners();
  }
}

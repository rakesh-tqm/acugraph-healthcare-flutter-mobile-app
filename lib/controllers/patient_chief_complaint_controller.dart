/*
This class is representing the patient chief controller class to show the chief complaints in patient info tab also to add or edit
chief complaints in Today's visit section.
This class is calling inside patient_screen/components/patient_chief_complaint_listview.dart
*/

import 'package:acugraph6/controllers/common_controller.dart';
import 'package:acugraph6/controllers/patient_controller.dart';
import 'package:acugraph6/data_layer/custom/search_result.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:provider/provider.dart';
import '../data_layer/models/patient_chief_complaint.dart';
import '../utils/utils.dart';

class PatientChiefComplaintController extends CommonController {
  //Initializing array of chief complaints to store all the data related to selected patient.
  List<PatientChiefComplaint> patientChiefComplaintList = [];

  PatientChiefComplaint? selectedChiefComplaint;

/* Function to get the patient chief complaints related to selected patient. */
  getPatientChiefComplaintList({required BuildContext context}) async {
    try {
      patientChiefComplaintList.clear();
      SearchResult<PatientChiefComplaint> patientChiefComplaintData =
          await PatientChiefComplaint().fetchMany(filters: {
        "patient_uuid":
            context.read<PatientController>().selectedPatient?.id ?? ""
      });
      patientChiefComplaintList.addAll(patientChiefComplaintData.resources);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  /*Function to create/edit patient chief complaint related to selected patient*/
  addEditPatientChiefComplaint(
      {required BuildContext context,
      required PatientChiefComplaint patientChiefComplaint}) async {
    try {
      SmartDialog.showLoading();
      patientChiefComplaint.patient =
          context.read<PatientController>().selectedPatient;
      if (patientChiefComplaint.id != null) {
        await patientChiefComplaint.update();
        showTips(context, "Patient chief complaint updated Successfully");
      } else {
        await patientChiefComplaint.create();
        showTips(context, "Patient chief complaint created Successfully");
      }
      SmartDialog.dismiss();
      Navigator.pop(context);
      getPatientChiefComplaintList(context: context);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  Future<PatientChiefComplaint?> getPatientChiefComplaintsById({required BuildContext context,required String chiefComplaintId}) async {
    try {

      PatientChiefComplaint patientChiefComplaint = await PatientChiefComplaint().fetchById(chiefComplaintId,include: ['patient']);
      notifyListeners();
      return patientChiefComplaint;
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
    return null;
  }

}

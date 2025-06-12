///TODO:Work in progress this will be use after completion of Global Search navigation

import 'package:acugraph6/controllers/common_controller.dart';
import 'package:acugraph6/controllers/patient_controller.dart';
import 'package:acugraph6/data_layer/custom/search_result.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

import '../data_layer/models/patient_chief_complaint_snapshot.dart';

class PatientChiefComplaintSnapshotController extends CommonController {
//Function to get patient chief complaint snapshot by chief complaint id
  Future<PatientChiefComplaintSnapshot?> getPatientChiefComplaintsSnapShotsById(
      {required BuildContext context, required String chiefComplaintId}) async {
    try {
      PatientChiefComplaintSnapshot patientChiefComplaint =
          await PatientChiefComplaintSnapshot().fetchById(chiefComplaintId,
              include: ['patient', 'chief-complaint']);
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

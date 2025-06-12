/* This class is representing the patient photos controller, handling the functionality to add the photo of patient in
Today's Visit drawer and list of all photos that will show in patient detail screen.
*/

import 'package:acugraph6/controllers/common_controller.dart';
import 'package:acugraph6/controllers/patient_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:provider/provider.dart';
import '../data_layer/custom/search_result.dart';
import '../data_layer/models/patient_attachment.dart';
import '../utils/utils.dart';

class PatientAttachmentController extends CommonController {
  //Instance of Patient Attachment to store the selected patient attachment detail and to
  //perform edit functionality in today's visit selected from patient detail screen.
  PatientAttachment? selectedPatientAttachment;

  /* Function to create/edit attachments related to selected patient in Today's Visit section.*/
  addEditPatientAttachment(
      {required BuildContext context,
      required PatientAttachment patientAttachment}) async {
    try {
      SmartDialog.showLoading();
      patientAttachment.patient =
          context.read<PatientController>().selectedPatient;
      if (patientAttachment.id != null) {
        await patientAttachment.update();
        showTips(context, "Patient attachment updated Successfully");
      } else {
        await patientAttachment.create();
        showTips(context, "Patient attachment created Successfully");
      }
      SmartDialog.dismiss();
      Navigator.pop(context);
      selectedPatientAttachment = null;
      context.read<PatientController>().getPatientById(context: context);
      notifyListeners();
    } catch (e) {
      SmartDialog.dismiss();
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  /* Function to delete patient attachment from patient detail screen*/
  deletePatientAttachment(
      {required BuildContext context,
      required PatientAttachment patientAttachment}) async {
    try {
      SmartDialog.showLoading();
      await patientAttachment.delete();
      showTips(context, "Patient attachment deleted Successfully");
      SmartDialog.dismiss();
      Navigator.pop(context);
      selectedPatientAttachment = null;
      context.read<PatientController>().getPatientById(context: context);
      notifyListeners();
    } catch (e) {
      SmartDialog.dismiss();
      Navigator.pop(context);
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  Future<PatientAttachment?> getPatientAttachmentById(
      {required BuildContext context,
      required String patientAttachmentID}) async {
    try {
      PatientAttachment patientAttachment =
          await PatientAttachment().fetchById(patientAttachmentID,include:['patient']);
      notifyListeners();
      return patientAttachment;
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
    return null;
  }
}

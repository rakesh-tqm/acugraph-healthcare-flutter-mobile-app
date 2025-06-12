/*
This class is representing the patient notes controller to show the notes in patient detail screen , to create or edit the notes
in Today's visit section.
*/

import 'package:acugraph6/controllers/common_controller.dart';
import 'package:acugraph6/controllers/patient_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:provider/provider.dart';
import '../data_layer/custom/search_result.dart';
import '../data_layer/models/note.dart';
import '../data_layer/models/patient.dart';
import '../utils/utils.dart';

class PatientNotesController extends CommonController {
  //Variable to store the TextEditor's text from Notes Screen with the help of Quill controller.
  String? patientNoteDescription;

  //Instance of Note to store the selected patient note detail to perform edit or to display in Today's Visit notes tab selected from patient detail screen.
  Note? selectedNote;

  /* Function to create, edit and delete (If invalid or blank data) patient notes. */
  createEditDeletePatientNote({required BuildContext context}) async {
    try {
      SmartDialog.showLoading();
      if (selectedNote != null) {
        if ((patientNoteDescription ?? "").isNotEmpty) {
          selectedNote?.text = patientNoteDescription.toString();
          await selectedNote?.update();
          showTips(context, "Patient notes updated Successfully");
          Navigator.pop(context);
          context.read<PatientController>().getPatientById(context: context);
          patientNoteDescription = null;
          selectedNote = null;
          notifyListeners();
        } else {
          selectedNote?.text = patientNoteDescription.toString();
          await selectedNote?.delete();
          showTips(context, "Patient notes deleted Successfully");
          Navigator.pop(context);
          context.read<PatientController>().getPatientById(context: context);
          patientNoteDescription = null;
          selectedNote = null;
          notifyListeners();
        }
      } else {
        if ((patientNoteDescription ?? "").isNotEmpty) {
          selectedNote = Note();
          selectedNote?.type = "patient";
          selectedNote?.text = patientNoteDescription.toString();
          selectedNote?.patient =
              context.read<PatientController>().selectedPatient;
          await selectedNote?.create();
          showTips(context, "Patient notes created Successfully");
          Navigator.pop(context);
          context.read<PatientController>().getPatientById(context: context);
          patientNoteDescription = null;
          selectedNote = null;
          notifyListeners();
        } else {
          SmartDialog.showToast("Please enter notes");
        }
      }

      SmartDialog.dismiss();
    } catch (e) {
      SmartDialog.dismiss();
      SmartDialog.showToast(e.toString());
    }
  }

  //Function to get patient notes by note id. This function is calling in global search module.
  Future<Note?> getPatientNoteById(
      {required BuildContext context, required String noteId}) async {
    try {
      Note patientNote = await Note()
          .fetchById(noteId, include: ['patient', 'treatment-plans']);
      notifyListeners();
      return patientNote;
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
    return null;
  }

  /* Function to delete patient notes from patient detail screen*/
  deletePatientNote(
      {required BuildContext context, required Note patientNote}) async {
    try {
      SmartDialog.showLoading();
      await patientNote.delete();
      showTips(context, "Patient note deleted Successfully");
      SmartDialog.dismiss();
      selectedNote = null;
      Navigator.pop(context);
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
}

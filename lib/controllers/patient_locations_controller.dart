/*
This class is representing the patient location controller class to show the location indication points in patient detail screen , to add or edit the location points
in Today's visit location tab.
*/

import 'package:acugraph6/controllers/patient_controller.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:provider/provider.dart';

import '../data_layer/models/patient_location_indication_point.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../data_layer/custom/search_result.dart';
import '../data_layer/models/patient_location_indication.dart';
import 'common_controller.dart';

class PatientLocationsController extends CommonController {
//Variable object to store selected location indication
  PatientLocationIndication? selectedLocationIndication;

  //List object to store the selected patient location's point list
  List<PatientLocationIndicationPoint>? selectedPatientLocationPointList;

  /* Function to get the list of patient location indication points . */
  Future<List<PatientLocationIndicationPoint>>
      getPatientLocationsIndicationPointsList(
          {required BuildContext context,
          required PatientLocationIndication patientLocationIndication}) async {
    isLoadingData = true;
    try {
      SearchResult<PatientLocationIndicationPoint> patientLocationPointData =
          await PatientLocationIndicationPoint().fetchMany(filters: {
        "patient_location_indication_uuid": patientLocationIndication.id
      });
      for (PatientLocationIndicationPoint patientLocationIndicationPoint
          in patientLocationPointData.resources) {
        patientLocationIndicationPoint.locationIndication =
            patientLocationIndication;
      }
      isLoadingData = false;
      notifyListeners();
      return patientLocationPointData.resources;
    } catch (e) {
      isLoadingData = false;
      // notifyListeners();
      if (kDebugMode) {
        print(e.toString());
      }
      return [];
    }
  }

  /* Function to create patient location indication. */
  Future<PatientLocationIndication?> createPatientLocationsIndication(
      {required BuildContext context, String? description}) async {
    isLoadingData = true;
    // notifyListeners();
    try {
      PatientLocationIndication patientLocationIndication =
          PatientLocationIndication();
      patientLocationIndication.patient =
          context.read<PatientController>().selectedPatient;
      patientLocationIndication.description = description;
      await patientLocationIndication.create();
      context.read<PatientController>().getPatientById(context: context);
      isLoadingData = false;
      return patientLocationIndication;
    } catch (e) {
      isLoadingData = false;
      if (kDebugMode) {
        print(e.toString());
      }
      return null;
    }
  }

  /* Function to create the patient location indication points.*/
  Future<void> createLocationIndicationPoints(
      {required BuildContext context,
      required List<PatientLocationIndicationPoint>
          locationIndicationPoints}) async {
    isLoadingData = true;
    // notifyListeners();
    if (locationIndicationPoints.isNotEmpty) {
      for (PatientLocationIndicationPoint locationIndicationPoint
          in locationIndicationPoints) {
        try {
          await locationIndicationPoint.create();
        } catch (e) {
          if (kDebugMode) {
            print(e.toString());
          }
        }
      }
    } else {}
    await context.read<PatientController>().getPatientById(context: context);
    isLoadingData = false;
    notifyListeners();
    // getPatientLocationsIndicationList(context: context, reset: true);
  }

  /* Function to update the patient location indication points .*/
  Future<void> updateLocationIndicationPoints(
      {required BuildContext context,
      required List<PatientLocationIndicationPoint>
          locationIndicationPoints}) async {
    isLoadingData = true;
    // notifyListeners();
    if (locationIndicationPoints.isNotEmpty) {
      for (PatientLocationIndicationPoint locationIndicationPoint
          in locationIndicationPoints) {
        try {
          await locationIndicationPoint.update();
        } catch (e) {
          if (kDebugMode) {
            print(e.toString());
          }
        }
      }
    } else {}
    await context.read<PatientController>().getPatientById(context: context);
    isLoadingData = false;
    notifyListeners();
  }

  /* Function to delete the patient location indication points .*/
  Future<void> deleteLocationIndicationPoints(
      {required BuildContext context,
      required List<PatientLocationIndicationPoint> locationIndicationPoints,
      PatientLocationIndication? patientLocationIndication,
      bool needToDeleteComplete = false}) async {
    isLoadingData = true;
    SmartDialog.showLoading();
    // notifyListeners();
    if (locationIndicationPoints.isNotEmpty) {
      for (PatientLocationIndicationPoint locationIndicationPoint
          in locationIndicationPoints) {
        try {
          await locationIndicationPoint.delete();
        } catch (e) {
          SmartDialog.dismiss();
          if (kDebugMode) {
            print(e.toString());
          }
        }
      }
    } else {
      SmartDialog.dismiss();
    }

    if (needToDeleteComplete) {
      await patientLocationIndication?.delete();
      Navigator.pop(context);
      await context.read<PatientController>().getPatientById(context: context);
      SmartDialog.dismiss();
      notifyListeners();
    }
    isLoadingData = false;
  }

  //Function to get patient location indications by id. This function is calling in global search module
  Future<PatientLocationIndication?> getPatientLocationIndicationById(
      {required BuildContext context,
      required String locationIndicationId}) async {
    try {
      PatientLocationIndication locationIndication =
          await PatientLocationIndication()
              .fetchById(locationIndicationId, include: ['patient']);
      notifyListeners();
      return locationIndication;
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
    return null;
  }

  //Function to get patient location indications point by id. This function is calling in global search module
  Future<PatientLocationIndicationPoint?> getPatientLocationIndicationPointById(
      {required BuildContext context,
      required String locationIndicationPointId}) async {
    try {
      PatientLocationIndicationPoint locationIndicationPoint =
          await PatientLocationIndicationPoint().fetchById(
              locationIndicationPointId,
              include: ['patient', 'location-indication']);
      notifyListeners();
      return locationIndicationPoint;
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
    return null;
  }
}

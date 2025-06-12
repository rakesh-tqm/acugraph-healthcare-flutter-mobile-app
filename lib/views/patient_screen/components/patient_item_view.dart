/* Widget class for Table Rows to display the patient list data */

import 'package:acugraph6/controllers/exam_controller.dart';
import 'package:acugraph6/controllers/patient_controller.dart';
import 'package:acugraph6/controllers/preference_controller.dart';
import 'package:acugraph6/controllers/treatment_plan_library_controller.dart';
import 'package:acugraph6/data_layer/models/patient.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../utils/constant_image_path.dart';
import '../../../utils/constants.dart';
import '../../../utils/sizes_helpers.dart';
import '../../../utils/utils.dart';
import '../edit_patient.dart';

class PatientItemView extends StatelessWidget {
  //Instance to get particular patient data
  final Patient patientData;

  final PatientController? patientController;

  // retrieving the header value from patient screen
  dynamic header;

  PatientItemView(
      {Key? key,
      required this.patientData,
      this.header,
      this.patientController})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<PreferenceController>(
        builder: (context, provider, widget) => Container(
            height: screenHeight(context) * .06,
            margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
            child: Row(
              children: <Widget>[
                provider.showPatientPhoto
                    ?
                    //Patient Profile pic
                    Expanded(
                        flex: 1,
                        child: Container(
                          alignment: Alignment.centerLeft,
                          margin: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                          child: SizedBox(
                            width: screenHeight(context) * 0.055,
                            height: screenHeight(context) * 0.055,
                            child: ((patientData.mugshot?.id ?? "") != "")
                                ? CircleAvatar(
                                    backgroundColor: kLightGrey,
                                    radius: 25,
                                    child: ClipOval(
                                      child: FadeInImage(
                                          fit: BoxFit.cover,
                                          placeholder: (patientData.gender
                                                      ?.toLowerCase() ==
                                                  "m")
                                              ? const AssetImage(
                                                  ConstantImagePath
                                                      .malePlaceholder)
                                              : const AssetImage(
                                                  ConstantImagePath
                                                      .femalePlaceholder),
                                          imageErrorBuilder:
                                              (context, error, stackTrace) {
                                            return Image.asset(ConstantImagePath
                                                .userWarningPlaceholder);
                                          },
                                          image: NetworkImage(
                                              "$patientImage/${patientData.mugshot?.id ?? ""}",
                                              headers: header),
                                          width: screenHeight(context) * 0.055,
                                          height:
                                              screenHeight(context) * 0.055),
                                    ),
                                  )
                                : CircleAvatar(
                                    radius: 25,
                                    backgroundColor: kLightGrey,
                                    child: ClipOval(
                                        child: Image(
                                            image: (patientData.gender
                                                        ?.toLowerCase() ==
                                                    "m")
                                                ? const AssetImage(
                                                    ConstantImagePath
                                                        .malePlaceholder)
                                                : const AssetImage(
                                                    ConstantImagePath
                                                        .femalePlaceholder),
                                            width:
                                                screenHeight(context) * 0.055,
                                            height: screenHeight(context) *
                                                0.055))),
                          ),
                        ))
                    : Container(),

                //Patient Name
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                    child: GestureDetector(
                      onTap: () {
                        patientController?.selectPatient(patientData);
                        patientController?.changeCurrentScreen(
                            PatientRecordsScreensEnum.patientRecords);
                        patientController?.getPatientById(context: context);
                        context
                            .read<TreatmentPlanLibraryController>()
                            .selectedTreatmentPlan = null;
                      },
                      child: Text(
                        (patientData.firstName ?? "") +
                            " " +
                            (patientData.middleName ?? "") +
                            " " +
                            (patientData.lastName ?? ""),
                        style: getTextTheme(
                            fontWeight: FontWeight.w400,
                            textColor: kDarkBlue,
                            fontSize: screenHeight(context) * 0.020),
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ),
                  flex: 3,
                ),

                //Date  of Birth
                Expanded(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          dateFormat(
                            patientData.dob,
                            provider.dateFormatValue,
                          ),
                          style: getTextTheme(
                              fontWeight: FontWeight.w400,
                              textColor: kDarkBlue,
                              fontSize: screenHeight(context) * 0.016),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                  flex: 2,
                ),

                //Age
                provider.showCurrentPatientAge
                    ? Expanded(
                        child: Row(
                          children: [
                            Flexible(
                              child: Container(
                                margin: const EdgeInsets.only(left: 5),
                                child: Text(
                                  calculateAge(patientData.dob),
                                  style: getTextTheme(
                                      fontWeight: FontWeight.w400,
                                      textColor: kDarkBlue,
                                      fontSize: screenHeight(context) * 0.016),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                        ),
                        flex: 2,
                      )
                    : Container(),

                //Last Edit
                Expanded(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          ((patientData.updatedAt ?? "") != "")
                              ? dateFormat((patientData.updatedAt),
                                  provider.dateFormatValue)
                              : "",
                          style: getTextTheme(
                              fontWeight: FontWeight.w400,
                              textColor: kDarkBlue,
                              fontSize: screenHeight(context) * 0.016),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                  flex: 2,
                ),

                //Exams or Graphs
                Expanded(
                  child: Row(
                    children: [
                      Flexible(
                        child: Container(
                          margin: const EdgeInsets.only(left: 15),
                          child: Text(
                            patientData.examsCount.toString(),
                            style: getTextTheme(
                                fontWeight: FontWeight.w400,
                                textColor: kDarkBlue,
                                fontSize: screenHeight(context) * 0.016),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                  flex: 2,
                ),

                //ID
                Expanded(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(patientData.patientId ?? "",
                            style: getTextTheme(
                                fontWeight: FontWeight.w400,
                                textColor: kDarkBlue,
                                fontSize: screenHeight(context) * 0.016),
                            textAlign: TextAlign.center),
                      ),
                    ],
                  ),
                  flex: 2,
                ),

                //Custom Title
                Expanded(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          patientData.custom ?? "",
                          style: getTextTheme(
                              fontWeight: FontWeight.w400,
                              textColor: kDarkBlue,
                              fontSize: screenHeight(context) * 0.016),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                  flex: 2,
                ),

                //Edit Icon
                Expanded(
                  child: GestureDetector(
                    child: Image(
                        image: const AssetImage(ConstantImagePath.editIcon),
                        width: screenHeight(context) * 0.028,
                        height: screenHeight(context) * 0.028),
                    onTap: () {
                      patientController?.navigateToPush(
                          context,
                          EditPatient(
                            patientObject: patientData,
                            isFromDetails: false,
                          ));
                    },
                  ),
                  flex: 1,
                ),

                //Exam
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      patientController?.selectPatient(patientData);
                      context.read<ExamController>().selectedExam = null;
                      context.read<PatientController>().changeCurrentScreen(
                          PatientRecordsScreensEnum.newExam);
                      patientController?.getPatientById(context: context);
                    },
                    child: Image(
                        image: const AssetImage(ConstantImagePath.newExamIcon),
                        width: screenHeight(context) * 0.028,
                        height: screenHeight(context) * 0.028),
                  ),
                  flex: 2,
                ),
              ],
            )));
  }
}

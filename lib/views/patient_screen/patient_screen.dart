/*
 This class is representing the patient screen just after the practitioner
  login including search, hide and show functionality based on which patient data will show.
 */

import 'dart:async';

import 'package:acugraph6/controllers/preference_controller.dart';
import 'package:acugraph6/utils/constants.dart';
import 'package:acugraph6/views/patient_screen/add_patient.dart';
import 'package:acugraph6/views/patient_screen/components/by_pass_privacy_alert.dart';
import 'package:acugraph6/views/patient_screen/components/search_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../controllers/exam_controller.dart';
import '../../controllers/patient_controller.dart';
import '../../controllers/treatment_plan_library_controller.dart';
import '../../utils/sizes_helpers.dart';
import '../../utils/utils.dart';
import 'components/patient_item_view.dart';

class PatientScreen extends StatefulWidget {
  const PatientScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<PatientScreen> createState() => _PatientScreenState();
}

class _PatientScreenState extends State<PatientScreen> {
  //Hide and show toggle button animation duration
  final animationDuration = const Duration(milliseconds: 200);

  //Controller for the ListView widget
  late ScrollController _controller;

  // this variable is use stores the bool value of patient show/hide toggle button
  bool isPatientListVisible = false;

  Timer? timer;

  /* Here we are initializing variables and functions , basically
   the entry point of the stateful widget tree .
     */
  @override
  void initState() {
    super.initState();
    if (context.read<PatientController>().patientsList.isEmpty) {
      context.read<PatientController>().getPatientsData(
          context: context,
          searchText:
              context.read<PatientController>().searchTextController.text,
          reset: false);
    }

    //Initializing Scroll Controller
    _controller = ScrollController()..addListener(loadMore);
  }

  /* Function to load more Patient Data by checking listview scroll position */
  void loadMore() {
    {
      if (_controller.position.extentAfter < 300) {
        context.read<PatientController>().loadMorePatient(context,
            context.read<PatientController>().searchTextController.text);
      }
    }
  }

/* Function to releases the memory allocated to the existing variables of the state */
  @override
  void dispose() {
    _controller.dispose();
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PatientController>(
      builder: (context, provider, child) => Column(
        children: [
          provider.isPatientListVisible
              ? showPatientTopView(provider)
              : hidePatientsTopView(provider),
          SizedBox(
            height: screenHeight(context) * 0.70,
            child: (provider.isPatientListVisible)
                ? showPatients(provider)
                : hidePatients(provider),
          ),

// Hide Patients, Switch Button, Show Patient
          Container(
            alignment: Alignment.center,
            width: screenWidth(context) * 0.48,
            height: screenHeight(context) * 0.09,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                  transform: Matrix4.translationValues(0.0, -8.0, 0.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Hide Patients
                      Container(
                        width: screenWidth(context) * .15,
                        height: screenHeight(context) * 0.06,
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                            onTap: () {
                              if (context
                                  .read<PreferenceController>()
                                  .showPrivacyWarning) {}
                              setState(() {
                                isPatientListVisible = false;
                              });
                              provider
                                  .patientListShowHide(isPatientListVisible);
                            },
                            child: Text(
                              "Hide Patients",
                              textAlign: TextAlign.right,
                              style: getTextTheme(
                                  textColor: kDarkGrey,
                                  fontWeight: FontWeight.w400,
                                  fontSize: screenHeight(context) * 0.020),
                            )),
                      ),

                      //Toggle button
                      GestureDetector(
                        onTap: () {
                          if (!provider.isPatientListVisible) {
                            if (context
                                .read<PreferenceController>()
                                .showPrivacyWarning) {
                              setState(() {
                                isPatientListVisible = !isPatientListVisible;
                              });
                              provider
                                  .patientListShowHide(isPatientListVisible);
                            } else {
                              //UI of Dialog Box ByPass privacy alert
                              showDialog(
                                barrierDismissible: true,
                                context: context,
                                builder: (context) {
                                  //Return ByPassPrivacyAlertContent box
                                  return ByPassPrivacyAlertView(
                                    onContinueTapped: () {
                                      setState(() {
                                        isPatientListVisible = true;
                                      });
                                      provider.patientListShowHide(
                                          isPatientListVisible);
                                    },
                                  );
                                },
                              );
                            }
                          } else {
                            setState(() {
                              isPatientListVisible = !isPatientListVisible;
                            });
                            provider.patientListShowHide(isPatientListVisible);
                          }
                        },
                        child: AnimatedContainer(
                          duration: animationDuration,
                          alignment: Alignment.center,
                          width: 50,
                          height: 25,
                          margin: const EdgeInsets.fromLTRB(20, 2, 20, 2),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: provider.isPatientListVisible
                                ? kLightGrey
                                : kWhiteGrey,
                            border: Border.all(color: Colors.white, width: 0.2),
                            boxShadow: const [
                              BoxShadow(
                                color: kLightGrey,
                              ),
                            ],
                          ),
                          child: AnimatedAlign(
                            duration: animationDuration,
                            alignment: provider.isPatientListVisible
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 0),
                              child: Container(
                                width: 25,
                                height: 25,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Show Patients
                      Container(
                        width: screenWidth(context) * .15,
                        height: screenHeight(context) * 0.06,
                        alignment: Alignment.centerLeft,
                        child: GestureDetector(
                          onTap: () {
                            if (!provider.isPatientListVisible) {
                              if (context
                                  .read<PreferenceController>()
                                  .showPrivacyWarning) {
                                setState(() {
                                  isPatientListVisible = true;
                                });
                                provider
                                    .patientListShowHide(isPatientListVisible);
                              } else {
                                //UI of Dialog Box ByPass privacy alert
                                showDialog(
                                  barrierDismissible: true,
                                  context: context,
                                  builder: (context) {
                                    //Return ByPassPrivacyAlertContent box
                                    return ByPassPrivacyAlertView(
                                        onContinueTapped: () {
                                      setState(() {
                                        isPatientListVisible = true;
                                      });
                                      provider.patientListShowHide(
                                          isPatientListVisible);
                                    });
                                  },
                                );
                              }
                            } else {
                              setState(() {
                                isPatientListVisible = true;
                              });
                              provider
                                  .patientListShowHide(isPatientListVisible);
                            }
                          },
                          child: Text('Show Patients',
                              style: getTextTheme(
                                fontWeight: FontWeight.w400,
                                textColor: kDarkGrey,
                                fontSize: screenHeight(context) * 0.020,
                              ),
                              textAlign: TextAlign.left),
                        ),
                      )

                      //),
                    ],
                  ),
                ),
              ],
            ),
          )

          //),
        ],
      ),
    );
    //return Container();
  }

  /* Widget to show the top view with only Acugraph Logo */
  Widget hidePatientsTopView(PatientController provider) {
    // Acugraph Logo //
    return SizedBox(
      width: screenWidth(context) * .28,
      height: screenHeight(context) * 0.109,
      child: getLogo(
        context,
        Matrix4.translationValues(0.0, 0.0, 0.0),
        SvgPicture.asset(
          svgLogoImagePath,
          width: screenWidth(context) * 0.20,
          height: screenHeight(context) * 0.08,
          fit: BoxFit.fitWidth,
        ),
      ),
    );
    // );
  }

  void onGoSearchOrMoveToPatientDetail(PatientController? patientController) {
    if (context
        .read<PatientController>()
        .searchTextController
        .text
        .replaceAll(" ", "")
        .isNotEmpty) {
      patientController?.getPatientsData(
          context: context,
          searchText:
              context.read<PatientController>().searchTextController.text,
          reset: true);
    } else {
      if ((patientController?.patientsList ?? []).isNotEmpty) {
        patientController?.selectPatient(patientController.patientsList[0]);
        patientController
            ?.changeCurrentScreen(PatientRecordsScreensEnum.patientRecords);
        patientController?.getPatientById(context: context);
        context.read<TreatmentPlanLibraryController>().selectedTreatmentPlan =
            null;
        context.read<ExamController>().selectedExam = null;
      } else {
        patientController?.getPatientsData(
            context: context,
            searchText:
                context.read<PatientController>().searchTextController.text,
            reset: true);
      }
    }
  }

  /*Widget to show the top view with Search/Go/Add New Patient */
  Widget showPatientTopView(PatientController provider) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        //Box containing two containers inside row: one for Search Input field/Go and other for Add new patient //
        SizedBox(
          width: screenWidth(context),
          height: screenHeight(context) * 0.109,
          child: Row(
            children: [
              // SearchWidget for Search Input field and Go Button//
              SearchWidget(
                  searchTextController:
                      context.read<PatientController>().searchTextController,
                  onSubmitted: () {
                    onGoSearchOrMoveToPatientDetail(provider);
                  },
                  onChangedText: (text) {
                    timer?.cancel();
                    timer = Timer(const Duration(milliseconds: 700), () {
                      provider.getPatientsData(
                          context: context,
                          searchText: context
                              .read<PatientController>()
                              .searchTextController
                              .text,
                          reset: true);
                    });
                  },
                  onClearText: () {
                    provider.getPatientsData(
                        context: context,
                        searchText: context
                            .read<PatientController>()
                            .searchTextController
                            .text,
                        reset: true);
                  },
                  patientListCount: provider.patientsList.length),

              // Second container for add new patient //
              Expanded(
                flex: 50,
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      height: screenHeight(context) * 0.10,
                      margin: const EdgeInsets.fromLTRB(0, 0, 15, 13),
                      child:
                          // + Add new patient //
                          TextButton.icon(
                        icon: Icon(
                          Icons.add_circle,
                          size: screenHeight(context) * 0.029,
                          color: const Color(0x807373C7),
                        ),
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.transparent),
                          alignment: Alignment.centerRight,
                        ),
                        label: Text(
                          "Add a new patient",
                          textAlign: TextAlign.left,
                          style: getTextTheme(
                              textColor: kDarkBlue,
                              fontWeight: FontWeight.w400,
                              fontSize: screenHeight(context) * 0.020),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const AddPatient()),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
    // );
  }

  /* Widget for hiding patients when toggle is OFF */
  Widget hidePatients(PatientController provider) {
    return Container(
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Select Patient Label //
          getlabeltext(context, 'Select a Patient to Begin:', FontWeight.bold,
              kDarkGrey, screenHeight(context) * 0.028),

          // For Spacing //
          SizedBox(height: screenHeight(context) * 0.02),

          // Search InputField and Go Button //
          SearchWidget(
              searchTextController:
                  context.read<PatientController>().searchTextController,
              onSubmitted: () {
                onGoSearchOrMoveToPatientDetail(provider);
              },
              onChangedText: (text) {
                timer?.cancel();
                timer = Timer(const Duration(microseconds: 700), () {
                  provider.getPatientsData(
                      context: context,
                      searchText: context
                          .read<PatientController>()
                          .searchTextController
                          .text,
                      reset: true);
                });
              },
              onClearText: () {
                provider.getPatientsData(
                    context: context,
                    searchText: context
                        .read<PatientController>()
                        .searchTextController
                        .text,
                    reset: true);
              },
              patientListCount: provider.patientsList.length),
          // For Spacing //
          SizedBox(height: screenHeight(context) * 0.06),

          // or + Add new patient //
          SizedBox(
            width: screenWidth(context) * .28,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // or //
                Text(
                  "or",
                  textAlign: TextAlign.left,
                  style: getTextTheme(
                      textColor: kDarkBlue,
                      fontWeight: FontWeight.w400,
                      fontSize: screenHeight(context) * 0.020),
                ),
                // + Add new patient //
                TextButton.icon(
                  icon: Icon(
                    Icons.add_circle,
                    size: screenHeight(context) * 0.029,
                    color: const Color(0x807373C7),
                  ),
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(Colors.transparent),
                    alignment: Alignment.centerRight,
                  ),
                  label: Text(
                    "Add a new patient",
                    textAlign: TextAlign.left,
                    style: getTextTheme(
                        textColor: kDarkBlue,
                        fontWeight: FontWeight.w400,
                        fontSize: screenHeight(context) * 0.020),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AddPatient()),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

/* Widget for Patient List Table Header */
  Widget itemHeader(PatientController patientController) {
    return Consumer<PreferenceController>(
      builder: (context, provider, widget) => Container(
          height: screenHeight(context) * .06,
          margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
          child: Row(
            children: <Widget>[
              //Patient profile picture
              provider.showPatientPhoto
                  ? Expanded(
                      flex: 1,
                      child: Text(
                        "",
                        style: getTextTheme(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.left,
                      ))
                  : Container(),

              //Name
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    patientController.sortingPatientFields(
                        selectedPatientField: SortByPatientFields.name);
                  },
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(39, 0, 0, 0),
                    child: Row(
                      children: [
                        Flexible(
                          child: Text(
                            "Name",
                            style: getTextTheme(
                                fontWeight: (patientController
                                                .sortByPatientField !=
                                            null &&
                                        patientController.sortByPatientField ==
                                            SortByPatientFields.name)
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                textColor: kDarkBlue,
                                fontSize: screenHeight(context) * 0.018),
                            textAlign: TextAlign.left,
                          ),
                        ),
                        (patientController.sortByPatientField != null &&
                                patientController.sortByPatientField ==
                                    SortByPatientFields.name)
                            ? Icon((patientController.isSortingReverse)
                                ? Icons.arrow_drop_up
                                : Icons.arrow_drop_down)
                            : Container()
                      ],
                    ),
                  ),
                ),
                flex: 3,
              ),

              //Date of Birth
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    patientController.sortingPatientFields(
                        selectedPatientField: SortByPatientFields.dob);
                  },
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          "Date of Birth",
                          style: getTextTheme(
                              fontWeight: (patientController
                                              .sortByPatientField !=
                                          null &&
                                      patientController.sortByPatientField ==
                                          SortByPatientFields.dob)
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              textColor: kDarkBlue,
                              fontSize: screenHeight(context) * 0.018),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      (patientController.sortByPatientField != null &&
                              patientController.sortByPatientField ==
                                  SortByPatientFields.dob)
                          ? Icon(patientController.isSortingReverse
                              ? Icons.arrow_drop_up
                              : Icons.arrow_drop_down)
                          : Container()
                    ],
                  ),
                ),
                flex: 2,
              ),

              //Age
              provider.showCurrentPatientAge
                  ? Expanded(
                      child: GestureDetector(
                        onTap: () {
                          patientController.sortingPatientFields(
                              selectedPatientField: SortByPatientFields.age);
                        },
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                "Age",
                                style: getTextTheme(
                                    fontWeight:
                                        (patientController.sortByPatientField !=
                                                    null &&
                                                patientController
                                                        .sortByPatientField ==
                                                    SortByPatientFields.age)
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                    textColor: kDarkBlue,
                                    fontSize: screenHeight(context) * 0.018),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            (patientController.sortByPatientField != null &&
                                    patientController.sortByPatientField ==
                                        SortByPatientFields.age)
                                ? Icon(patientController.isSortingReverse
                                    ? Icons.arrow_drop_up
                                    : Icons.arrow_drop_down)
                                : Container()
                          ],
                        ),
                      ),
                      flex: 2,
                    )
                  : Container(),

              //Last Edit
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    patientController.sortingPatientFields(
                        selectedPatientField: SortByPatientFields.lastEdit);
                  },
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          "Last Edit",
                          style: getTextTheme(
                              fontWeight: (patientController
                                              .sortByPatientField !=
                                          null &&
                                      patientController.sortByPatientField ==
                                          SortByPatientFields.lastEdit)
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              textColor: kDarkBlue,
                              fontSize: screenHeight(context) * 0.018),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      (patientController.sortByPatientField != null &&
                              patientController.sortByPatientField ==
                                  SortByPatientFields.lastEdit)
                          ? Icon(patientController.isSortingReverse
                              ? Icons.arrow_drop_up
                              : Icons.arrow_drop_down)
                          : Container()
                    ],
                  ),
                ),
                flex: 2,
              ),

              //Graph
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    patientController.sortingPatientFields(
                        selectedPatientField: SortByPatientFields.graph);
                  },
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          "Graph",
                          style: getTextTheme(
                              fontWeight: (patientController
                                              .sortByPatientField !=
                                          null &&
                                      patientController.sortByPatientField ==
                                          SortByPatientFields.graph)
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              textColor: kDarkBlue,
                              fontSize: screenHeight(context) * 0.018),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      (patientController.sortByPatientField != null &&
                              patientController.sortByPatientField ==
                                  SortByPatientFields.graph)
                          ? Icon(patientController.isSortingReverse
                              ? Icons.arrow_drop_up
                              : Icons.arrow_drop_down)
                          : Container()
                    ],
                  ),
                ),
                flex: 2,
              ),

              //ID
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    patientController.sortingPatientFields(
                        selectedPatientField: SortByPatientFields.patientId);
                  },
                  child: Row(
                    children: [
                      Text(
                        "ID",
                        style: getTextTheme(
                            fontWeight:
                                (patientController.sortByPatientField != null &&
                                        patientController.sortByPatientField ==
                                            SortByPatientFields.patientId)
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                            textColor: kDarkBlue,
                            fontSize: screenHeight(context) * 0.018),
                        textAlign: TextAlign.center,
                      ),
                      (patientController.sortByPatientField != null &&
                              patientController.sortByPatientField ==
                                  SortByPatientFields.patientId)
                          ? Icon(patientController.isSortingReverse
                              ? Icons.arrow_drop_up
                              : Icons.arrow_drop_down)
                          : Container()
                    ],
                  ),
                ),
                flex: 2,
              ),

              //Custom Field
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    patientController.sortingPatientFields(
                        selectedPatientField: SortByPatientFields.customField);
                  },
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          provider.customFieldTitle ?? "Custom Field",
                          style: getTextTheme(
                              fontWeight: (patientController
                                              .sortByPatientField !=
                                          null &&
                                      patientController.sortByPatientField ==
                                          SortByPatientFields.customField)
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              textColor: kDarkBlue,
                              fontSize: screenHeight(context) * 0.018),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      (patientController.sortByPatientField != null &&
                              patientController.sortByPatientField ==
                                  SortByPatientFields.customField)
                          ? Icon(patientController.isSortingReverse
                              ? Icons.arrow_drop_up
                              : Icons.arrow_drop_down)
                          : Container()
                    ],
                  ),
                ),
                flex: 2,
              ),

              //Edit Patient
              Expanded(
                child: Text(
                  "Edit",
                  style: getTextTheme(
                      fontWeight: FontWeight.normal,
                      textColor: kDarkBlue,
                      fontSize: screenHeight(context) * 0.018),
                  textAlign: TextAlign.center,
                ),
                flex: 1,
              ),

              //New Exam
              Expanded(
                child: Text(
                  "New Exam",
                  style: getTextTheme(
                      fontWeight: FontWeight.normal,
                      textColor: kDarkBlue,
                      fontSize: screenHeight(context) * 0.018),
                  textAlign: TextAlign.center,
                ),
                flex: 2,
              ),
            ],
          )),
    );
  }

  /* Widget for show patient list when toggle is ON */
  Widget showPatients(PatientController patientController) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        // Call Table header function to show titles of each column //
        itemHeader(patientController),

        // ListView to displaying patients//
        Container(
            transform: Matrix4.translationValues(0.0, 0.0, 0.0),
            height: screenHeight(context) * 0.623,
            child: MediaQuery.removePadding(
                context: context,
                removeTop: true,
                child: ListView.builder(
                    itemCount: patientController.patientsList.length,
                    controller: _controller,
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemBuilder: (_, index) {
                      //Initializing header from patient controller class
                      var header =
                          context.read<PatientController>().getHeader();
                      /*Return Widget for Table Rows to display the patient list data */
                      return PatientItemView(
                        patientData: patientController.patientsList[index],
                        header: header,
                        patientController: patientController,
                      );
                    })
                // itemView(
                //   patientData,
                // )
                )),
      ],
    );
  }
}

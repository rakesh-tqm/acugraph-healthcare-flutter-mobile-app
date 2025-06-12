/*
 This class is used to display all the history of a particular patient like treatmentplans, expandedcare, location points, notes etc.
*/

import 'dart:io';
import 'dart:ui' as ui;

import 'package:acugraph6/controllers/patient_controller.dart';
import 'package:acugraph6/data_layer/models/exam.dart';
import 'package:acugraph6/data_layer/models/patient_location_indication.dart';
import 'package:acugraph6/data_layer/models/treatment_plan.dart';
import 'package:acugraph6/utils/constants.dart';
import 'package:acugraph6/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sticky_headers/sticky_headers.dart';

import '../../controllers/exam_controller.dart';
import '../../data_layer/models/note.dart';
import '../../data_layer/models/patient_attachment.dart';
import '../../utils/constant_image_path.dart';
import '../../utils/sizes_helpers.dart';
import '../patient_exams/exam_item_view.dart';
import '../patient_locations/point_location_item_view.dart';
import '../patient_notes/notes_item_view.dart';
import '../patient_photos/photo_item_view.dart';
import '../patient_treatment_plan/patient_treatment_plan_view.dart';

class PatientDetail extends StatefulWidget {
  // default constructor of patient detail
  const PatientDetail({
    Key? key,
  }) : super(key: key);

  @override
  State<PatientDetail> createState() => _PatientDetailState();
}

class _PatientDetailState extends State<PatientDetail> {
  //bodyResizedImageOnCurrentView used to resized the bodyMainImage with respect to the current screen view.
  ui.Image? bodyResizedImageOnCurrentView;

  //bodyMainImage is main body image which is fetching from assets and using this we are resizing into another image having
  // name bodyResizedImageOnCurrentView.By calculating coordinates using height and width of bodyMainImage and
  // bodyResizedImageOnCurrentView, then printing coordinates on bodyResizedImageOnCurrentView image.
  ui.Image? bodyMainImage;

  DateTime? headerDate;

  @override
  void initState() {
    super.initState();
    getPatientImages();
    context.read<ExamController>().selectedExam = null;
  }

  /* Function to get the male or female image from the assets and resizing it according to current view to print the
  exact coordinates. These resizing methods are written in utils class. */
  void getPatientImages() async {
    if (context
            .read<PatientController>()
            .selectedPatient
            ?.gender
            ?.toLowerCase() ==
        "m") {
      getUiImage(ConstantImagePath.painLocatorMaleIcon).then((value) async {
        bodyMainImage = value;
        getImageForCurrentView(bodyImage: bodyMainImage!, imagePartition: 8)
            .then((value) {
          bodyResizedImageOnCurrentView = value;
          setState(() {});
        });
      });
    } else {
      getUiImage(ConstantImagePath.painLocatorFemaleIcon).then((value) {
        bodyMainImage = value;
        getImageForCurrentView(bodyImage: bodyMainImage!, imagePartition: 8)
            .then((value) {
          bodyResizedImageOnCurrentView = value;
          setState(() {});
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PatientController>(
      builder: (context, provider, child) {
        return Column(children: [
          SizedBox(
              height: screenHeight(context) * 0.91,
              child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                        flex: 5,
                        child: TextButton(
                          onPressed: () {
                            context
                                .read<PatientController>()
                                .changeCurrentScreen(
                                    PatientRecordsScreensEnum.selectPatient);
                          },
                          // back button
                          child: Container(
                              alignment: Alignment.topRight,
                              height: 50,
                              width: 50,
                              child: Padding(
                                padding: Platform.isIOS
                                    ? const EdgeInsets.only(
                                        left: 18.0,
                                        right: 18,
                                        top: 12,
                                        bottom: 15)
                                    : const EdgeInsets.only(
                                        left: 18.0,
                                        right: 18,
                                        top: 20,
                                        bottom: 15),
                                child: Icon(Icons.arrow_back_ios,
                                    color: kDarkBlue,
                                    size: screenHeight(context) * 0.026),
                              )),
                        )),

                    // Center Box for office visit patient name and date//
                    Expanded(
                        flex: 85,
                        child: Container(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(children: [
                              SizedBox(
                                  width: screenWidth(context),
                                  child: Text(
                                    "Office visit for ${context.watch<PatientController>().selectedPatient?.firstName} ${context.watch<PatientController>().selectedPatient?.lastName}",
                                    textAlign: TextAlign.left,
                                    style: getTextTheme(
                                        textColor: kDarkBlue,
                                        fontSize: screenHeight(context) * 0.020,
                                        fontWeight: FontWeight.w800),
                                  )),
                              // Container for divider
                              const Divider(color: kLightBlue),

                              Expanded(
                                child: ListView.builder(
                                    scrollDirection: Axis.vertical,
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    itemCount: provider
                                            .selectedGroupedRecord?.length ??
                                        0,
                                    itemBuilder: (_, index) {
                                      final String date = provider
                                          .selectedGroupedRecord?.keys
                                          .elementAt(index);
                                      final recordItem =
                                          provider.selectedGroupedRecord?[date];

                                      return StickyHeader(
                                        header: Container(
                                          padding: const EdgeInsets.only(
                                              top: 5, bottom: 5),
                                          color: const Color.fromRGBO(
                                              250, 250, 250, 1),
                                          width: screenWidth(context),
                                          child: Text(
                                            "OFFICE VISIT $date",
                                            textAlign: TextAlign.left,
                                            style: getTextTheme(
                                                textColor: kDarkGreyBold,
                                                fontSize:
                                                    screenHeight(context) *
                                                        0.021,
                                                fontWeight: FontWeight.w700),
                                          ),
                                        ),
                                        content: ListView.builder(
                                            scrollDirection: Axis.vertical,
                                            shrinkWrap: true,
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            itemCount: recordItem?.length ?? 0,
                                            itemBuilder: (_, index) {
                                              return detailRecordItem(recordItem
                                                      ?.elementAt(index)) ??
                                                  Container();
                                            }),
                                      );
                                    }),
                              )
                            ]),
                          ),
                        )),
                  ])),
        ]);
      },
    );
  }

  Widget? detailRecordItem(dynamic recordItem) {
    Widget? widget;
    var header = context.read<PatientController>().getHeader();
    if (recordItem is Exam) {
      widget = ExamItemView(
        examData: recordItem,
      );
    } else if (recordItem is Note) {
      widget = NotesItemView(
        notesData: recordItem,
      );
    } else if (recordItem is PatientLocationIndication) {
      // widget = Text("Location Indication");
      var newCurrentBodyImage = bodyResizedImageOnCurrentView?.clone();
      widget = (bodyResizedImageOnCurrentView != null)
          ? PointLocationItemView(
              locationIndication: recordItem,
              bodyResizedImageOnCurrentView: newCurrentBodyImage!,
              bodyMainImage: bodyMainImage!,
            )
          : Container();
    } else if (recordItem is PatientAttachment) {
      widget = (header != null)
          ? PhotoItemView(attachmentData: recordItem, header: header)
          : Container();
    } else if (recordItem is TreatmentPlan) {
      widget = TreatmentPlanView(
        treatmentPlan: recordItem,
      );

    }

    return widget;
  }
}

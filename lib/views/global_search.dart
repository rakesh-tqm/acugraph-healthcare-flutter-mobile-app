/* This class is used for global searchable content within patient records by provided keyword.
It will search all user-entered fields that contain text within any sort of patient record. For example:
 - Descriptions for patient attachments
 - Exam home care instructions
 - Text from all patient notes
 - All aspects of patient chief complaints (name, onset, location, duration, etc) Patient location descriptions and comments
etc search the patients.
 */
import 'package:acugraph6/controllers/global_search_controller.dart';
import 'package:acugraph6/controllers/patient_locations_controller.dart';
import 'package:acugraph6/data_layer/models/patient_chief_complaint_snapshot.dart';
import 'package:acugraph6/data_layer/models/patient_location_indication.dart';
import 'package:acugraph6/data_layer/models/patient_location_indication_point.dart';
import 'package:acugraph6/utils/constant_image_path.dart';
import 'package:acugraph6/utils/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:substring_highlight/substring_highlight.dart';

import '../controllers/patient_attatchment_controller.dart';
import '../controllers/patient_chief_complaint_controller.dart';
import '../controllers/patient_chief_complaint_snapshot_controller.dart';
import '../controllers/patient_controller.dart';
import '../controllers/patient_notes_controller.dart';
import '../controllers/preference_controller.dart';
import '../controllers/today_visit_drawer_controller.dart';
import '../data_layer/models/note.dart';
import '../data_layer/models/patient_attachment.dart';
import '../data_layer/models/patient_chief_complaint.dart';
import '../utils/constants.dart';
import '../utils/sizes_helpers.dart';
import 'common_widgets/side_drawers/modules/today_visit_drawer/today_visit_drawer.dart';

class GlobalSearch extends StatefulWidget {
  const GlobalSearch({Key? key}) : super(key: key);

  @override
  State<GlobalSearch> createState() => _GlobalSearchState();
}

class _GlobalSearchState extends State<GlobalSearch>
    with TickerProviderStateMixin {
  //This variable is used to add animation on the screen.
  late AnimationController animationController;

  //Variable used to set the new page start and end position
  late Animation<Offset> animationPosition;

  //Variable used to type the search text in global search box
  final TextEditingController _textEditingController = TextEditingController();

  /* Here we are initializing variables and functions , basically the entry point of
  the stateful widget tree .
     */
  @override
  void initState() {
    super.initState();
    // Set Animation objects //
    animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    animationPosition =
        Tween<Offset>(begin: const Offset(0.0, -4.0), end: Offset.zero)
            .animate(animationController);
    animationController.forward();

    _textEditingController.text =
        Provider.of<GlobalSearchController>(context, listen: false).searchText;
  }

  @override
  Widget build(BuildContext context) {
    // Add Faded View in background
    return Material(
      color: Colors.black.withOpacity(0.54),
      child: Align(
          alignment: Alignment.topRight,
          child: Padding(
            padding: const EdgeInsets.all(40.0),
            // Transit View from top to bottom
            child: SlideTransition(
              position: animationPosition,
              child: Consumer<GlobalSearchController>(
                builder: (context, provider, child) => Container(
                    width: screenWidth(context) * .95,
                    height: screenHeight(context) * .85,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          //color of shadow
                          spreadRadius: 5,
                          //spread radius
                          blurRadius: 7,
                          // blur radius
                          offset:
                          const Offset(0, 2), // changes position of shadow
                          //first paramerter of offset is left-right
                          //second parameter is top to down
                        ),
                        //you can set more BoxShadow() here
                      ],
                    ),
                    child: Column(children: [
                      //getgreycross(context),

                      Container(
                        margin: const EdgeInsets.fromLTRB(0, 15, 18, 0),
                        alignment: Alignment.topRight,
                        color: Colors.white,
                        child: GestureDetector(
                          child: Icon(Icons.clear,
                              color: Colors.grey,
                              size: screenHeight(context) * 0.026),
                          onTap: () {
                            animationController.reverse();
                            Navigator.pop(context);
                          },
                        ),
                      ),

                      //Global search text
                      Container(
                        width: screenWidth(context),
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          color: Colors.transparent,
                        ),
                        child: Text(
                            "GLOBAL RECORDS SEARCH",
                            style:getTextTheme(
                                fontWeight:  FontWeight.w700,
                                textColor: kDarkGreyBold,
                                fontSize: screenHeight(context) * 0.021),
                            textAlign: TextAlign.center),
                      ),
                      //For Spacing
                      SizedBox(height: screenHeight(context) * 0.03),

                      //Global Search textfield
                      SizedBox(
                        width: screenWidth(context) * .5,
                        height: screenHeight(context) * 0.05,
                        child: TextField(
                          textAlignVertical: TextAlignVertical.center,
                          onSubmitted: (term) {
                            provider.getSearchedData(
                                context: context,
                                searchText: _textEditingController.value.text);
                          },
                          style: getTextTheme(
                              fontSize: screenHeight(context) * 0.018,
                              textColor: kDarkGrey),
                          decoration: InputDecoration(
                              hintText: 'Search',
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: screenHeight(context) * 0.018,
                                  horizontal: 10.0),
                              enabledBorder: const OutlineInputBorder(
                                gapPadding: 1,
                                borderSide:
                                BorderSide(color: kLightGrey, width: 1.2),
                              ),
                              focusedBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(color: kLightGrey)),
                              border: const OutlineInputBorder(),
                              suffixIcon: _textEditingController.text.isNotEmpty
                                  ? IconButton(
                                icon: Icon(Icons.clear,
                                    color: kLightGrey,
                                    size: screenHeight(context) * 0.025),
                                onPressed: () {
                                  _textEditingController.clear();
                                },
                              )
                                  : IconButton(
                                icon: Icon(Icons.search,
                                    color: kLightGrey,
                                    size: screenHeight(context) * 0.025),
                                onPressed: () {
                                  //_textController.clear();
                                },
                              )),
                          onChanged: (text) {
                            if (kDebugMode) {
                              print(text);
                            }
                          },
                          controller: _textEditingController,
                        ),
                      ),
                      // For spacing
                      SizedBox(height: screenHeight(context) * 0.03),

                      //Condition to check whether the search results exist or not , if result is empty then show message
                      // with No Result Found
                      (provider.suggestionsList.isEmpty)
                          ? itemViewParentEmpty()
                          : Expanded(
                        child: ListView.builder(
                          shrinkWrap: true,
                          padding: const EdgeInsets.all(8),
                          itemCount: provider.suggestionsList.length,
                          itemBuilder: (BuildContext context, int index) {
                            return itemViewParent(index, provider);
                          },
                        ),
                      ),
                    ])),
              ),
            ),
          )),
    );
  }

  /* Widget of List showing Patient profile pic with name */
  Widget itemViewParent(int index, GlobalSearchController provider) {
    return Container(
      transform: Matrix4.translationValues(0.0, -20.0, 0.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: Row(
              children: [
                //Patient Photo
                Image(
                    image: const AssetImage(ConstantImagePath.photoIcon),
                    width: screenHeight(context) * 0.055,
                    height: screenHeight(context) * 0.055),
                //Patient Name
                Container(
                  margin: const EdgeInsets.only(left: 8.0),
                  child: Text(
                      provider.suggestionsList[index].patient?.firstName ?? "",
                      style:getTextTheme(
                          fontWeight:  FontWeight.w400,
                          textColor: kDarkGrey,
                          fontSize: screenHeight(context) * 0.019),
                      textAlign: TextAlign.left),
                ),
              ],
            ),
          ),
          //Grey Line
          Container(
              height: screenHeight(context) * 0.001,
              margin: const EdgeInsets.fromLTRB(10, 0, 20, 0),
              transform: Matrix4.translationValues(0.0, -8.0, 0.0),
              color: Colors.grey[400]),
          // Items listed under profile photo with name based on search text
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
            itemCount: provider.suggestionsList[index].results?.length,
            itemBuilder: (BuildContext context, int subIndex) {
              return GestureDetector(
                child: itemChildParent(index, subIndex, provider),
                onTap: () async {
                  searchItemClickEvent(
                      context: context,
                      patientIndex: index,
                      searchItemIndex: subIndex);
                },
              );
            },
          )
        ],
      ),
    );
  }

  /* List under patient profile Photo with name based on search text */
  Widget itemChildParent(
      parentIndex, subIndex, GlobalSearchController provider) {
    dynamic htmlText;
    if (provider.suggestionsList[parentIndex].results?[subIndex].source ==
        "Note") {
      htmlText = convertDeltaToPlainText(
          jsonDelta: provider
              .suggestionsList[parentIndex].results?[subIndex].context ??
              "");
    }
    //Screen Height
    return Container(
      transform: Matrix4.translationValues(0.0, 0.0, 0.0),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Labels like Notes, Chief complaints will show in this text, based on search text.
            Expanded(
                flex: 10,
                child: Text(
                    provider.suggestionsList[parentIndex].results?[subIndex]
                        .source ??
                        "",
                    style:getTextTheme(
                        fontWeight: FontWeight.w500,
                        textColor: kDarkGreyBold,
                        fontSize: screenHeight(context) * 0.018),
                    textAlign: TextAlign.center)),
            // Date label
            Expanded(
                flex: 16,
                child: Text(
                    dateTimeFormat(
                        provider.suggestionsList[parentIndex].results?[subIndex]
                            .date,
                        context.read<PreferenceController>().dateFormatValue),
                    style:getTextTheme(
                        fontWeight: FontWeight.w500,
                        textColor: kDarkGreyBold,
                        fontSize: screenHeight(context) * 0.018),
                    textAlign: TextAlign.center)),
            //Description
            provider.suggestionsList[parentIndex].results?[subIndex].source ==
                "Note"
                ? Expanded(
                flex: 84,
                child: GestureDetector(
                  child: SubstringHighlight(
                    text: htmlText,
                    // search result string from database or something
                    term: (_textEditingController
                        .value.text), // user typed "et"
                  ),
                ))
                : Expanded(
                flex: 84,
                child: GestureDetector(
                  child: SubstringHighlight(
                    text: provider.suggestionsList[parentIndex]
                        .results?[subIndex].context ??
                        "",
                    // search result string from database or something
                    term: (_textEditingController
                        .value.text), // user typed "et"
                  ),
                ))
          ],
        ),
      ),
    );
  }

  /* Widget to show when search result are empty */
  Widget itemViewParentEmpty() {
    return Container(
      width: screenWidth(context) * 0.89,
      height: screenHeight(context) * 0.60,
      alignment: Alignment.center,
      // height: screenHeight(context)*0.50,
      child: Text('No Result Found',
          style:getTextTheme(
              fontWeight: FontWeight.w500,
              textColor:kDarkBlue,
              fontSize: screenHeight(context) * 0.028),
          textAlign:TextAlign.center),
    );
  }

  /*Function to releases the memory allocated to the existing variables of the state. */
  @override
  dispose() {
    animationController.dispose(); // you need this
    super.dispose();
  }

  /* Function to redirect the page as user click on the respective search result , like if search shows the chief complaint then on click it will redirect to chief complaint
section.
 */
  searchItemClickEvent(
      {required BuildContext context,
        required int patientIndex,
        required int searchItemIndex}) async {
    if (context
        .read<GlobalSearchController>()
        .suggestionsList[patientIndex]
        .results?[searchItemIndex]
        .source ==
        'Note') {
      Note? note =
      await context.read<PatientNotesController>().getPatientNoteById(
        context: context,
        noteId: context
            .read<GlobalSearchController>()
            .suggestionsList[patientIndex]
            .results?[searchItemIndex]
            .id ??
            "",
      );
      context.read<PatientNotesController>().selectedNote = note;

      context
          .read<TodayVisitDrawerController>()
          .changeCurrentTodayVisitDrawerContent(TodayVisitDrawerTabEnum.notes);

      context.read<PatientController>().selectPatient(note!.patient!);

      context
          .read<PatientController>()
          .changeCurrentScreen(PatientRecordsScreensEnum.patientRecords);

      Navigator.pop(context);

      Navigator.push(
          context,
          PageRouteBuilder(
            opaque: false,
            pageBuilder: (BuildContext context, _, __) {
              return const TodayVisitDrawer();
            },
          ));
    } else if (context
        .read<GlobalSearchController>()
        .suggestionsList[patientIndex]
        .results?[searchItemIndex]
        .source ==
        'Patient Chief Complaint') {
      PatientChiefComplaint? patientChiefComplaint = await context
          .read<PatientChiefComplaintController>()
          .getPatientChiefComplaintsById(
        context: context,
        chiefComplaintId: context
            .read<GlobalSearchController>()
            .suggestionsList[patientIndex]
            .results?[searchItemIndex]
            .id ??
            "",
      );
      context.read<PatientChiefComplaintController>().selectedChiefComplaint =
          patientChiefComplaint;

      context
          .read<TodayVisitDrawerController>()
          .changeCurrentTodayVisitDrawerContent(
          TodayVisitDrawerTabEnum.chiefComplaint);

      context
          .read<PatientController>()
          .selectPatient(patientChiefComplaint!.patient!);
      context
          .read<PatientController>()
          .changeCurrentScreen(PatientRecordsScreensEnum.patientRecords);

      Navigator.pop(context);

      Navigator.push(
          context,
          PageRouteBuilder(
            opaque: false,
            pageBuilder: (BuildContext context, _, __) {
              return const TodayVisitDrawer();
            },
          ));
    } else if (context
        .read<GlobalSearchController>()
        .suggestionsList[patientIndex]
        .results?[searchItemIndex]
        .source ==
        'Patient Attachment') {
      PatientAttachment? patientAttachment = await context
          .read<PatientAttachmentController>()
          .getPatientAttachmentById(
        context: context,
        patientAttachmentID: context
            .read<GlobalSearchController>()
            .suggestionsList[patientIndex]
            .results?[searchItemIndex]
            .id ??
            "",
      );
      context.read<PatientAttachmentController>().selectedPatientAttachment =
          patientAttachment;

      context
          .read<TodayVisitDrawerController>()
          .changeCurrentTodayVisitDrawerContent(TodayVisitDrawerTabEnum.photos);

      context
          .read<PatientController>()
          .selectPatient(patientAttachment!.patient!);
      context
          .read<PatientController>()
          .changeCurrentScreen(PatientRecordsScreensEnum.patientRecords);
      Navigator.pop(context);

      Navigator.push(
          context,
          PageRouteBuilder(
            opaque: false,
            pageBuilder: (BuildContext context, _, __) {
              return const TodayVisitDrawer();
            },
          ));
    } else if (context
        .read<GlobalSearchController>()
        .suggestionsList[patientIndex]
        .results?[searchItemIndex]
        .source ==
        'Patient Chief Complaint Snapshot') {
      var chiefComplaintId = context
          .read<GlobalSearchController>()
          .suggestionsList[patientIndex]
          .results?[searchItemIndex]
          .id ??
          "";
      PatientChiefComplaintSnapshot? patientChiefComplaint = await context
          .read<PatientChiefComplaintSnapshotController>()
          .getPatientChiefComplaintsSnapShotsById(
        context: context,
        chiefComplaintId: chiefComplaintId,
      );

      context.read<PatientChiefComplaintController>().selectedChiefComplaint =
          patientChiefComplaint?.chiefComplaint;

      context
          .read<TodayVisitDrawerController>()
          .changeCurrentTodayVisitDrawerContent(
          TodayVisitDrawerTabEnum.chiefComplaint);

      context
          .read<PatientController>()
          .selectPatient(patientChiefComplaint!.patient!);
      context
          .read<PatientController>()
          .changeCurrentScreen(PatientRecordsScreensEnum.patientRecords);

      Navigator.pop(context);

      Navigator.push(
          context,
          PageRouteBuilder(
            opaque: false,
            pageBuilder: (BuildContext context, _, __) {
              return const TodayVisitDrawer();
            },
          ));
    } else if (context
        .read<GlobalSearchController>()
        .suggestionsList[patientIndex]
        .results?[searchItemIndex]
        .source ==
        'Patient Location Indication') {
      PatientLocationIndication? locationIndication = await context
          .read<PatientLocationsController>()
          .getPatientLocationIndicationById(
        context: context,
        locationIndicationId: context
            .read<GlobalSearchController>()
            .suggestionsList[patientIndex]
            .results?[searchItemIndex]
            .id ??
            "",
      );
      context.read<PatientLocationsController>().selectedLocationIndication =
          locationIndication;
      context
          .read<PatientLocationsController>()
          .selectedPatientLocationPointList =
      await context
          .read<PatientLocationsController>()
          .getPatientLocationsIndicationPointsList(
          context: context,
          patientLocationIndication: locationIndication!);

      context
          .read<TodayVisitDrawerController>()
          .changeCurrentTodayVisitDrawerContent(
          TodayVisitDrawerTabEnum.location);

      context
          .read<PatientController>()
          .selectPatient(locationIndication.patient!);
      context
          .read<PatientController>()
          .changeCurrentScreen(PatientRecordsScreensEnum.patientRecords);

      Navigator.pop(context);

      Navigator.push(
          context,
          PageRouteBuilder(
            opaque: false,
            pageBuilder: (BuildContext context, _, __) {
              return const TodayVisitDrawer();
            },
          ));
    } else if (context
        .read<GlobalSearchController>()
        .suggestionsList[patientIndex]
        .results?[searchItemIndex]
        .source ==
        'Patient Location Indication Point') {
      PatientLocationIndicationPoint? locationIndicationPoint = await context
          .read<PatientLocationsController>()
          .getPatientLocationIndicationPointById(
        context: context,
        locationIndicationPointId: context
            .read<GlobalSearchController>()
            .suggestionsList[patientIndex]
            .results?[searchItemIndex]
            .id ??
            "",
      );
      context.read<PatientLocationsController>().selectedLocationIndication =
          locationIndicationPoint?.locationIndication;
      context
          .read<PatientLocationsController>()
          .selectedPatientLocationPointList =
      await context
          .read<PatientLocationsController>()
          .getPatientLocationsIndicationPointsList(
          context: context,
          patientLocationIndication:
          locationIndicationPoint!.locationIndication!);

      context
          .read<TodayVisitDrawerController>()
          .changeCurrentTodayVisitDrawerContent(
          TodayVisitDrawerTabEnum.location);

      context
          .read<PatientController>()
          .selectPatient(locationIndicationPoint.patient!);
      context
          .read<PatientController>()
          .changeCurrentScreen(PatientRecordsScreensEnum.patientRecords);

      Navigator.pop(context);

      Navigator.push(
          context,
          PageRouteBuilder(
            opaque: false,
            pageBuilder: (BuildContext context, _, __) {
              return const TodayVisitDrawer();
            },
          ));
    }
    context.read<PatientController>().getPatientById(context: context);
  }
}

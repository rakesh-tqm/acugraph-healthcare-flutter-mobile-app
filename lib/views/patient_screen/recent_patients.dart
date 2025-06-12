/*
 This class is representing the list of most recently viewed patients. This list is capped at the last 10 patients.
 */

import 'package:acugraph6/controllers/patient_controller.dart';
import 'package:acugraph6/data_layer/models/patient.dart';
import 'package:acugraph6/utils/constant_image_path.dart';
import 'package:acugraph6/utils/constants.dart';
import 'package:acugraph6/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../utils/sizes_helpers.dart';
import '../../controllers/preference_controller.dart';
import '../../controllers/treatment_plan_library_controller.dart';

class RecentPatientDrawer extends StatefulWidget {
  const RecentPatientDrawer({Key? key}) : super(key: key);

  @override
  State<RecentPatientDrawer> createState() => _RecentPatientDrawerState();
}

class _RecentPatientDrawerState extends State<RecentPatientDrawer>
    with TickerProviderStateMixin {
  //Variable controller to redirect the new page
  late AnimationController controller;

  //variable used to set the new page start and end position
  late Animation<Offset> position;


  /* Here we are initializing variables and functions , basically the entry point of the stateful
 widget tree .
     */
  @override
  void initState() {
    super.initState();
    //Set the speed of animation
    controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    position = Tween<Offset>(begin: const Offset(0.0, -4.0), end: Offset.zero)
        .animate(controller);
    //CurvedAnimation(parent: controller, curve: Curves.bounceInOut));
    controller.forward();

    context.read<PatientController>().getRecentPatientsData();
  }

  /* Widget for Recent patient Table Rows */
  Widget itemView(int index) {
    //Initializing the variable to get the lastedit value
    var lastVisitDateTime = dateTimeFormat(
        context.read<PatientController>().recentPatients?.patients?[index].lastOpenedAt,
        context.read<PreferenceController>().dateFormatValue);
    //Initializing header from patient controller class
    var header = context.read<PatientController>().getHeader();
    return Consumer<PatientController>(
      builder: (context, provider, child) => Container(
        height: screenHeight(context) * .06,
        margin: const EdgeInsets.all(10),
        child: Row(
          children: <Widget>[
            Expanded(
              flex: 50,
              child: Container(
                alignment: Alignment.centerLeft,
                margin: const EdgeInsets.fromLTRB(15, 0, 0, 0),
                // color: Colors.red,

                child: Row(
                  children: [
                    //Patient profile picture
                    ((provider.recentPatients?.patients?[index].mugshot) !=
                        null)
                        ? SizedBox(
                      width: screenHeight(context) * 0.055,
                      height: screenHeight(context) * 0.055,
                      child: CircleAvatar(
                          backgroundColor: kLightGrey,
                          radius: 25,
                          child: ClipOval(
                            child: Image(
                              image: NetworkImage(
                                "$patientImage/${provider.recentPatients?.patients?[index].mugshot?.uuid}",
                                headers: header,
                              ),
                            ),
                          )),
                    )
                        : Image(
                        image: const AssetImage(
                            ConstantImagePath.placeHolderUserIcon),
                        width: screenHeight(context) * 0.055,
                        height: screenHeight(context) * 0.055),
                    //Redirect to patient detail by clicking on Patient name
                    GestureDetector(
                      onTap: ()async {
                        Patient patient=Patient();
                        patient.id=provider.recentPatients?.patients?[index].uuid;
                        patient.firstName=provider.recentPatients?.patients?[index].firstName;
                        patient.lastName=provider.recentPatients?.patients?[index].lastName;
                        patient.mugshot?.id=provider.recentPatients?.patients?[index].mugshot?.uuid;
                        provider.selectPatient(patient);
                        provider.changeCurrentScreen(
                            PatientRecordsScreensEnum.patientRecords);
                        context.read<PatientController>().getPatientById(context: context);
                        context.read<TreatmentPlanLibraryController>().selectedTreatmentPlan=null;
                        controller.reverse();
                        Navigator.pop(context);
                      },
                      //Patient Name
                      child: Container(
                        alignment: Alignment.centerLeft,
                        margin: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                        child: Text(
                          (provider.recentPatients?.patients?[index]
                              .firstName ??
                              "") +
                              " " +
                              (provider.recentPatients?.patients?[index]
                                  .middleName ??
                                  "") +
                              " " +
                              (provider.recentPatients?.patients?[index]
                                  .lastName ??
                                  ""),
                          style: getTextTheme(
                              fontWeight: FontWeight.w400,
                              textColor: kDarkGrey,
                              fontSize: screenHeight(context) * 0.020),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            //Last Edit text and time
            Expanded(
              child: Container(
                alignment: Alignment.centerRight,
                margin: const EdgeInsets.fromLTRB(0, 0, 16, 0),
                child: Text(
                  " Last Edit: $lastVisitDateTime",
                  style: getTextTheme(
                      fontWeight: FontWeight.bold,
                      textColor: kDarkBlue,
                      fontSize: screenHeight(context) * 0.018),
                  textAlign: TextAlign.right,
                ),
              ),
              flex: 50,
            ),
          ],
        ),
      ),
    );
  }

  /* Function to releases the memory allocated to the existing variables of the state. */
  @override
  dispose() {
    controller.dispose(); // you need this
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //To open and close the recent patient drawer
    return GestureDetector(
      onTap: () {
        controller.reverse();
        Navigator.pop(context);
      },
      //Add Faded View in background
      child: Material(
        color: Colors.black.withOpacity(0.54),
        child: Align(
          alignment: Alignment.topRight,
          child: Padding(
            padding: const EdgeInsets.all(40.0),
            //Transit View from top
            child: SlideTransition(
              position: position,
              child:
              // Content Box //
              Container(
                width: screenWidth(context) * .60,
                height: screenHeight(context) * .65,
                decoration: BoxDecoration(
                  color: kWhite,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5), //color of shadow
                      spreadRadius: 5, //spread radius
                      blurRadius: 7, // blur radius
                      offset: const Offset(0, 2), // changes position of shadow
                      //first paramerter of offset is left-right
                      //second parameter is top to down
                    ),
                    //you can set more BoxShadow() here
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        // List View
                        Consumer<PatientController>(
                          builder: (context, provider, child) => Container(
                            height: screenHeight(context) * 0.60,
                            width: screenWidth(context) * 0.56,
                            //color: Colors.green,
                            transform:
                            Matrix4.translationValues(0.0, 17.0, 0.0),
                            child: ListView.builder(
                                itemCount: (provider
                                    .recentPatients?.patients?.length ??
                                    0),
                                physics: const AlwaysScrollableScrollPhysics(),
                                itemBuilder: (BuildContext context, int index) {
                                  return itemView(index);
                                }),
                          ),
                        ),

                        //Cross Button //
                        Container(
                          margin: const EdgeInsets.fromLTRB(0, 10, 6, 0),

                          //height: screenHeight(context) * 0.05,
                          height: screenHeight(context) * 0.58,
                          width: screenWidth(context) * 0.03,
                          alignment: Alignment.topRight,
                          child: GestureDetector(
                            child: Icon(Icons.clear,
                                color: Colors.grey,
                                size: screenHeight(context) * 0.026),
                            onTap: () {
                              controller.reverse();
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

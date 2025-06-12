/*
This class is representing the chief complaints list displaying in patient info right side tab.
*/
import 'package:acugraph6/controllers/patient_controller.dart';
import 'package:acugraph6/data_layer/models/patient.dart';
import 'package:acugraph6/utils/constants.dart';
import 'package:acugraph6/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../controllers/patient_chief_complaint_controller.dart';
import '../../../controllers/today_visit_drawer_controller.dart';
import '../../../utils/sizes_helpers.dart';
import '../../common_widgets/side_drawers/modules/today_visit_drawer/today_visit_drawer.dart';

class PatientChiefComplaintListView extends StatefulWidget {
  const PatientChiefComplaintListView({Key? key}) : super(key: key);

  @override
  State<PatientChiefComplaintListView> createState() =>
      _PatientChiefComplaintListViewState();
}

class _PatientChiefComplaintListViewState
    extends State<PatientChiefComplaintListView> {

/* Here we are initializing variables and functions , basically
   the entry point of the stateful widget tree .
     */
  @override
  void initState() {
context.read<PatientChiefComplaintController>()?.getPatientChiefComplaintList(
          context: context);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PatientChiefComplaintController>(
      builder: (context, provider, child) => SizedBox(
        height: screenHeight(context) * 0.30,
        //Chief Complaint Listview
        child: ListView.builder(
            itemCount: provider.patientChiefComplaintList.length,
            physics: const AlwaysScrollableScrollPhysics(),
            itemBuilder: (BuildContext context, int index) {
              return GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  provider.selectedChiefComplaint =
                      provider.patientChiefComplaintList[index];
                  context
                          .read<TodayVisitDrawerController>()
                          .currentTodayVisitDate =
                      provider.selectedChiefComplaint?.updatedAt ??
                          DateTime.now();

                  context
                      .read<TodayVisitDrawerController>()
                      .changeCurrentTodayVisitDrawerContent(
                          TodayVisitDrawerTabEnum.chiefComplaint);

                  DateTime.now();
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      opaque: false,
                      pageBuilder: (BuildContext context, _, __) {
                        return const TodayVisitDrawer();
                      },
                    ),
                  );
                },
                child: Container(
                  height: screenHeight(context) * 0.03,
                  alignment: Alignment.centerLeft,
                  margin: const EdgeInsets.fromLTRB(20, 5, 0, 5),
                  //Chief Complaint Title
                  child: Text(
                    '${provider.patientChiefComplaintList[index].name}',
                    style: getTextTheme(
                        fontSize: screenHeight(context) * 0.020,
                        fontWeight: FontWeight.w400,
                        textColor: kDarkBlue),
                  ),
                ),
              );
            }),
      ),
    );
  }
}

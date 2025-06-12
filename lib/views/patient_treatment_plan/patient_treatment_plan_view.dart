/*This class display the Treatment Plan Points, Recommendations(Expanded Care/Home Care) in Patient detail Screen inside Treatment Plan Module*/

import 'package:acugraph6/data_layer/models/treatment_plan.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/treatment_plan_drawer_controller.dart';
import '../../controllers/treatment_plan_library_controller.dart';
import '../../data_layer/models/treatment_plan_point.dart';
import '../../data_layer/models/treatment_plan_recommendation.dart';
import '../../utils/constants.dart';
import '../../utils/sizes_helpers.dart';
import '../../utils/utils.dart';
import '../common_widgets/side_drawers/modules/treatment_plan_drawer/treatment_plan_drawer.dart';
import 'components/recommendation_item_view.dart';
import '../patient_screen/components/patient_detail_module_title.dart';
import 'components/treatment_plan_header_fields.dart';
import 'components/treatment_plan_point_tile.dart';

class TreatmentPlanView extends StatefulWidget {
  //treatmentPlan object specify the treatment plan data passing from patient detail's screen getting from getPatientById method
  TreatmentPlan treatmentPlan;
  TreatmentPlanView({Key? key, required this.treatmentPlan}) : super(key: key);

  @override
  State<TreatmentPlanView> createState() => _TreatmentPlanViewState();
}

class _TreatmentPlanViewState extends State<TreatmentPlanView> {


  //Initializing array to store the treatment plan points.
  List<TreatmentPlanPoint> treatmentPlanPoint = [];


  //Initializing array to store the expanded care
  List<TreatmentPlanRecommendation> expandedCare = [];

  //Initializing array to store the home care
  List<TreatmentPlanRecommendation> homeCare = [];

  /* Here we are initializing variables and functions , basically
  the entry point of the stateful widget tree .*/
  @override
  void initState() {
    super.initState();
    //Function call to get treatment plan points and recommendations from TreatmentPlanPointController
    getTreatmentPlanData();
  }

  void getTreatmentPlanData() {
    try{
    // if (widget.treatmentPlan.id==null) {

      context
          .read<TreatmentPlanLibraryController>()
          .getTreatmentPlanData(treatmentPlan: widget.treatmentPlan)
          .then((treatmentPlanData) {
            if(treatmentPlanData!=null){
              // widget.treatmentPlan.points = treatmentPlanData.points;
              // widget.treatmentPlan.recommendations = treatmentPlanData.recommendations;
              if (treatmentPlanData.points != null) {
                treatmentPlanPoint.addAll(treatmentPlanData.points ?? []);
                widget.treatmentPlan.points=treatmentPlanData.points;
                widget.treatmentPlan.note=treatmentPlanData.note;
              }
              if (treatmentPlanData.recommendations != null) {
                widget.treatmentPlan.recommendations=treatmentPlanData.recommendations;


                homeCare.addAll((widget.treatmentPlan.recommendations??[])
                    .where((element) => element.treatAtHome == true));

                expandedCare.addAll((widget.treatmentPlan.recommendations??[])
                    .where((element) => element.treatedInOffice == true));
              }
            }

        if (mounted) {
          setState(() {});
        }
      });
    }
        catch(e){
          if(kDebugMode){
            print(e.toString());
          }
        }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, top: 10, bottom: 10, right: 10),
      child: Column(
        children: [

          //Points View
          GestureDetector(
            onTap: () {
              //initializing selectedTreatmentPlan getting from patient detail screen
              context.read<TreatmentPlanLibraryController>().selectedTreatmentPlan=widget.treatmentPlan;
              context
                  .read<TreatmentPlanDrawerController>()
                  .changeCurrentTreatmentPlanDrawerContent(
                      TreatmentPlanDrawerTabEnum.points);

              Navigator.push(
                  context,
                  PageRouteBuilder(
                      opaque: false,
                      pageBuilder: (BuildContext context, _, __) {
                        return const TreatmentPlanDrawer();
                      }));
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    //Treatment plan title text
                    PatientDetailModuleTitle(
                        moduleTitle: "TREATMENT PLAN",
                        moduleDateTime: dateTimeFormat(
                            widget.treatmentPlan.updatedAt?.toLocal(), 'dd MMM yyyy'),
                        doctorName:
                            "  --${(widget.treatmentPlan.lastEditedBy ?? "")}"),
                    //  Grey cross icon for delete
                    Padding(
                      padding: const EdgeInsets.only(right: 20.0),
                      child: GestureDetector(
                        child: Icon(Icons.clear,
                            color: kLightGrey,
                            size: screenHeight(context) * 0.034),
                        onTap: () {
                          showDialog(
                              barrierDismissible: true,
                              context: context,
                              builder: (context) {
                                return deleteRecordAlertBox(
                                    context: context,
                                    title: "Treatment Plan",
                                    subTitle:
                                        "Are you sure you want to delete this treatment plan record?",
                                    delete: () {
                                      //calling delete method from controller
                                      context
                                          .read<TreatmentPlanLibraryController>()
                                          .deletePatientTreatmentPlan(
                                              context: context,
                                              treatmentPlan:
                                              widget.treatmentPlan);
                                    });
                              });
                        },
                      ),
                    ),
                  ],
                ),
                Container(
                  height: screenHeight(context) * 0.06,
                  width: screenWidth(context) * 0.65,
                  alignment: Alignment.centerLeft,
                  margin: const EdgeInsets.fromLTRB(25, 0, 25, 0),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        //No. of  Points
                        Text("${treatmentPlanPoint.length}",
                            style: getTextTheme(
                              fontWeight: FontWeight.w500,
                              textColor: kDarkBlue,
                              fontSize: screenHeight(context) * 0.028,
                            ),
                            textAlign: TextAlign.left),
                        //horizontal and vertical spacing
                        SizedBox(
                          width: screenWidth(context) * 0.005,
                          height: screenHeight(context) * 0.001,
                        ),
                        //POINTS title text
                        Text("POINTS",
                            style: getTextTheme(
                              fontWeight: FontWeight.w500,
                              textColor: kDarkBlue,
                              fontSize: screenHeight(context) * 0.019,
                            ),
                            textAlign: TextAlign.left),
                      ]),
                ),

                // Grey horizontal line //
                Container(
                  height: screenHeight(context) * 0.001,
                  margin: const EdgeInsets.fromLTRB(25, 0, 25, 0),
                  // margin: const EdgeInsets.fromLTRB(52, 0, 52, 0),
                  color: kBorderLightGrey,
                ),
                //Treatment Plan points header fields
                const TreatmentPlanHeaderFields(
                  isEdit: false,
                ),
                // Grey horizontal line //
                Container(
                  height: screenHeight(context) * 0.001,
                  margin: const EdgeInsets.fromLTRB(25, 0, 25, 0),
                  color: kBorderLightGrey,
                ),
                //Treatment Plan points list data inside Listview widget
                ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: treatmentPlanPoint.length,
                  itemBuilder: (BuildContext context, int index) {
                    return TreatmentPlanPointTile(
                        treatmentPlanPoint: treatmentPlanPoint[index],
                        isEdit: false);
                  },
                ),
              ],
            ),
          ),
          //Expanded Care View
          expandedCare.isEmpty
              ? Container()
              : GestureDetector(
                  onTap: () {
                    //initializing selectedTreatmentPlan getting from patient detail screen
                    setState(() {
                      context
                          .read<TreatmentPlanLibraryController>()
                          .selectedTreatmentPlan = widget.treatmentPlan;
                    });
                    context
                        .read<TreatmentPlanDrawerController>()
                        .changeCurrentTreatmentPlanDrawerContent(
                            TreatmentPlanDrawerTabEnum.expandedCare);
                    DateTime.now();
                    Navigator.push(
                        context,
                        PageRouteBuilder(
                            opaque: false,
                            pageBuilder: (BuildContext context, _, __) {
                              return const TreatmentPlanDrawer();
                            }));
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          //Expanded care title text
                          PatientDetailModuleTitle(
                              moduleTitle: "EXPANDED CARE",
                              moduleDateTime: dateTimeFormat(
                                  widget.treatmentPlan.updatedAt,
                                  'dd MMM yyyy'),
                              doctorName:
                                  "  --${(widget.treatmentPlan.lastEditedBy ?? "")}"),
                          //  Grey cross icon for delete
                          Padding(
                            padding: const EdgeInsets.only(right: 20.0),
                            child: GestureDetector(
                              child: Icon(Icons.clear,
                                  color: kLightGrey,
                                  size: screenHeight(context) * 0.034),
                              onTap: () {
                                showDialog(
                                    barrierDismissible: true,
                                    context: context,
                                    builder: (context) {
                                      return deleteRecordAlertBox(
                                          context: context,
                                          title: "Expanded Care",
                                          subTitle:
                                              "Are you sure you want to delete this expanded care record?",
                                          delete: () {
                                            //calling delete method from controller
                                            context
                                                .read<
                                                    TreatmentPlanLibraryController>()
                                                .deletePatientTreatmentPlan(
                                                    context: context,
                                                    treatmentPlan: widget
                                                        .treatmentPlan);
                                          });
                                    });
                              },
                            ),
                          ),
                        ],
                      ),
                      //Expanded Care list data inside Listview widget
                      ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: expandedCare.length,
                        itemBuilder: (BuildContext context, int index) {
                          return RecommendationItemView(
                            recommendationData: expandedCare[index],
                            isEdit: false,
                          );
                        },
                      ),
                    ],
                  ),
                ),

          //Home Care View
          homeCare.isEmpty
              ? Container()
              : GestureDetector(
                  onTap: () {
                    //initializing selectedTreatmentPlan getting from patient detail screen
                    setState(() {
                      context
                          .read<TreatmentPlanLibraryController>()
                          .selectedTreatmentPlan = widget.treatmentPlan;
                    });

                    // context
                    //         .read<TreatmentPlanDrawerController>()
                    //         .currentTreatmentPlanDate =
                    //     treatmentPlan?.updatedAt?.toLocal() ?? DateTime.now();
                    context
                        .read<TreatmentPlanDrawerController>()
                        .changeCurrentTreatmentPlanDrawerContent(
                            TreatmentPlanDrawerTabEnum.homeCare);
                    DateTime.now();
                    Navigator.push(
                        context,
                        PageRouteBuilder(
                            opaque: false,
                            pageBuilder: (BuildContext context, _, __) {
                              return const TreatmentPlanDrawer();
                            }));
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          //Expanded care title text
                          PatientDetailModuleTitle(
                              moduleTitle: "HOME CARE",
                              moduleDateTime: dateTimeFormat(
                                  widget.treatmentPlan.updatedAt,
                                  'dd MMM yyyy'),
                              doctorName:
                                  "  --${(widget.treatmentPlan.lastEditedBy ?? "")}"),
                          //  Grey cross icon for delete
                          Padding(
                            padding: const EdgeInsets.only(right: 20.0),
                            child: GestureDetector(
                              child: Icon(Icons.clear,
                                  color: kLightGrey,
                                  size: screenHeight(context) * 0.034),
                              onTap: () {
                                showDialog(
                                    barrierDismissible: true,
                                    context: context,
                                    builder: (context) {
                                      return deleteRecordAlertBox(
                                          context: context,
                                          title: "Home Care",
                                          subTitle:
                                              "Are you sure you want to delete this home care record?",
                                          delete: () {
                                            //calling delete method from controller
                                            context
                                                .read<
                                                    TreatmentPlanLibraryController>()
                                                .deletePatientTreatmentPlan(
                                                    context: context,
                                                    treatmentPlan: widget
                                                        .treatmentPlan);
                                          });
                                    });
                              },
                            ),
                          ),
                        ],
                      ),
                      //Home Care list data inside Listview widget
                      ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: homeCare.length,
                        itemBuilder: (BuildContext context, int index) {
                          return RecommendationItemView(
                            recommendationData: homeCare[index],
                            isEdit: false,
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
}

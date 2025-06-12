/*This class return the single widget items of TreatmentPlanPoint list view
 This class is commonly using for both patient detail and Treatment drawer point view */

import 'package:acugraph6/controllers/treatment_plan_library_controller.dart';
import 'package:acugraph6/data_layer/models/treatment_plan_point.dart';
import 'package:acugraph6/utils/constant_image_path.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../utils/constants.dart';
import '../../../utils/sizes_helpers.dart';
import '../../../utils/utils.dart';

class TreatmentPlanPointTile extends StatefulWidget {
  //treatmentPlanPoint object specify the points data passing from patient detail's treatment plan module and treatment plan drawer points view
  final TreatmentPlanPoint? treatmentPlanPoint;
  //isEdit specify this class is in edit view or not for patient detail screen and Treatment Drawer points view.
  final bool isEdit;
  const TreatmentPlanPointTile(
      {Key? key, required this.treatmentPlanPoint, required this.isEdit})
      : super(key: key);

  @override
  State<TreatmentPlanPointTile> createState() => _TreatmentPlanPointTileState();
}

class _TreatmentPlanPointTileState extends State<TreatmentPlanPointTile> {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      height: screenHeight(context) * .06,
      margin: const EdgeInsets.fromLTRB(25, 5, 5, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          //Point Name
          if (widget.treatmentPlanPoint?.itemName == null) ...[
            Expanded(
              child: Text(
                '',
                style: getTextTheme(
                    fontWeight: FontWeight.bold,
                    textColor: kDarkBlue,
                    fontSize: screenHeight(context) * 0.018),
                textAlign: TextAlign.left,
              ),
            ),
          ] else ...[
            Expanded(
              child: Text(
                '${widget.treatmentPlanPoint?.itemName}',
                style: getTextTheme(
                    fontWeight: FontWeight.bold,
                    textColor: kDarkBlue,
                    fontSize: screenHeight(context) * 0.0165),
                textAlign: TextAlign.left,
              ),
            ),
          ],

          // Enabled/Disabled Auricular Icon
          if (widget.treatmentPlanPoint?.itemType == 'body') ...[
            Expanded(
              child: GestureDetector(
                onTap: () {
                  if (widget.isEdit) {
                    setState(() {
                      widget.treatmentPlanPoint?.itemType = "ear";
                    });
                    context
                        .read<TreatmentPlanLibraryController>()
                        .updateTreatmentPlanPoint(
                            context: context,
                            treatmentPlanPoint: widget.treatmentPlanPoint);
                  }
                },
                child: Image(
                    image: const AssetImage(ConstantImagePath.earDisableIcon),
                    width: screenHeight(context) * 0.028,
                    height: screenHeight(context) * 0.028),
              ),
            ),
          ] else ...[
            Expanded(
              child: GestureDetector(
                onTap: () {
                  if (widget.isEdit) {
                    setState(() {
                      widget.treatmentPlanPoint?.itemType = "body";
                    });
                    context
                        .read<TreatmentPlanLibraryController>()
                        .updateTreatmentPlanPoint(
                            context: context,
                            treatmentPlanPoint: widget.treatmentPlanPoint);
                  }
                },
                child: Image(
                    image: const AssetImage(ConstantImagePath.auriCuloIcon),
                    width: screenHeight(context) * 0.028,
                    height: screenHeight(context) * 0.028),
              ),
            ),
          ],

          // Left/Right Side
          Flexible(
            child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Left Side
                  if (widget.treatmentPlanPoint?.left == true) ...[
                    GestureDetector(
                      onTap: () {
                        if (widget.isEdit) {
                          setState(() {
                            widget.treatmentPlanPoint?.left = false;
                          });
                          context
                              .read<TreatmentPlanLibraryController>()
                              .updateTreatmentPlanPoint(
                                  context: context,
                                  treatmentPlanPoint:
                                      widget.treatmentPlanPoint);
                        }
                      },
                      child: Image(
                          image: const AssetImage(
                              ConstantImagePath.leftTredTriangleIcon),
                          width: screenHeight(context) * 0.028,
                          height: screenHeight(context) * 0.028),
                    ),
                  ] else ...[
                    GestureDetector(
                      onTap: () {
                        if (widget.isEdit) {
                          setState(() {
                            widget.treatmentPlanPoint?.left = true;
                          });
                          context
                              .read<TreatmentPlanLibraryController>()
                              .updateTreatmentPlanPoint(
                                  context: context,
                                  treatmentPlanPoint:
                                      widget.treatmentPlanPoint);
                        }
                      },
                      child: Image(
                          image: const AssetImage(
                              ConstantImagePath.leftTriangleIcon),
                          width: screenHeight(context) * 0.028,
                          height: screenHeight(context) * 0.028),
                    ),
                  ],

                  // Right Side
                  if (widget.treatmentPlanPoint?.right == true) ...[
                    GestureDetector(
                      onTap: () {
                        if (widget.isEdit) {
                          setState(() {
                            widget.treatmentPlanPoint?.right = false;
                          });
                          context
                              .read<TreatmentPlanLibraryController>()
                              .updateTreatmentPlanPoint(
                                  context: context,
                                  treatmentPlanPoint:
                                      widget.treatmentPlanPoint);
                        }
                      },
                      child: Image(
                          image: const AssetImage(
                              ConstantImagePath.rightTredTriangleIcon),
                          width: screenHeight(context) * 0.028,
                          height: screenHeight(context) * 0.028),
                    ),
                  ] else ...[
                    GestureDetector(
                      child: Image(
                          image: const AssetImage(
                              ConstantImagePath.rightTriangleIcon),
                          width: screenHeight(context) * 0.028,
                          height: screenHeight(context) * 0.028),
                      onTap: () {
                        if (widget.isEdit) {
                          setState(() {
                            widget.treatmentPlanPoint?.right = true;
                          });
                          context
                              .read<TreatmentPlanLibraryController>()
                              .updateTreatmentPlanPoint(
                                  context: context,
                                  treatmentPlanPoint:
                                      widget.treatmentPlanPoint);
                        }
                      },
                    )
                  ]
                ]),
            flex: 1,
          ),

          //Office
          if (widget.treatmentPlanPoint?.treatedInOffice == false) ...[
            Expanded(
              child: GestureDetector(
                onTap: () {
                  if (widget.isEdit) {
                    setState(() {
                      widget.treatmentPlanPoint?.treatedInOffice = true;
                    });
                    context
                        .read<TreatmentPlanLibraryController>()
                        .updateTreatmentPlanPoint(
                            context: context,
                            treatmentPlanPoint: widget.treatmentPlanPoint);
                  }
                },
                child: Image(
                    image: const AssetImage(ConstantImagePath.disableTickIcon),
                    width: screenHeight(context) * 0.028,
                    height: screenHeight(context) * 0.028),
              ),
            ),
          ] else ...[
            Expanded(
              flex: 1,
              child: GestureDetector(
                onTap: () {
                  if (widget.isEdit) {
                    setState(() {
                      widget.treatmentPlanPoint?.treatedInOffice = false;
                    });
                    context
                        .read<TreatmentPlanLibraryController>()
                        .updateTreatmentPlanPoint(
                            context: context,
                            treatmentPlanPoint: widget.treatmentPlanPoint);
                  }
                },
                child: Image(
                    image: const AssetImage(ConstantImagePath.enabledTickIcon),
                    width: screenHeight(context) * 0.028,
                    height: screenHeight(context) * 0.028),
              ),
            ),
          ],

          //Home
          if (widget.treatmentPlanPoint?.treatAtHome == false) ...[
            Expanded(
              flex: 1,
              child: GestureDetector(
                onTap: () {
                  if (widget.isEdit) {
                    setState(() {
                      widget.treatmentPlanPoint?.treatAtHome = true;
                    });
                    context
                        .read<TreatmentPlanLibraryController>()
                        .updateTreatmentPlanPoint(
                            context: context,
                            treatmentPlanPoint: widget.treatmentPlanPoint);
                  }
                },
                child: Image(
                    image: const AssetImage(ConstantImagePath.disableTickIcon),
                    width: screenHeight(context) * 0.028,
                    height: screenHeight(context) * 0.028),
              ),
            ),
          ] else ...[
            Expanded(
              flex: 1,
              child: GestureDetector(
                onTap: () {
                  if (widget.isEdit) {
                    setState(() {
                      widget.treatmentPlanPoint?.treatAtHome = false;
                    });
                    context
                        .read<TreatmentPlanLibraryController>()
                        .updateTreatmentPlanPoint(
                            context: context,
                            treatmentPlanPoint: widget.treatmentPlanPoint);
                  }
                },
                child: Image(
                    image: const AssetImage(ConstantImagePath.enabledTickIcon),
                    width: screenHeight(context) * 0.028,
                    height: screenHeight(context) * 0.028),
              ),
            ),
          ],

          //If it is in edit view then it will show the delete icon button
          widget.isEdit
              ?
              //Delete button
              Expanded(
                  child:
          context
              .read<TreatmentPlanLibraryController>().newTreatmentPlanPoint.isNotEmpty?
          GestureDetector(
            child: Image(
                image: const AssetImage(ConstantImagePath.trashIcon),
                width: screenHeight(context) * 0.020,
                height: screenHeight(context) * 0.020),
            onTap: () {
              context
                  .read<TreatmentPlanLibraryController>().removeTemproryTreatmentPlanPoint(widget.treatmentPlanPoint);
              context
                  .read<TreatmentPlanLibraryController>()
                  .deleteTreatmentPlanPoint(
                  context: context,
                  treatmentPlanPoint:
                  widget.treatmentPlanPoint);
            },
          ):
          GestureDetector(
                    child: Image(
                        image: const AssetImage(ConstantImagePath.trashIcon),
                        width: screenHeight(context) * 0.020,
                        height: screenHeight(context) * 0.020),
                    onTap: () {
                      context
                          .read<TreatmentPlanLibraryController>()
                          .deleteTreatmentPlanPoint(
                          context: context,
                          treatmentPlanPoint:
                          widget.treatmentPlanPoint);
                      context
                          .read<TreatmentPlanLibraryController>()
                          .selectedTreatmentPlan
                          ?.points
                          ?.remove(widget.treatmentPlanPoint);
                      // showDialog(
                      //     barrierDismissible: true,
                      //     context: context,
                      //     builder: (context) {
                      //       return deleteRecordAlertBox(
                      //           context: context,
                      //           title: "Treatment Plan Point",
                      //           subTitle:
                      //               "Are you sure you want to delete this treatment plan point record?",
                      //           delete: () {
                      //             context
                      //                 .read<TreatmentPlanLibraryController>()
                      //                 .deleteTreatmentPlanPoint(
                      //                     context: context,
                      //                     treatmentPlanPoint:
                      //                         widget.treatmentPlanPoint);
                      //             context
                      //                 .read<TreatmentPlanLibraryController>()
                      //                 .selectedTreatmentPlan
                      //                 ?.points
                      //                 ?.remove(widget.treatmentPlanPoint);
                      //           });
                      //     });
                    },
                  ),
                )
              :
              //else it will show blank box without content
              SizedBox(
                  width: screenHeight(context) * 0.020,
                  height: screenHeight(context) * 0.020),
        ],
      ),
    );
  }
}

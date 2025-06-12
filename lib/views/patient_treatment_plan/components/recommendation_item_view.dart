import 'package:acugraph6/utils/constants.dart';
import 'package:acugraph6/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:readmore/readmore.dart';
import '../../../controllers/treatment_plan_library_controller.dart';
import '../../../data_layer/models/treatment_plan_recommendation.dart';
import '../../../utils/constant_image_path.dart';
import '../../../utils/sizes_helpers.dart';

class RecommendationItemView extends StatefulWidget {
  TreatmentPlanRecommendation? recommendationData;
  //isEdit specify this class is in edit view or not for patient detail screen and Treatment Drawer expanded care or home care view.
  final bool isEdit;
  RecommendationItemView(
      {Key? key, required this.recommendationData, required this.isEdit})
      : super(key: key);

  @override
  State<RecommendationItemView> createState() => _RecommendationItemViewState();
}

class _RecommendationItemViewState extends State<RecommendationItemView> {
  @override
  void initState() {
    super.initState();
    getTreatmentPlanRecommendationById();
  }

  //Function to get treatment plan recommendation data by recommendation id from the controller
  getTreatmentPlanRecommendationById() {
    context
        .read<TreatmentPlanLibraryController>()
        .getTreatmentPlanRecommendationById(
            recommendationId: widget.recommendationData?.id ?? "")
        .then((value) {
      widget.recommendationData = value;

      return value;
    });
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    String htmlText = convertDeltaToHtml(
      jsonDelta: widget.recommendationData?.description ?? "",
    );
    RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);
    String parsedString = htmlText.replaceAll(exp, '');
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 5, 0, 5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
              width: screenWidth(context) * 0.67,
              height: screenHeight(context) * 0.03,
              margin: const EdgeInsets.fromLTRB(0, 8, 8, 0),
              child: Text(
                "${widget.recommendationData?.title}:",
                style: getTextTheme(
                    fontWeight: FontWeight.bold,
                    textColor: kDarkBlue,
                    fontSize: screenHeight(context) * 0.018),
              )),

          Container(
            width: screenWidth(context) * 0.67,
            margin: const EdgeInsets.fromLTRB(0, 2, 8, 0),
            transform: Matrix4.translationValues(0.0, -4.0, 0.0),
            child: ReadMoreText(
              parsedString,
              trimLines: 1,
              textAlign: TextAlign.left,
              style: getTextTheme(
                  fontSize: screenHeight(context) * 0.018,
                  fontWeight: FontWeight.w500,
                  textColor: kDarkGrey),
              colorClickableText: kDarkBlue,
              trimMode: TrimMode.Line,
              trimCollapsedText: 'See more',
              trimExpandedText: ' See less',
              moreStyle: getTextTheme(
                  fontSize: screenHeight(context) * 0.018,
                  fontWeight: FontWeight.bold,
                  textColor: kDarkBlue),
            ),
          ),

          // Delete and attach icon
          Container(
            margin: const EdgeInsets.fromLTRB(0, 5, 8, 0),
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                widget.isEdit
                    ? Container(
                        margin: const EdgeInsets.only(right: 10),
                        child: GestureDetector(
                          onTap: () {
                            showDialog(
                                barrierDismissible: true,
                                context: context,
                                builder: (context) {
                                  return deleteRecordAlertBox(
                                      context: context,
                                      title: "Treatment Plan Recommendation",
                                      subTitle:
                                          "Are you sure you want to delete this treatment plan recommendation record?",
                                      delete: () async {
                                        context
                                            .read<
                                                TreatmentPlanLibraryController>()
                                            .deleteTreatmentPlanRecommendation(
                                                context: context,
                                                snapShotUuID: widget
                                                        .recommendationData
                                                        ?.snapshot
                                                        ?.id ??
                                                    "",
                                                treatAtHome: false,
                                                treatInOffice: false);
                                      });
                                });
                          },
                          child: Image.asset(ConstantImagePath.trashIcon,
                              width: screenHeight(context) * 0.02,
                              height: screenHeight(context) * 0.02),
                        ),
                      )
                    : Container(),
                widget.recommendationData?.attachment != null
                    ? GestureDetector(
                        child: Image(
                            image:
                                const AssetImage(ConstantImagePath.attachIcon),
                            width: screenHeight(context) * 0.02,
                            height: screenHeight(context) * 0.02),
                      )
                    : Container(),
              ],
            ),
          ),

          // For Spacing //
          SizedBox(height: screenHeight(context) * 0.02),
          // Grey horizontal line //
          Container(
            height: 1,
            color: kBorderLightGrey,
          ),
        ],
      ),
    );
  }
}

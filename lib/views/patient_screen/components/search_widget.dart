/*
This Search Widget is commonly used in patient screen either patient list is visible or hidden.
 */

import 'package:acugraph6/controllers/patient_controller.dart';
import 'package:acugraph6/utils/sizes_helpers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../utils/constants.dart';
import '../../../utils/utils.dart';
import '../../common_widgets/custom_button.dart';

class SearchWidget extends StatelessWidget {
  //Passing Search Input field text
  final TextEditingController searchTextController;

  //Call back function to submit the searched text
  final Function? onSubmitted;
  final Function(String)? onChangedText;
  final Function? onClearText;

  //variable used to get the patient list count to display in patient found label text
  final int? patientListCount;

  const SearchWidget(
      {Key? key,
      required this.searchTextController,
      this.onSubmitted,
      this.onClearText,
      this.onChangedText,
      this.patientListCount})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: screenWidth(context) * .50,
      height: screenHeight(context) * 0.15,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //Search Input Field//
              Expanded(
                flex: 80,
                child: Container(
                  margin: const EdgeInsets.fromLTRB(20, 7, 0, 0),
                  height: screenHeight(context) * 0.05,
                  child: TextField(
                    controller: searchTextController,
                    onSubmitted: (term) {
                      if (onSubmitted != null) {
                        onSubmitted!();
                      }
                      context
                          .read<PatientController>()
                          .patientListShowHide(true);
                    },
                    textAlignVertical: TextAlignVertical.center,
                    style: getTextTheme(
                        fontSize: screenHeight(context) * 0.018,
                        textColor: kDarkGrey),
                    decoration: InputDecoration(
                        hintText: 'Please type a patient\'s name here',
                        contentPadding: EdgeInsets.symmetric(
                            vertical: screenHeight(context) * 0.018,
                            horizontal: 10.0),
                        // contentPadding: EdgeInsets.fromLTRB(15, screenHeight * 0.018 * 2, 15, screenHeight * 0.018 *2),
                        enabledBorder: const OutlineInputBorder(
                          gapPadding: 1,
                          borderSide: BorderSide(color: kLightGrey, width: 1.2),
                        ),
                        focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: kLightGrey)),
                        border: const OutlineInputBorder(),
                        suffixIcon: searchTextController.text.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.clear,
                                    color: kLightGrey,
                                    size: screenHeight(context) * 0.025),
                                onPressed: () {
                                  searchTextController.clear();
                                  if (onClearText != null) {
                                    onClearText!();
                                  }
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
                      // if (text.isEmpty) {
                      if (onChangedText != null) {
                        onChangedText!(text);
                      }
                      // }
                    },
                  ),
                ),
              ),

              // Go Button //
              Expanded(
                flex: 20,
                child: Container(
                    height: screenHeight(context) * 0.05,
                    margin: const EdgeInsets.fromLTRB(10, 7, 10, 0),
                    child: CustomButton(
                      buttonBg: kLightGrey,
                      textColor: Colors.white,
                      buttonText: 'GO',
                      onPressed: () {
                        if (onSubmitted != null) {
                          onSubmitted!();
                        }
                        context
                            .read<PatientController>()
                            .patientListShowHide(true);
                      },
                    )),
              ),
            ],
          ),
          //Patient found label text
          Container(
            // alignment: Alignment.center,
            margin: const EdgeInsets.fromLTRB(0, 10, 55, 0),
            child: patientListCount == 1
                ? getlabeltext(context, '$patientListCount Patient Found',
                    FontWeight.w500, kLightGrey, screenHeight(context) * 0.018)
                : getlabeltext(context, '$patientListCount Patients Found',
                    FontWeight.w500, kLightGrey, screenHeight(context) * 0.018),
          ),
        ],
      ),
    );
  }
}

/* Widget to show the ByPass privacy alert, based on preferences set in the settings account section */

import 'package:acugraph6/controllers/preference_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../utils/constants.dart';
import '../../../utils/sizes_helpers.dart';
import '../../../utils/utils.dart';
import '../../common_widgets/custom_button.dart';

class ByPassPrivacyAlertView extends StatefulWidget {
  //It's a call back function, used in Bypass Privacy popup to continue the patient list visibility.
  final Function onContinueTapped;
  const ByPassPrivacyAlertView({Key? key, required this.onContinueTapped}) : super(key: key);

  @override
  State<ByPassPrivacyAlertView> createState() => _ByPassPrivacyAlertViewState();
}

class _ByPassPrivacyAlertViewState extends State<ByPassPrivacyAlertView> {
  @override
  Widget build(BuildContext context) {
    /* To update the Checkbox check color */
    Color getColor(Set<MaterialState> states) {
      return kDarkGreyBold;
    }
    return  AlertDialog(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(
            20.0,
          ),
        ),
      ),
      backgroundColor: Colors.white,
      contentPadding: const EdgeInsets.fromLTRB(23, 0, 23, 12),
      title: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              children: [
                // Please Note label //
                Expanded(
                  flex: 50,
                  child: Container(
                    alignment: Alignment.centerLeft,
                    margin: const EdgeInsets.only(bottom: 15),
                    height: screenHeight(context) * 0.05,
                    child: Text("PLEASE NOTE: ",textAlign:TextAlign.left ,style: getTextTheme(fontWeight:FontWeight.bold,fontSize:screenHeight(context) * 0.021,textColor: kDarkGreyBold  ),),
                  ),
                ),

                //Cross Button //
                Expanded(
                  flex: 50,
                  child: Container(
                    alignment: Alignment.centerRight,
                    margin: const EdgeInsets.only(bottom: 15),
                    height: screenHeight(context) * 0.05,
                    child: GestureDetector(
                      child: Icon(Icons.clear,
                          color: Colors.grey,
                          size: screenHeight(context) * 0.026),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      content:
      // Center Content Box //
       Consumer<PreferenceController>(
        builder: (context, provider, child) => SizedBox(
          width: screenWidth(context) * 0.40,
          height: screenHeight(context) * 0.30,
          child: Column(
            children: [
              // Pop up inner text //
              Expanded(
                flex: 4,
                child: Container(
                  alignment: Alignment.topLeft,
                  child: getlabeltext(
                      context,
                      'Patients names and records are protected sensitive information and should only be viewed when privacy can be maintained. Click continue to display bulk information.',
                      FontWeight.w400,
                      kDarkGrey,
                      screenHeight(context) * 0.018),
                ),
              ),

              //Cancel and Continue //
              Expanded(
                flex: 3,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Cancel Button //
                    Container(
                      alignment: Alignment.centerRight,
                      margin: const EdgeInsets.fromLTRB(10, 3, 0, 0),
                      child: CustomButton(buttonText: 'Cancel', buttonBg: kWhite, textColor: kLightGrey, onPressed: () {
                        Navigator.pop(context);
                      }),
                    ),

                    // Space //
                    Container(
                      alignment: Alignment.center,
                      margin: const EdgeInsets.fromLTRB(10, 3, 0, 0),
                      child:  Text(
                        "   ",
                        style: getTextTheme(
                            textColor: Colors.white, fontSize: 18),
                      ),
                    ),

                    // Continue Button //
                    Container(
                        alignment: Alignment.centerLeft,
                        margin: const EdgeInsets.fromLTRB(0, 3, 10, 0),
                        child:  CustomButton(buttonText: 'CONTINUE', onPressed:(){
                          widget.onContinueTapped();
                          Navigator.pop(context);
                        }, textColor: Colors.white, buttonBg: kLightGrey,

                        )
                    ),
                  ],
                ),
              ),

              // Check box and text//
              Expanded(
                flex: 3,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Checkbox //
                    Container(
                      alignment: Alignment.centerRight,
                      transform:
                      Matrix4.translationValues(3.0, 0.0, 0.0),
                      child: Checkbox(
                        checkColor: Colors.white,
                        fillColor:
                        MaterialStateProperty.resolveWith(getColor),
                        value: provider.showPrivacyWarning,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0.5)),
                        onChanged: (value) {
                          setState(() {
                            provider.showPrivacyWarning =
                                value ?? false;

                          });
                        },
                      ),
                    ),

                    // ),

                    // Text Button //
                    Container(
                      alignment: Alignment.centerLeft,
                      transform:
                      Matrix4.translationValues(-3.0, 0.0, 0.0),
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            provider.showPrivacyWarning =
                            !provider.showPrivacyWarning;
                          });
                        },
                        child: Text(
                          "Bypass Privacy Warning Alerts",
                          style: getTextTheme(
                            fontSize: screenHeight(context) * 0.016,
                            fontWeight: FontWeight.w500,
                            textColor: kLightGrey,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

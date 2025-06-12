/*
 This class is used when patient self entry mode is ON,and after filling the patient self entry
  form sending the patient profile photo and all the form data to server.
  */

import 'dart:convert';

import 'package:acugraph6/utils/constant_image_path.dart';
import 'package:acugraph6/views/file_camera_alert.dart';
import 'package:flutter/material.dart';

import '../../../controllers/patient_controller.dart';
import '../../../utils/constants.dart';
import '../../../utils/sizes_helpers.dart';
import '../../../utils/utils.dart';

class SelfEntryPatientProfilePic extends StatefulWidget {

// Initializing the patient form data from self entry screen.

  final PatientController provider;
  final String patientId;
  final String firstName;
  final String lastName;
  final String middleName;
  final String dob;
  final String selectedGender;
  final String address1;
  final String address2;
  final String address3;
  final String city;
  final String state;
  final String postalCode;
  final String country;
  final String phoneNumber;
  final String email;
  final String custom;
  final bool showExtendedGenderOptions;
  final String genderIdentityText;
  final String hormoneText;
  final String surgeries;
  final bool enableGenderSelectionOnGraphs;
  final bool isSkinTonePreference;


  const SelfEntryPatientProfilePic({
    Key? key,
    required this.patientId,
    required this.firstName,
    required this.lastName,
    required this.middleName,
    required this.dob,
    required this.selectedGender,
    required this.address1,
    required this.address2,
    required this.address3,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
    required this.phoneNumber,
    required this.email,
    required this.custom,
    required this.showExtendedGenderOptions,
    required this.genderIdentityText,
    required this.hormoneText,
    required this.surgeries,
    required this.enableGenderSelectionOnGraphs,
    required this.isSkinTonePreference, required this.provider,
  }) : super(key: key);

  @override
  State<SelfEntryPatientProfilePic> createState() => _SelfEntryPatientProfilePicState();
}

class _SelfEntryPatientProfilePicState extends State<SelfEntryPatientProfilePic> {
  //Variable used to convert profile image of patient into base 64
  String patientImageInBase64 = "";
  //Variable used to get extension of image file when patient profile picture uploaded
  String? patientImageExtension = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Top Gap
          Container(
            height: screenHeight(context) * 0.05,
          ),

          // Profile Photo and Add your patient photo
          SizedBox(
            height: screenHeight(context) * 0.35,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                // Profile Photo button //
                GestureDetector(
                  onTap: () async {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => FileCameraAlert(onSaveImage: ({ base64Img,  fileExtension}) {
                            setState(() {
                              patientImageInBase64 = base64Img??"";
                              patientImageExtension = fileExtension??"";
                            });
                          },)),
                    );
                  },
                  child: Container(
                    alignment: Alignment.centerRight,
                    child: (patientImageInBase64 != "")
                        ? Image.memory(base64Decode(patientImageInBase64))
                        : Image.asset(ConstantImagePath.addPhotoIcon,
                        width: screenHeight(context) * 0.10,
                        alignment: Alignment.center,
                        height: screenHeight(context) * 0.10),
                  ),
                ),

                // Add your patient photo text
                Container(
                  alignment: Alignment.centerLeft,
                  margin: const EdgeInsets.fromLTRB(14, 0, 0, 0),
                  child: settext(
                      context,
                      "ADD YOUR PATIENT PHOTO",
                      FontWeight.w500,
                      kDarkGreyBold,
                      screenHeight(context) * 0.022,
                      TextAlign.left),
                ),
              ],
            ),
          ),

          // Clear form, Go Back and Next Button
          Container(
            height: screenHeight(context) * 0.53,
            alignment: Alignment.bottomRight,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Clear form //
                SizedBox(
                  height: screenHeight(context) * 0.038,
                  width: screenWidth(context) * 0.10,
                  child: TextButton(
                    onPressed: () {},
                    child: Text(
                      "Clear Form",
                      style: TextStyle(
                          fontSize: screenHeight(context) * 0.018,
                          fontWeight: FontWeight.w500,
                          color: kDarkGrey),
                    ),
                  ),
                ),

                //For Spacing
                SizedBox(
                  height: screenHeight(context) * 0.038,
                  width: screenWidth(context) * 0.03,
                ),

                // Go Back //
                SizedBox(
                  height: screenHeight(context) * 0.038,
                  width: screenWidth(context) * 0.10,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      "Go Back",
                      style: TextStyle(
                          fontSize: screenHeight(context) * 0.018,
                          fontWeight: FontWeight.w500,
                          color: kDarkGrey,
                          backgroundColor: Colors.transparent),
                    ),
                  ),
                ),

                //For spacing
                SizedBox(
                  height: screenHeight(context) * 0.038,
                  width: screenWidth(context) * 0.04,
                ),

                // Next button //
                Container(
                  height: screenHeight(context) * 0.038,
                  width: screenWidth(context) * 0.063,
                  color: kLightGrey,
                  child: TextButton(
                    onPressed: () {
                      createPatient(widget.provider);
                    },
                    child: Text(
                      "NEXT",
                      style: TextStyle(
                        fontSize: screenHeight(context) * 0.018,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                //For spacing
                Container(
                  height: screenHeight(context) * 0.05,
                  width: screenWidth(context) * 0.04,
                  alignment: Alignment.bottomRight,
                ),
              ],
            ),
          ),

          //For spacing
          Container(
            height: screenHeight(context) * 0.05,
          ),
        ],
      ),
    );
  }

  /* Function to create patient */
  createPatient(PatientController provider) {
    provider.createEditPatient(
        context: context,
        patientId:widget.patientId,
        firstName:widget.firstName,
        lastName:widget.lastName,
        middleName:widget.middleName,
        dob:widget.dob,
        selectedGender:widget.selectedGender,
        address1:widget.address1,
        address2:widget.address2,
        address3:widget.address3,
        city:widget.city,
        state:widget.state,
        postalCode:widget.postalCode,
        country:widget.country,
        phoneNumber:widget.phoneNumber,
        email:widget.email,
        custom:widget.custom,
        showExtendedGenderOptions:widget.showExtendedGenderOptions,
        genderIdentityText:widget.genderIdentityText,
        hormoneText:widget.hormoneText,
        surgeries:widget.surgeries,
        enableGenderSelectionOnGraphs:widget.enableGenderSelectionOnGraphs,
        isSkinTonePreference:widget.isSkinTonePreference,
        isPatientSelfEntry: true,imageInBase64: patientImageInBase64,imageFileExtension: patientImageExtension??"",
        imageFileName: "avatar_${DateTime.now().millisecondsSinceEpoch}"
    );

  }

}

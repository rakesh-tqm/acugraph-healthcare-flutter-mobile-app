/*
 This class is used to when user completed the self entry process.
*/

import 'package:acugraph6/views/auth_screen.dart';
import 'package:acugraph6/views/patient_screen/self_entry_patient.dart';
import 'package:flutter/material.dart';

import '../../utils/utils.dart';

class PatientThanks extends StatefulWidget {
  const PatientThanks({Key? key}) : super(key: key);

  @override
  State<PatientThanks> createState() => _PatientThanksState();
}

class _PatientThanksState extends State<PatientThanks> {
  @override
  Widget build(BuildContext context) {
    // Screen Width and Height
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Column(
        children: [
          // Unlock Button //
          Container(
            height: screenHeight * 0.16,
            alignment: Alignment.centerRight,
            child: Container(
              height: screenHeight * 0.035,
              width: screenWidth * 0.09,
              margin: const EdgeInsets.fromLTRB(0, 0, 45, 0),
              color: const Color(0xFF99acc9),
              child: TextButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil<void>(
                    context,
                    MaterialPageRoute<void>(
                        builder: (BuildContext context) =>
                            const AuthScreen()),
                    ModalRoute.withName('/'),
                  );
                },
                child: Text(
                  "UNLOCK",
                  style: TextStyle(
                    fontSize: screenHeight * 0.018,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),

          // Thank you Box //
          SizedBox(
            height: screenHeight * 0.58,
            width: screenWidth,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: screenHeight * 0.03,
                  child: settext(
                      context,
                      "THANK YOU!",
                      FontWeight.bold,
                      const Color(0xFF596981),
                      screenHeight * 0.023,
                      TextAlign.center),
                ),
                // text your patient file has been created
                SizedBox(
                  height: screenHeight * 0.04,
                  child: settext(
                      context,
                      "YOUR PATIENT FILE HAS BEEN CREATED",
                      FontWeight.bold,
                      const Color(0xFF596981),
                      screenHeight * 0.023,
                      TextAlign.center),
                ),
                // for spacing
                SizedBox(height: screenHeight * 0.08),
                // text please return this device now, or
                settext(
                    context,
                    "Please return this device now, or",
                    FontWeight.w400,
                    const Color(0xFF596981),
                    screenHeight * 0.021,
                    TextAlign.center),
                // text add another new patient
                settext(
                    context,
                    "Add another new patient",
                    FontWeight.w400,
                    const Color(0xFF596981),
                    screenHeight * 0.021,
                    TextAlign.center),
              ],
            ),
          ),

          //Go Back and Another Patient
          Container(
            height: screenHeight * 0.20,
            width: screenWidth,
            alignment: Alignment.bottomRight,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Go Back text

                SizedBox(
                  height: screenHeight * 0.038,
                  width: screenWidth * 0.10,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil<void>(
                        context,
                        MaterialPageRoute<void>(
                            builder: (BuildContext context) =>
                                const AuthScreen()),
                        ModalRoute.withName('/'),
                      );
                    },
                    child: Text(
                      "Go Back",
                      style: TextStyle(
                          fontSize: screenHeight * 0.018,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF919DAC),
                          backgroundColor: Colors.transparent),
                    ),
                  ),
                ),

                // For spacing
                SizedBox(
                  height: screenHeight * 0.038,
                  width: screenWidth * 0.01,
                ),

                // Add Another Patient
                SizedBox(
                  height: screenHeight * 0.038,
                  width: screenWidth * 0.19,
                  //color: Color(0xFF99acc9),
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil<void>(
                        context,
                        MaterialPageRoute<void>(
                            builder: (BuildContext context) =>
                                const SelfEntryPatient()),
                        ModalRoute.withName('/'),
                      );
                    },
                    child: Text(
                      "Add Another Patient",
                      style: TextStyle(
                        fontSize: screenHeight * 0.018,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF919DAC),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

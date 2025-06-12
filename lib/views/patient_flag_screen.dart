import 'dart:convert';
// import 'package:delta_markdown/delta_markdown.dart';
import 'package:delta_to_html/delta_to_html.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as text;
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/flutter_quill.dart' as document;
import 'package:html2md/html2md.dart' as html2md;
import 'package:html2md/html2md.dart';
import 'package:provider/provider.dart';

import '../controllers/patient_controller.dart';
import '../utils/utils.dart';

class PatientFlag extends StatefulWidget {
  PatientFlag({Key? key}) : super(key: key);

  @override
  State<PatientFlag> createState() => _PatientFlagState();
}

class _PatientFlagState extends State<PatientFlag> {
  QuillController _controller = QuillController.basic();

  @override
  void initState() {
    super.initState();

    var html = Provider.of<PatientController>(context, listen: false)
        .selectedPatient
        ?.warnings;
    var markdown = html2md.convert(html ?? "",
        styleOptions: {'headingStyle': 'atx'},
        ignore: ['script'],
        rules: [Rule('custom')]);

    // delta_markdown is outdated and doesn't work on current flutter version
    // Is this really neccessary? Maybe not, please fix that in case it is

    final convertedValue =
        r'[{"insert":"Hello "},{"insert":"Markdown","attributes":{"bold":true}},{"insert":"\n"}]';
    // final convertedValue = markdownToDelta(markdown);
    if (html != null) {
      _controller = QuillController(
          document: document.Document.fromJson(jsonDecode(convertedValue)),
          selection: const TextSelection.collapsed(offset: 0));
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return GestureDetector(
      onTap: () {
        // Navigator.pop(context);
      },
      child: Material(
        color: Colors.black.withOpacity(0.54),
        child: Align(
          alignment: Alignment.center,
          child: Container(
            width: screenWidth * 0.75,
            height: screenHeight * 0.65,
            decoration: BoxDecoration(
              color: const Color(0xFFF9F9F9),
              borderRadius: BorderRadius.circular(
                  screenHeight * 0.01), //border corner radius
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
                //greycrosscon
                Container(
                  //padding: EdgeInsets.only(right: 18.0),
                  margin: const EdgeInsets.fromLTRB(0, 10, 22, 0),
                  height: screenHeight * 0.05,
                  alignment: Alignment.centerRight,
                  //color: Colors.yellow,

                  child: GestureDetector(
                    child: Icon(Icons.clear,
                        color: Colors.grey, size: screenHeight * 0.028),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                ),

                //PATIENT WARNINGS
                Container(
                  height: screenHeight * 0.05,
                  alignment: Alignment.centerLeft,
                  margin: const EdgeInsets.fromLTRB(25, 0, 22, 0),
                  //color: Colors.red,
                  child: settext(
                      context,
                      "PATIENT WARNINGS",
                      FontWeight.bold,
                      const Color(0xFF66768B),
                      screenHeight * 0.020,
                      TextAlign.left),
                ),

                // Editor Tool Bar
                Container(
                  height: screenHeight * 0.05,
                  width: screenWidth * 0.89,
                  margin: const EdgeInsets.fromLTRB(38, 15, 38, 0),
                  // transform: Matrix4.translationValues(-138.0, 0.0, 0.0),
                  // color: Colors.green,

                  alignment: Alignment.centerLeft,
                  decoration: const BoxDecoration(
                      border: Border(
                    left: BorderSide(
                      color: Color(0xFFBDD0E6),
                      width: 1.5,
                    ),
                    top: BorderSide(
                      color: Color(0xFFBDD0E6),
                      width: 1.5,
                    ),
                    right: BorderSide(
                      color: Color(0xFFBDD0E6),
                      width: 1.5,
                    ),
                  )),

                  child: Container(
                    width: screenWidth * 0.45,
                    height: screenHeight * 1.090,
                    color: Colors.transparent,
                    //transform: Matrix4.translationValues(-30.0, 0.0, 0.0),

                    child: QuillToolbar.basic(
                      controller: _controller,
                      showAlignmentButtons: true,
                      toolbarIconSize: 15,
                      toolbarSectionSpacing: 0,
                      showUndo: false,
                      showRedo: false,
                      showDividers: false,
                      showInlineCode: false,
                      showCodeBlock: false,
                      showQuote: false,
                      showIndent: false,
                      showLink: false,
                      multiRowsDisplay: false,
                      showDirection: false,
                      showListCheck: false,
                      showFontSize: true,
                      showBoldButton: true,
                      showItalicButton: true,
                      showSmallButton: false,
                      showUnderLineButton: true,
                      showStrikeThrough: true,
                      showColorButton: true,
                      showBackgroundColorButton: false,
                      showClearFormat: false,
                      showLeftAlignment: false,
                      showCenterAlignment: false,
                      showRightAlignment: false,
                      showJustifyAlignment: false,
                      showHeaderStyle: false,
                      showListNumbers: true,
                      showListBullets: true,
                      showSearchButton: false,
                      fontSizeValues: const {
                        'Small': '8',
                        'Medium': '24.5',
                        'Large': '46',
                        'Clear': '0'
                      },
                      toolbarIconAlignment: WrapAlignment.start,
                    ),
                  ),
                ),

                // Grey line //
                Container(
                  height: screenHeight * 0.001,
                  margin: const EdgeInsets.fromLTRB(38, 0, 38, 0),
                  color: const Color(0xFFBDD0E6),
                ),

                //Editor
                Container(
                  height: screenHeight * 0.340,
                  padding: EdgeInsets.all(15.0),
                  decoration: const BoxDecoration(
                      border: Border(
                    left: BorderSide(
                      color: Color(0xFFBDD0E6),
                      width: 1.5,
                    ),
                    bottom: BorderSide(
                      color: Color(0xFFBDD0E6),
                      width: 1.5,
                    ),
                    right: BorderSide(
                      color: Color(0xFFBDD0E6),
                      width: 1.5,
                    ),
                  )),
                  margin: const EdgeInsets.fromLTRB(38, 0, 38, 0),
                  child: QuillEditor.basic(
                    controller: _controller,
                    readOnly: false, // true for view only mode
                  ),
                ),

                //Cancel and Save
                Container(
                  height: screenHeight * 0.08,
                  margin: const EdgeInsets.fromLTRB(38, 0, 38, 0),
                  alignment: Alignment.bottomRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Cancel
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: text.Text(
                          "Cancel",
                          style: TextStyle(
                              fontSize: screenHeight * 0.018,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF919DAC),
                              backgroundColor: Colors.transparent),
                        ),
                      ),

                      SizedBox(
                        height: screenHeight * 0.05,
                        width: screenWidth * 0.04,
                      ),

                      // Save
                      Container(
                        color: const Color(0xFF99acc9),
                        child: TextButton(
                          onPressed: () {
                            List deltaJson =
                                _controller.document.toDelta().toJson();
                            if (kDebugMode) {
                              print(DeltaToHTML.encodeJson(deltaJson));
                            }
                            // submitEditPatientPatient(
                            //     DeltaToHTML.encodeJson(deltaJson));
                          },
                          child: text.Text(
                            "SAVE",
                            style: TextStyle(
                              fontSize: screenHeight * 0.018,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
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
      ),
    );
  }
}

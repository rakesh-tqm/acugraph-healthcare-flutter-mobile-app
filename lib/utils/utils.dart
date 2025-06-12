/* This is a utility file.
* TODO: Planning to shift this in common_widgets controller. We are analysing the scope. Commenting is still pending.
* */
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:acugraph6/utils/constants.dart';
import 'package:acugraph6/utils/sizes_helpers.dart';
import 'package:delta_to_html/delta_to_html.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart' as document;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import '../data_layer/models/patient_location_indication_point.dart';
import '../views/common_widgets/custom_button.dart';

// Showing
void showTips(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(message),
  ));
}

Future<String> get _localPath async {
  //Get external storage directory
  // var directory = await getExternalStorageDirectory();
  //Check if external storage not available. If not available use
  //internal applications directory
  var directory = await getApplicationDocumentsDirectory();
  return directory.path;
}

Future<File> get _localFile async {
  final path = await _localPath;
  return File('$path/acugraphcs_log.txt');
}

bool isInProgressed = false;
Future<File?> writeLogInText(String data) async {
  if(!isInProgressed){
    isInProgressed = true;
    final file = await _localFile;
    // Write the file in append mode so it would append the data to
    //existing file
    var filer = file.writeAsString('$data\n', mode: FileMode.append);
    isInProgressed =false;
    return filer;
  }else{
    return null;
  }

}

colorToHexString(Color color) {
  return '#FF${color.value.toRadixString(16).substring(2, 8)}';
}

hexStringToColor(String hexColor) {
  hexColor = hexColor.toUpperCase().replaceAll("#", "");
  if (hexColor.length == 6) {
    hexColor = "FF" + hexColor;
  }
  return Color(int.parse(hexColor, radix: 16));
}

//simple convenience method to conver int rgb values to a dart:ui Color, with no transparency.
rgbToColor(int r, int g, int b) {
  return Color.fromRGBO(r, g, b, 1.0);
}

DateTime stringDOBFormat(String stringDate) {
  DateTime tempDate = DateFormat("MM-dd-yyyy").parse(stringDate);
  return tempDate;
}

String dateFormat(DateTime? dateTime, String? formatDate) {
  if (dateTime == null) {
    return "";
  } else {
    String formattedDate = DateFormat(formatDate).format(dateTime);
    return formattedDate;
  }
}

String dateFormatYYYY(DateTime? dateTime) {
  if (dateTime == null) {
    return "";
  } else {
    String formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);
    return formattedDate;
  }
}

String dateFormateMonth(DateTime? dateTime) {
  if (dateTime == null) {
    return "";
  } else {
    String formattedDate = DateFormat.yMMMMEEEEd().format(dateTime);
    return formattedDate;
  }
}

String dateFormatMonths(DateTime? dateTime) {
  if (dateTime == null) {
    return "";
  } else {
    String formattedDate = DateFormat("d MMM yyyy").format(dateTime);
    return formattedDate;
  }
}

String dateTimeFormat(DateTime? dateTime, String? formatDate) {
  if (dateTime == null) {
    return "";
  } else {
    String formattedDate = DateFormat(formatDate).format(dateTime);
    String formattedTime = DateFormat('hh:mm a').format(dateTime);
    return "$formattedDate at $formattedTime";
  }
}

String dateWithTimeFormat(DateTime? dateTime) {
  if (dateTime == null) {
    return "";
  } else {
    String formattedDate = DateFormat("d MMM yyyy hh:mm a").format(dateTime);

    return formattedDate;
  }
}

String dateTimeFormatFromString(String? dateTime, String? formatDate) {
  if (dateTime == null) {
    return "";
  } else {
    DateTime tempDate = DateTime.parse(dateTime);

    String formattedDate = DateFormat(formatDate).format(tempDate);
    String formattedTime = DateFormat('hh:mm a').format(tempDate);
    return "$formattedDate at $formattedTime";
  }
}

String calculateAge(DateTime? birthDate) {
  if (birthDate != null) {
    DateTime currentDate = DateTime.now();
    int age = currentDate.year - birthDate.year;
    int month1 = currentDate.month;
    int month2 = birthDate.month;
    if (month2 > month1) {
      age--;
    } else if (month1 == month2) {
      int day1 = currentDate.day;
      int day2 = birthDate.day;
      if (day2 > day1) {
        age--;
      }
    }
    return "$age";
  } else {
    return "";
  }
}

String removeAllHtmlTags(String htmlText) {
  RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);

  return htmlText.replaceAll(exp, '');
}

Widget spacingWithFlex(BuildContext context, int flex) {
  return Expanded(
    child: Container(),
  );
}

//Function to return common Text Style for all over the screen,
TextStyle getTextTheme({
  Color? textColor,
  double? fontSize,
  FontWeight? fontWeight,
}) {
  return TextStyle(
    color: textColor,
    fontWeight: fontWeight,
    fontSize: fontSize,
  );
}

//Label Text For Add Patient, SelfEntry Pateint, Edit Patient Form
Widget addLabel(BuildContext context, Widget? setchild) {
  return Expanded(
    flex: 30,
    child: Container(
      alignment: Alignment.centerRight,
      margin: const EdgeInsets.fromLTRB(0, 0, 20, 0),
      child: setchild,
    ),
  );
}

//Icon Button//
Widget iconbtn(BuildContext context, Widget seticon, VoidCallback onpressed) {
  return IconButton(onPressed: onpressed, icon: seticon);
}

//Function to convert Delta text to HTML
String convertDeltaToHtml({required String jsonDelta}) {
  try {
    var jsonData = jsonDelta.replaceAll(r'\\n', r'\n');
    return DeltaToHTML.encodeJson(jsonDecode(jsonData));
  } catch (e) {
    return "";
  }
}

//Function to convert Delta to plain text
String convertDeltaToPlainText({required String jsonDelta}) {
  try {
    var jsonData = jsonDelta.replaceAll(r'\\n', r'\n');
    var doc = document.Document.fromJson(jsonDecode(jsonData));
    return doc.toPlainText();
  } catch (e) {
    return "";
  }
}

Point<double> calculateCoordsForPrint({
  required double mainImageWidth,
  required double mainImageHeight,
  required double currentImageWidth,
  required double currentImageHeight,
  required double x,
  required double y,
}) {
  var newTargetx = (x * currentImageWidth) / (mainImageWidth * 2.5);
  var newTargety = (y * currentImageHeight) / (mainImageHeight * 2.5);
  return Point(newTargetx, newTargety);
}

Point<double> calculateCoordsForDatabase({
  required double mainImageWidth,
  required double mainImageHeight,
  required double currentImageWidth,
  required double currentImageHeight,
  required double x,
  required double y,
}) {
  //coordinates for database
  var targetx = (x * (mainImageWidth * 2.5)) / currentImageWidth;
  var targety = (y * (mainImageHeight * 2.5)) / currentImageHeight;
  return Point(targetx, targety);
}

/* Funcion getUiImage is a method to get patient image either male or female from assets and also getting  patient image height and width.*/
Future<ui.Image> getUiImage(String imageAssetPath) async {
  final ByteData assetImageByteData = await rootBundle.load(imageAssetPath);
  final codec =
      await ui.instantiateImageCodec(assetImageByteData.buffer.asUint8List());
  var bodyImage = (await codec.getNextFrame()).image;
  return bodyImage;
}

Future<ui.Image> getImageForCurrentView(
    {required ui.Image bodyImage, required int imagePartition}) async {
  final assetImageByteData =
      await bodyImage.toByteData(format: ui.ImageByteFormat.png);

  // final ByteData? assetImageByteData =  bodyImage.;
  final newcodec = await ui.instantiateImageCodec(
    assetImageByteData!.buffer.asUint8List(),
    targetHeight: (bodyImage.height) ~/ imagePartition,
    targetWidth: (bodyImage.width) ~/ imagePartition,
  );
  final newImage = (await newcodec.getNextFrame()).image;
  return newImage;
}

/* Function used to focus the cursor into next textfield using tab or enter key  */
fieldFocusChange(
    BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
  FocusScope.of(context).requestFocus(nextFocus);
}

/* To update the Checkbox check color*/
Color updateCheckBoxColor(Set<MaterialState> states) {
  return kDarkGreyBold;
}

bool checkNewPointAlreadyExist(
    List<PatientLocationIndicationPoint> patientsLocationPointsList,
    Point currentPoint) {
  var isAlreadyExist = false;
  for (var item in patientsLocationPointsList) {
    var distanceTo = Point(
            (currentPoint.x).toDouble(), (currentPoint.y).toDouble())
        .distanceTo(Point((item.x ?? 0).toDouble(), (item.y ?? 0).toDouble()));

    if (kDebugMode) {
      print(distanceTo);
    }
    if (distanceTo < 80) {
      return true;
    }
  }
  return isAlreadyExist;
}

extension DateHelper on DateTime {
  bool isSameDate(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  int getDifferenceInDaysWithNow() {
    final now = DateTime.now();
    return now.difference(this).inDays;
  }
}

// Widget to ask for confirmation before delete the record.
Widget deleteRecordAlertBox(
    {required BuildContext context,
    required String title,
    required String subTitle,
    required Function delete}) {
  return AlertDialog(
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(
          10.0,
        ),
      ),
    ),
    backgroundColor: kWhite,
    title: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Header text //
            Text(
              title.toUpperCase(),
              textAlign: TextAlign.left,
              style: getTextTheme(
                  fontWeight: FontWeight.w700,
                  fontSize: screenHeight(context) * 0.02,
                  textColor: kDarkGreyBold),
            ),

            //Cross Button //
            Container(
                transform: Matrix4.translationValues(10.0, 0.0, 0.0),
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: Icon(Icons.clear,
                      color: kLightGrey, size: screenHeight(context) * 0.03),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                )),
          ],
        ),
      ],
    ),
    content: Container(
      // width: screenWidth(context) * 0.2,
      height: screenHeight(context) * 0.18,
      transform: Matrix4.translationValues(0.0, -10.0, 0.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Inner text //
          Expanded(
            child: Text("$subTitle\nThis action cannot be undone.",
                style: getTextTheme(
                    fontWeight: FontWeight.w600,
                    textColor: kDarkGrey,
                    fontSize: screenHeight(context) * 0.02)),
          ),

          //Yes and no button //
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomButton(
                buttonText: 'Save This $title Record',
                onPressed: () {
                  Navigator.pop(context);
                },
                buttonBg: kLightGrey,
                textColor: kWhite,
              ),
              SizedBox(
                height: screenWidth(context) * 0.01,
              ),
              CustomButton(
                buttonText: 'Yes, Delete This $title Record',
                onPressed: () {
                  delete();
                },
                buttonBg: kLightSkinTone,
                textColor: kWhite,
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

Widget leftTitles(double value, TitleMeta meta) {
  if (value == meta.max) {
    return Container();
  }
  const style = TextStyle(
    color: kBorderLightBlack,
    fontSize: 10,
  );
  return SideTitleWidget(
    child: Text(
      meta.formattedValue,
      style: style,
    ),
    axisSide: meta.axisSide,
  );
}

BarTouchData get barTouchData => BarTouchData(
      enabled: false,
      touchTooltipData: BarTouchTooltipData(
        direction: TooltipDirection.auto,
        tooltipBgColor: Colors.transparent,
        tooltipPadding: const EdgeInsets.all(0),
        tooltipMargin: 0.0,
        getTooltipItem: (
          BarChartGroupData group,
          int groupIndex,
          BarChartRodData rod,
          int rodIndex,
        ) {
          return BarTooltipItem(
            rod.toY.round().toString(),
            const TextStyle(
              fontSize: 10,
              color: kBlack,
              fontWeight: FontWeight.bold,
            ),
          );
        },
      ),
    );

/*This function will return the graph bars color base on bar state*/
List<Color> getBarColor(String state) {
  switch (state.toUpperCase()) {
    case "LOW":
      return [kBarGraphBlue, kBarGraphBlue.withOpacity(0.8)];
    case "HIGH":
      return [kBarGraphOrange, kBarGraphOrange.withOpacity(0.8)];
    case "SPLIT":
      return [kBarGraphPurple, kBarGraphPurple.withOpacity(0.8)];
    default:
      return [kBarGraphGreen, kBarGraphGreen.withOpacity(0.8)];
  }
}

Future<String> readValueUTF8(List<int>? bytes) async {
  String bar = "";
  try {
    if (bytes != null) {
      // bar = ascii.decode(bytes);
      bar = utf8.decode(bytes);
    } else {}
  } on Exception catch (_) {
    print('never reached');
  }

  return bar;
}

int toInt16(Uint8List byteArray, int index) {
  ByteBuffer buffer = byteArray.buffer;
  ByteData data = new ByteData.view(buffer);
  int short = data.getInt16(index, Endian.little);
  return short;
}

int toInt32(Uint8List byteArray, int index) {
  ByteBuffer buffer = byteArray.buffer;
  ByteData data = new ByteData.view(buffer);
  int short = data.getInt32(index, Endian.little);
  return short;
}

String convertUint8ListToString(Uint8List uint8list) {
  return String.fromCharCodes(uint8list);
}


// Setting rounded numbers 1, 2, 3 in Treatment Plan Diet Section
Widget setRoundNumbers(BuildContext context, String number) {
  double screenWidth = MediaQuery.of(context).size.width;
  double screenHeight = MediaQuery.of(context).size.height;
  return Container(
    margin: const EdgeInsets.fromLTRB(0, 0, 6, 0),
    width: screenWidth * 0.025,
    height: screenHeight * 0.025,
    alignment: Alignment.center,
    decoration: const BoxDecoration(
      color:kLightGrey,
      shape: BoxShape.circle,
    ),
    child: Text(number,
        style:getTextTheme(
       fontWeight: FontWeight.w800,
         textColor:   kWhite,
      fontSize:  screenHeight * 0.016),
       textAlign: TextAlign.center),
  );
}

//Settings Record Checkbox Text
Widget checkBoxText(BuildContext context, Widget? setchild) {
  return Container(
    alignment: Alignment.centerLeft,
    transform: Matrix4.translationValues(1.0, 1.0, 0.0),
    child: setchild,
  );
}


// Set Text //
Widget settext(BuildContext context, String? textlabel, FontWeight? fontwt,
    Color? txtcolor, double? textsz, TextAlign? txtalignment) {
  return Text(
    textlabel ?? "",
    style: TextStyle(
      fontSize: textsz,
      color: txtcolor,
      fontWeight: fontwt,
    ),
    textAlign: txtalignment,
  );
}


// AcuGraph Logo //
Widget getLogo(BuildContext context, Matrix4? matrixval, Widget? logoimage) {
  return Container(
    alignment: Alignment.center,
    transform: matrixval,
    decoration: const BoxDecoration(color: Colors.transparent),
    child: logoimage,
  );
}

// Set Labels //
Widget getlabeltext(BuildContext context, String textlabel, FontWeight? fontwt,
    Color? txtcolor, double? textsz) {
  double screenWidth = MediaQuery.of(context).size.width;
  return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(0),
      width: screenWidth * 0.45,
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: Text(
        textlabel,
        style: TextStyle(color: txtcolor, fontWeight: fontwt, fontSize: textsz),
      ));
}

String removeLeadingZeros(int number) {
  // Convert the number to a string and remove leading zeros
  String result = number.toString().replaceAll(RegExp('^0+'), '');
  return result.isEmpty ? '0' : result;
}
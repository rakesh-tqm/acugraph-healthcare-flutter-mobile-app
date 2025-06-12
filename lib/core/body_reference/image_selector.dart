import 'package:acugraph6/database/database_helper.dart';
import 'package:sqlite3/sqlite3.dart' as sql;

import '../../data_layer/drivers/logger.dart';

class ImageSelector {
  late String genderSelector;
  late String skinToneSelector;
  late String leftRightSelector;
  late String imageName;

  static sql.Database? _sqliteDatabaseInstance;

  static Future<DatabaseHelper> getDatabaseHelper() async {
    var databaseHelper = DatabaseHelper();
    if (ImageSelector._sqliteDatabaseInstance != null) {
      databaseHelper.dbInstance = ImageSelector._sqliteDatabaseInstance;
      return databaseHelper;
    }
    await databaseHelper.init(
        password: "",
        databasePath: "",
        databaseName: "",
        isBundleDB: true);
    ImageSelector._sqliteDatabaseInstance = databaseHelper.dbInstance;
    return databaseHelper;
  }

  ImageSelector() {
    // Read user preferences and populate selectors
    genderSelector = "M"; // F
    skinToneSelector = "L"; // D
    leftRightSelector = "L"; // R
  }

  void selectPoint(String pointName) async {
    Map<String, Object?> pointCoords = await _getPointCoordsRow(pointName);

    if (pointCoords.isEmpty) {
      Logger.debug("No point '$pointName' found. Gender: '$genderSelector'",
          type: LogType.local,
          localType: LogLocalType.both,
          stack: false,
          report: false);
      return;
    }

    final String imageName = pointCoords["image_name"] as String;

    print(imageName);
  }

  Future<Map<String, Object?>> _getPointCoordsRow(String pointName) async {
    var databaseHelper = await ImageSelector.getDatabaseHelper();
    List<Map<String, Object?>>? rows = await databaseHelper.readRows(
      "PointCoords",
      // where: "point_name = '$pointName' AND gender = '$genderSelector'"
    );

    int count = await databaseHelper.countRows("PointCoords");
    print(count);

    return rows?.first ?? {};
  }
}

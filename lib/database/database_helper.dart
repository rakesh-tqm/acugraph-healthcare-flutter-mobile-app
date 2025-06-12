import 'dart:io';

import 'package:acugraph6/database/sqlcipher_library_windows.dart';
import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/open.dart';
import 'package:sqlite3/sqlite3.dart' as sql;

import '../data_layer/drivers/logger.dart';
import '../utils/utils.dart';

/*
  This database connection class is used to connect to encrypted SQLite database files stored on the local computer or
  in the application bundle. Several database files are distributed within AcuGraph, and others may be created "on-the-fly"
  as AcuGraph runs. This database tool provides the connections to and basic operations on these files.
 */
class DatabaseHelper {
  String _dbPassword = ""; //The database encryption key
  String _databaseName = ""; //The name of the database file
  String _databasePath =
      ""; //The *absolute* path to the directory where the database file lives on the file system.

  sql.Database? dbInstance; //Database instance.
  bool _isEncryptedDatabase = true;

  /*
    This constructor requires the password, path, and filename for the database connection.
    isBundleDB indicates whether this database was originally shipped in the application bundle.
    readOnlyDatabase indicates whether the connection via the sqlite library should be set to read-only.
   */
  Future<void> init(
      {required String password,
      required String
          databasePath, //Note that this is the *filesystem* path for a database we will create. NOT an assetBundle path.
      required String databaseName,
      required bool isBundleDB,
      bool readOnlyDatabase = false,
      bool isEncryptedDatabase = true}) async {
    try {
      //Store the passed-in vars into the instance vars
      _dbPassword = password;
      _databaseName = databaseName;
      _databasePath = databasePath;
      _isEncryptedDatabase = isEncryptedDatabase;
      //get a reference to the application support directory. All database file should be stored here.
      Directory appSupport = await getApplicationSupportDirectory();
      //descend into the "db" folder within Application Support.
      _databasePath = Directory(join(appSupport.path, "db")).path;
      //Check to make sure that the database folder already exists. If it does not, create it.
      if (FileSystemEntity.typeSync(_databasePath) ==
          FileSystemEntityType.notFound) {
        //we need to create the db directory.
        await (Directory(_databasePath).create());
      }

      /*
      Since this class will be used to interact with databases that ship with the application in it's bundle as well
      as with databases that are created on the fly, isBundleDB must be passed in to indicate if we are dealing with
      a bundled db or not. If we are, we have to do a few extra things:

      Flutter does not let you directly manipulate assets that are shipped in the bundle. They *must* be moved out
      to a different location first. If the database we want to connect to is shipped in the application bundle,
      we have to do a little bit of housekeeping at this point to make sure we are connecting to the correct file.

      Generally, rather than connecting to the database file that ships directly in the app bundle, we'll actually
      connect to a copy of that database which was previously put there from a prior run of the app. However, in the case
      of an application update which provides a new version of that database file, we need to make sure we copy
      the database file from the bundle *first*, then connect to the copy that lives in the application support area on
      the file system.

      So, we'll check to see if the copy exists in application support. If it does, we'll calculate the checksum of that
      file. Then we'll calculate the checksum of the version that is in the application bundle. If the checksums do not
      match, then the version in application support is out of date and should be replaced.

      At the end of all this logic, _databasePath and _databaseName should be set to the correct database file we will be
      using.
     */
      if (isBundleDB) {
        //check to see if the _databaseName exists in dbDir or not.
        File dbFile = File(join(_databasePath, _databaseName));
        if (FileSystemEntity.typeSync(dbFile.path) ==
            FileSystemEntityType.notFound) {
          //this file does not exist. We need to copy it from the bundle.
          print("A database was not found. Copying from the bundle.");
          await copyAssetToAppData(
              join('assets/database/', _databaseName), dbFile);
        }
        //At this point we should have a database file in the application support directory, either just copied here or
        //remaining here from a previous run. Calculate a checksum of that version, as well as the version in the
        //application bundle.
        Digest bundleFileDigest = await calculateBundleAssetMD5Checksum(join(
            'assets/database/',
            _databaseName)); // HMMmm... How do we calculate the MD5 sum on something in the root bundle?
        Digest appDataFileDigest = await calculateFileMD5Checksum(dbFile);
        print(
            "Existing db hash code: " + appDataFileDigest.hashCode.toString());
        print("Bundle db hash code: " + bundleFileDigest.hashCode.toString());
        //if the 2 digests are equal, we're good to go. If not, we need to delete the local copy and pull the version
        //out of the rootBundle instead.
        if (bundleFileDigest.hashCode != appDataFileDigest.hashCode) {
          print("on-disk database hash does not match bundle database hash.");
          //the on-disk version of this file differs from the version in the app bundle. Copy the one from the app bundle.
          dbFile.deleteSync();
          await copyAssetToAppData(
              join('assets/database/', _databaseName), dbFile);
          //We'll assume that the hashes now match, so we don't need to re-check.
        } else {
          print("Database hashes match! No need to copy from the bundle...");
        }
      }
      //determine platform, and connect to respective database.
      if (Platform.isWindows == false) {
      } else {
        open.overrideFor(OperatingSystem.windows, openSQLCipherOnWindows);
      }
      //Local DB file path
      File dbFile = File(join(_databasePath, _databaseName));
      if (isBundleDB) {
        dbInstance = sql.sqlite3.open(dbFile.path, mode: sql.OpenMode.readOnly);
      } else {
        dbInstance =
            sql.sqlite3.open(dbFile.path, mode: sql.OpenMode.readWriteCreate);
      }

      //Check to make sure we are connected, then supply the encryption key.
      if (dbInstance != null) {
        if (dbInstance!.handle.address > 0) {
          if (kDebugMode) {
            print("Connected to a database file: " + dbFile.path);
          }
          if (isEncryptedDatabase) {
            dbInstance!.execute("PRAGMA key = '" + _dbPassword + "'");
          }
          if (kDebugMode) {
            print("Database encryption key applied to the database.");
          }
        }
      } else {
        //We appear to be unable to open the database. Now what?
        Logger.warn(
            "Unable to open the local logging database. This is a pretty big problem, and someone should look at it now.",
            type: LogType.remote,
            localType: LogLocalType.console,
            stack: true,
            report: true);
      }
    } catch (e) {
      Logger.warn("Exception with database init: " + e.toString(),
          type: LogType.local,
          localType: LogLocalType.console,
          stack: true,
          report: true);
    }
  }

  //Copies the named asset out of the bundle and onto the file system as a regular file. Expect that this resource will be
  //a pretty large file, so we'll process the copy in smaller chunks.
  Future<void> copyAssetToAppData(String assetPath, File dbFile) async {
    ByteData data = await rootBundle.load(assetPath);
    //process the bytes in chunks.
    int chunkSize = 10000000; //10MB chunks
    for (int i = 0; i * chunkSize < data.lengthInBytes; i++) {
      int start = i * chunkSize;
      int bytesToRead = chunkSize;
      //make sure we don't overrun off the end of the bytes array.
      bytesToRead = start + bytesToRead > data.lengthInBytes
          ? data.lengthInBytes - start
          : bytesToRead;
      Uint8List chunk = data.buffer.asUint8List(start, bytesToRead);
      // Save copied asset to documents, flush the buffers on completion.
      await dbFile.writeAsBytes(chunk, mode: FileMode.append, flush: true);
    }
  }

  /*
    Utility function to calculate the MD5 hash of a file.
   */
  Future<Digest> calculateFileMD5Checksum(File f) async {
    int chunkSize = 10000000; //10MB chunks
    int fileLength = f
        .lengthSync(); //get the length of the file so we know how many bytes we need to read.
    var output = AccumulatorSink<Digest>();
    var input = md5.startChunkedConversion(output);
    for (int i = 0; i * chunkSize < fileLength; i++) {
      int start = i * chunkSize;
      int bytesToRead = chunkSize;
      bytesToRead = start + bytesToRead > fileLength ? fileLength : bytesToRead;
      Stream<List<int>> stream = f.openRead(i, bytesToRead);
      await for (var data in stream) {
        input.add(data);
      }
    }
    input.close();
    var digest = output.events.single;
    return digest;
  }

  /*
    Utility function to calculate the MD5 hash of an asset from the rootBundle - very similar to how we do this
    for regular files, but streams out of the rootBundle rather than a regular file system file.
   */
  Future<Digest> calculateBundleAssetMD5Checksum(String assetPath) async {
    ByteData data = await rootBundle.load(assetPath);
    //process the bytes in chunks.
    int chunkSize = 10000000; //10MB chunks
    var output = AccumulatorSink<Digest>();
    var input = md5.startChunkedConversion(output);
    for (int i = 0; i * chunkSize < data.lengthInBytes; i++) {
      int start = i * chunkSize;
      int bytesToRead = chunkSize;
      //make sure we don't overrun off the end of the bytes array.
      bytesToRead = start + bytesToRead > data.lengthInBytes
          ? data.lengthInBytes - start
          : bytesToRead;
      //print("Calculating MD5 Chunk: i="+i.toString() + " start = " + start.toString() + " bytesToRead=" + (bytesToRead).toString() + " and data length = " + data.lengthInBytes.toString() );
      Uint8List chunk = data.buffer.asUint8List(i, bytesToRead);
      //read the asset in chunks, and pump them into the MD5 sum calculator.
      input.add(chunk);
    }
    input.close();
    var digest = output.events.single;
    return digest;
  }

  /*
    This starts up the connection for the database on Windows.
   */
  Future<void> initiatedbInstance() async {
    if (Platform.isWindows == false) {
    } else {
      open.overrideFor(OperatingSystem.windows, openSQLCipherOnWindows);
    }
    //Local DB file path
    File dbFile = File(join(_databasePath, _databaseName));
    dbInstance =
        sql.sqlite3.open(dbFile.path, mode: sql.OpenMode.readWriteCreate);
    //Check to make sure we are connected, then supply the encryption key.
    if (dbInstance != null) {
      if (dbInstance!.handle.address > 0) {
        if (kDebugMode) {
          print("Connected to a database file: " + dbFile.path);
        }
        if (_isEncryptedDatabase) {
          dbInstance!.execute("PRAGMA key = '" + _dbPassword + "'");
        }
        if (kDebugMode) {
          print("Database encryption key applied to the database.");
        }
      }
    }
  }

  ///Create Statement
  void createStatement(String statement) {
    dbInstance?.execute('''${statement}''');
  }

  void closeDatabase() {
    dbInstance?.dispose();
  }

  Future<int> countRows(String table, {String? where}) async {
    if (dbInstance != null) {
      String whereStatement = "";
      if ((where ?? "").isNotEmpty) {
        whereStatement = " WHERE $where";
      }

      List<Map<String, Object?>>? result = dbInstance!
          .select("SELECT COUNT(*) as total FROM $table $whereStatement");

      if (result.first.containsKey('total')) {
        return int.parse(result.first['total'].toString());
      }
      return 0;
    }
    return 0;
  }

  ///Read rows
  Future<List<Map<String, Object?>>?> readRows(
    String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    if (dbInstance != null) {
      String whereStatement = "";
      if ((where ?? "").isNotEmpty) {
        var keysList = where?.split("?");
        var whereValue = "";

        if (keysList != null) {
          for (int i = 0; i < keysList.length; i++) {
            if (i == keysList.length - 1) {
              if (keysList.elementAt(i).isNotEmpty) {
                whereValue +=
                    "${keysList.elementAt(i)}\'${whereArgs?.elementAt(i)}\'";
              }
            } else {
              if (keysList.elementAt(i).isNotEmpty) {
                whereValue +=
                    "${keysList.elementAt(i)}\'${whereArgs?.elementAt(i)}\'";
              }
            }
          }
        }
        whereStatement = " WHERE $whereValue";
      }

      String orderByStatement = "";
      if ((orderBy ?? "").isNotEmpty) {
        orderByStatement = " ORDER BY $orderBy";
      }

      String limitStatement = "";
      if (limit != null) {
        limitStatement = " LIMIT $limit";
      }
      String offsetStatement = "";
      if (offset != null) {
        offsetStatement = " OFFSET $offset";
      }
      List<Map<String, Object?>>? result = dbInstance!.select(
          'SELECT * FROM $table$whereStatement$orderByStatement$limitStatement$offsetStatement');

      // result.forEach((element) {
      //   print(element);
      // });
      return result;
    }
    return null;
  }

  ///delete rows
  Future<Object?> deleteRow(String table,
      {String? where, List<Object?>? whereArgs}) async {
    String whereStatement = "";

    if (dbInstance != null) {
      if ((where ?? "").isNotEmpty) {
        var keysList = where?.split("?");
        var whereValue = "";

        if (keysList != null) {
          for (int i = 0; i < keysList.length; i++) {
            if (i == keysList.length - 1) {
              if (keysList.elementAt(i).isNotEmpty) {
                whereValue +=
                    "${keysList.elementAt(i)}\'${whereArgs?.elementAt(i)}\'";
              }
            } else {
              if (keysList.elementAt(i).isNotEmpty) {
                whereValue +=
                    "${keysList.elementAt(i)}\'${whereArgs?.elementAt(i)}\'";
              }
            }
          }
        }
        whereStatement = " WHERE $whereValue";
      }
      var statement = 'DElETE FROM $table$whereStatement';
      var result = dbInstance!.select(statement);
      return result;
    }
    return null;
  }

  ///Insert rows
  Future<Object?> insertRow(String table,
      {required Map<String, Object?> values}) async {
    String value = "";
    for (int i = 0; i < values.values.length; i++) {
      if (i == values.values.length - 1) {
        value += "\'${values.values.elementAt(i)}\'";
      } else {
        value += "\'${values.values.elementAt(i)}\',";
      }
    }
    if (dbInstance != null) {
      var result = dbInstance!
          .select('INSERT INTO $table ${values.keys} VALUES($value)');
      return result;
    }
    return null;
  }

  ///Update rows
  Future<Object?> updateRow(String table,
      {required Map<String, Object?> values,
      String? where,
      List<Object?>? whereArgs}) async {
    String whereStatement = "";
    String updteValues = "";

    if (dbInstance != null) {
      if ((where ?? "").isNotEmpty) {
        var keysList = (where ?? "").split(",");
        var whereValue = "";

        if (keysList != null) {
          for (int i = 0; i < keysList.length; i++) {
            if (i == keysList.length - 1) {
              whereValue += "${keysList.elementAt(i)}"
                  .replaceAll("?", "\'${whereArgs?.elementAt(i)}\'");
            } else {
              whereValue += "${keysList.elementAt(i)},"
                  .replaceAll("?", "\'${whereArgs?.elementAt(i)}\'");
            }
          }
        }
        whereStatement = " WHERE $whereValue";
      }
    }

    if (values != null) {
      String value = "";
      for (int i = 0; i < values.values.length; i++) {
        if (i == values.length - 1) {
          value +=
              "${values.keys.elementAt(i)}=\'${values.values.elementAt(i)}\'";
        } else {
          value +=
              "${values.keys.elementAt(i)}=\'${values.values.elementAt(i)}\',";
        }
      }
      updteValues = " $value";
    }
    var updateStatement = 'UPDATE $table SET $updteValues$whereStatement';

    if (dbInstance != null) {
      var result = dbInstance!.select(updateStatement);

      return result;
    }
    return null;
  }

  ///Get Sqlite Version and SQLCipher version
  void getVersion() {
    if (dbInstance != null) {
      final sql.ResultSet resultSet =
          dbInstance!.select("SELECT sqlite_version()");
      resultSet.forEach((element) {
        print(element);
      });

      final sql.ResultSet resultSet2 =
          dbInstance!.select("PRAGMA cipher_version");
      resultSet2.forEach((element) {
        print(element);
      });
    }
  }
}

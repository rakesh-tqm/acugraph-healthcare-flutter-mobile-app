import 'dart:io';

import 'package:acugraph6/controllers/custom_note_template_controller.dart';
import 'package:acugraph6/controllers/exam_controller.dart';
import 'package:acugraph6/controllers/global_search_controller.dart';
import 'package:acugraph6/controllers/logging_panel_controller.dart';
import 'package:acugraph6/controllers/patient_attatchment_controller.dart';
import 'package:acugraph6/controllers/patient_controller.dart';
import 'package:acugraph6/controllers/patient_notes_controller.dart';
import 'package:acugraph6/controllers/preference_controller.dart';
import 'package:acugraph6/controllers/treatment_plan_drawer_controller.dart';
import 'package:acugraph6/data_layer/drivers/logger.dart';
import 'package:acugraph6/data_layer/drivers/sqlite.dart';
import 'package:acugraph6/views/graphs/models/sound_selector.dart';
import 'package:acugraph6/views/splash_screen.dart';
import 'package:dart_vlc/dart_vlc.dart';
import 'package:desktop_window/desktop_window.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:provider/provider.dart';

import 'controllers/attachment_controller.dart';
import 'controllers/auth_controllers.dart';
import 'controllers/exam_food_controller.dart';
import 'controllers/meridian_information_controller.dart';
import 'controllers/patient_chief_complaint_controller.dart';
import 'controllers/patient_chief_complaint_snapshot_controller.dart';
import 'controllers/patient_locations_controller.dart';
import 'controllers/probes_controller.dart';
import 'controllers/report_preset_controller.dart';
import 'controllers/report_preview_controller.dart';
import 'controllers/screen_controller.dart';
import 'controllers/settings_controller.dart';
import 'controllers/tenant_controller.dart';
import 'controllers/today_visit_drawer_controller.dart';
import 'controllers/treatment_plan_library_controller.dart';
import 'controllers/user_controller.dart';
import 'core/body_reference/image_selector.dart';

// Having a navigatorKey makes accessing to context easily from anywhere
// See: https://stackoverflow.com/a/61773774/10484812
final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 'Catch-all' Flutter-related exceptions to add a Logger entry.
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    ErrorHandler.onErrorDetails(details);
  };
  // 'Catch-all' Non-flutter-related (More related to the platform, data types, etc) exceptions to add a Logger entry.
  PlatformDispatcher.instance.onError = (error, stack) {
    ErrorHandler.onError(error, stack);
    return true;
  };
  //Here handling minimum screen size for desktops like windows, macos
  if (Platform.isWindows || Platform.isLinux) {
    DartVLC.initialize();
  }
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    await DesktopWindow.setMinWindowSize(const Size(900, 720));
    await DesktopWindow.setWindowSize(const Size(900, 720));
  }
  ////TODO:Encrypted database implementation in progress
  initialDatabase();
  ///Set preferred orientation to portrait
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
  runApp(
    MultiProvider(
      /// List of provider, the UI updates when `notifyListeners()` is called
      /// on the service classes
      providers: [
        ChangeNotifierProvider(create: (_) => ExamController()),
        ChangeNotifierProvider(create: (_) => PatientController()),
        ChangeNotifierProvider(create: (_) => GlobalSearchController()),
        ChangeNotifierProvider(create: (_) => PatientLocationsController()),
        ChangeNotifierProvider(create: (_) => PatientNotesController()),
        ChangeNotifierProvider(create: (_) => TodayVisitDrawerController()),
        ChangeNotifierProvider(create: (_) => CustomNoteTemplateController()),
        ChangeNotifierProvider(create: (_) => PatientAttachmentController()),
        ChangeNotifierProvider(create: (_) => TreatmentPlanDrawerController()),
        ChangeNotifierProvider(create: (_) => TreatmentPlanLibraryController()),
      ],
      child: const MyApp(),
    ),
  );
}

initialDatabase() async {
  await Logger.init();
  await SqliteCache.init();
  await SoundSelector.init();
}


class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  info() async {

    ImageSelector imageSelector = ImageSelector();
    imageSelector.selectPoint("LU 1");

    print('Fe');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorObservers: [FlutterSmartDialog.observer],
      navigatorKey: navigatorKey,
      builder: FlutterSmartDialog.init(),
      theme: ThemeData.light(),
      initialRoute: '/',
      routes: {
        "/": (_) => const Splash(),
      },
    );
  }
}

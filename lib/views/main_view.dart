/* This class is representing the module detail view of selected module. For example if 'Select A Patient' module is selected then this class
will open the detail view of 'Select A Patient' module.

*/
import 'package:acugraph6/controllers/common_controller.dart';
import 'package:acugraph6/controllers/tenant_controller.dart';
import 'package:acugraph6/views/common_widgets/side_drawers/modules/patient_info_drawer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/attachment_controller.dart';
import '../controllers/patient_controller.dart';
import '../controllers/preference_controller.dart';
import '../controllers/screen_controller.dart';
import 'common_widgets/header/main_header_view.dart';
import 'common_widgets/side_drawers/right_side_drawer_buttons.dart';

class MainView extends StatefulWidget {
  const MainView({Key? key}) : super(key: key);

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  //Variable to hold a global key for this Scaffold state to perform functions like open drawer or messenger toast
  final GlobalKey<ScaffoldState> _key = GlobalKey();

  @override
  void initState() {

    super.initState();
    if(context.read<AttachmentController>().clinicLogoId==null){
      context.read<AttachmentController>().getAttachmentList(flag: "clinic_logo");
    }
    if(context.read<AttachmentController>().coverPageList.isEmpty){
      context.read<AttachmentController>().getAttachmentList(flag: "report cover page");

    }
    context.read<PreferenceController>().getPreferenceList();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: const PatientInfo(),
      resizeToAvoidBottomInset: true,
      key: _key,
      body: Consumer<PatientController>(
        builder: (context, provider, child) => Column(
          children: [
            //Calling MainHeaderView to show the header on the top bar
            const MainHeaderView(),

            Expanded(
              flex: 1,
              child: Stack(
                children: [
                  SingleChildScrollView(
                    child: Container(
                        child:
                        context.watch<PatientController>().currentScreen),
                  ),
                  //Side Drawer Buttons
                  Positioned(
                    // height: (screenHeight(context) * 0.85),
                      right: 0,
                      child: RightSideDrawerButtons(
                        scaffoldKey: _key,
                      ))
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

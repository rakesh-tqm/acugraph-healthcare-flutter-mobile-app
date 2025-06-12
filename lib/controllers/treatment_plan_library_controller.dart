/*This class is representing the patient treatment plan controller to show the Treatment Plan Point,Recommendations(Expanded Care/Home Care) in patient detail screen
to create or edit the Treatment Plan Points, Recommendations in Treatment Plan drawer section. This class also holding the operation of library settings and Library module
because in library module all the operations are performing based on treatment plan id
 */

import 'package:acugraph6/controllers/common_controller.dart';
import 'package:acugraph6/controllers/patient_controller.dart';
import 'package:acugraph6/controllers/treatment_plan_drawer_controller.dart';
import 'package:acugraph6/data_layer/models/point_information.dart';
import 'package:acugraph6/data_layer/models/treatment_plan.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:provider/provider.dart';
import '../data_layer/custom/search_result.dart';
import '../data_layer/models/attachment.dart';
import '../data_layer/models/library.dart';
import '../data_layer/models/library_item.dart';
import '../data_layer/models/note.dart';
import '../data_layer/models/treatment_plan_point.dart';
import '../data_layer/models/treatment_plan_recommendation.dart';
import '../utils/constants.dart';
import '../utils/utils.dart';

class TreatmentPlanLibraryController extends CommonController {
  //Instance of Treatment Plan to store the selected treatment plan id to perform edit or to display in Treatment Plan Points tab selected from patient detail screen.
  TreatmentPlan? selectedTreatmentPlan;

  // Instance of library list used to store all the library setting data
  List<Library> libraryList = [];

  // Instance of library list used to store all the library data
  List<LibraryItem> libraryItemsList = [];

  // Instance of library list used to store all the library data when search is implemented
  List<Library> searchLibraryListItem = [];

  // Instance of library list used to store all the library data when search is implemented
  List<LibraryItem> searchLibraryItem = [];

  // Instance of treatment plan used to store all the treatment plans data
  List<Attachment> libraryAttachmentList = [];

  // Initialized value for selected channel use to display the dropdown selected value
  String? selectedChannel = 'LU';

  // Initialized value for selected imbalance use to display the dropdown selected value
  String? selectedImbalance = 'Split';

  // Initialized value for selected category use to display the dropdown selected value
  Library? selectedCategory;

  // DropDown imbalance values
  List<String>? imbalance = ['Split', 'High', 'Low'];

  //Graph Finding Checkbox variable use to store the value of check box in adding to library screen
  bool graphFindingsBool = false;

  // boolean value to show/hide channel use to display the widget in adding to library screen
  bool showHideChannel = false;

  // Initialized value for selected file to check file is selected for upload or not
  bool selectedFile = false;

  // Initialized value for selected library item
  int selectedSubItem = -1;

  // Initialized value for selected library category
  int selectedParentItem = -1;

  // Initialized value for selected category id use to store the id of selected library category
  String selectedCategoryId = "";

  // base64image value initialized use to convert image to base64
  String base64BitImage = "";

  // fileExtension value initialized use to pick the extension of the file picked
  String? fileExtension = "";

  // fileName value initialized use to store the file name
  String? fileName = "";

  // libraryItemId value initialized use to store the id of selected library item
  String? libraryItemId = "";

  // bool value to check search is implemented
  bool isSearching = false;

  // Instance of treatment plan used to store all the treatment plans data
  List<TreatmentPlanRecommendation> treatmentRecommendationList = [];

  List<TreatmentPlanPoint?> newTreatmentPlanPoint = [];

  /* Function to get the list of treatment plan point and recommendations based on treatment plan fetch by id including points and recommendations. */
  Future<TreatmentPlan?> getTreatmentPlanData(
      {required TreatmentPlan treatmentPlan}) async {
    TreatmentPlan? treatmentPlanData;
    treatmentRecommendationList.clear();
    try {
      treatmentPlanData = await TreatmentPlan().fetchById(
          treatmentPlan.id ?? "",
          include: ['note', 'points', 'recommendations']);

      if ((treatmentPlanData.recommendations ?? []).isNotEmpty) {
        for (var item in treatmentPlanData.recommendations ?? []) {
          var treatmentValue = await getTreatmentPlanRecommendationById(
              recommendationId: item.id);
          item.attachment = treatmentValue?.attachment;
          item.snapshot = treatmentValue?.snapshot;
        }
        treatmentRecommendationList
            .addAll((treatmentPlanData.recommendations ?? []));
      }

      notifyListeners();
      return treatmentPlanData;
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
      notifyListeners();
    }
    return null;
  }

  /*Function to get recommendation data by recommendation ID with include features 'attachment', 'snapshot' and plan*/
  Future<TreatmentPlanRecommendation?> getTreatmentPlanRecommendationById(
      {required String recommendationId}) async {
    try {
      TreatmentPlanRecommendation recommendationData =
          await TreatmentPlanRecommendation()
              .fetchById(recommendationId, include: ['attachment', 'snapshot']);
      return recommendationData;
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
    return null;
  }

  /* Function to delete patient treatment plan from patient detail screen*/
  deletePatientTreatmentPlan(
      {required BuildContext context,
      required TreatmentPlan treatmentPlan}) async {
    try {
      SmartDialog.showLoading();
      await treatmentPlan.delete();
      showTips(context, "Patient treatment plan deleted Successfully");
      SmartDialog.dismiss();
      Navigator.pop(context);
      context.read<PatientController>().getPatientById(context: context);
      notifyListeners();
    } catch (e) {
      SmartDialog.dismiss();
      Navigator.pop(context);
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

// setSelectedTreatmentPlan(TreatmentPlan? treatmentPlan)async{
//     selectedTreatmentPlan=treatmentPlan;
//     notifyListeners();
// }

  /*Function to create new treatment plan*/
  Future<TreatmentPlan?> addTreatmentPlan(
      {required TreatmentPlan? treatmentPlan}) async {
    try {
      await treatmentPlan?.create();
      print(treatmentPlan?.id);
      // if(treatmentPlan!=null){
      //   selectedTreatmentPlan=treatmentPlan;
      //   // getTreatmentPlanData(treatmentPlan: treatmentPlan);
      // }
      notifyListeners();
      return treatmentPlan;
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
    return null;
  }

  /*Function to add treatment plan point from graphing module*/
  Future<TreatmentPlanPoint?> addTreatmentPlanPoint(
      {required BuildContext context,
      required TreatmentPlanPoint? treatmentPlanPoint}) async {
    try {
      await treatmentPlanPoint?.create();
      // updateTreatmentPlan(treatmentPlan: selectedTreatmentPlan);
      return treatmentPlanPoint;
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
    return null;
  }

/* Function to update treatment plan point from treatment plan drawer*/
  updateTreatmentPlanPoint(
      {required BuildContext context,
      required TreatmentPlanPoint? treatmentPlanPoint}) async {
    try {
      if (selectedTreatmentPlan != null) {
        SmartDialog.showLoading();
        await treatmentPlanPoint?.update();
        SmartDialog.dismiss();
        SmartDialog.showToast("Treatment plan point updated Successfully");
        getTreatmentPlanData(treatmentPlan: selectedTreatmentPlan!);
        updateTreatmentPlan(treatmentPlan: selectedTreatmentPlan);
        context.read<PatientController>().getPatientById(context: context);
        notifyListeners();
      }
    } catch (e) {
      SmartDialog.dismiss();
      Navigator.pop(context);
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  /* Function to delete treatment plan point from treatment plan drawer*/
  deleteTreatmentPlanPoint(
      {required BuildContext context,
      required TreatmentPlanPoint? treatmentPlanPoint}) async {
    try {
      SmartDialog.showLoading();
      await treatmentPlanPoint?.delete();
      SmartDialog.dismiss();
      SmartDialog.showToast("Treatment plan point deleted Successfully");
      Navigator.pop(context);
      context.read<PatientController>().getPatientById(context: context);
      getTreatmentPlanData(
          treatmentPlan: selectedTreatmentPlan ?? TreatmentPlan());
      notifyListeners();
    } catch (e) {
      SmartDialog.dismiss();
      Navigator.pop(context);
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  //remove temporary treatment plan point
  removeTemproryTreatmentPlanPoint(TreatmentPlanPoint? point) {
    newTreatmentPlanPoint.remove(point);
    notifyListeners();
  }

  /*Function to get point information*/
  Future<PointInformation?> getPointInformation(String pointName) async {
    try {
      PointInformation pointInformation =
          await PointInformation().fetchByName(pointName);
      return pointInformation;
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
    return null;
  }

  /* Function to update/delete treatment plan recommendation from treatment plan drawer
  * Note: For delete, pass the false bool value to both variable treatAtHome and treatInOffice in this function parameter
  * */
  deleteTreatmentPlanRecommendation(
      {required BuildContext context,
      required String snapShotUuID,
      bool? treatAtHome,
      bool? treatInOffice}) async {
    try {
      SmartDialog.showLoading();
      await selectedTreatmentPlan?.updateRecommendation(
          libraryItemSnapshotUuid: snapShotUuID,
          treatAtHome: treatAtHome,
          treatedInOffice: treatInOffice);
      SmartDialog.dismiss();
      SmartDialog.showToast("Deleted Successfully");
      Navigator.pop(context);
      context.read<PatientController>().getPatientById(context: context);

      getTreatmentPlanData(
              treatmentPlan: selectedTreatmentPlan ?? TreatmentPlan())
          .then((value) {
        selectedTreatmentPlan = value;
      });
      Navigator.pop(context);

      notifyListeners();
    } catch (e) {
      SmartDialog.dismiss();
      Navigator.pop(context);
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  /* This function is used to get all library category data */
  getLibraryData(
      {required BuildContext context,
      String searchText = "",
      bool reset = false}) async {
    try {
      // Condition to check reset value is true or not, if it is true then it'll reset the library list
      if (reset) {
        _resetLibraryList();
      }
      isLoadingData = true;
      currentPage = currentPage + 1;
      SearchResult<Library> libraryData = await Library().fetchMany(
          page: (currentPage),
          pageSize: pageSize,
          sort: '-updated_at',
          include: ['items']);

      totalResources = libraryData.totalResources;
      libraryList.addAll(libraryData.resources);
      context.read<TreatmentPlanLibraryController>().selectedCategory =
          libraryList[0];
      if (kDebugMode) {
        print(libraryList);
      }
      isLoadingData = false;

      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  /* Function to load more library Data in library setting*/
  loadMoreLibrary(BuildContext context) async {
    // If the library list count exceeds or equals to the total library list, then no new API will be call.
    // Checking display library list count till load more does not exceed from the total.
    if (!isLoadingData && (totalResources > libraryList.length)) {
      getLibraryData(context: context);
    }
  }

  /* Function to reset the current page and library list to default value*/
  _resetLibraryList() {
    currentPage = 0;
    libraryList.clear();
    // notifyListeners();
  }

  //Function to add/edit library in category setting
  addEditLibrary(
      {required BuildContext context, required Library library}) async {
    try {
      SmartDialog.showLoading();
      if (library.id != null) {
        await library.update();
      } else {
        await library.create();
      }
      getLibraryData(context: context, reset: true);
      SmartDialog.dismiss();
      notifyListeners();
      Navigator.pop(context);
    } catch (e) {
      SmartDialog.dismiss();
      Navigator.pop(context);
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

//Function to delete library category in setting
  deletedLibrary(
      {required BuildContext context, required Library library}) async {
    try {
      SmartDialog.showLoading();
      await library.delete();
      getLibraryData(context: context, reset: true);
      SmartDialog.dismiss();
      notifyListeners();
      Navigator.pop(context);
    } catch (e) {
      SmartDialog.dismiss();
      Navigator.pop(context);
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  //Function to search treatments in Add/Edit library screen
  searchLibraryListItemFilter(
      {required BuildContext context, String searchText = ""}) {
    searchLibraryListItem.clear();
    notifyListeners();
    List<Library> results = [];
    if (searchText == "") {
      results = context.read<TreatmentPlanLibraryController>().libraryList;
    } else {
      results = context
          .read<TreatmentPlanLibraryController>()
          .libraryList
          .where((element) => element.name
              .toString()
              .toLowerCase()
              .contains(searchText.toLowerCase()))
          .toList();
    }
    searchLibraryListItem.addAll(results);
    notifyListeners();
  }

  //Function to search library item from library lost in library module
  searchLibraryItemFilter(
      {required BuildContext context, String searchText = ""}) {
    searchLibraryItem.clear();
    List<LibraryItem> results = [];
    if (searchText == "") {
      results = libraryItemsList;
    } else {
      results = libraryItemsList
          .where((element) => element.title
              .toString()
              .toLowerCase()
              .contains(searchText.toLowerCase()))
          .toList();
    }
    searchLibraryItem.addAll(results);
    if (kDebugMode) {
      print(searchLibraryItem.length);
    }
    notifyListeners();
  }

/* This function is used to get all library data */
  getLibraryItemData(
      {required BuildContext context,
      String searchText = "",
      bool reset = false}) async {
    try {
      // Condition to check reset value is true or not, if it is true then it'll reset the library list
      if (reset) {
        _resetLibraryItemsList();
      }
      libraryItemsList.clear();
      isLoadingData = true;
      SearchResult<LibraryItem> libraryItemsData = await LibraryItem()
          .fetchMany(
              page: (1),
              pageSize: 1000,
              sort: '-updated_at',
              include: ["library", "attachment"]);

      totalResources = libraryItemsData.totalResources;
      libraryItemCount = libraryItemsData.totalResources;
      libraryItemsList.addAll(libraryItemsData.resources);
      if (kDebugMode) {
        print(libraryItemsData);
      }
      isLoadingData = false;
      searchLibraryItemFilter(context: context, searchText: "");
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  // //Api get library items count
  // void getTreatmentRecommendation({required String patientUDID}) async {
  //
  //   SearchResult<TreatmentPlan> treatmentPlanData =
  //   await TreatmentPlan().fetchMany(
  //     page: (1),
  //     pageSize: 1,
  //     sort: '-updated_at',
  //     include: ["recommendations"],
  //     filters: {"patient_uuid": patientUDID},
  //   );
  //   // treatmentPlanList.addAll(treatmentPlanData.resources);
  //   if (treatmentPlanData.resources.isNotEmpty) {
  //     for (var item in treatmentPlanData.resources[0].recommendations ?? []) {
  //       var treatmentRecommendation = await TreatmentPlanRecommendation()
  //           .fetchById(item?.id ?? "", include: ['snapshot']);
  //       item.snapshot = treatmentRecommendation.snapshot;
  //     }
  //
  //   }
  //
  //   notifyListeners();
  // }

  /* Function to add library attachments*/
  addLibraryAttachment(
      {required BuildContext context, required Attachment attachment}) async {
    try {
      SmartDialog.showLoading();
      await attachment.create();
      SmartDialog.showToast("Attachment created Successfully");

      SmartDialog.dismiss();

      getAttachmentList(flag: attachment.flag);
      // if (attachment.flag == "clinic_logo") {
      //   base64Format = attachment.base64;
      //   notifyListeners();
      // }
      notifyListeners();
    } catch (e) {
      SmartDialog.dismiss();
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  /* Function to add library item*/
  addEditLibraryItem(
      {required BuildContext context, required LibraryItem libraryItem}) async {
    try {
      SmartDialog.showLoading();
      if (libraryItem.id == "") {
        await libraryItem.create();
        SmartDialog.showToast("Item created Successfully");
      } else {
        await libraryItem.update();
        SmartDialog.showToast("Item updated Successfully");
      }

      SmartDialog.dismiss();

      getLibraryItemData(context: context, reset: true);
      notifyListeners();
    } catch (e) {
      SmartDialog.dismiss();
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  /*Function to get attachment list */
  getAttachmentList({String? flag}) async {
    try {
      SearchResult<Attachment> attachmentData =
          await Attachment().fetchMany(filters: {"flag": flag});
      libraryAttachmentList.addAll(attachmentData.resources);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  //Function to delete attachment
  deleteAttachment(
      {required BuildContext context, required Attachment attachment}) async {
    try {
      SmartDialog.showLoading();
      await attachment.delete();
      showTips(context, "Attachment deleted Successfully");
      SmartDialog.dismiss();
      getAttachmentList(flag: attachment.flag);
      notifyListeners();
      Navigator.pop(context);
    } catch (e) {
      SmartDialog.dismiss();
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  //Function to delete library item
  deleteLibraryItem(
      {required BuildContext context, required LibraryItem libraryItem}) async {
    try {
      SmartDialog.showLoading();
      await libraryItem.delete();
      showTips(context, "Library Item deleted Successfully");
      SmartDialog.dismiss();
      getLibraryItemData(context: context, reset: true);
      notifyListeners();
      Navigator.pop(context);
    } catch (e) {
      SmartDialog.dismiss();
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  // update treatment recommendation
  updateRecommendation(
      {required BuildContext context,
      required TreatmentPlanRecommendation treatmentRecommendation,
      required TreatmentPlan treatmentPlan}) async {
    try {
      SmartDialog.showLoading();

      await treatmentPlan.updateRecommendation(
          libraryItemSnapshotUuid: treatmentRecommendation.snapshot?.id ?? "",
          treatAtHome: treatmentRecommendation.treatAtHome,
          treatedInOffice: treatmentRecommendation.treatedInOffice);
      SmartDialog.showToast("Item updated Successfully");

      SmartDialog.dismiss();
      context.read<TreatmentPlanLibraryController>().getTreatmentPlanData(
          treatmentPlan: context
              .read<TreatmentPlanLibraryController>()
              .selectedTreatmentPlan!);

      getLibraryItemData(context: context, reset: true);
      notifyListeners();
    } catch (e) {
      SmartDialog.dismiss();
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  // update treatment library recommendation
  updateLibraryRecommendation(
      {required BuildContext context,
      required String snapShotId,
      required bool treatAtHome,
      required bool treatedInOffice,
      required TreatmentPlan treatmentPlan}) async {
    try {
      SmartDialog.showLoading();

      await treatmentPlan.updateRecommendation(
          libraryItemSnapshotUuid: snapShotId,
          treatAtHome: treatAtHome,
          treatedInOffice: treatedInOffice);
      SmartDialog.showToast("Item updated Successfully");

      SmartDialog.dismiss();
      context.read<TreatmentPlanLibraryController>().getTreatmentPlanData(
          treatmentPlan: context
              .read<TreatmentPlanLibraryController>()
              .selectedTreatmentPlan!);

      getLibraryItemData(context: context, reset: true);
      notifyListeners();
    } catch (e) {
      SmartDialog.dismiss();
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

/* Function to reset the current page and library items list to default value*/
  _resetLibraryItemsList() {
    currentPage = 0;
    libraryItemsList.clear();
    // notifyListeners();
  }

  /*Function to create treatment plan note*/
  Future<Note?> addTreatmentNote({required Note note}) async {
    try {
      await note.create();
      return note;
    } catch (e) {
      SmartDialog.dismiss();
      if (kDebugMode) {
        print(e.toString());
      }
    }
    return null;
  }

  /*Function to update treatment plan including notes*/
  Future updateTreatmentPlan({required TreatmentPlan? treatmentPlan}) async {
    try {
      await treatmentPlan?.update();
      getTreatmentPlanData(treatmentPlan: treatmentPlan!);
    } catch (e) {
      SmartDialog.dismiss();
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }
}

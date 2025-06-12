/*
  Intelligraph adjusts graph values based on a large-scale research project conducted several years ago using actual readings
  across hundreds of practitioners and tens of thousands of exams. Statistical analysis was performed, which yielded accurate
  adjustments which should be made to raw graph readings based on age and gender of the patient.

  This class is a self-contained tool for performing these adjustments.
 */

import 'package:acugraph6/core/treatment_derivation/constants.dart';
import 'package:acugraph6/data_layer/models/intelli_graph_calc.dart';
import 'package:acugraph6/data_layer/custom/search_result.dart';

class Intelligraph {
  /*
  Here are the actual adjustment values used when performing Intelligraph calculations. Use the patient's age and gender
  to determine which set of values to use.
   */
  //Maps for the female values, broken down by max age.
  Map f10 = {};
  Map f20 = {};
  Map f32 = {};
  Map f43 = {};
  Map f52 = {};
  Map f62 = {};
  Map f150 = {};
  //Maps for the male values, broken down by max age.
  Map m10 = {};
  Map m20 = {};
  Map m32 = {};
  Map m43 = {};
  Map m52 = {};
  Map m62 = {};
  Map m150 = {};
  //Map to hold all the calcs in one place.
  Map calcs = {};

  /*
  We'll use the constructor to populate the calcs map.
   */
  Intelligraph() {
    f10 = {
      "l_lu_int": 0.2300300000,
      "l_lu_adj": -0.0013188550,
      "r_lu_int": 0.1679100000,
      "r_lu_adj": -0.0008094780,
      "l_li_int": 0.0118200000,
      "l_li_adj": 0.0002824040,
      "r_li_int": 0.0176200000,
      "r_li_adj": 0.0002638570,
      "l_sp_int": 0.3061900000,
      "l_sp_adj": -0.0022604410,
      "r_sp_int": 0.3384900000,
      "r_sp_adj": -0.0025754130,
      "l_st_int": -0.1842200000,
      "l_st_adj": 0.0009076380,
      "r_st_int": -0.2762200000,
      "r_st_adj": 0.0016969930,
      "l_ht_int": 0.1489100000,
      "l_ht_adj": -0.0014244340,
      "r_ht_int": -0.0114200000,
      "r_ht_adj": -0.0002796210,
      "l_si_int": -0.0885800000,
      "l_si_adj": 0.0010133420,
      "r_si_int": -0.1431500000,
      "r_si_adj": 0.0013811950,
      "l_ki_int": -0.0847900000,
      "l_ki_adj": 0.0010569970,
      "r_ki_int": -0.1149700000,
      "r_ki_adj": 0.0013074960,
      "l_bl_int": 0.2446400000,
      "l_bl_adj": -0.0020913400,
      "r_bl_int": 0.1658700000,
      "r_bl_adj": -0.0015045000,
      "l_pc_int": 0.1065600000,
      "l_pc_adj": -0.0009342950,
      "r_pc_int": -0.0101600000,
      "r_pc_adj": -0.0002712270,
      "l_te_int": 0.0866500000,
      "l_te_adj": -0.0002078510,
      "r_te_int": 0.2199100000,
      "r_te_adj": -0.0008094780,
      "l_lr_int": -0.2713900000,
      "l_lr_adj": 0.0018872710,
      "r_lr_int": -0.3250000000,
      "r_lr_adj": 0.0023191430,
      "l_gb_int": -0.2994200000,
      "l_gb_adj": 0.0016894120,
      "r_gb_int": -0.2352600000,
      "r_gb_adj": 0.0012360810
    };
    f20 = {
      "l_lu_int": 0.2220000000,
      "l_lu_adj": -0.0007822020,
      "r_lu_int": 0.1275500000,
      "r_lu_adj": -0.0002658160,
      "l_li_int": -0.0878900000,
      "l_li_adj": 0.0013066590,
      "r_li_int": -0.1020300000,
      "r_li_adj": 0.0013059930,
      "l_sp_int": 0.5755700000,
      "l_sp_adj": -0.0042833570,
      "r_sp_int": 0.5436900000,
      "r_sp_adj": -0.0042568340,
      "l_st_int": -0.2066600000,
      "l_st_adj": 0.0013564860,
      "r_st_int": -0.1667500000,
      "r_st_adj": 0.0010643060,
      "l_ht_int": 0.0901600000,
      "l_ht_adj": -0.0010051390,
      "r_ht_int": -0.0284600000,
      "r_ht_adj": -0.0003725110,
      "l_si_int": -0.2563000000,
      "l_si_adj": 0.0020299020,
      "r_si_int": -0.2823100000,
      "r_si_adj": 0.0022469920,
      "l_ki_int": -0.0451700000,
      "l_ki_adj": 0.0008509260,
      "r_ki_int": -0.0563700000,
      "r_ki_adj": 0.0008372230,
      "l_bl_int": 0.2612000000,
      "l_bl_adj": -0.0025746420,
      "r_bl_int": 0.2938000000,
      "r_bl_adj": -0.0029442110,
      "l_pc_int": 0.1189700000,
      "l_pc_adj": -0.0010131210,
      "r_pc_int": -0.0234900000,
      "r_pc_adj": -0.0001459480,
      "l_te_int": -0.1297800000,
      "l_te_adj": 0.0011185660,
      "r_te_int": -0.0887500000,
      "r_te_adj": -0.0002658160,
      "l_lr_int": -0.1565100000,
      "l_lr_adj": 0.0014495230,
      "r_lr_int": -0.1061500000,
      "r_lr_adj": 0.0010185490,
      "l_gb_int": -0.2598900000,
      "l_gb_adj": 0.0011898710,
      "r_gb_int": -0.2364200000,
      "r_gb_adj": 0.0010665450
    };
    f32 = {
      "l_lu_int": 0.2869700000,
      "l_lu_adj": -0.0012435200,
      "r_lu_int": 0.2521300000,
      "r_lu_adj": -0.0010208190,
      "l_li_int": -0.0462800000,
      "l_li_adj": 0.0009548110,
      "r_li_int": -0.0551300000,
      "r_li_adj": 0.0009794440,
      "l_sp_int": 0.5872100000,
      "l_sp_adj": -0.0043760050,
      "r_sp_int": 0.5448000000,
      "r_sp_adj": -0.0043034750,
      "l_st_int": -0.2102800000,
      "l_st_adj": 0.0011638690,
      "r_st_int": -0.1977100000,
      "r_st_adj": 0.0010839580,
      "l_ht_int": 0.1068100000,
      "l_ht_adj": -0.0009084670,
      "r_ht_int": -0.0152300000,
      "r_ht_adj": -0.0003572370,
      "l_si_int": -0.2278000000,
      "l_si_adj": 0.0021503260,
      "r_si_int": -0.2526300000,
      "r_si_adj": 0.0020733430,
      "l_ki_int": -0.0575600000,
      "l_ki_adj": 0.0010338750,
      "r_ki_int": -0.0672900000,
      "r_ki_adj": 0.0009719420,
      "l_bl_int": 0.1204300000,
      "l_bl_adj": -0.0018073310,
      "r_bl_int": 0.1345800000,
      "r_bl_adj": -0.0020171250,
      "l_pc_int": 0.1377500000,
      "l_pc_adj": -0.0008908310,
      "r_pc_int": 0.0361700000,
      "r_pc_adj": -0.0004591020,
      "l_te_int": -0.1440700000,
      "l_te_adj": 0.0011352250,
      "r_te_int": -0.1368100000,
      "r_te_adj": -0.0010208190,
      "l_lr_int": -0.0911200000,
      "l_lr_adj": 0.0008807040,
      "r_lr_int": -0.1036100000,
      "r_lr_adj": 0.0009155450,
      "l_gb_int": -0.3103700000,
      "l_gb_adj": 0.0014520420,
      "r_gb_int": -0.2909900000,
      "r_gb_adj": 0.0013666170
    };
    f43 = {
      "l_lu_int": 0.2533800000,
      "l_lu_adj": -0.0011805510,
      "r_lu_int": 0.2416600000,
      "r_lu_adj": -0.0009539610,
      "l_li_int": 0.0187300000,
      "l_li_adj": 0.0006702250,
      "r_li_int": 0.0510200000,
      "r_li_adj": 0.0003003450,
      "l_sp_int": 0.4743800000,
      "l_sp_adj": -0.0035189690,
      "r_sp_int": 0.4326100000,
      "r_sp_adj": -0.0034622590,
      "l_st_int": -0.1693800000,
      "l_st_adj": 0.0006024520,
      "r_st_int": -0.1603600000,
      "r_st_adj": 0.0004580660,
      "l_ht_int": 0.1006200000,
      "l_ht_adj": -0.0009181160,
      "r_ht_int": -0.0445100000,
      "r_ht_adj": -0.0001063030,
      "l_si_int": -0.1797200000,
      "l_si_adj": 0.0016810080,
      "r_si_int": -0.2034100000,
      "r_si_adj": 0.0015986750,
      "l_ki_int": -0.0582900000,
      "l_ki_adj": 0.0013931420,
      "r_ki_int": -0.0632500000,
      "r_ki_adj": 0.0012148410,
      "l_bl_int": 0.0150400000,
      "l_bl_adj": -0.0010939280,
      "r_bl_int": 0.0393900000,
      "r_bl_adj": -0.0014083530,
      "l_pc_int": 0.1431200000,
      "l_pc_adj": -0.0010205910,
      "r_pc_int": 0.0327500000,
      "r_pc_adj": -0.0004651390,
      "l_te_int": -0.1125000000,
      "l_te_adj": 0.0009880810,
      "r_te_int": -0.0309700000,
      "r_te_adj": -0.0009539610,
      "l_lr_int": -0.1073200000,
      "l_lr_adj": 0.0010771370,
      "r_lr_int": -0.1102300000,
      "r_lr_adj": 0.0010467950,
      "l_gb_int": -0.2864900000,
      "l_gb_adj": 0.0013436040,
      "r_gb_int": -0.2762700000,
      "r_gb_adj": 0.0012797930
    };
    f52 = {
      "l_lu_int": 0.2914000000,
      "l_lu_adj": -0.0013494180,
      "r_lu_int": 0.2755400000,
      "r_lu_adj": -0.0011809670,
      "l_li_int": 0.0931600000,
      "l_li_adj": 0.0001143330,
      "r_li_int": 0.0958500000,
      "r_li_adj": -0.0000374440,
      "l_sp_int": 0.4272500000,
      "l_sp_adj": -0.0034531590,
      "r_sp_int": 0.3921900000,
      "r_sp_adj": -0.0034003240,
      "l_st_int": -0.1725000000,
      "l_st_adj": 0.0007665760,
      "r_st_int": -0.1641400000,
      "r_st_adj": 0.0006591420,
      "l_ht_int": 0.1020300000,
      "l_ht_adj": -0.0009263570,
      "r_ht_int": -0.0276000000,
      "r_ht_adj": -0.0002852760,
      "l_si_int": -0.1859500000,
      "l_si_adj": 0.0016100900,
      "r_si_int": -0.2057400000,
      "r_si_adj": 0.0016558940,
      "l_ki_int": -0.0500700000,
      "l_ki_adj": 0.0013274270,
      "r_ki_int": -0.0534900000,
      "r_ki_adj": 0.0011954390,
      "l_bl_int": -0.0400500000,
      "l_bl_adj": -0.0008616610,
      "r_bl_int": -0.0358600000,
      "r_bl_adj": -0.0010383710,
      "l_pc_int": 0.1459300000,
      "l_pc_adj": -0.0009984800,
      "r_pc_int": 0.0466300000,
      "r_pc_adj": -0.0005497690,
      "l_te_int": -0.1027100000,
      "l_te_adj": 0.0009965270,
      "r_te_int": -0.0541900000,
      "r_te_adj": -0.0011809670,
      "l_lr_int": -0.1027800000,
      "l_lr_adj": 0.0010985670,
      "r_lr_int": -0.1182400000,
      "r_lr_adj": 0.0011442320,
      "l_gb_int": -0.2858600000,
      "l_gb_adj": 0.0014073560,
      "r_gb_int": -0.2708200000,
      "r_gb_adj": 0.0013969650
    };
    f62 = {
      "l_lu_int": 0.3623200000,
      "l_lu_adj": -0.0018036660,
      "r_lu_int": 0.3349600000,
      "r_lu_adj": -0.0015577790,
      "l_li_int": 0.2155400000,
      "l_li_adj": -0.0006197360,
      "r_li_int": 0.2503400000,
      "r_li_adj": -0.0009432680,
      "l_sp_int": 0.2720200000,
      "l_sp_adj": -0.0021593930,
      "r_sp_int": 0.2419700000,
      "r_sp_adj": -0.0021793480,
      "l_st_int": -0.2007700000,
      "l_st_adj": 0.0007695550,
      "r_st_int": -0.2007700000,
      "r_st_adj": 0.0007943080,
      "l_ht_int": 0.0953200000,
      "l_ht_adj": -0.0008411290,
      "r_ht_int": -0.0226000000,
      "r_ht_adj": -0.0002989720,
      "l_si_int": -0.1434200000,
      "l_si_adj": 0.0013905990,
      "r_si_int": -0.1556500000,
      "r_si_adj": 0.0013926110,
      "l_ki_int": -0.0913600000,
      "l_ki_adj": 0.0014362630,
      "r_ki_int": -0.0889000000,
      "r_ki_adj": 0.0013212660,
      "l_bl_int": -0.1221000000,
      "l_bl_adj": -0.0004874510,
      "r_bl_int": -0.1167800000,
      "r_bl_adj": -0.0005740670,
      "l_pc_int": 0.1971700000,
      "l_pc_adj": -0.0012184290,
      "r_pc_int": 0.1001300000,
      "r_pc_adj": -0.0008494390,
      "l_te_int": -0.0341100000,
      "l_te_adj": 0.0005461240,
      "r_te_int": -0.0018000000,
      "r_te_adj": -0.0015577790,
      "l_lr_int": -0.1553200000,
      "l_lr_adj": 0.0013794530,
      "r_lr_int": -0.1433400000,
      "r_lr_adj": 0.0012282070,
      "l_gb_int": -0.3084300000,
      "l_gb_adj": 0.0014197810,
      "r_gb_int": -0.2844100000,
      "r_gb_adj": 0.0013030770
    };
    f150 = {
      "l_lu_int": 0.4023400000,
      "l_lu_adj": -0.0021405270,
      "r_lu_int": 0.3797600000,
      "r_lu_adj": -0.0017838600,
      "l_li_int": 0.3663000000,
      "l_li_adj": -0.0015338850,
      "r_li_int": 0.3736500000,
      "r_li_adj": -0.0017108390,
      "l_sp_int": 0.0081200000,
      "l_sp_adj": -0.0002716020,
      "r_sp_int": -0.0255500000,
      "r_sp_adj": -0.0001723400,
      "l_st_int": -0.1956800000,
      "l_st_adj": 0.0006720730,
      "r_st_int": -0.1721000000,
      "r_st_adj": 0.0005084650,
      "l_ht_int": 0.0710500000,
      "l_ht_adj": -0.0008428520,
      "r_ht_int": -0.0168300000,
      "r_ht_adj": -0.0004586350,
      "l_si_int": -0.0610700000,
      "l_si_adj": 0.0010146300,
      "r_si_int": -0.0529700000,
      "r_si_adj": 0.0008790930,
      "l_ki_int": -0.1221000000,
      "l_ki_adj": 0.0013641450,
      "r_ki_int": -0.0941100000,
      "r_ki_adj": 0.0010333950,
      "l_bl_int": -0.2853200000,
      "l_bl_adj": 0.0007930650,
      "r_bl_int": -0.2633100000,
      "r_bl_adj": 0.0005408790,
      "l_pc_int": 0.1964900000,
      "l_pc_adj": -0.0013708670,
      "r_pc_int": 0.1102200000,
      "r_pc_adj": -0.0009524450,
      "l_te_int": 0.0405900000,
      "l_te_adj": 0.0003925360,
      "r_te_int": 0.1112300000,
      "r_te_adj": -0.0017838600,
      "l_lr_int": -0.1243100000,
      "l_lr_adj": 0.0010950530,
      "r_lr_int": -0.0960900000,
      "r_lr_adj": 0.0008222760,
      "l_gb_int": -0.2786000000,
      "l_gb_adj": 0.0011349440,
      "r_gb_int": -0.2717400000,
      "r_gb_adj": 0.0010915480
    };

    m10 = {
      "l_lu_int": 0.1444400000,
      "l_lu_adj": -0.0005169390,
      "r_lu_int": 0.0620600000,
      "r_lu_adj": -0.0001065440,
      "l_li_int": 0.0794900000,
      "l_li_adj": 0.0000923590,
      "r_li_int": 0.0047600000,
      "r_li_adj": 0.0005776100,
      "l_sp_int": 0.3326800000,
      "l_sp_adj": -0.0027865980,
      "r_sp_int": 0.2874600000,
      "r_sp_adj": -0.0023920320,
      "l_st_int": -0.1532400000,
      "l_st_adj": 0.0006694480,
      "r_st_int": -0.1687900000,
      "r_st_adj": 0.0008046910,
      "l_ht_int": 0.0744800000,
      "l_ht_adj": -0.0004795790,
      "r_ht_int": -0.0570300000,
      "r_ht_adj": 0.0003144250,
      "l_si_int": -0.0780900000,
      "l_si_adj": 0.0009758070,
      "r_si_int": -0.1051400000,
      "r_si_adj": 0.0009225560,
      "l_ki_int": -0.1027100000,
      "l_ki_adj": 0.0010636390,
      "r_ki_int": -0.0043000000,
      "r_ki_adj": 0.0003423140,
      "l_bl_int": 0.2042600000,
      "l_bl_adj": -0.0018413840,
      "r_bl_int": 0.2126300000,
      "r_bl_adj": -0.0018827360,
      "l_pc_int": 0.0479600000,
      "l_pc_adj": -0.0003886720,
      "r_pc_int": -0.0865300000,
      "r_pc_adj": 0.0004319400,
      "l_te_int": 0.0639400000,
      "l_te_adj": -0.0001685600,
      "r_te_int": 0.1653600000,
      "r_te_adj": -0.0001065440,
      "l_lr_int": -0.1862600000,
      "l_lr_adj": 0.0011798490,
      "r_lr_int": -0.2123300000,
      "r_lr_adj": 0.0013693860,
      "l_gb_int": -0.2636500000,
      "l_gb_adj": 0.0013422000,
      "r_gb_int": -0.2614600000,
      "r_gb_adj": 0.0013966650
    };
    m20 = {
      "l_lu_int": 0.1230100000,
      "l_lu_adj": -0.0000322980,
      "r_lu_int": 0.0346200000,
      "r_lu_adj": 0.0003812000,
      "l_li_int": -0.1334100000,
      "l_li_adj": 0.0012587620,
      "r_li_int": -0.1667800000,
      "r_li_adj": 0.0012972340,
      "l_sp_int": 0.3808400000,
      "l_sp_adj": -0.0031237400,
      "r_sp_int": 0.3283200000,
      "r_sp_adj": -0.0028936230,
      "l_st_int": 0.0411000000,
      "l_st_adj": -0.0001764400,
      "r_st_int": -0.0223600000,
      "r_st_adj": 0.0002921060,
      "l_ht_int": -0.0575300000,
      "l_ht_adj": 0.0003946980,
      "r_ht_int": -0.1449000000,
      "r_ht_adj": 0.0006808100,
      "l_si_int": -0.2641600000,
      "l_si_adj": 0.0020512120,
      "r_si_int": -0.2924800000,
      "r_si_adj": 0.0019403850,
      "l_ki_int": 0.2099400000,
      "l_ki_adj": -0.0007102320,
      "r_ki_int": 0.1793900000,
      "r_ki_adj": -0.0004964360,
      "l_bl_int": 0.2087200000,
      "l_bl_adj": -0.0024427880,
      "r_bl_int": 0.1830200000,
      "r_bl_adj": -0.0023436930,
      "l_pc_int": -0.1172900000,
      "l_pc_adj": 0.0009745730,
      "r_pc_int": -0.1711900000,
      "r_pc_adj": 0.0009919830,
      "l_te_int": -0.1108800000,
      "l_te_adj": 0.0006682120,
      "r_te_int": -0.1202600000,
      "r_te_adj": 0.0003812000,
      "l_lr_int": 0.0131900000,
      "l_lr_adj": 0.0003567820,
      "r_lr_int": 0.0377500000,
      "r_lr_adj": 0.0001295930,
      "l_gb_int": -0.0566000000,
      "l_gb_adj": -0.0001328130,
      "r_gb_int": -0.0820400000,
      "r_gb_adj": 0.0001604380
    };
    m32 = {
      "l_lu_int": 0.2208800000,
      "l_lu_adj": -0.0005610120,
      "r_lu_int": 0.1564700000,
      "r_lu_adj": -0.0002500230,
      "l_li_int": -0.1324600000,
      "l_li_adj": 0.0012314010,
      "r_li_int": -0.1246800000,
      "r_li_adj": 0.0008724930,
      "l_sp_int": 0.2954000000,
      "l_sp_adj": -0.0025201710,
      "r_sp_int": 0.2224900000,
      "r_sp_adj": -0.0021745610,
      "l_st_int": -0.0340700000,
      "l_st_adj": 0.0001591290,
      "r_st_int": -0.0159000000,
      "r_st_adj": -0.0000251830,
      "l_ht_int": -0.0207600000,
      "l_ht_adj": 0.0001934840,
      "r_ht_int": -0.0212700000,
      "r_ht_adj": -0.0002856890,
      "l_si_int": -0.2122100000,
      "l_si_adj": 0.0015703330,
      "r_si_int": -0.2628600000,
      "r_si_adj": 0.0018804430,
      "l_ki_int": 0.1788400000,
      "l_ki_adj": -0.0001464840,
      "r_ki_int": 0.1947300000,
      "r_ki_adj": -0.0003782560,
      "l_bl_int": 0.0376300000,
      "l_bl_adj": -0.0013611090,
      "r_bl_int": 0.0260300000,
      "r_bl_adj": -0.0014969950,
      "l_pc_int": -0.0005000000,
      "l_pc_adj": 0.0001722100,
      "r_pc_int": -0.0930500000,
      "r_pc_adj": 0.0005043700,
      "l_te_int": -0.2295600000,
      "l_te_adj": 0.0015368060,
      "r_te_int": -0.2252600000,
      "r_te_adj": -0.0002500230,
      "l_lr_int": 0.1648100000,
      "l_lr_adj": -0.0007158220,
      "r_lr_int": 0.1431400000,
      "r_lr_adj": -0.0006343980,
      "l_gb_int": -0.1225800000,
      "l_gb_adj": 0.0003019170,
      "r_gb_int": -0.1452600000,
      "r_gb_adj": 0.0005197270
    };
    m43 = {
      "l_lu_int": 0.2158600000,
      "l_lu_adj": -0.0004620130,
      "r_lu_int": 0.1672100000,
      "r_lu_adj": -0.0002107890,
      "l_li_int": -0.0675300000,
      "l_li_adj": 0.0007243080,
      "r_li_int": -0.1084000000,
      "r_li_adj": 0.0007816520,
      "l_sp_int": 0.2477800000,
      "l_sp_adj": -0.0023038140,
      "r_sp_int": 0.2205400000,
      "r_sp_adj": -0.0022790510,
      "l_st_int": -0.0186200000,
      "l_st_adj": -0.0000355690,
      "r_st_int": -0.0184700000,
      "r_st_adj": -0.0000298570,
      "l_ht_int": -0.0075800000,
      "l_ht_adj": 0.0000593790,
      "r_ht_int": -0.0749900000,
      "r_ht_adj": 0.0001631940,
      "l_si_int": -0.1702700000,
      "l_si_adj": 0.0012170040,
      "r_si_int": -0.2237600000,
      "r_si_adj": 0.0014042770,
      "l_ki_int": 0.1522900000,
      "l_ki_adj": 0.0000839890,
      "r_ki_int": 0.1627700000,
      "r_ki_adj": 0.0000122410,
      "l_bl_int": -0.0116000000,
      "l_bl_adj": -0.0013211860,
      "r_bl_int": -0.0181600000,
      "r_bl_adj": -0.0013205580,
      "l_pc_int": 0.0015300000,
      "l_pc_adj": 0.0003318620,
      "r_pc_int": -0.0528400000,
      "r_pc_adj": 0.0004419030,
      "l_te_int": -0.1847200000,
      "l_te_adj": 0.0012728640,
      "r_te_int": -0.1675100000,
      "r_te_adj": -0.0002107890,
      "l_lr_int": 0.1078700000,
      "l_lr_adj": -0.0002465890,
      "r_lr_int": 0.1024900000,
      "r_lr_adj": -0.0002759080,
      "l_gb_int": -0.1305500000,
      "l_gb_adj": 0.0003752600,
      "r_gb_int": -0.1233300000,
      "r_gb_adj": 0.0004176240
    };
    m52 = {
      "l_lu_int": 0.2026200000,
      "l_lu_adj": -0.0004489300,
      "r_lu_int": 0.1650000000,
      "r_lu_adj": -0.0001683440,
      "l_li_int": -0.0350100000,
      "l_li_adj": 0.0003603060,
      "r_li_int": -0.0720100000,
      "r_li_adj": 0.0005435290,
      "l_sp_int": 0.2091100000,
      "l_sp_adj": -0.0020098520,
      "r_sp_int": 0.1559800000,
      "r_sp_adj": -0.0016983390,
      "l_st_int": -0.0114200000,
      "l_st_adj": -0.0000176420,
      "r_st_int": 0.0120900000,
      "r_st_adj": -0.0002087420,
      "l_ht_int": -0.0071800000,
      "l_ht_adj": 0.0000403230,
      "r_ht_int": -0.0955800000,
      "r_ht_adj": 0.0002156310,
      "l_si_int": -0.2071900000,
      "l_si_adj": 0.0015578340,
      "r_si_int": -0.2256600000,
      "r_si_adj": 0.0014459190,
      "l_ki_int": 0.1319700000,
      "l_ki_adj": 0.0001520160,
      "r_ki_int": 0.1533500000,
      "r_ki_adj": -0.0000576520,
      "l_bl_int": -0.0105700000,
      "l_bl_adj": -0.0012715410,
      "r_bl_int": -0.0348300000,
      "r_bl_adj": -0.0011783680,
      "l_pc_int": 0.0076400000,
      "l_pc_adj": 0.0003142830,
      "r_pc_int": -0.0458800000,
      "r_pc_adj": 0.0002901270,
      "l_te_int": -0.1592100000,
      "l_te_adj": 0.0010873830,
      "r_te_int": -0.1446300000,
      "r_te_adj": -0.0001683440,
      "l_lr_int": 0.1114800000,
      "l_lr_adj": -0.0002103960,
      "r_lr_int": 0.1017500000,
      "r_lr_adj": -0.0002424650,
      "l_gb_int": -0.1193600000,
      "l_gb_adj": 0.0003681230,
      "r_gb_int": -0.0824800000,
      "r_gb_adj": 0.0001426130
    };
    m62 = {
      "l_lu_int": 0.2268100000,
      "l_lu_adj": -0.0006900860,
      "r_lu_int": 0.2184900000,
      "r_lu_adj": -0.0006978950,
      "l_li_int": 0.0298300000,
      "l_li_adj": 0.0000092640,
      "r_li_int": 0.0145600000,
      "r_li_adj": -0.0000802660,
      "l_sp_int": 0.1059200000,
      "l_sp_adj": -0.0013031510,
      "r_sp_int": 0.1178000000,
      "r_sp_adj": -0.0015337090,
      "l_st_int": 0.0091100000,
      "l_st_adj": -0.0003399290,
      "r_st_int": -0.0123700000,
      "r_st_adj": -0.0000051000,
      "l_ht_int": -0.0190400000,
      "l_ht_adj": 0.0002557320,
      "r_ht_int": -0.0544400000,
      "r_ht_adj": -0.0001394140,
      "l_si_int": -0.2150100000,
      "l_si_adj": 0.0017261460,
      "r_si_int": -0.2010500000,
      "r_si_adj": 0.0012447430,
      "l_ki_int": 0.0867500000,
      "l_ki_adj": 0.0004932940,
      "r_ki_int": 0.1102300000,
      "r_ki_adj": 0.0003860980,
      "l_bl_int": -0.0951500000,
      "l_bl_adj": -0.0007297200,
      "r_bl_int": -0.0828400000,
      "r_bl_adj": -0.0008916160,
      "l_pc_int": 0.0331800000,
      "l_pc_adj": 0.0001875150,
      "r_pc_int": 0.0203800000,
      "r_pc_adj": -0.0001917760,
      "l_te_int": -0.1575100000,
      "l_te_adj": 0.0011778460,
      "r_te_int": -0.1374300000,
      "r_te_adj": -0.0006978950,
      "l_lr_int": 0.0867700000,
      "l_lr_adj": -0.0000376970,
      "r_lr_int": 0.1269900000,
      "r_lr_adj": -0.0003916180,
      "l_gb_int": -0.0978900000,
      "l_gb_adj": 0.0000631590,
      "r_gb_int": -0.1140800000,
      "r_gb_adj": 0.0003918230
    };
    m150 = {
      "l_lu_int": 0.2048800000,
      "l_lu_adj": -0.0004713510,
      "r_lu_int": 0.1787500000,
      "r_lu_adj": -0.0002779700,
      "l_li_int": 0.0518900000,
      "l_li_adj": 0.0001435090,
      "r_li_int": 0.0892000000,
      "r_li_adj": -0.0003955610,
      "l_sp_int": -0.0361500000,
      "l_sp_adj": -0.0005491370,
      "r_sp_int": -0.0159600000,
      "r_sp_adj": -0.0008608030,
      "l_st_int": 0.0234600000,
      "l_st_adj": -0.0002665730,
      "r_st_int": 0.0471400000,
      "r_st_adj": -0.0004501640,
      "l_ht_int": -0.0280500000,
      "l_ht_adj": -0.0000556720,
      "r_ht_int": -0.0886100000,
      "r_ht_adj": -0.0000211010,
      "l_si_int": -0.1620200000,
      "l_si_adj": 0.0011288660,
      "r_si_int": -0.1877800000,
      "r_si_adj": 0.0010745400,
      "l_ki_int": 0.1418400000,
      "l_ki_adj": 0.0001473140,
      "r_ki_int": 0.1595400000,
      "r_ki_adj": -0.0001150540,
      "l_bl_int": -0.2441100000,
      "l_bl_adj": 0.0003616700,
      "r_bl_int": -0.2316600000,
      "r_bl_adj": 0.0002382040,
      "l_pc_int": 0.0585100000,
      "l_pc_adj": -0.0001283430,
      "r_pc_int": -0.0278900000,
      "r_pc_adj": 0.0001263820,
      "l_te_int": -0.0984100000,
      "l_te_adj": 0.0007687000,
      "r_te_int": -0.0656400000,
      "r_te_adj": -0.0002779700,
      "l_lr_int": 0.1450200000,
      "l_lr_adj": -0.0002026680,
      "r_lr_int": 0.1951400000,
      "r_lr_adj": -0.0005599320,
      "l_gb_int": -0.0814700000,
      "l_gb_adj": 0.0001345090,
      "r_gb_int": -0.0276200000,
      "r_gb_adj": -0.0003066050
    };

    calcs = {
      "f10": f10,
      "f20": f20,
      "f32": f32,
      "f43": f43,
      "f52": f52,
      "f62": f62,
      "f150": f150,
      "m10": m10,
      "m20": m20,
      "m32": m32,
      "m43": m43,
      "m52": m52,
      "m62": m62,
      "m150": m150,
    };
  }

  /*
  This is the main method used in this class, which receives a Map of chartValues, the age and gender of the patient,
  and uses those to adjust the raw values recorded from the probe.

  Returns a Map of adjusted values.
 */
  processExamValues(
      Map chartValues, String patientAge, String patientGender) async {
    num graphMean = 0;
    num sum = 0;
    for (int i = 0; i < chartValues.keys.length; i++) {
      sum = sum + chartValues[chartValues.keys.elementAt(i)];
    }
    //graphMean = (sum / 24).floor(); //this matches the way that Xojo did the math.
    graphMean = (sum /
        24); //better precision, but does make the resulting Intelligraph numbers *slightly* different. Discussed
    //this with Adrian on 02/16/2023, and he agreed this was the better way to do it.

    //go fetch all the intelligraph calculation adjustments from the API.
    // SearchResult<IntelliGraphCalc> oldCalcs =
    //     await IntelliGraphCalc().fetchMany(page: 1, pageSize: 1, filters: {
    //   'gender': patientGender,
    //   'age_max': "ge," + patientAge,
    //   'age_min': "le," + patientAge
    // });
    // IntelliGraphCalc igc = oldCalcs.resources.first;
    //
    // return igc;

    double age = double.parse(patientAge);
    String key = patientGender.toLowerCase();
    if (age < 10) {
      key += "10";
    } else if (age < 20) {
      key += "20";
    } else if (age < 32) {
      key += "32";
    } else if (age < 43) {
      key += "43";
    } else if (age < 52) {
      key += "52";
    } else if (age < 62) {
      key += "62";
    } else {
      key += "150";
    }
    Map myCalcs = calcs[key];

    //chartValues[LEFT_ABBREV + "-" + LUNG] = 0.0;
    chartValues[LEFT_ABBREV + "-" + LUNG] = performIntelligraphCalc(
        chartValues[LEFT_ABBREV + "-" + LUNG],
        myCalcs["l_lu_int"],
        myCalcs["l_lu_adj"],
        graphMean);
    chartValues[RIGHT_ABBREV + "-" + LUNG] = performIntelligraphCalc(
        chartValues[RIGHT_ABBREV + "-" + LUNG],
        myCalcs["r_lu_int"],
        myCalcs["r_lu_adj"],
        graphMean);
    chartValues[LEFT_ABBREV + "-" + PERICARDIUM] = performIntelligraphCalc(
        chartValues[LEFT_ABBREV + "-" + PERICARDIUM],
        myCalcs["l_pc_int"],
        myCalcs["l_pc_adj"],
        graphMean);
    chartValues[RIGHT_ABBREV + "-" + PERICARDIUM] = performIntelligraphCalc(
        chartValues[RIGHT_ABBREV + "-" + PERICARDIUM],
        myCalcs["r_pc_int"],
        myCalcs["r_pc_adj"],
        graphMean);
    chartValues[LEFT_ABBREV + "-" + HEART] = performIntelligraphCalc(
        chartValues[LEFT_ABBREV + "-" + HEART],
        myCalcs["l_ht_int"],
        myCalcs["l_ht_adj"],
        graphMean);
    chartValues[RIGHT_ABBREV + "-" + HEART] = performIntelligraphCalc(
        chartValues[RIGHT_ABBREV + "-" + HEART],
        myCalcs["r_ht_int"],
        myCalcs["r_ht_adj"],
        graphMean);
    chartValues[LEFT_ABBREV + "-" + SMALL_INTESTINE] = performIntelligraphCalc(
        chartValues[LEFT_ABBREV + "-" + SMALL_INTESTINE],
        myCalcs["l_si_int"],
        myCalcs["l_si_adj"],
        graphMean);
    chartValues[RIGHT_ABBREV + "-" + SMALL_INTESTINE] = performIntelligraphCalc(
        chartValues[RIGHT_ABBREV + "-" + SMALL_INTESTINE],
        myCalcs["r_si_int"],
        myCalcs["r_si_adj"],
        graphMean);
    chartValues[LEFT_ABBREV + "-" + TRIPLE_ENERGIZER] = performIntelligraphCalc(
        chartValues[LEFT_ABBREV + "-" + TRIPLE_ENERGIZER],
        myCalcs["l_te_int"],
        myCalcs["l_te_adj"],
        graphMean);
    chartValues[RIGHT_ABBREV + "-" + TRIPLE_ENERGIZER] =
        performIntelligraphCalc(
            chartValues[RIGHT_ABBREV + "-" + TRIPLE_ENERGIZER],
            myCalcs["r_te_int"],
            myCalcs["r_te_adj"],
            graphMean);
    chartValues[LEFT_ABBREV + "-" + LARGE_INTESTINE] = performIntelligraphCalc(
        chartValues[LEFT_ABBREV + "-" + LARGE_INTESTINE],
        myCalcs["l_li_int"],
        myCalcs["l_li_adj"],
        graphMean);
    chartValues[RIGHT_ABBREV + "-" + LARGE_INTESTINE] = performIntelligraphCalc(
        chartValues[RIGHT_ABBREV + "-" + LARGE_INTESTINE],
        myCalcs["r_li_int"],
        myCalcs["r_li_adj"],
        graphMean);
    chartValues[LEFT_ABBREV + "-" + SPLEEN] = performIntelligraphCalc(
        chartValues[LEFT_ABBREV + "-" + SPLEEN],
        myCalcs["l_sp_int"],
        myCalcs["l_sp_adj"],
        graphMean);
    chartValues[RIGHT_ABBREV + "-" + SPLEEN] = performIntelligraphCalc(
        chartValues[RIGHT_ABBREV + "-" + SPLEEN],
        myCalcs["r_sp_int"],
        myCalcs["r_sp_adj"],
        graphMean);
    chartValues[LEFT_ABBREV + "-" + LIVER] = performIntelligraphCalc(
        chartValues[LEFT_ABBREV + "-" + LIVER],
        myCalcs["l_lr_int"],
        myCalcs["l_lr_adj"],
        graphMean);
    chartValues[RIGHT_ABBREV + "-" + LIVER] = performIntelligraphCalc(
        chartValues[RIGHT_ABBREV + "-" + LIVER],
        myCalcs["r_lr_int"],
        myCalcs["r_lr_adj"],
        graphMean);
    chartValues[LEFT_ABBREV + "-" + KIDNEY] = performIntelligraphCalc(
        chartValues[LEFT_ABBREV + "-" + KIDNEY],
        myCalcs["l_ki_int"],
        myCalcs["l_ki_adj"],
        graphMean);
    chartValues[RIGHT_ABBREV + "-" + KIDNEY] = performIntelligraphCalc(
        chartValues[RIGHT_ABBREV + "-" + KIDNEY],
        myCalcs["r_ki_int"],
        myCalcs["r_ki_adj"],
        graphMean);
    chartValues[LEFT_ABBREV + "-" + BLADDER] = performIntelligraphCalc(
        chartValues[LEFT_ABBREV + "-" + BLADDER],
        myCalcs["l_bl_int"],
        myCalcs["l_bl_adj"],
        graphMean);
    chartValues[RIGHT_ABBREV + "-" + BLADDER] = performIntelligraphCalc(
        chartValues[RIGHT_ABBREV + "-" + BLADDER],
        myCalcs["r_bl_int"],
        myCalcs["r_bl_adj"],
        graphMean);
    chartValues[LEFT_ABBREV + "-" + GALL_BLADDER] = performIntelligraphCalc(
        chartValues[LEFT_ABBREV + "-" + GALL_BLADDER],
        myCalcs["l_gb_int"],
        myCalcs["l_gb_adj"],
        graphMean);
    chartValues[RIGHT_ABBREV + "-" + GALL_BLADDER] = performIntelligraphCalc(
        chartValues[RIGHT_ABBREV + "-" + GALL_BLADDER],
        myCalcs["r_gb_int"],
        myCalcs["r_gb_adj"],
        graphMean);
    chartValues[LEFT_ABBREV + "-" + STOMACH] = performIntelligraphCalc(
        chartValues[LEFT_ABBREV + "-" + STOMACH],
        myCalcs["l_st_int"],
        myCalcs["l_st_adj"],
        graphMean);
    chartValues[RIGHT_ABBREV + "-" + STOMACH] = performIntelligraphCalc(
        chartValues[RIGHT_ABBREV + "-" + STOMACH],
        myCalcs["r_st_int"],
        myCalcs["r_st_adj"],
        graphMean);

    //print("Hmmm");
    //print(chartValues);
    //now that all the calculations have been done, return the adjusted chartValues.
    return chartValues;
  }

/*
  Adjust a single measurement. The parameters for exactly how much to adjust are passed in:
  rawValue - the initial, raw value as it was read from the probe.
  INTn -
  ADJn -
  graphMean - the mathematical average of the original 24 readings for this exam
 */
  performIntelligraphCalc(num rawValue, num INTn, num ADJn, num graphMean) {
    num retVal = rawValue - ((INTn + (ADJn * graphMean)) * graphMean);
    retVal = retVal.round();
    //make sure the return value lies between 6 and 200, inclusive.
    if (retVal < 6) {
      retVal = 6;
    }
    if (retVal > 200) {
      retVal = 200;
    }
    return retVal.round();
  }
}

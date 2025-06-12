//Meridians can be in 1 of these 4 states.
const String SPLIT = "Split";
const String NORMAL = "Normal";
const String LOW = "Low";
const String HIGH = "High";

const String YIN = "Yin";
const String YANG = "Yang";

const String LEFT = "Left";
const String RIGHT = "Right";
const String BALANCED = "Balanced";

const String UPPER = "Upper";
const String LOWER = "Lower";

const String DEFICIENT = "Deficient";
const String EXCESSIVE = "Excessive";

const String LEFT_ABBREV = "L";
const String RIGHT_ABBREV = "R";

//Official meridian abbreviations for ALL meridian references across the entire application.
const String LUNG = "LU";
const String PERICARDIUM = "PC";
const String HEART = "HT";
const String SMALL_INTESTINE = "SI";
const String TRIPLE_ENERGIZER = "TE";
const String LARGE_INTESTINE = "LI";
const String SPLEEN = "SP";
const String LIVER = "LR";
const String KIDNEY = "KI";
const String BLADDER = "BL";
const String GALL_BLADDER = "GB";
const String STOMACH = "ST";
const String CONCEPTION_VESSEL = "CV";
const String GOVERNER_VESSEL = "GV";

//We use constants for some commonly-referred to items to avoid typos.
const String ARM = "Arm";
const String FEET = "Feet";
const String HAND = "Hand";
const String HEAD = "Head";
const String LEG = "Leg";
const String TORSO = "Torso";

const String SOURCE_POINTS = "Source Points";
const String TSING_POINTS = "Jing-well Points";
const String RYODORAKU_POINTS = "Ryodoraku Points";

const String EMPEROR_FIRE = "Emperor Fire";
const String MINISTER_FIRE = "Minister Fire";
const String METAL = "Metal";
const String WATER = "Water";
const String WOOD = "Wood";
const String EARTH = "Earth";

const String QI_LEVEL = "Qi Level";
const String BELT_BLOCK = "Belt Block";
const String PZ_POINT_ABBREV = "P.Z.";
const String POINTZERO = "Point Zero";
const String AP_POINT_ABBREV = "A.P.";
const String AUTONOMICPOINT = "Autonomic Point";
const String MO_POINT_ABBREV = "M.O.";
const String MASTEROSCILLATION = "Master Oscillation Point";
const String LEFT_RIGHT_IMBALANCE = "Left/Right Imbalance";

const String endOfLine = "\n";

const String SP_TWENTY_ONE_SELF_MASSAGE = "SP 21 self-massage 4 times per day for 30 seconds.";
const TREAT_ALL_JING_WELL_POINTS_WITH_PRESSURE = "Treat all Jing-well points with pressure or laser 2 times per day.";
const CONSIDER_ADHESIVE_TACK_OR_SEED = "Consider adhesive tack or seed on auricular points for 2-3 days.";
const PATIENT_TO_SELF_MASSAGE = "Patient to self massage";
const TWO_TIMES_PER_DAY = "2 x per day.";

//All the different point types:
const String POINT_TYPE_SOURCE = "Source (Yuan)";
const String POINT_TYPE_JING_WELL = "Jing-well";
const String POINT_TYPE_LUO = "Luo (Connecting)";
const String POINT_TYPE_TONIFICATION = "Tonification";
const String POINT_TYPE_SEDATION = "Sedation";
const String POINT_TYPE_ALARM = "Alarm (Mu)";
const String POINT_TYPE_HORARY = "Horary";
const String POINT_TYPE_SPRING = "Ying-spring";
const String POINT_TYPE_STREAM = "Shu-stream";
const String POINT_TYPE_RIVER = "Jing-river";
const String POINT_TYPE_SEA = "He-sea";
const String POINT_TYPE_FIRE = "Fire";
const String POINT_TYPE_EARTH = "Earth";
const String POINT_TYPE_METAL = "Metal";
const String POINT_TYPE_WATER = "Water";
const String POINT_TYPE_WOOD = "Wood";
const String POINT_TYPE_RYODORAKU = "Ryodoraku";
const String POINT_TYPE_ASSOCIATED = "Associated (Shu)";
const String POINT_TYPE_XI = "Xi (Cleft)";
const String POINT_TYPE_LOWER_HE_SEA = "Lower He-Sea";
const String POINT_TYPE_ENTRY = "Entry";
const String POINT_TYPE_EXIT = "Exit";

//allMeridians and meridianIndex are a couple of arrays that need to be here and need to contain the same stuff,
// for legacy reasons. The Treater uses them extensively.
const List<String> allMeridians = [
  LUNG,
  PERICARDIUM,
  HEART,
  SMALL_INTESTINE,
  TRIPLE_ENERGIZER,
  LARGE_INTESTINE,
  SPLEEN,
  LIVER,
  KIDNEY,
  BLADDER,
  GALL_BLADDER,
  STOMACH
];

const List<String> meridianIndex = [
  LUNG,
  PERICARDIUM,
  HEART,
  SMALL_INTESTINE,
  TRIPLE_ENERGIZER,
  LARGE_INTESTINE,
  SPLEEN,
  LIVER,
  KIDNEY,
  BLADDER,
  GALL_BLADDER,
  STOMACH
];

//There are a bunch of other point classifications: associated, source, jing-well, metal, wood, sea, river, etc.
//The following Maps are just these classifications all organized so various parts of the treater can access
//them in a consistent way.

const Map associatedPoints = {
  LUNG: BLADDER + " 13",
  PERICARDIUM: BLADDER + " 14",
  HEART: BLADDER + " 15",
  SMALL_INTESTINE: BLADDER + " 27",
  TRIPLE_ENERGIZER: BLADDER + " 22",
  LARGE_INTESTINE: BLADDER + " 25",
  SPLEEN: BLADDER + " 20",
  LIVER: BLADDER + " 18",
  KIDNEY: BLADDER + " 23",
  BLADDER: BLADDER + " 28",
  GALL_BLADDER: BLADDER + " 19",
  STOMACH: BLADDER + " 21"
};

const Map associatedPointReasons = {
  BLADDER + " 13": LUNG + " + or -",
  BLADDER + " 14": PERICARDIUM + " + or -",
  BLADDER + " 15": HEART + " + or -",
  BLADDER + " 27": SMALL_INTESTINE + " + or -",
  BLADDER + " 22": TRIPLE_ENERGIZER + " + or -",
  BLADDER + " 25": LARGE_INTESTINE + " + or -",
  BLADDER + " 20": SPLEEN + " + or -",
  BLADDER + " 18": LIVER + " + or -",
  BLADDER + " 23": KIDNEY + " + or -",
  BLADDER + " 28": BLADDER + " + or -",
  BLADDER + " 19": GALL_BLADDER + " + or -",
  BLADDER + " 21": STOMACH + " + or -"
};

const Map sourcePoints = {
  LUNG: LUNG + " 9",
  PERICARDIUM: PERICARDIUM + " 7",
  HEART: HEART + " 7",
  SMALL_INTESTINE: SMALL_INTESTINE + " 4",
  TRIPLE_ENERGIZER: TRIPLE_ENERGIZER + " 4",
  LARGE_INTESTINE: LARGE_INTESTINE + " 4",
  SPLEEN: SPLEEN + " 3",
  LIVER: LIVER + " 3",
  KIDNEY: KIDNEY + " 3",
  BLADDER: BLADDER + " 64",
  GALL_BLADDER: GALL_BLADDER + " 40",
  STOMACH: STOMACH + " 42"
};

const Map jingWellPoints = {
  LUNG: LUNG + " 11",
  PERICARDIUM: PERICARDIUM + " 9",
  HEART: HEART + " 9",
  SMALL_INTESTINE: SMALL_INTESTINE + " 1",
  TRIPLE_ENERGIZER: TRIPLE_ENERGIZER + " 1",
  LARGE_INTESTINE: LARGE_INTESTINE + " 1",
  SPLEEN: SPLEEN + " 1",
  LIVER: LIVER + " 1",
  KIDNEY: KIDNEY + "", //special exception for Kidney
  BLADDER: BLADDER + " 67",
  GALL_BLADDER: GALL_BLADDER + " 44",
  STOMACH: STOMACH + " 45"
};

const Map alarmPoints = {
  LUNG: LUNG + " 1",
  PERICARDIUM: CONCEPTION_VESSEL + " 17",
  HEART: CONCEPTION_VESSEL + " 14",
  SMALL_INTESTINE: CONCEPTION_VESSEL + " 4",
  TRIPLE_ENERGIZER: CONCEPTION_VESSEL + " 5",
  LARGE_INTESTINE: STOMACH + " 25",
  SPLEEN: LIVER + " 13",
  LIVER: LIVER + " 14",
  KIDNEY: GALL_BLADDER + " 25",
  BLADDER: CONCEPTION_VESSEL + " 3",
  GALL_BLADDER: GALL_BLADDER + " 24",
  STOMACH: CONCEPTION_VESSEL + " 12"
};

const Map horaryPoints = {
  LUNG: LUNG + " 8",
  PERICARDIUM: PERICARDIUM + " 8",
  HEART: HEART + " 8",
  SMALL_INTESTINE: SMALL_INTESTINE + " 5",
  TRIPLE_ENERGIZER: TRIPLE_ENERGIZER + " 6",
  LARGE_INTESTINE: LARGE_INTESTINE + " 1",
  SPLEEN: SPLEEN + " 3",
  LIVER: LIVER + " 1",
  KIDNEY: KIDNEY + " 10",
  BLADDER: BLADDER + " 66",
  GALL_BLADDER: GALL_BLADDER + " 41",
  STOMACH: STOMACH + " 36"
};

const Map springPoints = {
  LUNG: LUNG + " 10",
  PERICARDIUM: PERICARDIUM + " 8",
  HEART: HEART + " 8",
  SMALL_INTESTINE: SMALL_INTESTINE + " 2",
  TRIPLE_ENERGIZER: TRIPLE_ENERGIZER + " 2",
  LARGE_INTESTINE: LARGE_INTESTINE + " 2",
  SPLEEN: SPLEEN + " 2",
  LIVER: LIVER + " 2",
  KIDNEY: KIDNEY + " 2",
  BLADDER: BLADDER + " 66",
  GALL_BLADDER: GALL_BLADDER + " 43",
  STOMACH: STOMACH + " 44"
};

const Map streamPoints = {
  LUNG: LUNG + " 9",
  PERICARDIUM: PERICARDIUM + " 7",
  HEART: HEART + " 7",
  SMALL_INTESTINE: SMALL_INTESTINE + " 3",
  TRIPLE_ENERGIZER: TRIPLE_ENERGIZER + " 3",
  LARGE_INTESTINE: LARGE_INTESTINE + " 3",
  SPLEEN: SPLEEN + " 3",
  LIVER: LIVER + " 3",
  KIDNEY: KIDNEY + " 3",
  BLADDER: BLADDER + " 65",
  GALL_BLADDER: GALL_BLADDER + " 41",
  STOMACH: STOMACH + " 43"
};

const Map riverPoints = {
  LUNG: LUNG + " 8",
  PERICARDIUM: PERICARDIUM + " 5",
  HEART: HEART + " 4",
  SMALL_INTESTINE: SMALL_INTESTINE + " 5",
  TRIPLE_ENERGIZER: TRIPLE_ENERGIZER + " 6",
  LARGE_INTESTINE: LARGE_INTESTINE + " 5",
  SPLEEN: SPLEEN + " 5",
  LIVER: LIVER + " 4",
  KIDNEY: KIDNEY + " 7",
  BLADDER: BLADDER + " 60",
  GALL_BLADDER: GALL_BLADDER + " 38",
  STOMACH: STOMACH + " 41"
};

const Map seaPoints = {
  LUNG: LUNG + " 5",
  PERICARDIUM: PERICARDIUM + " 3",
  HEART: HEART + " 3",
  SMALL_INTESTINE: SMALL_INTESTINE + " 8",
  TRIPLE_ENERGIZER: TRIPLE_ENERGIZER + " 10",
  LARGE_INTESTINE: LARGE_INTESTINE + " 11",
  SPLEEN: SPLEEN + " 9",
  LIVER: LIVER + " 8",
  KIDNEY: KIDNEY + " 10",
  BLADDER: BLADDER + " 40",
  GALL_BLADDER: GALL_BLADDER + " 34",
  STOMACH: STOMACH + " 36"
};

const Map firePoints = {
  LUNG: LUNG + " 10",
  PERICARDIUM: PERICARDIUM + " 8",
  HEART: HEART + " 8",
  SMALL_INTESTINE: SMALL_INTESTINE + " 5",
  TRIPLE_ENERGIZER: TRIPLE_ENERGIZER + " 6",
  LARGE_INTESTINE: LARGE_INTESTINE + " 5",
  SPLEEN: SPLEEN + " 2",
  LIVER: LIVER + " 2",
  KIDNEY: KIDNEY + " 2",
  BLADDER: BLADDER + " 60",
  GALL_BLADDER: GALL_BLADDER + " 38",
  STOMACH: STOMACH + " 41"
};

const Map earthPoints = {
  LUNG: LUNG + " 9",
  PERICARDIUM: PERICARDIUM + " 7",
  HEART: HEART + " 7",
  SMALL_INTESTINE: SMALL_INTESTINE + " 8",
  TRIPLE_ENERGIZER: TRIPLE_ENERGIZER + " 10",
  LARGE_INTESTINE: LARGE_INTESTINE + " 11",
  SPLEEN: SPLEEN + " 3",
  LIVER: LIVER + " 3",
  KIDNEY: KIDNEY + " 3",
  BLADDER: BLADDER + " 40",
  GALL_BLADDER: GALL_BLADDER + " 34",
  STOMACH: STOMACH + " 36"
};

const Map metalPoints = {
  LUNG: LUNG + " 8",
  PERICARDIUM: PERICARDIUM + " 5",
  HEART: HEART + " 4",
  SMALL_INTESTINE: SMALL_INTESTINE + " 1",
  TRIPLE_ENERGIZER: TRIPLE_ENERGIZER + " 1",
  LARGE_INTESTINE: LARGE_INTESTINE + " 1",
  SPLEEN: SPLEEN + " 5",
  LIVER: LIVER + " 4",
  KIDNEY: KIDNEY + " 7",
  BLADDER: BLADDER + " 67",
  GALL_BLADDER: GALL_BLADDER + " 44",
  STOMACH: STOMACH + " 45"
};

const Map waterPoints = {
  LUNG: LUNG + " 5",
  PERICARDIUM: PERICARDIUM + " 3",
  HEART: HEART + " 3",
  SMALL_INTESTINE: SMALL_INTESTINE + " 2",
  TRIPLE_ENERGIZER: TRIPLE_ENERGIZER + " 2",
  LARGE_INTESTINE: LARGE_INTESTINE + " 2",
  SPLEEN: SPLEEN + " 9",
  LIVER: LIVER + " 8",
  KIDNEY: KIDNEY + " 10",
  BLADDER: BLADDER + " 66",
  GALL_BLADDER: GALL_BLADDER + " 43",
  STOMACH: STOMACH + " 44"
};

const Map woodPoints = {
  LUNG: LUNG + " 11",
  PERICARDIUM: PERICARDIUM + " 9",
  HEART: HEART + " 9",
  SMALL_INTESTINE: SMALL_INTESTINE + " 3",
  TRIPLE_ENERGIZER: TRIPLE_ENERGIZER + " 3",
  LARGE_INTESTINE: LARGE_INTESTINE + " 3",
  SPLEEN: SPLEEN + " 1",
  LIVER: LIVER + " 1",
  KIDNEY: KIDNEY + " 1",
  BLADDER: BLADDER + " 65",
  GALL_BLADDER: GALL_BLADDER + " 41",
  STOMACH: STOMACH + " 43"
};

const Map ryodorakuPoints = {
  LUNG: LUNG + " 9",
  PERICARDIUM: PERICARDIUM + " 7",
  HEART: HEART + " 7",
  SMALL_INTESTINE: SMALL_INTESTINE + " 5",
  TRIPLE_ENERGIZER: TRIPLE_ENERGIZER + " 4",
  LARGE_INTESTINE: LARGE_INTESTINE + " 5",
  SPLEEN: SPLEEN + " 3",
  LIVER: LIVER + " 3",
  KIDNEY: KIDNEY + " 4",
  BLADDER: BLADDER + " 65",
  GALL_BLADDER: GALL_BLADDER + " 40",
  STOMACH: STOMACH + " 42"
};

const Map xiPoints = {
  LUNG: LUNG + " 6",
  PERICARDIUM: PERICARDIUM + " 4",
  HEART: HEART + " 6",
  SMALL_INTESTINE: SMALL_INTESTINE + " 6",
  TRIPLE_ENERGIZER: TRIPLE_ENERGIZER + " 7",
  LARGE_INTESTINE: LARGE_INTESTINE + " 7",
  SPLEEN: SPLEEN + " 8",
  LIVER: LIVER + " 6",
  KIDNEY: KIDNEY + " 5",
  BLADDER: BLADDER + " 63",
  GALL_BLADDER: GALL_BLADDER + " 36",
  STOMACH: STOMACH + " 34"
};

const Map heSeaPoints = {
  SMALL_INTESTINE: STOMACH + " 39",
  TRIPLE_ENERGIZER: BLADDER + " 39",
  LARGE_INTESTINE: STOMACH + " 37",
  BLADDER: BLADDER + " 40",
  GALL_BLADDER: GALL_BLADDER + " 34",
  STOMACH: STOMACH + " 36"
};

const Map entryPoints = {
  LUNG: LUNG + " 1",
  PERICARDIUM: PERICARDIUM + " 1",
  HEART: HEART + " 1",
  SMALL_INTESTINE: SMALL_INTESTINE + " 1",
  TRIPLE_ENERGIZER: TRIPLE_ENERGIZER + " 1",
  LARGE_INTESTINE: LARGE_INTESTINE + " 4",
  SPLEEN: SPLEEN + " 1",
  LIVER: LIVER + " 1",
  KIDNEY: KIDNEY + " 1",
  BLADDER: BLADDER + " 1",
  GALL_BLADDER: GALL_BLADDER + " 1",
  STOMACH: STOMACH + " 1"
};

const Map exitPoints = {
  LUNG: LUNG + " 7",
  PERICARDIUM: PERICARDIUM + " 8",
  HEART: HEART + " 9",
  SMALL_INTESTINE: SMALL_INTESTINE + " 19",
  TRIPLE_ENERGIZER: TRIPLE_ENERGIZER + " 22",
  LARGE_INTESTINE: LARGE_INTESTINE + " 20",
  SPLEEN: SPLEEN + " 21",
  LIVER: LIVER + " 14",
  KIDNEY: KIDNEY + " 22",
  BLADDER: BLADDER + " 67",
  GALL_BLADDER: GALL_BLADDER + " 41",
  STOMACH: STOMACH + " 42"
};

//Luo Points are used to treat "split" meridians. Here's a dictionary of the Luo points indexed by meridian.
const Map luoPoints = {
  LUNG: LUNG + " 7",
  PERICARDIUM: PERICARDIUM + " 6",
  HEART: HEART + " 5",
  SMALL_INTESTINE: SMALL_INTESTINE + " 7",
  TRIPLE_ENERGIZER: TRIPLE_ENERGIZER + " 5",
  LARGE_INTESTINE: LARGE_INTESTINE + " 6",
  SPLEEN: SPLEEN + " 4",
  LIVER: LIVER + " 5",
  KIDNEY: KIDNEY + " 4",
  BLADDER: BLADDER + " 58",
  GALL_BLADDER: GALL_BLADDER + " 37",
  STOMACH: STOMACH + " 40"
};

//sedation Points are used to treat "low" meridians. Here's a dictionary of the sedation points indexed by meridian.
const Map sedationPoints = {
  LUNG: LUNG + " 5",
  PERICARDIUM: PERICARDIUM + " 7",
  HEART: HEART + " 7",
  SMALL_INTESTINE: SMALL_INTESTINE + " 8",
  TRIPLE_ENERGIZER: TRIPLE_ENERGIZER + " 10",
  LARGE_INTESTINE: LARGE_INTESTINE + " 2",
  SPLEEN: SPLEEN + " 5",
  LIVER: LIVER + " 2",
  KIDNEY: KIDNEY + " 1",
  BLADDER: BLADDER + " 65",
  GALL_BLADDER: GALL_BLADDER + " 38",
  STOMACH: STOMACH + " 45"
};

//tonification Points are used to treat "high" meridians. Here's a dictionary of the tonifications points
// indexed by meridian.
const Map tonificationPoints = {
  LUNG: LUNG + " 9",
  PERICARDIUM: PERICARDIUM + " 9",
  HEART: HEART + " 9",
  SMALL_INTESTINE: SMALL_INTESTINE + " 3",
  TRIPLE_ENERGIZER: TRIPLE_ENERGIZER + " 3",
  LARGE_INTESTINE: LARGE_INTESTINE + " 11",
  SPLEEN: SPLEEN + " 2",
  LIVER: LIVER + " 8",
  KIDNEY: KIDNEY + " 7",
  BLADDER: BLADDER + " 67",
  GALL_BLADDER: GALL_BLADDER + " 43",
  STOMACH: STOMACH + " 41"
};

const Map auricularTonificationPoints = {
  LUNG: LUNG + " 9",
  PERICARDIUM: PERICARDIUM + " 9",
  HEART: HEART + " 9",
  SMALL_INTESTINE: SMALL_INTESTINE + " 3",
  TRIPLE_ENERGIZER: TRIPLE_ENERGIZER + " 3",
  LARGE_INTESTINE: LARGE_INTESTINE + " 11",
  SPLEEN: SPLEEN + " 2",
  LIVER: LIVER + " 8",
  KIDNEY: KIDNEY + " 7",
  BLADDER: BLADDER + " 67",
  GALL_BLADDER: GALL_BLADDER + " 43",
  STOMACH: STOMACH + " 41"
};

const Map auricularLuoPoints = {
  LUNG: LUNG + " 7",
  PERICARDIUM: PERICARDIUM + " 6",
  HEART: HEART + " 5",
  SMALL_INTESTINE: SMALL_INTESTINE + " 7",
  TRIPLE_ENERGIZER: TRIPLE_ENERGIZER + " 5",
  LARGE_INTESTINE: LARGE_INTESTINE + " 6",
  SPLEEN: SPLEEN + " 4",
  LIVER: LIVER + " 5",
  KIDNEY: KIDNEY + " 4",
  BLADDER: BLADDER + " 60",
  GALL_BLADDER: GALL_BLADDER + " 37",
  STOMACH: STOMACH + " 40"
};

//It is important to know generally where a point lies on the human body, for organizing treatments in anatomical order.
const Map anatomicalPointLocations = {
  LUNG + " 11": HAND,
  LUNG + " 10": HAND,
  LUNG + " 9": HAND,
  PERICARDIUM + " 9": HAND,
  PERICARDIUM + " 8": HAND,
  PERICARDIUM + " 7": HAND,
  PERICARDIUM: HAND,
  HEART + " 9": HAND,
  HEART + " 8": HAND,
  HEART + " 7": HAND,
  LARGE_INTESTINE + " 1": HAND,
  LARGE_INTESTINE + " 2": HAND,
  LARGE_INTESTINE + " 3": HAND,
  LARGE_INTESTINE + " 4": HAND,
  LARGE_INTESTINE + " 5": HAND,
  TRIPLE_ENERGIZER + " 1": HAND,
  TRIPLE_ENERGIZER + " 2": HAND,
  TRIPLE_ENERGIZER + " 3": HAND,
  TRIPLE_ENERGIZER + " 4": HAND,
  SMALL_INTESTINE + " 1": HAND,
  SMALL_INTESTINE + " 2": HAND,
  SMALL_INTESTINE + " 3": HAND,
  SMALL_INTESTINE + " 4": HAND,
  SMALL_INTESTINE + " 5": HAND,
  SMALL_INTESTINE + " 6": HAND,
  LUNG + " 8": ARM,
  LUNG + " 7": ARM,
  LUNG + " 6": ARM,
  LUNG + " 5": ARM,
  PERICARDIUM + " 6": ARM,
  PERICARDIUM + " 5": ARM,
  PERICARDIUM + " 4": ARM,
  PERICARDIUM + " 3": ARM,
  HEART + " 6": ARM,
  HEART + " 5": ARM,
  HEART + " 4": ARM,
  HEART + " 3": ARM,
  LARGE_INTESTINE + " 6": ARM,
  LARGE_INTESTINE + " 7": ARM,
  LARGE_INTESTINE + " 11": ARM,
  TRIPLE_ENERGIZER + " 5": ARM,
  TRIPLE_ENERGIZER + " 6": ARM,
  TRIPLE_ENERGIZER + " 7": ARM,
  TRIPLE_ENERGIZER + " 10": ARM,
  SMALL_INTESTINE + " 7": ARM,
  SMALL_INTESTINE + " 8": ARM,
  SPLEEN + " 1": FEET,
  SPLEEN + " 2": FEET,
  SPLEEN + " 3": FEET,
  SPLEEN + " 4": FEET,
  SPLEEN + " 5": FEET,
  LIVER + " 1": FEET,
  LIVER + " 2": FEET,
  LIVER + " 3": FEET,
  LIVER + " 4": FEET,
  KIDNEY + " 1": FEET,
  KIDNEY + " 2": FEET,
  KIDNEY + " 3": FEET,
  KIDNEY + " 4": FEET,
  KIDNEY + " 5": FEET,
  KIDNEY + " P": FEET,
  KIDNEY: FEET,
  BLADDER + " 67": FEET,
  BLADDER + " 66": FEET,
  BLADDER + " 65": FEET,
  BLADDER + " 64": FEET,
  BLADDER + " 63": FEET,
  BLADDER + " 60": FEET,
  GALL_BLADDER + " 44": FEET,
  GALL_BLADDER + " 43": FEET,
  GALL_BLADDER + " 41": FEET,
  GALL_BLADDER + " 40": FEET,
  STOMACH + " 45": FEET,
  STOMACH + " 44": FEET,
  STOMACH + " 43": FEET,
  STOMACH + " 42": FEET,
  STOMACH + " 41": FEET,
  SPLEEN + " 8": LEG,
  SPLEEN + " 9": LEG,
  LIVER + " 5": LEG,
  LIVER + " 6": LEG,
  LIVER + " 8": LEG,
  KIDNEY + " 7": LEG,
  KIDNEY + " 10": LEG,
  BLADDER + " 54": LEG,
  BLADDER + " 58": LEG,
  GALL_BLADDER + " 34": LEG,
  GALL_BLADDER + " 36": LEG,
  GALL_BLADDER + " 37": LEG,
  GALL_BLADDER + " 38": LEG,
  STOMACH + " 34": LEG,
  STOMACH + " 36": LEG,
  STOMACH + " 40": LEG,
  CONCEPTION_VESSEL + " 3": TORSO,
  SPLEEN + " 21": TORSO,
  CONCEPTION_VESSEL + " 8": TORSO,
  GALL_BLADDER + " 22": TORSO,
  STOMACH + " 3": HEAD,
  GALL_BLADDER + " 13": HEAD,
};

//Channel divergence treatments are a black magic.
const String LEFT_RIGHT_DIVERGENCE = "L/R Diverg.";
const String EV_DIVERGENCE = "E.V. Diverg.";
const String YY_DIVERGENCE = "Y/Y Diverg.";
const Map channelDivergencesPointReasons = {
  BLADDER + " 13": LEFT_RIGHT_DIVERGENCE,
  BLADDER + " 14": LEFT_RIGHT_DIVERGENCE,
  BLADDER + " 15": LEFT_RIGHT_DIVERGENCE,
  BLADDER + " 27": LEFT_RIGHT_DIVERGENCE,
  BLADDER + " 22": LEFT_RIGHT_DIVERGENCE,
  BLADDER + " 25": LEFT_RIGHT_DIVERGENCE,
  BLADDER + " 20": LEFT_RIGHT_DIVERGENCE,
  BLADDER + " 18": LEFT_RIGHT_DIVERGENCE,
  BLADDER + " 23": LEFT_RIGHT_DIVERGENCE,
  BLADDER + " 28": LEFT_RIGHT_DIVERGENCE,
  BLADDER + " 19": LEFT_RIGHT_DIVERGENCE,
  BLADDER + " 21": LEFT_RIGHT_DIVERGENCE,
  SMALL_INTESTINE + " 3": EV_DIVERGENCE,
  BLADDER + " 62": EV_DIVERGENCE,
  GALL_BLADDER + " 41": EV_DIVERGENCE,
  TRIPLE_ENERGIZER + " 5": EV_DIVERGENCE,
  LARGE_INTESTINE + " 5": EV_DIVERGENCE,
  STOMACH + " 40": EV_DIVERGENCE,
  LUNG + " 7": EV_DIVERGENCE,
  KIDNEY + " 6": EV_DIVERGENCE,
  PERICARDIUM + " 6": EV_DIVERGENCE,
  SPLEEN + " 4": EV_DIVERGENCE,
  LIVER + " 4": EV_DIVERGENCE,
  HEART + " 5": EV_DIVERGENCE,
  KIDNEY + " 10": YY_DIVERGENCE,
  BLADDER + " 40": YY_DIVERGENCE,
  LIVER + " 8": YY_DIVERGENCE,
  GALL_BLADDER + " 34": YY_DIVERGENCE,
  SPLEEN + " 9": YY_DIVERGENCE,
  STOMACH + " 36": YY_DIVERGENCE,
  HEART + " 3": YY_DIVERGENCE,
  SMALL_INTESTINE + " 8": YY_DIVERGENCE,
  PERICARDIUM + " 3": YY_DIVERGENCE,
  TRIPLE_ENERGIZER + " 10": YY_DIVERGENCE,
  LUNG + " 5": YY_DIVERGENCE,
  LARGE_INTESTINE + " 11": YY_DIVERGENCE,
  BLADDER + " 1": YY_DIVERGENCE,
  GALL_BLADDER + " 1": YY_DIVERGENCE,
  STOMACH + " 1": YY_DIVERGENCE,
  BLADDER + " 2": YY_DIVERGENCE,
  BLADDER + " 11": YY_DIVERGENCE,
  GALL_BLADDER + " 12": YY_DIVERGENCE,
  STOMACH + " 12": YY_DIVERGENCE
};

const Map evMeridianTxPoints = {
  SMALL_INTESTINE: SMALL_INTESTINE + " 3",
  BLADDER: BLADDER + " 62",
  GALL_BLADDER: GALL_BLADDER + " 41",
  TRIPLE_ENERGIZER: TRIPLE_ENERGIZER + " 5",
  LARGE_INTESTINE: LARGE_INTESTINE + " 5",
  STOMACH: STOMACH + " 40",
  LUNG: LUNG + " 7",
  KIDNEY: KIDNEY + " 6",
  PERICARDIUM: PERICARDIUM + " 6",
  SPLEEN: SPLEEN + " 4",
  LIVER: LIVER + " 4",
  HEART: HEART + " 5"
};

const Map yyHeSeaTxPoints = {
  LUNG: LUNG + " 5",
  PERICARDIUM: PERICARDIUM + " 3",
  HEART: HEART + " 3",
  SMALL_INTESTINE: SMALL_INTESTINE + " 8",
  TRIPLE_ENERGIZER: TRIPLE_ENERGIZER + " 10",
  LARGE_INTESTINE: LARGE_INTESTINE + " 11",
  SPLEEN: SPLEEN + " 9",
  LIVER: LIVER + " 8",
  KIDNEY: KIDNEY + " 10",
  BLADDER: BLADDER + " 40",
  GALL_BLADDER: GALL_BLADDER + " 34",
  STOMACH: STOMACH + " 36"
};

const Map yyMasterTxPoints = {
  LUNG: STOMACH + " 12",
  PERICARDIUM: GALL_BLADDER + " 12",
  HEART: BLADDER + " 2",
  SMALL_INTESTINE: BLADDER + " 2",
  TRIPLE_ENERGIZER: GALL_BLADDER + " 12",
  LARGE_INTESTINE: STOMACH + " 12",
  SPLEEN: STOMACH + " 2",
  LIVER: GALL_BLADDER + " 1",
  KIDNEY: BLADDER + " 11",
  BLADDER: BLADDER + " 11",
  GALL_BLADDER: GALL_BLADDER + " 1",
  STOMACH: STOMACH + " 2"
};

const Map leftRightDivergencesTxPoints = {
  LUNG: BLADDER + " 13",
  PERICARDIUM: BLADDER + " 14",
  HEART: BLADDER + " 15",
  SMALL_INTESTINE: BLADDER + " 27",
  TRIPLE_ENERGIZER: BLADDER + " 22",
  LARGE_INTESTINE: BLADDER + " 25",
  SPLEEN: BLADDER + " 20",
  LIVER: BLADDER + " 18",
  KIDNEY: BLADDER + " 23",
  BLADDER: BLADDER + " 28",
  GALL_BLADDER: BLADDER + " 19",
  STOMACH: BLADDER + " 21"
};

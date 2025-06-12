/*
A Treatment Recommendation holds 3 lists of treatment points:

  Primary points - these go in the top line of the treatment recommendation pane below a graph, and will always be associated
  with one or more meridians.

  Secondary points - these go in the top line of the treatment recommendation pane below a graph, UNLESS there is already
  a primary point for that meridian. If there is, that point moves down to the second line under the graph. All secondary
  points will also be associated with 1 or more meridians.

  Group points - these go in the top line of a treatment recommendation pane below a graph, but get bumped down to the
   second or third row of the recommendations following these rules:
    If there is already a point for the given meridian(s) in primary, then move to the second row.
    If there is already a point for the given meridian(s) in primary and secondary, move to the third row.
    If there is no meridian(s) associated with this point, it always goes in the third row.

  When displaying these points, items in the first and second row always line up with the meridian(s) they treat. In the
  case that a point treats N meridians, it appears under all of them separately.

  Items in the third row are never lined up with any meridian, regardless of whether they specifically treat any given
  meridians or the graph as a whole.
 */
import "package:acugraph6/core/treatment_derivation/treatment_point.dart";
class TreatmentRecommendation {
  List<TreatmentPoint> primaryPoints = [];
  List<TreatmentPoint> secondaryPoints = [];
  List<TreatmentPoint> groupPoints = [];
}

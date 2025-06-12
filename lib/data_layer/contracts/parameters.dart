/// An interface all data layer parameters must implement.
///
/// Many drivers may require parameters for filtering, sorting, including related resources, etc.
/// This interface defines [build] method, which would be used to add parameters to a driver fetch action.
abstract class Parameters {
  String build();
}

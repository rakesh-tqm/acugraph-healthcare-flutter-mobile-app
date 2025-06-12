import 'package:acugraph6/data_layer/contracts/parameters.dart';
import 'package:acugraph6/data_layer/exceptions/model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'generated/json_api_parameters.g.dart';

/// A parameters subclass for json:api requests
///
/// Contains all possible query parameters in a json:api request
@JsonSerializable()
class JsonApiParameters implements Parameters {
  late int? page = 1;
  late int? pageSize = 15;
  late Map<String, dynamic> filters;
  late Map<String, dynamic> fields;
  late List include;
  late String? sortBy;
  late Map<String, Map<String, String>> includableResources;
  late bool? onlyTrashed;
  late bool? withTrashed;

  JsonApiParameters({
    this.page,
    this.pageSize,
    this.include = const [],
    this.includableResources = const {},
    this.sortBy,
    this.fields = const {},
    this.filters = const {},
    this.onlyTrashed,
    this.withTrashed,
  });

  @override
  String build() {
    String queryParams = "?";

    /// Checks whether an invalid element is included
    final Set invalidIncludes =
        include.toSet().difference(includableResources.keys.toSet());
    if (invalidIncludes.isNotEmpty) {
      throw ParamException('Invalid include parameters: $invalidIncludes');
    } else if (include.isNotEmpty) {
      queryParams = "${queryParams}include=";
      // Sort the include parameters alphabetically to avoid cache duplication in api_calls_registry
      include.sort();
      for (var element in include) {
        if (includableResources[element]?['type'] != 'ignoredInEager') {
          queryParams = "$queryParams$element,";
        }
      }
      queryParams = queryParams.substring(0, queryParams.length - 1);
      queryParams = "$queryParams&";
    }

    if (sortBy != null) {
      queryParams = "${queryParams}sort=$sortBy&";
    }

    if (page != null) {
      queryParams = "${queryParams}page[number]=$page&";
    }

    if (pageSize != null) {
      queryParams = "${queryParams}page[size]=$pageSize&";
    }

    if (fields.isNotEmpty) {
      fields.forEach((resource, fieldsList) {
        queryParams = "${queryParams}fields[$resource]=$fieldsList&";
      });
    }

    if (filters.isNotEmpty) {
      filters.forEach((key, value) {
        queryParams = "${queryParams}filter[$key]=$value&";
      });
    }

    if (onlyTrashed == true) {
      queryParams = "${queryParams}filter[trashed]=1&";
    }

    if (withTrashed == true) {
      queryParams = "${queryParams}filter[with-trashed]=1&";
    }

    queryParams = queryParams.substring(0, queryParams.length - 1);

    return queryParams;
  }

  // Parse the query parameters to be compatible with the SQLite cache driver
  String buildForCache() {
    String query = "";

    /// Checks whether an invalid element is included
    final Set invalidIncludes =
        include.toSet().difference(includableResources.keys.toSet());
    if (invalidIncludes.isNotEmpty) {
      throw ParamException('Invalid include parameters: $invalidIncludes');
    }

    // Add custom Stratus filters if we happen to support caching for fetchMany requests
    if (filters.isNotEmpty) {
      query += "AND ";
      filters.forEach((key, value) {
        query += "$key = '$value' AND ";
      });
      query = query.substring(0, query.length - 5);
    }

    if (withTrashed == true) {
      query += " AND deleted_at IS NOT NULL";
    } else if (withTrashed == false) {
      query += " AND deleted_at IS NULL";
    }

    if (sortBy != null) {
      query +=
          " ORDER BY ${sortBy!.replaceFirst('-', '')} ${sortBy!.startsWith('-') ? 'DESC' : 'ASC'}";
    }

    int pageLimit = pageSize ?? 15;

    query += " LIMIT $pageLimit";

    if (page != null) {
      query += " OFFSET ${(page! - 1) * pageLimit}";
    }

    return query;
  }

  factory JsonApiParameters.fromJson(Map<String, dynamic> json) =>
      _$JsonApiParametersFromJson(json);

  Map<String, dynamic> toJson() => _$JsonApiParametersToJson(this);
}

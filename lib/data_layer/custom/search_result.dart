import 'package:acugraph6/data_layer/contracts/multiple_results.dart';
import 'package:acugraph6/data_layer/custom/json_api_parameters.dart';
import 'package:json_annotation/json_annotation.dart';

part 'generated/search_result.g.dart';

/// A container for iterable [resources] with useful json:api meta data
@JsonSerializable()
class SearchResult<T> implements MultipleResult<T> {
  @JsonKey(ignore: true)
  late List<T> resources;
  late int currentPage;
  late int lastPage;
  late int perPage;
  @JsonKey(name: 'from')
  late int fromResource;
  @JsonKey(name: 'to')
  late int toResource;
  @JsonKey(name: 'total')
  late int totalResources;
  @JsonKey(name: 'parameters')
  late JsonApiParameters queryParameters;

  SearchResult();

  Map<String, dynamic> emptyJson() {
    return {
      'items': [],
      'meta': {
        'currentPage': 0,
        'lastPage': 0,
        'perPage': 0,
        'from': 0,
        'to': 0,
        'total': 0,
        'parameters': {},
        'resources': [],
      },
    };
  }

  factory SearchResult.fromJson(Map<String, dynamic> json) =>
      _$SearchResultFromJson(json);

  Map<String, dynamic> toJson() => _$SearchResultToJson(this);
}

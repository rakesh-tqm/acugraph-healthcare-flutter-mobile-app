import 'dart:io';
import 'package:acugraph6/controllers/auth_controllers.dart';
import 'package:acugraph6/data_layer/contracts/driver.dart';
import 'package:acugraph6/data_layer/custom/json_api_parameters.dart';
import 'package:acugraph6/data_layer/custom/search_result.dart';
import 'package:acugraph6/data_layer/drivers/logger.dart';
import 'package:acugraph6/data_layer/drivers/sqlite.dart';
import 'package:acugraph6/data_layer/exceptions/network.dart';
import 'package:acugraph6/utils/constants.dart';
import 'package:acugraph6/utils/preferences.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:provider/provider.dart';

import '../../main.dart';

// A Driver for http json:api requests
mixin HttpJsonApi implements Driver {
  @JsonKey(ignore: true)
  String namespacePath = 'api/v1';
  @JsonKey(ignore: true)
  Map<String, Map<String, String>> possiblyIncludables = {};

  String _resourceModel = '';

  @JsonKey(ignore: true)
  bool isCacheable = false;

  Future<Map<String, String>> buildJsonApiHeaders() async {
    String? xTenant = await getStringPreferences(preference_x_tenant_key);
    String? authToken =
        await getStringPreferences(preference_user_bearer_token);

    // String? xTenant = 'a';
    // String? authToken = '26|temv0BP1oSvULPazWtYE3vH7qO0G6LTJKHattbQZ';

    Map<String, String> headers = {
      'Content-Type': 'application/vnd.api+json',
      'Accept': 'application/vnd.api+json',
      'X-Acugraph-Token': acugraphToken,
      'X-Tenant': '$xTenant',
      'Authorization': 'Bearer $authToken'
    };

    return headers;
  }

  /// Fetches multiple resources from a given [path], applying some [parameters].
  ///
  /// In http requests, it forms a [fullPath] using a [baseUrl], a [namespacePath] (example: /api/v1) and a given [path],
  /// also applies query parameters sent in [parameters].
  @override
  Future<dynamic> driverFetchMany(
      String path, JsonApiParameters parameters) async {
    _resourceModel = path;
    String? fullPath = "$namespacePath/$path";
    fullPath = "$baseUrl$fullPath${parameters.build()}";
    dynamic response = await _jsonApiRequest('GET', fullPath, null, true);

    return response;
  }

  /// Fetches the resource [identifier] from a given [path], applying some [parameters]
  ///
  /// In http requests, it forms a [fullPath] using a [baseUrl], a [namespacePath] (example: /api/v1) and a given [path],
  /// also applies query parameters sent in [parameters].
  @override
  Future<Map<String, dynamic>> driverFetchById(
      String path, String identifier, JsonApiParameters parameters) async {
    _resourceModel = path;
    if (isCacheable) {
      dynamic cachedResponse = await SqliteCache.fetchById(
          path, identifier, parameters, possiblyIncludables);

      if (cachedResponse != null) {
        // Logger.debug('Parameters: ${parameters.build()}');
        // Logger.debug('Found in cache: $path/$identifier');
        // Logger.debug('Data: $cachedResponse');
        return cachedResponse;
      }
    }

    String? fullPath = "$namespacePath/$path";
    fullPath = "$baseUrl$fullPath/$identifier${parameters.build()}";
    dynamic response = await _jsonApiRequest('GET', fullPath, null);
    // Logger.debug('Found in Stratus: $path/$identifier');
    return response;
  }

  /// Creates a new [path] resource in the driver persistent storage using [data] as resource attributes.
  ///
  /// In json:api requests, data must be a valid json
  @override
  Future<Map<String, dynamic>> driverCreate(String path, dynamic data) async {
    _resourceModel = path;
    Map<String, dynamic> body = _wrapResponseData(path, data);
    String? fullPath = "$namespacePath/$path";
    fullPath = "$baseUrl$fullPath";
    dynamic response = await _jsonApiRequest('POST', fullPath, body);

    return response;
  }

  /// Updates the resource [identifier] from [path] in the driver persistent storage using [data] as resource attributes.
  ///
  /// In json:api requests, data must be a valid json.
  /// If all attributes in [data] are the same as in the json:api server, nothing is updated.
  @override
  Future<Map<String, dynamic>> driverUpdate(
      String path, String identifier, dynamic data) async {
    _resourceModel = path;
    Map<String, dynamic> body = _wrapResponseData(path, data);
    String? fullPath = "$namespacePath/$path";
    fullPath = "$baseUrl$fullPath/$identifier";
    dynamic response = await _jsonApiRequest('PATCH', fullPath, body);

    return response;
  }

  /// Removes the resource [identifier] from [path] from the driver persistent storage.
  ///
  /// An empty response with status code 204 is returned if the element was removed successfully.
  @override
  Future<Map<String, dynamic>> driverDelete(
      String path, String identifier) async {
    _resourceModel = path;
    String? fullPath = "$namespacePath/$path";
    fullPath = "$baseUrl$fullPath/$identifier";
    dynamic response = await _jsonApiRequest('DELETE', fullPath, null);

    return response;
  }

  /// Builds a generic http request specifically formed for json:api requests.
  ///
  /// For requests which use body part, the [body] is sent as json.
  /// [body] has to be set before headers to avoid malformed requests and getting fake 415 responses.
  dynamic _jsonApiRequest(
      String method, String path, Map<String, dynamic>? body,
      [bool includeMetadata = false]) async {
    dynamic responseJson;
    try {
      final request = http.Request(method, Uri.parse(path));
      if (body != null) {
        request.body = jsonEncode(body);
      }
      Map<String, String> headers = await buildJsonApiHeaders();
      request.headers.addAll(headers);

      //debug stmt currently ignores data payload. Just trying to get a sense for how often each request type is fired.
      Logger.debug("http_json_api:: " + method + " -- " + path,
          type: LogType.local,
          localType: LogLocalType.both,
          stack: false,
          report: false);

      http.StreamedResponse response = await request.send();
      //store the original path, hash of the payload, and result in cache...
      responseJson = response;
    } on SocketException {
      throw 'No Internet connection';
    }

    return _inspectJsonApiResponse(responseJson, includeMetadata);
  }

  /// Builds a response according to the [response.statusCode] obtained in the request.
  dynamic _inspectJsonApiResponse(http.StreamedResponse response,
      [bool includeMetadata = false]) async {
    var body = await response.stream.bytesToString();
    // Logger.debug(
    //     'Request to ${response.request?.url} returned with status code ${response.statusCode}',
    //     localType: LogLocalType.console,
    //     stack: false);

    switch (response.statusCode) {
      case 200:
      case 201:
        var responseJson = jsonDecode(body);
        var responseData = _unWrapResponseData(responseJson, includeMetadata);

        if (isCacheable) {
          if (responseJson['data'] is List) {
            for (final item in responseData['items']) {
              SqliteCache.upsert(_resourceModel, item, possiblyIncludables);
            }
          } else {
            SqliteCache.upsert(
                _resourceModel, responseData, possiblyIncludables);
          }
          // Logger.debug(responseJson.toString());
        }
        return responseData;
      case 204:
        return jsonDecode('{}');
      case 400:
        Logger.debug("http_json_api::response 400: " + body,
            type: LogType.local,
            localType: LogLocalType.both,
            stack: true,
            report: false);
        throw BadRequestException(body);
      case 401:
        Logger.debug("http_json_api::response 401: " + body,
            type: LogType.local,
            localType: LogLocalType.both,
            stack: false,
            report: false);
        //this is an unauthorized tenant token. Force them to log out and re-authorize this computer.
        BuildContext? context = navigatorKey.currentContext;
        if (context != null) {
          context.read<AuthController>().logout(
              context: context,
              message: "Your session has expired. Please login again.",
              performApiCall: false);

          Map<String, dynamic> responseData = {};
          if (includeMetadata == true) {
            responseData = SearchResult().emptyJson();
          }

          return responseData;
        } else {
          throw UnauthorisedException(body);
        }
      case 403:
        Logger.debug("http_json_api::response 403: " + body,
            type: LogType.local,
            localType: LogLocalType.both,
            stack: true,
            report: false);
        //this is an unauthorized bearer token. We should send them back to the login screen.
        BuildContext? context = navigatorKey.currentContext;
        if (context != null) {
          context.read<AuthController>().logout(
              context: context,
              message: "Your session has expired. Please login again.",
              performApiCall: false);

          Map<String, dynamic> responseData = {};
          if (includeMetadata == true) {
            responseData = SearchResult().emptyJson();
          }

          return responseData;
        } else {
          throw UnauthorisedException(body);
        }
      case 500:
        Logger.debug("http_json_api::response 500: " + body,
            type: LogType.local,
            localType: LogLocalType.both,
            stack: true,
            report: false);
        throw InternalServerException(body);

      default:
        throw FetchDataException(
            'Error occurred while Communication with Server with StatusCode : ${response.statusCode}. Trace: $body');
    }
  }

  /// Parses a json:api response to match model attributes format.
  dynamic _unWrapResponseData(dynamic json, [bool includeMetadata = false]) {
    dynamic filteredJson;
    // fetchMany
    if (json['data'] is List) {
      filteredJson = {'items': [], 'meta': {}};
      for (final resource in json['data']) {
        dynamic item = _parseAttributes(resource);
        if (json.containsKey('included')) {
          item = _parseFetchManyRelatedResources(item, resource, json);
        }
        filteredJson['items'].add(item);
      }

      if (includeMetadata &&
          filteredJson.containsKey('items') &&
          json.containsKey('meta')) {
        filteredJson['meta'] = json['meta']['page'];
      }
    }
    // fetchMany without results
    else if (json['data'] == null) {
      return json;
    }
    // fetchOne
    else if (json['data'].containsKey('attributes')) {
      filteredJson = _parseAttributes(json['data']);

      if (json.containsKey('included')) {
        filteredJson = _parseRelatedResources(filteredJson, json);
      }
    }

    return filteredJson;
  }

  /// Adds some elements present in the json:api response data to the model attributes list.
  ///
  /// json:api returns the id of the resource outside attributes object.
  /// To make attributes hydration easier, id has to be inside attributes object
  _parseAttributes(dynamic json) {
    var attributes = <String, dynamic>{'id': json['id']};
    if (json.containsKey('attributes')) attributes.addAll(json['attributes']);

    return attributes;
  }

  /// Retrieves included resources and parse them to match model attributes.
  _parseRelatedResources(dynamic filteredJson, dynamic json) {
    dynamic resources = {};
    for (final included in json['included']) {
      final String key = possiblyIncludables.keys.firstWhere(
          (key) => possiblyIncludables[key]!['resource'] == included['type']);
      if (!resources.containsKey(key)) {
        resources[key] = {'data': []};
      }

      resources[key]['data']?.add(included);
    }

    resources.forEach((key, value) {
      filteredJson[key] = _unWrapResponseData(value)['items'];

      if (possiblyIncludables[key]!['type'] == 'belongsTo' ||
          possiblyIncludables[key]!['type'] == 'hasOne') {
        filteredJson[key] = filteredJson[key][0];
      }
    });

    return filteredJson;
  }

  /// Retrieves included resources in fetchMany operations and parse them to match model attributes.
  ///
  /// To avoid having repeated included resources, json:api adds included ones to a separated array of included objects.
  /// This way, if a resource is already included, it won't be included again, saving response sizes.
  /// We have to access every resource's relationships, and find their related resources in the array of included objects.
  _parseFetchManyRelatedResources(
      dynamic item, dynamic resource, dynamic json) {
    if (resource.containsKey('relationships')) {
      resource['relationships'].forEach((key, value) {
        if (value.containsKey('data') && value['data'] != null) {
          value.forEach((key, relationship) {
            dynamic relatedResources = {};
            for (final included in json['included']) {
              // hasOne and belongsTo logic
              if (relationship is Map) {
                relatedResources =
                    _includeResource(included, relationship, relatedResources);
              }
              // hasMany logic
              else {
                for (final related in relationship) {
                  relatedResources =
                      _includeResource(included, related, relatedResources);
                }
              }
            }

            relatedResources.forEach((key, value) {
              item[key] = _unWrapResponseData(value)['items'];

              if (possiblyIncludables[key]!['type'] == 'belongsTo' ||
                  possiblyIncludables[key]!['type'] == 'hasOne') {
                item[key] = item[key][0];
              }
            });
          });
        }
      });
    }
    return item;
  }

  /// Appends an [included] resource to the list of [relatedResources] whether matches with the expected [related] type and id
  _includeResource(
      dynamic included, dynamic related, dynamic relatedResources) {
    if (included['type'] == related['type'] &&
        included['id'] == related['id']) {
      final String key = possiblyIncludables.keys.firstWhere(
          (key) => possiblyIncludables[key]!['resource'] == included['type']);
      if (!relatedResources.containsKey(key)) {
        relatedResources[key] = {'data': []};
      }

      relatedResources[key]['data']?.add(included);
    }

    return relatedResources;
  }

  /// Wraps the model attributes in a format json:apis can understand. The natural opposite to [_unWrapResponseData].
  dynamic _wrapResponseData(String resourceType, dynamic json) {
    dynamic body = {
      "data": {'type': resourceType, 'attributes': json}
    };
    if (json.containsKey('id')) {
      if (json['id'] != null) {
        body['data']['id'] = json['id'];
      }
      body['data']['attributes'].remove('id');
    }

    /// Removes related resources attributes since json:api doesn't support them as attributes and
    /// appends belongsTo relationships to the response data.
    possiblyIncludables.forEach((key, value) {
      if (value['type'] == 'belongsTo' &&
          body['data']['attributes'][key] != null) {
        if (!body['data'].containsKey('relationships')) {
          body['data']['relationships'] = {};
        }

        body['data']['relationships'][key] = {
          "data": {
            "type": value['resource'],
            "id": body['data']['attributes'][key]['id']
          }
        };
      }

      body['data']['attributes'].remove(key);
    });

    return body;
  }
}

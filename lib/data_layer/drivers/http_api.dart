import 'dart:io';
import 'package:acugraph6/data_layer/contracts/driver.dart';
import 'package:acugraph6/data_layer/drivers/logger.dart';
import 'package:acugraph6/data_layer/exceptions/network.dart';
import 'package:acugraph6/utils/constants.dart';
import 'package:acugraph6/utils/preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// A Driver for http requests inside Stratus
///
/// This mixin doesn't implement the base Driver, since every model needs a different set of methods, with different parameters, etc.
mixin HttpApi {
  Future<Map<String, String>> buildHeaders() async {
    String? xTenant = await getStringPreferences(preference_x_tenant_key);
    String? authToken =
        await getStringPreferences(preference_user_bearer_token);

    // String? xTenant = 'a';
    // String? authToken = '26|temv0BP1oSvULPazWtYE3vH7qO0G6LTJKHattbQZ';

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-Tenant': '$xTenant',
      'X-Acugraph-Token': acugraphToken,
      'Authorization': 'Bearer $authToken'
    };

    return headers;
  }

  /// Fetches multiple resources from a given [path], applying some [parameters].
  ///
  /// In http requests, it forms a [fullPath] using a [baseUrl] and a given [path],
  /// also applies query parameters sent in [parameters].
  // @override
  Future<dynamic> get(String path, String parameters) async {
    String fullPath = "$baseUrl$path$parameters";
    Logger.debug("http_api::GET -- " + fullPath,
        type: LogType.local,
        localType: LogLocalType.both,
        stack: false,
        report: false);
    dynamic response = await _request('GET', fullPath, null);

    return response;
  }

  Future<dynamic> post(String path, dynamic data) async {
    String fullPath = "$baseUrl$path";
    //debug stmt currently ignores data payload. Just trying to get a sense for how often each request type is fired.
    Logger.debug("http_api::POST -- " + fullPath,
        type: LogType.local,
        localType: LogLocalType.both,
        stack: false,
        report: false);
    dynamic response = await _request('POST', fullPath, data);

    return response;
  }

  Future<dynamic> patch(String path, dynamic data) async {
    String fullPath = "$baseUrl$path";
    //debug stmt currently ignores data payload. Just trying to get a sense for how often each request type is fired.
    Logger.debug("http_api::PATCH -- " + fullPath,
        type: LogType.local,
        localType: LogLocalType.both,
        stack: false,
        report: false);
    dynamic response = await _request('PATCH', fullPath, data);

    return response;
  }

  /// Builds a generic http request specifically formed for https requests.
  ///
  /// For requests which use body part, the [body] is sent as json.
  /// [body] has to be set before headers to avoid malformed requests and getting fake 415 responses.
  dynamic _request(
      String method, String path, Map<String, dynamic>? body) async {
    dynamic responseJson;
    try {
      final request = http.Request(method, Uri.parse(path));
      if (body != null) {
        request.body = jsonEncode(body);
      }
      Map<String, String> headers = await buildHeaders();
      request.headers.addAll(headers);

      //debug stmt currently ignores data payload and headers. Just trying to get a sense for how often each request type is fired.
      Logger.debug("http_api::_request -- " + method + " -- " + path,
          type: LogType.local,
          localType: LogLocalType.both,
          stack: false,
          report: false);

      http.StreamedResponse response = await request.send();
      responseJson = response;
    } on SocketException {
      throw 'No Internet connection';
    }

    return _inspectResponse(responseJson);
  }

  /// Builds a response according to the [response.statusCode] obtained in the request.
  dynamic _inspectResponse(http.StreamedResponse response) async {
    var body = await response.stream.bytesToString();

    switch (response.statusCode) {
      case 200:
      case 201:
        return jsonDecode(body);
      case 204:
        return jsonDecode('{}');
      case 400:
        throw BadRequestException(body);
      case 401:
        throw UnauthorisedException(body);
      case 403:
        throw UnauthorisedException(body);
      case 500:
        throw InternalServerException(body);

      default:
        throw FetchDataException(
            'Error occurred while Communication with Server with StatusCode : ${response.statusCode}. Trace: $body');
    }
  }
}

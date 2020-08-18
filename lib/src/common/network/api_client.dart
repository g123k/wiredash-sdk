import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart';

class ApiClient {
  ApiClient(
      {@required this.httpClient,
      @required this.projectId,
      @required this.secret,
      String host})
      : host = host ?? _defaultHost;

  static const String _defaultHost = 'https://api.wiredash.io/';

  final Client httpClient;
  final String projectId;
  final String secret;
  final String host;

  Future<Map<String, dynamic>> get(String urlPath) async {
    final url = '$host$urlPath';
    final BaseResponse response = await httpClient.get(url, headers: {
      'project': 'Project $projectId',
      'authorization': 'Secret $secret'
    });
    final responseString = utf8.decode((response as Response).bodyBytes);
    if (response.statusCode != 200) {
      throw Exception('${response.statusCode}:\n$responseString');
    }
    try {
      return json.decode(responseString) as Map<String, dynamic>;
    } catch (exception) {
      throw Exception('${exception.toString()}\n$responseString');
    }
  }

  Future<Map<String, dynamic>> post({
    @required String urlPath,
    @required Map<String, String> arguments,
    List<MultipartFile> files,
  }) async {
    final url = '$host$urlPath';
    BaseResponse response;
    String responseString;

    arguments.removeWhere((key, value) => value == null || value.isEmpty);
    files.removeWhere((element) => element == null);

    if (files != null && files.isNotEmpty) {
      final multipartRequest = MultipartRequest('POST', Uri.parse(url))
        ..fields.addAll(arguments)
        ..files.addAll(files);
      multipartRequest.headers['project'] = 'Project $projectId';
      multipartRequest.headers['authorization'] = 'Secret $secret';

      response = await multipartRequest.send();
      responseString =
          utf8.decode(await (response as StreamedResponse).stream.toBytes());
    } else {
      try {
        response = await httpClient.post(
          url,
          headers: {
            'project': 'Project $projectId',
            'authorization': 'Secret $secret',
            'Content-Type': 'application/json'
          },
          body: json.encode(arguments),
        );

        responseString = utf8.decode((response as Response).bodyBytes);
      } catch (err) {
        rethrow;
      }
    }

    if (response.statusCode != 200) {
      throw Exception('${response.statusCode}:\n$responseString');
    }
    try {
      return json.decode(responseString) as Map<String, dynamic>;
    } catch (exception) {
      throw Exception('${exception.toString()}\n$responseString');
    }
  }
}

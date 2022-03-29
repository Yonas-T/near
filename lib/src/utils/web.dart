import 'package:flutter/foundation.dart';

import '../providers/provider.dart';
import './exponential_backoff.dart';
import 'package:http/http.dart' as http;

const START_WAIT_TIME_MS = 1000;
const BACKOFF_MULTIPLIER = 1.5;
const RETRY_NUMBER = 10;

class ConnectionInfo {
  String url;
  String? user;
  String? password;
  bool? allowInsecure;
  dynamic timeout;
  Map<String, String>? headers;
  ConnectionInfo({
    required this.url,
    this.user,
    this.password,
    this.allowInsecure,
    this.timeout,
    this.headers,
  });

  factory ConnectionInfo.fromJson(Map<String, dynamic> json) {
    return ConnectionInfo(
      url: json['url'],
      user: json.containsKey('user') ? json['user'] : null,
      password: json.containsKey('password') ? json['password'] : null,
      allowInsecure:
          json.containsKey('allowInsecure') ? json['allowInsecure'] : null,
      timeout: json['timeout'],
      headers: json.containsKey('allowInsecure')
          ? json['headers'] as Map<String, String>?
          : null,
    );
  }
}

Future<dynamic> fetchJson(dynamic connectionInfoOrUrl, String? json) async {
  ConnectionInfo connectionInfo = ConnectionInfo(url: '');
  if (connectionInfoOrUrl is String) {
    connectionInfo.url = connectionInfoOrUrl;
  } else {
    connectionInfo = connectionInfoOrUrl as ConnectionInfo;
  }
  print('ccc' +
      connectionInfo.url.toString() +
      connectionInfo.headers.toString());
  var response = await exponentialBackoff(
      START_WAIT_TIME_MS, RETRY_NUMBER, BACKOFF_MULTIPLIER, () async {
    var response;
    try {
      if (json != null) {
        response = await http.post(Uri.parse(connectionInfo.url),
            headers: {
              // ...?connectionInfo.headers,
              'Content-Type': 'application/json'
            },
            body: json);
      } else {
        response = await http.get(
          Uri.parse(connectionInfo.url),
          headers: {
            // ...?connectionInfo.headers,
            'Content-Type': 'application/json'
          },
        );
      }

      // const response = await fetch(connectionInfo.url, {
      //   method: json ? 'POST' : 'GET',
      //   body: json ? json : undefined,
      //   headers: {...connectionInfo.headers, 'Content-Type': 'application/json'}
      // });

      if (response.statusCode == 503) {
        print(
            'Retrying HTTP request for ${connectionInfo.url} as it\'s not available now');
        return null;
      }

      return response;
    } catch (error) {
      if (error.toString().contains('FetchError') ||
          error.toString().contains('Failed to fetch')) {
        if (kDebugMode) {
          print(
              'Retrying HTTP request for ${connectionInfo.url} because of error: $error');
        }
        return null;
      }
      throw Exception(error.toString());
    }
  });
  if (response == null) {
    throw Exception(
        'Exceeded $RETRY_NUMBER attempts for ${connectionInfo.url}.');
  }
  print('ress ' + response.statusCode.toString());
  return await response;
}

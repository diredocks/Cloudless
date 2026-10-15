import 'dart:convert';

import 'package:http/http.dart' as http;

/// Shared plumbing for the app's JSON HTTP clients.
///
/// Owns the (optionally injected) [http.Client] and provides a [getJson] that
/// performs a `GET`, checks the status code and decodes the UTF-8 body,
/// translating each failure into the subclass's own exception type.
abstract class JsonApiClient {
  JsonApiClient({http.Client? client})
    : _client = client ?? http.Client(),
      _ownsClient = client == null;

  final http.Client _client;
  final bool _ownsClient;

  /// The exception raised when the request cannot be sent or read.
  Exception transportFailure();

  /// The exception raised for a non-200 [statusCode].
  Exception badStatus(int statusCode);

  /// The exception raised when the body is not valid JSON.
  Exception invalidBody();

  Future<Object?> getJson(Uri uri) async {
    final http.Response response;
    try {
      response = await _client.get(uri);
    } on Exception {
      throw transportFailure();
    }

    if (response.statusCode != 200) {
      throw badStatus(response.statusCode);
    }

    try {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } on FormatException {
      throw invalidBody();
    }
  }

  void dispose() {
    if (_ownsClient) _client.close();
  }
}

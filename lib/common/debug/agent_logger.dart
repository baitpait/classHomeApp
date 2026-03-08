import 'dart:convert';

import 'package:http/http.dart' as http;

// #region agent log
void agentLog({
  required String location,
  required String message,
  required Map<String, dynamic> data,
  String hypothesisId = '',
  String runId = 'pre-fix-1',
}) {
  final payload = <String, dynamic>{
    'sessionId': 'a3e876',
    'runId': runId,
    'hypothesisId': hypothesisId,
    'location': location,
    'message': message,
    'data': data,
    'timestamp': DateTime.now().millisecondsSinceEpoch,
  };

  http
      .post(
        Uri.parse(
          'http://127.0.0.1:7245/ingest/b3ce8b46-392a-4e14-a8f0-01a59f9d2762',
        ),
        headers: const {
          'Content-Type': 'application/json',
          'X-Debug-Session-Id': 'a3e876',
        },
        body: jsonEncode(payload),
      )
      .catchError((_) {});
}
// #endregion


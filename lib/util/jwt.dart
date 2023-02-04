import 'dart:convert';

String getOrgIdFromJwt(String jwt) {
  var payload = parseJwt(jwt);
  return payload['org_id'];
}

Map<String, dynamic> parseJwt(String token) {
  final parts = token.split('.');
  if (parts.length != 3) {
    throw Exception('invalid token');
  }

  final payload = _decodeBase64(parts[1]);
  final payloadMap = json.decode(payload);
  if (payloadMap is! Map<String, dynamic>) {
    throw Exception('invalid payload');
  }

  return payloadMap;
}

String _decodeBase64(String str) {
  String normalizedSource = base64Url.normalize(str);
  return utf8.decode(base64Url.decode(normalizedSource));
}

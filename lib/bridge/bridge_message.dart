import 'dart:convert';

class BridgeRequest {
  const BridgeRequest({
    required this.id,
    required this.method,
  });

  final String id;
  final String method;

  factory BridgeRequest.parse(String rawMessage) {
    final decoded = jsonDecode(rawMessage);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Request must be an object.');
    }

    final id = decoded['id'];
    final method = decoded['method'];
    if (id is! String ||
        id.trim().isEmpty ||
        method is! String ||
        method.trim().isEmpty) {
      throw const FormatException('Request id and method are required.');
    }

    return BridgeRequest(id: id, method: method);
  }
}

class BridgeResponse {
  const BridgeResponse.success(this.id, this.result)
      : ok = true,
        error = null;

  const BridgeResponse.error(this.id, this.error)
      : ok = false,
        result = null;

  final String id;
  final bool ok;
  final Object? result;
  final String? error;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ok': ok,
      if (result != null) 'result': result,
      if (error != null) 'error': error,
    };
  }
}

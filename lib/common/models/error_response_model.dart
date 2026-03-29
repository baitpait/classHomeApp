
class ErrorResponseModel {
  List<Errors>? _errors;

  List<Errors>? get errors => _errors;

  ErrorResponseModel({
    List<Errors>? errors}){
    _errors = errors;
  }

  ErrorResponseModel.fromJson(dynamic json) {
    if (json == null) {
      return;
    }
    if (json is String) {
      _errors = [Errors(code: '', message: json)];
      return;
    }
    if (json is! Map) {
      return;
    }
    final map = Map<String, dynamic>.from(json);
    _errors = _parseErrorsField(map['errors']);
    if ((_errors == null || _errors!.isEmpty) && map['message'] != null) {
      _errors = [Errors(code: '', message: map['message'].toString())];
    }
  }

  static List<Errors>? _parseErrorsField(dynamic e) {
    if (e == null) {
      return null;
    }
    if (e is String) {
      return [Errors(code: '', message: e)];
    }
    if (e is List) {
      return e.map((v) => Errors.fromJson(v)).toList();
    }
    if (e is Map) {
      final out = <Errors>[];
      e.forEach((k, v) {
        if (v is List) {
          for (final item in v) {
            out.add(Errors(code: k.toString(), message: item.toString()));
          }
        } else if (v is String) {
          out.add(Errors(code: k.toString(), message: v));
        } else if (v != null) {
          out.add(Errors(code: k.toString(), message: v.toString()));
        }
      });
      return out.isEmpty ? null : out;
    }
    return [Errors.fromJson(e)];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    if (_errors != null) {
      map["errors"] = _errors!.map((v) => v.toJson()).toList();
    }
    return map;
  }

}

/// code : "l_name"
/// message : "The last name field is required."

class Errors {
  String? _code;
  String? _message;

  String? get code => _code;
  String? get message => _message;

  Errors({
    String? code,
    String? message}){
    _code = code;
    _message = message;
  }

  Errors.fromJson(dynamic json) {
    if (json is String) {
      _code = '';
      _message = json;
      return;
    }
    if (json is Map) {
      _code = json['code']?.toString();
      _message = json['message']?.toString();
    }
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["code"] = _code;
    map["message"] = _message;
    return map;
  }

}

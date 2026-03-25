import 'package:flutter/material.dart';
import 'package:hexacom_user/common/models/api_response_model.dart';
import 'package:hexacom_user/common/models/response_model.dart';
import 'package:hexacom_user/features/contact_us/domain/reposotories/contact_repo.dart';

class ContactUsProvider with ChangeNotifier {
  final ContactRepo contactRepo;
  ContactUsProvider({required this.contactRepo});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// Field-level validation errors from last 422 response (e.g. name, email, message).
  Map<String, String> _lastFieldErrors = {};
  Map<String, String> get lastFieldErrors => Map.unmodifiable(_lastFieldErrors);

  Future<ResponseModel> sendContactUsMessage({
    required String name,
    required String email,
    String? phone,
    String? subject,
    required String message,
  }) async {
    _isLoading = true;
    _lastFieldErrors = {};
    notifyListeners();
    ApiResponseModel apiResponse = await contactRepo.sendContactUsMessage(
      name: name,
      email: email,
      phone: phone,
      subject: subject,
      message: message,
    );
    _isLoading = false;

    final response = apiResponse.response;
    if (response == null) {
      final err = apiResponse.error?.toString() ?? 'Something went wrong.';
      notifyListeners();
      return ResponseModel(false, err);
    }

    final status = response.statusCode ?? 0;
    final data = response.data is Map ? response.data as Map<String, dynamic> : null;

    if (status == 201) {
      final msg = data?['message']?.toString() ?? 'Message sent successfully.';
      notifyListeners();
      return ResponseModel(true, msg);
    }

    if (status == 429) {
      notifyListeners();
      return ResponseModel(false, 'throttle_message');
    }

    if (status == 422 && data != null) {
      _lastFieldErrors = _parseLaravelValidationErrors(data);
      final firstError = _lastFieldErrors.values.isNotEmpty ? _lastFieldErrors.values.first : (data['message']?.toString() ?? 'Validation failed.');
      notifyListeners();
      return ResponseModel(false, firstError);
    }

    final errMsg = data?['message']?.toString() ?? 'Something went wrong.';
    notifyListeners();
    return ResponseModel(false, errMsg);
  }

  /// Laravel 422 returns errors: { "name": ["Name is required"], "email": ["..."] }.
  static Map<String, String> _parseLaravelValidationErrors(Map<String, dynamic> data) {
    final Map<String, String> out = {};
    final errors = data['errors'];
    if (errors is! Map) return out;
    for (final entry in errors.entries) {
      final key = entry.key.toString();
      final list = entry.value;
      if (list is List && list.isNotEmpty && list.first != null) {
        out[key] = list.first.toString();
      }
    }
    return out;
  }
}

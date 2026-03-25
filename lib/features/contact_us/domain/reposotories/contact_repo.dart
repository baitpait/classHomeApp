import 'package:dio/dio.dart';
import 'package:hexacom_user/data/datasource/remote/dio/dio_client.dart';
import 'package:hexacom_user/data/datasource/remote/exception/api_error_handler.dart';
import 'package:hexacom_user/common/models/api_response_model.dart';
import 'package:hexacom_user/utill/app_constants.dart';

/// Sends contact form data to POST /api/v1/contact-us.
/// Backend expects: name (required), email (required), phone (optional), subject (optional), message (required).
/// Returns 201 on success, 422 on validation error, 429 on throttle.
class ContactRepo {
  final DioClient? dioClient;
  ContactRepo({required this.dioClient});

  Future<ApiResponseModel> sendContactUsMessage({
    required String name,
    required String email,
    String? phone,
    String? subject,
    required String message,
  }) async {
    try {
      final response = await dioClient!.post(
        AppConstants.contactUsUri,
        data: {
          'name': name,
          'email': email,
          if (phone != null && phone.isNotEmpty) 'phone': phone,
          if (subject != null && subject.isNotEmpty) 'subject': subject,
          'message': message,
        },
        options: Options(
          validateStatus: (status) => status != null && status < 500,
        ),
      );
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      if (e is DioException && e.response != null) {
        return ApiResponseModel.withSuccess(e.response);
      }
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }
}

// ignore_for_file: empty_catches

import 'package:dio/dio.dart';
import 'package:hexacom_user/common/models/error_response_model.dart';
import 'package:hexacom_user/common/enums/app_mode.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/main.dart';
import 'package:hexacom_user/utill/app_constants.dart';
import 'package:flutter/foundation.dart';

class ApiErrorHandler {
  static dynamic getMessage(error) {
    dynamic errorDescription = "";
    if (error is Exception) {
      try {
        if (error is DioException) {
          switch (error.type) {
            case DioExceptionType.cancel:
              errorDescription = getTranslated('request_cancelled', Get.context!);
              break;

            case DioExceptionType.receiveTimeout:
              errorDescription = getTranslated('send_timeout_with_server', Get.context!);
              break;
            case DioExceptionType.badResponse:
              final statusCode = error.response?.statusCode;
              switch (statusCode) {
                case 500:
                case 503:
                  errorDescription = getTranslated('server_error', Get.context!);
                  break;
                case 429:
                  errorDescription = getTranslated('too_many_requests', Get.context!);
                  break;
                default:
                  ErrorResponseModel? errorResponse;
                  try {
                    if (error.response?.data != null) {
                      errorResponse = ErrorResponseModel.fromJson(error.response!.data);
                    }
                  }catch(e) {
                    if (kDebugMode) {
                      print('error is -> ${e.toString()}');
                    }
                  }

                  if (errorResponse != null && errorResponse.errors != null && errorResponse.errors!.isNotEmpty) {
                    if (kDebugMode) {
                      print('error----------------== ${errorResponse.errors![0].message} || error: ${error.response!.requestOptions.uri}');
                    }
                    errorDescription = errorResponse.toJson();
                  } else {
                    errorDescription = getTranslated('unavailable_to_process_data', Get.context!);
                  }
              }
              break;
            case DioExceptionType.sendTimeout:
              errorDescription = getTranslated('send_timeout_with_server', Get.context!);
              break;
            case DioExceptionType.connectionTimeout:
              errorDescription = getTranslated('send_timeout_with_server', Get.context!);
              break;
            case DioExceptionType.badCertificate:
              errorDescription = getTranslated('incorrect_certificate', Get.context!);
              break;
            case DioExceptionType.connectionError:
              errorDescription = '${getTranslated('unavailable_to_process_data', Get.context!)} ${ AppMode.demo == AppConstants.appMode
                  ? error.response?.requestOptions.path  : error.response?.statusCode ?? 'connection_error'}' ;
              break;
            case DioExceptionType.unknown:
              debugPrint('error----------------== ${error.response?.requestOptions.path} || ${error.response?.statusCode} ${error.response?.data}');

              errorDescription = getTranslated('unavailable_to_process_data', Get.context!);
              break;
          }
        } else {
          errorDescription = "Unexpected error occured";
        }
      } on FormatException catch (e) {
        errorDescription = e.toString();
      }
    } else {
      errorDescription = "is not a subtype of exception";
    }
    return errorDescription;
  }
}

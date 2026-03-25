import 'package:hexacom_user/common/models/api_response_model.dart';
import 'package:hexacom_user/common/models/error_response_model.dart';
import 'package:hexacom_user/features/auth/domain/enums/from_page_enum.dart';
import 'package:hexacom_user/main.dart';

import 'package:hexacom_user/helper/custom_snackbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:hexacom_user/features/splash/providers/splash_provider.dart';
import 'package:hexacom_user/utill/routes.dart';
import 'package:provider/provider.dart';


class ApiCheckerHelper {
  static void checkApi(ApiResponseModel apiResponse) {
    final ErrorResponseModel error = getError(apiResponse);
    final Errors firstError = (error.errors != null && error.errors!.isNotEmpty)
        ? error.errors!.first
        : Errors(code: '', message: null);

    final String code = firstError.code ?? '';
    final String? message = firstError.message;

    //config-missing
    if ((code == '401' || code == 'auth-001')
        && ModalRoute.of(Get.context!)?.settings.name != RouteHelper.getLoginRoute(Get.context!, FromPage.mainRoute.name)) {
      Provider.of<SplashProvider>(Get.context!, listen: false).removeSharedData();

      if( ModalRoute.of(Get.context!)!.settings.name != RouteHelper.getLoginRoute(Get.context!, FromPage.mainRoute.name)) {
        Navigator.pushNamedAndRemoveUntil(Get.context!, RouteHelper.getLoginRoute(Get.context!, FromPage.mainRoute.name), (route) => false);
      }
    }else {
      final fallback = 'unavailable_to_process_data';
      showCustomSnackBar(
        message ?? fallback,
        Get.context!,
      );
    }
  }

  static ErrorResponseModel getError(ApiResponseModel apiResponse){
    ErrorResponseModel error;

    try{
      final dynamic body = apiResponse.response != null
          ? (apiResponse.response as dynamic).data
          : apiResponse.error;

      if (body is ErrorResponseModel) {
        error = body;
      } else {
        error = ErrorResponseModel.fromJson(body);
      }
    }catch(e){
      if(apiResponse.error is String){
        error = ErrorResponseModel(errors: [Errors(code: '', message: apiResponse.error.toString())]);
      }else{
        error = ErrorResponseModel(errors: [Errors(code: '', message: 'unavailable_to_process_data')]);
      }
    }
    return error;
  }
}
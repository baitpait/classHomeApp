import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:hexacom_user/common/models/config_model.dart';
import 'package:hexacom_user/common/models/error_response_model.dart';
import 'package:hexacom_user/features/auth/domain/enums/from_page_enum.dart';
import 'package:hexacom_user/features/auth/domain/enums/verification_type_enum.dart';
import 'package:hexacom_user/common/models/api_response_model.dart';
import 'package:hexacom_user/common/models/response_model.dart';
import 'package:hexacom_user/features/auth/domain/reposotories/auth_repo.dart';
import 'package:hexacom_user/features/profile/providers/profile_provider.dart';
import 'package:hexacom_user/features/profile/screens/profile_screen.dart';
import 'package:hexacom_user/helper/auth_helper.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/main.dart';
import 'package:hexacom_user/features/splash/providers/splash_provider.dart';
import 'package:flutter/material.dart';
import 'package:hexacom_user/utill/feature_flags.dart';
import 'package:hexacom_user/utill/routes.dart';
import 'package:provider/provider.dart';
import '../../../helper/api_checker_helper.dart';
import '../../../helper/custom_snackbar_helper.dart';

class VerificationProvider with ChangeNotifier {
  final AuthRepo authRepo;

  VerificationProvider({required this.authRepo});

  bool _isLoading = false;
  bool _isEnableVerificationCode = false;
  String? _verificationMsg = '';
  String _verificationCode = '';
  Timer? _timer;
  int? currentTime;

  bool get isLoading => _isLoading;
  String? get verificationMessage => _verificationMsg;
  String get verificationCode => _verificationCode;
  bool get isEnableVerificationCode => _isEnableVerificationCode;

  set setVerificationMessage(String value)=> _verificationMsg = value;
  set setVerificationCode(String value)=> _verificationCode = value;

  Future<ResponseModel> verifyToken(String? email) async {
    _isLoading = true;
    notifyListeners();

    ApiResponseModel? apiResponse = await authRepo.verifyToken(email, _verificationCode);

    ResponseModel responseModel;

    if (apiResponse.response?.statusCode == 200) {
      responseModel = ResponseModel(true, apiResponse.response?.data["message"]);
    } else {
      responseModel = ResponseModel(false, ApiCheckerHelper.getError(apiResponse).errors?.first.message);
    }

    _isLoading = false;
    notifyListeners();

    return responseModel;
  }


  Future<void> sendVerificationCode(BuildContext buildContext, ConfigModel config, String userInput, {required String type, required String fromPage, String navigatePage = ''}) async {
    _isLoading = true;
    if(fromPage == FromPage.profile.name){
      showLoader(buildContext);
    }
    notifyListeners();

    if(AuthHelper.isCustomerVerificationEnable(config)){
      if(type == VerificationType.email.name && AuthHelper.isEmailVerificationEnable(config)){
        await checkEmail(buildContext, userInput, fromPage, navigatePage: navigatePage);
      }else if(type == VerificationType.phone.name && AuthHelper.isFirebaseVerificationEnable(config)){
        await firebaseVerifyPhoneNumber(buildContext, userInput, fromPage, navigatePage: navigatePage);
      }else if(type == VerificationType.phone.name && AuthHelper.isPhoneVerificationEnable(config)){
        await checkPhone(buildContext, userInput, fromPage, navigatePage: navigatePage);
      }
    }
  }

  Future<ResponseModel> checkEmail(BuildContext buildContext, String email, String fromPage, {String navigatePage = ''}) async {
    _isLoading = true;
    notifyListeners();
    ApiResponseModel apiResponse = await authRepo.sendVerificationCode(email, VerificationType.email);
    ResponseModel responseModel;
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      responseModel = ResponseModel(true, apiResponse.response!.data["token"]);


      bool isReplaceRoute = GoRouter.of(Get.context!).routeInformationProvider.value.uri.path == RouteHelper.verify;


      if(isReplaceRoute){
        if(fromPage == FromPage.profile.name){
          Navigator.pop(buildContext);
        }
        RouteHelper.getVerifyRoute(buildContext, email, fromPage, navigatePage: navigatePage,  action: RouteAction.pushReplacement);
      }else{
        if(fromPage == FromPage.profile.name){
          Navigator.pop(buildContext);
        }
        RouteHelper.getVerifyRoute(buildContext, email, fromPage, navigatePage: navigatePage, action: RouteAction.push);
      }

    } else {
      String? errorMessage = ApiCheckerHelper.getError(apiResponse).errors?.first.message.toString();
      showCustomSnackBar(errorMessage, buildContext);
      responseModel = ResponseModel(false, errorMessage);

    }
    _isLoading = false;
    notifyListeners();
    return responseModel;
  }

  Future<ResponseModel> checkPhone(BuildContext buildContext, String phone, String fromPage, {String navigatePage = ''}) async {
    _isLoading = true;
    notifyListeners();
    ApiResponseModel apiResponse = await authRepo.sendVerificationCode(phone, VerificationType.phone);
    ResponseModel responseModel;
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      responseModel = ResponseModel(true, apiResponse.response!.data["token"]);


      bool isReplaceRoute = GoRouter.of(Get.context!).routeInformationProvider.value.uri.path == RouteHelper.verify;

      if(isReplaceRoute){
        if(fromPage == FromPage.profile.name){
          Navigator.pop(buildContext);
        }
        RouteHelper.getVerifyRoute(buildContext, phone, fromPage, navigatePage: navigatePage, action: RouteAction.pushReplacement);
      }else{
        if(fromPage == FromPage.profile.name){
          Navigator.pop(buildContext);
        }
        RouteHelper.getVerifyRoute(buildContext, phone, fromPage, navigatePage: navigatePage, action: RouteAction.push);
      }

    } else {
      String errorMessage = ApiCheckerHelper.getError(apiResponse).errors![0].message ?? '';
      showCustomSnackBar(errorMessage, buildContext);
      responseModel = ResponseModel(false, errorMessage);
    }
    _isLoading = false;

    notifyListeners();
    return responseModel;
  }

  Future<ResponseModel> verifyVerificationCode(BuildContext context, {required String emailOrPhone, required VerificationType verificationType}) async {

    _isLoading = true;
    _verificationMsg = '';
    notifyListeners();

    ApiResponseModel? apiResponse = await authRepo.verifyVerificationCode(emailOrPhone, _verificationCode, verificationType);
    ResponseModel responseModel;

    if (apiResponse.response?.statusCode == 200) {
      String token = apiResponse.response?.data["token"];
      authRepo.saveUserToken(token);
      await authRepo.updateToken();

      responseModel = ResponseModel(true, apiResponse.response?.data["message"]);

    } else {
      _verificationMsg = ApiCheckerHelper.getError(apiResponse).errors?.first.message;

      responseModel = ResponseModel(false, _verificationMsg);
      showCustomSnackBar(_verificationMsg, context);
    }

    _isLoading = false;
    notifyListeners();
    return responseModel;
  }

  Future<(ResponseModel?, String?)> verifyPhoneForOtp(String phone, BuildContext context) async {
    _isLoading = true;
    if(phone.contains('++')) {
      phone = phone.replaceAll('++', '+');
    }
    _verificationMsg = '';


    notifyListeners();
    ApiResponseModel apiResponse = await authRepo.verifyOtp(phone, _verificationCode);
    ResponseModel? responseModel;
    String? token;
    String? tempToken;
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {

      Map map = apiResponse.response!.data;
      if(map.containsKey('temporary_token')) {
        tempToken = map["temporary_token"];
      }else if(map.containsKey('token')){
        token = map["token"];
      }

      if(token != null){
        authRepo.saveUserToken(token);
        await authRepo.updateToken();
        final ProfileProvider profileProvider = Provider.of<ProfileProvider>(Get.context!, listen: false);
        profileProvider.getUserInfo();
        responseModel = ResponseModel(true, 'verification');
      }else if(tempToken != null){
        responseModel = ResponseModel(true, 'verification');
      }
    } else {
      _verificationMsg = ApiCheckerHelper.getError(apiResponse).errors![0].message ?? '';
      showCustomSnackBar(_verificationMsg, context);
      responseModel = ResponseModel(false, _verificationMsg);
    }
    _isLoading = false;
    notifyListeners();
    return (responseModel, tempToken);
  }

  Future<ResponseModel> verifyProfileInfo(BuildContext context, String userInput, String type, String? session) async {
    _isLoading = true;
    notifyListeners();
    if(session?.isNotEmpty ?? false){
      type = 'firebase';
    }
    ApiResponseModel apiResponse = await authRepo.verifyProfileInfo(userInput, _verificationCode, type, session);
    ResponseModel? responseModel;

    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {

      Map map = apiResponse.response!.data;

      final ProfileProvider profileProvider = Provider.of<ProfileProvider>(Get.context!, listen: false);
      profileProvider.getUserInfo();
      showCustomSnackBar(apiResponse.response!.data['message'], isError: false, context);
      responseModel = ResponseModel(true, 'verification');

    } else {
      String? error = ErrorResponseModel.fromJson(apiResponse.error).errors![0].message;
      showCustomSnackBar(error ?? '', context);
      responseModel = ResponseModel(false, _verificationMsg);
    }
    _isLoading = false;
    notifyListeners();
    return responseModel;
  }

  Future<void> firebaseVerifyPhoneNumber(BuildContext buildContext, String phoneNumber, String fromPage, {bool isForgetPassword = false, String navigatePage = ''})async {
    if (FeatureFlags.disableFirebaseAuth) {
      _isLoading = false;
      notifyListeners();
      return;
    }
    _isLoading = true;
    notifyListeners();

    FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) {},
      verificationFailed: (FirebaseAuthException e) {
        if(Navigator.canPop(buildContext)) {
          if(!(GoRouter.of(buildContext).routeInformationProvider.value.uri.path == RouteHelper.profileScreen) && !(GoRouter.of(buildContext).routeInformationProvider.value.uri.path == RouteHelper.sendOtp)){
            Navigator.pop(Get.context!);
          }
        }
        _isLoading = false;
        if(fromPage == FromPage.profile.name){
          Navigator.pop(buildContext);
        }
        notifyListeners();
        showCustomSnackBar(getTranslated('${e.message}', buildContext), buildContext);
      },
      codeSent: (String vId, int? resendToken) {

        bool isReplaceRoute = GoRouter.of(buildContext).routeInformationProvider.value.uri.path == RouteHelper.verify;


        if(fromPage == FromPage.profile.name){
          Navigator.pop(buildContext);
        }

        _isLoading = false;
        notifyListeners();

        if(fromPage == FromPage.profile.name){
          if(isReplaceRoute){
            RouteHelper.getVerifyRoute(buildContext, phoneNumber, fromPage, session: vId, action: RouteAction.pushReplacement);
          }else{
            RouteHelper.getVerifyRoute(buildContext, phoneNumber, fromPage, session: vId, action: RouteAction.push);
          }
        }else{
          if(isReplaceRoute){
            RouteHelper.getVerifyRoute(buildContext, phoneNumber, isForgetPassword ? FromPage.forget.name : fromPage, navigatePage: navigatePage, session: vId, action: RouteAction.pushReplacement);
          }else{
            RouteHelper.getVerifyRoute(buildContext, phoneNumber, isForgetPassword ? FromPage.forget.name : fromPage, navigatePage: navigatePage, session: vId, action: RouteAction.push);
          }
        }
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  void updateVerificationCode(String query, int queryLen, {bool isUpdate = true}) {
    if (query.length == queryLen) {
      _isEnableVerificationCode = true;
    } else {
      _isEnableVerificationCode = false;
    }
    _verificationCode = query;
    if(isUpdate) {
      notifyListeners();
    }
  }



  void startVerifyTimer(){

    _timer?.cancel();
    currentTime = Provider.of<SplashProvider>(Get.context!, listen: false).configModel?.otpResendTime ?? 0;

    _timer =  Timer.periodic(const Duration(seconds: 1), (_){

      if(currentTime! > 0) {
        currentTime = currentTime! - 1;

      }else{
        _timer?.cancel();

      }

      notifyListeners();
    });

  }






}

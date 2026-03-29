import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hexacom_user/common/enums/data_source_enum.dart';
import 'package:hexacom_user/common/models/response_model.dart';
import 'package:hexacom_user/common/models/userinfo_model.dart';
import 'package:hexacom_user/data/datasource/local/cache_response.dart';
import 'package:hexacom_user/features/profile/domain/reposotories/profile_repo.dart';
import 'package:hexacom_user/helper/data_sync_provider.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class ProfileProvider with ChangeNotifier {
  final ProfileRepo? profileRepo;
  ProfileProvider({required this.profileRepo});


  UserInfoModel? _userInfoModel;
  UserInfoModel? get userInfoModel => _userInfoModel;
  String? _countryCode;


  bool _isLoading = false;
  bool get isLoading => _isLoading;
  String? get countryCode => _countryCode;



  Future<void> getUserInfo() async{
    DataSyncProvider.fetchAndSyncData(
      fetchFromLocal: ()=> profileRepo!.getUserInfo<CacheResponseData>(source: DataSourceEnum.local),
      fetchFromClient: ()=> profileRepo!.getUserInfo(source: DataSourceEnum.client),
      onResponse: (data, _){
        _userInfoModel = UserInfoModel.fromJson(data);
        profileRepo!.clearUserId().then((value) {
          saveUserId('${_userInfoModel!.id}');
        });

        notifyListeners();
      },
    );

  }



  Future<ResponseModel> updateUserInfo(UserInfoModel updateUserModel, String password, XFile?  file, String token) async {
    _isLoading = true;
    notifyListeners();

    late ResponseModel responseModel;
    try {
      final http.StreamedResponse response =
          await profileRepo!.updateProfile(updateUserModel, password, file, token);
      final body = await response.stream.bytesToString();
      dynamic decoded;
      try {
        decoded = body.isNotEmpty ? jsonDecode(body) : null;
      } catch (_) {
        decoded = null;
      }

      if (response.statusCode == 200) {
        if (decoded is Map) {
          final map = Map<String, dynamic>.from(decoded);
          final message = map['message']?.toString();
          _userInfoModel = updateUserModel;
          responseModel = ResponseModel(true, message);
        } else {
          _userInfoModel = updateUserModel;
          responseModel = ResponseModel(true, null);
        }
      } else {
        var err = 'Request failed (${response.statusCode})';
        if (decoded is Map) {
          final map = Map<String, dynamic>.from(decoded);
          final errors = map['errors'];
          if (errors is List &&
              errors.isNotEmpty &&
              errors.first is Map &&
              (errors.first as Map)['message'] != null) {
            err = (errors.first as Map)['message'].toString();
          } else if (map['message'] != null) {
            err = map['message'].toString();
          }
        }
        responseModel = ResponseModel(false, err);
      }
    } catch (e) {
      responseModel = ResponseModel(false, e.toString());
    }

    _isLoading = false;
    notifyListeners();
    return responseModel;
  }

  void saveUserId(String userId) => profileRepo!.saveUserID(userId);

  String getUserId()=> profileRepo!.getUserId();

  void setCountryCode (String countryCode, {bool isUpdate = true}){
    if(!countryCode.contains('+')){
      countryCode = "+$countryCode";
    }
    _countryCode = countryCode;
    if(isUpdate){
      notifyListeners();
    }
  }

  void resetUserProfile ({bool isUpdate = true}){
    if(_userInfoModel != null){
      _userInfoModel = null;
      if(isUpdate){
        notifyListeners();
      }
    }
  }
}

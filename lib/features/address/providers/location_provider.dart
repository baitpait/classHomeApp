import 'package:hexacom_user/common/models/address_model.dart';
import 'package:hexacom_user/common/models/api_response_model.dart';
import 'package:hexacom_user/common/models/response_model.dart';
import 'package:hexacom_user/features/address/domain/models/place_details_model.dart';
import 'package:hexacom_user/features/address/domain/reposotories/location_repo.dart';
import 'package:hexacom_user/helper/api_checker_helper.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationProvider with ChangeNotifier {
  final SharedPreferences sharedPreferences;
  final LocationRepo locationRepo;

  LocationProvider({required this.sharedPreferences, required this.locationRepo});

  bool _isLoading = false;
  String? _address;
  String? _pickAddress = '';
  String? _pickedAddressLatitude;
  String? _pickedAddressLongitude;
  List<AddressModel>? _addressList;

  bool get isLoading => _isLoading;
  String? get address => _address;
  String? get pickAddress => _pickAddress;
  String? get pickedAddressLatitude => _pickedAddressLatitude;
  String? get pickedAddressLongitude => _pickedAddressLongitude;

  set setAddress(String? addressValue) => _address = addressValue;

  void setPickedAddressLatLon(String? lat, String? lon, {bool isUpdate = true}) {
    _pickedAddressLatitude = lat;
    _pickedAddressLongitude = lon;
    if (isUpdate) {
      notifyListeners();
    }
  }

  void setLocationData(bool isUpdate) {
    _address = _pickAddress;
    if (isUpdate) {
      notifyListeners();
    }
  }

  void setPickData() {
    _pickAddress ??= _address;
  }

  Future<ResponseModel?> initAddressList() async {
    ResponseModel? responseModel;
    _addressList = null;
    ApiResponseModel apiResponse = await locationRepo.getAllAddress();
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      _addressList = [];
      apiResponse.response!.data.forEach((address) => _addressList!.add(AddressModel.fromJson(address)));
      responseModel = ResponseModel(true, 'successful');
    } else {
      _addressList = [];
      ApiCheckerHelper.checkApi(apiResponse);
    }
    notifyListeners();
    return responseModel;
  }
}


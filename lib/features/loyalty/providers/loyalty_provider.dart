import 'package:flutter/material.dart';
import 'package:hexacom_user/common/models/api_response_model.dart';
import 'package:hexacom_user/features/loyalty/domain/models/loyalty_log_model.dart';
import 'package:hexacom_user/features/loyalty/domain/models/loyalty_summary_model.dart';
import 'package:hexacom_user/features/loyalty/domain/reposotories/loyalty_repo.dart';
import 'package:hexacom_user/helper/api_checker_helper.dart';

class LoyaltyProvider extends ChangeNotifier {
  final LoyaltyRepo? loyaltyRepo;

  LoyaltyProvider({required this.loyaltyRepo});

  LoyaltySummaryModel? _summary;
  List<LoyaltyLogModel> _historyList = [];
  int _historyTotal = 0;
  int _historyCurrentPage = 1;
  int _historyLastPage = 1;
  bool _summaryLoading = false;
  bool _historyLoading = false;

  LoyaltySummaryModel? get summary => _summary;
  List<LoyaltyLogModel> get historyList => _historyList;
  int get historyTotal => _historyTotal;
  int get historyCurrentPage => _historyCurrentPage;
  int get historyLastPage => _historyLastPage;
  bool get summaryLoading => _summaryLoading;
  bool get historyLoading => _historyLoading;

  Future<void> fetchLoyalty(BuildContext context) async {
    _summaryLoading = true;
    notifyListeners();
    final ApiResponseModel res = await loyaltyRepo!.getLoyalty();
    _summaryLoading = false;
    final response = res.response;
    if (response != null && response.statusCode == 200 && response.data != null) {
      try {
        final data = response.data is Map<String, dynamic>
            ? response.data as Map<String, dynamic>
            : Map<String, dynamic>.from(response.data as Map);
        _summary = LoyaltySummaryModel.fromJson(data);
      } catch (_) {
        ApiCheckerHelper.checkApi(res);
      }
    } else {
      ApiCheckerHelper.checkApi(res);
    }
    notifyListeners();
  }

  Future<void> fetchLoyaltyHistory(BuildContext context, {bool refresh = false}) async {
    if (refresh) _historyCurrentPage = 1;
    _historyLoading = true;
    notifyListeners();
    final ApiResponseModel res = await loyaltyRepo!.getLoyaltyHistory(page: _historyCurrentPage);
    _historyLoading = false;
    final response = res.response;
    if (response != null && response.statusCode == 200 && response.data != null) {
      try {
        final raw = response.data;
        final data = raw is Map<String, dynamic> ? raw : Map<String, dynamic>.from(raw as Map);
        final dataList = data['data'];
        final list = (dataList is List)
            ? (dataList)
                .map((e) => LoyaltyLogModel.fromJson(Map<String, dynamic>.from(e as Map)))
                .toList()
            : <LoyaltyLogModel>[];
        if (refresh) {
          _historyList = list;
        } else {
          _historyList = [..._historyList, ...list];
        }
        _historyTotal = data['total'] is int ? data['total'] as int : int.tryParse('${data['total']}') ?? 0;
        _historyLastPage = data['last_page'] is int ? data['last_page'] as int : int.tryParse('${data['last_page']}') ?? 1;
        _historyCurrentPage = data['current_page'] is int ? data['current_page'] as int : _historyCurrentPage;
      } catch (_) {
        ApiCheckerHelper.checkApi(res);
      }
    } else {
      ApiCheckerHelper.checkApi(res);
    }
    notifyListeners();
  }

  void loadMoreHistory(BuildContext context) {
    if (_historyLoading || _historyCurrentPage >= _historyLastPage) return;
    _historyCurrentPage++;
    fetchLoyaltyHistory(context, refresh: false);
  }
}

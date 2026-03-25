import 'package:hexacom_user/common/enums/footer_type_enum.dart';
import 'package:hexacom_user/common/widgets/custom_app_bar_widget.dart';
import 'package:hexacom_user/common/widgets/custom_loader_widget.dart';
import 'package:hexacom_user/common/widgets/footer_web_widget.dart';
import 'package:hexacom_user/common/widgets/web_app_bar_widget.dart';
import 'package:hexacom_user/features/loyalty/domain/models/loyalty_log_model.dart';
import 'package:hexacom_user/features/loyalty/domain/models/loyalty_summary_model.dart';
import 'package:hexacom_user/features/loyalty/providers/loyalty_provider.dart';
import 'package:hexacom_user/features/splash/providers/splash_provider.dart';
import 'package:hexacom_user/helper/date_converter_helper.dart';
import 'package:hexacom_user/helper/price_converter_helper.dart';
import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/routes.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Spacing used across the screen for visual consistency.
class _LoyaltyLayout {
  static double padH(BuildContext context) =>
      ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeLarge : Dimensions.paddingSizeDefault;
  static const double sectionGap = Dimensions.paddingSizeDefault;
  static const double cardPadding = Dimensions.paddingSizeDefault;
  static const double cardRadius = Dimensions.radiusSizeLarge;
  static const double listItemGap = Dimensions.paddingSizeExtraSmall;
  static const double listItemRadius = Dimensions.radiusSizeDefault;
}

class MyPointsScreen extends StatefulWidget {
  const MyPointsScreen({super.key});

  @override
  State<MyPointsScreen> createState() => _MyPointsScreenState();
}

class _MyPointsScreenState extends State<MyPointsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LoyaltyProvider>(context, listen: false).fetchLoyalty(context);
      Provider.of<LoyaltyProvider>(context, listen: false).fetchLoyaltyHistory(context, refresh: true);
    });
  }

  Future<void> _refresh() async {
    final lp = Provider.of<LoyaltyProvider>(context, listen: false);
    await lp.fetchLoyalty(context);
    await lp.fetchLoyaltyHistory(context, refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    final configModel = context.watch<SplashProvider>().configModel;
    final loyaltyEnabled = configModel?.loyaltyPointsEnabled ?? false;
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final contentWidth = isDesktop
        ? Dimensions.getWebContentWidth(MediaQuery.sizeOf(context).width)
        : MediaQuery.sizeOf(context).width;

    return Scaffold(
      appBar: (ResponsiveHelper.isDesktop(context)
          ? const PreferredSize(preferredSize: Size.fromHeight(90), child: WebAppBarWidget())
          : CustomAppBarWidget(
              title: getTranslated('my_points', context),
              onBackPressed: () {
                if (!Navigator.canPop(context)) {
                  RouteHelper.getMainRoute(context, action: RouteAction.pushNamedAndRemoveUntil);
                } else {
                  Navigator.pop(context);
                }
              },
            )) as PreferredSizeWidget?,
      body: !loyaltyEnabled
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                child: Text(
                  getTranslated('loyalty_points', context) + ' ' + (Localizations.localeOf(context).languageCode == 'ar' ? 'غير مفعّلة' : 'disabled'),
                  style: rubikRegular.copyWith(fontSize: Dimensions.fontSizeDefault),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : RefreshIndicator(
              onRefresh: _refresh,
              color: Theme.of(context).primaryColor,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Center(
                      child: SizedBox(
                        width: contentWidth,
                        child: Consumer<LoyaltyProvider>(
                          builder: (context, lp, _) {
                            if (lp.summaryLoading && lp.summary == null) {
                              return Padding(
                                padding: const EdgeInsets.all(Dimensions.paddingSizeSection),
                                child: Center(child: CustomLoaderWidget(color: Theme.of(context).primaryColor)),
                              );
                            }
                            final summary = lp.summary;
                            if (summary == null && !lp.summaryLoading) {
                              return Padding(
                                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                                child: Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        getTranslated('load_points_failed', context),
                                        style: rubikRegular.copyWith(fontSize: Dimensions.fontSizeDefault),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: Dimensions.paddingSizeSmall),
                                      TextButton.icon(
                                        onPressed: () => lp.fetchLoyalty(context),
                                        icon: const Icon(Icons.refresh, size: 20),
                                        label: Text(getTranslated('retry', context)),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }
                            if (summary == null) return const SizedBox.shrink();
                            return _buildSummary(context, summary, configModel);
                          },
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Center(
                      child: SizedBox(
                        width: contentWidth,
                        child: Consumer<LoyaltyProvider>(
                          builder: (context, lp, _) {
                            if (lp.summary == null) return const SizedBox(height: 0);
                            return _buildProgressBar(context, lp.summary!);
                          },
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Center(
                      child: SizedBox(
                        width: contentWidth,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(
                            _LoyaltyLayout.padH(context),
                            _LoyaltyLayout.sectionGap,
                            _LoyaltyLayout.padH(context),
                            _LoyaltyLayout.listItemGap,
                          ),
                          child: Text(
                            getTranslated('points_history', context),
                            style: rubikSemiBold.copyWith(fontSize: Dimensions.fontSizeLarge),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Consumer<LoyaltyProvider>(
                    builder: (context, lp, _) {
                      if (lp.historyLoading && lp.historyList.isEmpty) {
                        return SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                            child: Center(child: CustomLoaderWidget(color: Theme.of(context).primaryColor)),
                          ),
                        );
                      }
                      if (lp.historyList.isEmpty) {
                        return SliverToBoxAdapter(
                          child: Center(
                            child: SizedBox(
                              width: contentWidth,
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(
                                  _LoyaltyLayout.padH(context),
                                  _LoyaltyLayout.sectionGap,
                                  _LoyaltyLayout.padH(context),
                                  _LoyaltyLayout.sectionGap,
                                ),
                                child: Center(
                                  child: Text(
                                    Localizations.localeOf(context).languageCode == 'ar' ? 'لا يوجد سجل نقاط' : 'No points history',
                                    style: rubikRegular.copyWith(fontSize: Dimensions.fontSizeDefault),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }
                      return SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            if (index == lp.historyList.length) {
                              if (lp.historyCurrentPage < lp.historyLastPage && !lp.historyLoading) {
                                lp.loadMoreHistory(context);
                              }
                              if (lp.historyLoading) {
                                return Center(
                                  child: SizedBox(
                                    width: contentWidth,
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(horizontal: _LoyaltyLayout.padH(context), vertical: Dimensions.paddingSizeSmall),
                                      child: const Center(child: SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2))),
                                    ),
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            }
                            final log = lp.historyList[index];
                            return Center(
                              child: SizedBox(
                                width: contentWidth,
                                child: _buildHistoryTile(context, log),
                              ),
                            );
                          },
                          childCount: lp.historyList.length + (lp.historyCurrentPage < lp.historyLastPage ? 1 : 0),
                        ),
                      );
                    },
                  ),
                  SliverToBoxAdapter(child: SizedBox(height: _LoyaltyLayout.sectionGap)),
                  const FooterWebWidget(footerType: FooterType.sliver),
                ],
              ),
            ),
    );
  }

  /// Main card: balance, level, total purchases, then rules as hint at bottom.
  Widget _buildSummary(BuildContext context, LoyaltySummaryModel summary, dynamic configModel) {
    final theme = Theme.of(context);
    final padH = _LoyaltyLayout.padH(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(padH, _LoyaltyLayout.sectionGap, padH, 0),
      child: Container(
        padding: const EdgeInsets.all(_LoyaltyLayout.cardPadding),
        decoration: BoxDecoration(
          color: theme.primaryColor.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(_LoyaltyLayout.cardRadius),
          border: Border.all(color: theme.primaryColor.withValues(alpha: 0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      getTranslated('loyalty_points', context),
                      style: rubikRegular.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: theme.hintColor,
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                    Text(
                      '${summary.points}',
                      style: rubikBold.copyWith(
                        fontSize: Dimensions.fontSizeThirty,
                        color: theme.primaryColor,
                        height: 1.1,
                      ),
                    ),
                    Text(
                      getTranslated('points', context),
                      style: rubikRegular.copyWith(
                        fontSize: Dimensions.fontSizeDefault,
                        color: theme.primaryColor.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeSmall,
                    vertical: Dimensions.paddingSizeExtraSmall,
                  ),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(_LoyaltyLayout.listItemRadius),
                  ),
                  child: Text(
                    _levelName(summary.level, summary.levels),
                    style: rubikSemiBold.copyWith(
                      fontSize: Dimensions.fontSizeDefault,
                      color: theme.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: _LoyaltyLayout.cardPadding),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  getTranslated('total_purchases', context),
                  style: rubikRegular.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    color: theme.hintColor,
                  ),
                ),
                Text(
                  PriceConverterHelper.convertPrice(summary.totalSpent),
                  style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeDefault),
                ),
              ],
            ),
            _buildRulesHint(context, configModel),
          ],
        ),
      ),
    );
  }

  /// Single-line hint: how points work (earn + redeem). Hint styling, not a section.
  Widget _buildRulesHint(BuildContext context, dynamic configModel) {
    final theme = Theme.of(context);
    final amountForOne = configModel?.loyaltyAmountForOnePoint ?? 10;
    final pointsPerAmount = configModel?.loyaltyPointsPerAmount ?? 1;
    final redemption = configModel?.loyaltyPointRedemptionValue ?? 0.5;
    final currencySymbol = configModel?.currencySymbol ?? '';
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final text = isAr
        ? 'كيف تعمل النقاط: كل $amountForOne $currencySymbol تشتريها = $pointsPerAmount نقطة · كل نقطة = $redemption $currencySymbol خصم'
        : 'How points work: every $amountForOne $currencySymbol = $pointsPerAmount pt(s) · 1 pt = $redemption $currencySymbol off';
    return Padding(
      padding: const EdgeInsets.only(top: _LoyaltyLayout.cardPadding),
      child: Text(
        text,
        style: rubikRegular.copyWith(
          fontSize: Dimensions.fontSizeSmall,
          color: theme.hintColor,
        ),
      ),
    );
  }

  String _levelName(String levelKey, Map<String, dynamic>? levels) {
    if (levels == null || levels[levelKey] is! Map) return levelKey;
    final name = (levels[levelKey] as Map)['name'];
    return name?.toString() ?? levelKey;
  }

  Widget _buildProgressBar(BuildContext context, LoyaltySummaryModel summary) {
    final theme = Theme.of(context);
    final padH = _LoyaltyLayout.padH(context);
    final next = summary.nextLevelEntry;
    if (next == null) {
      return Padding(
        padding: EdgeInsets.fromLTRB(padH, _LoyaltyLayout.sectionGap, padH, 0),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: _LoyaltyLayout.cardPadding,
            vertical: Dimensions.paddingSizeSmall,
          ),
          decoration: BoxDecoration(
            color: theme.primaryColor.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(_LoyaltyLayout.listItemRadius),
          ),
          child: Row(
            children: [
              Icon(Icons.workspace_premium, size: 20, color: theme.primaryColor),
              const SizedBox(width: Dimensions.paddingSizeSmall),
              Text(
                Localizations.localeOf(context).languageCode == 'ar' ? 'وصلت لأعلى مستوى' : 'Top level reached',
                style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeDefault, color: theme.primaryColor),
              ),
            ],
          ),
        ),
      );
    }
    final nextName = _levelName(next.key, summary.levels);
    final remaining = (next.value - summary.totalSpent).clamp(0.0, double.infinity);
    double currentMin = 0;
    if (summary.levels != null && summary.levels![summary.level] is Map) {
      final v = (summary.levels![summary.level] as Map)['min_spent'];
      currentMin = v is num ? v.toDouble() : 0;
    }
    final nextMin = next.value;
    final range = nextMin - currentMin;
    final progress = range <= 0 ? 1.0 : ((summary.totalSpent - currentMin) / range).clamp(0.0, 1.0);

    return Padding(
      padding: EdgeInsets.fromLTRB(padH, _LoyaltyLayout.sectionGap, padH, 0),
      child: Container(
        padding: const EdgeInsets.all(_LoyaltyLayout.cardPadding),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(_LoyaltyLayout.listItemRadius),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${getTranslated('spend_more_to_reach', context)} $nextName',
              style: rubikRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: theme.hintColor),
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: theme.dividerColor,
                valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeExtraSmall),
            Text(
              PriceConverterHelper.convertPrice(remaining),
              style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryTile(BuildContext context, LoyaltyLogModel log) {
    final theme = Theme.of(context);
    final dateStr = log.createdAt != null
        ? DateConverterHelper.isoStringToLocalDateOnly(log.createdAt!)
        : '';
    final description = log.description ??
        (log.isEarn
            ? (Localizations.localeOf(context).languageCode == 'ar' ? 'نقاط مكتسبة' : 'Points earned')
            : (Localizations.localeOf(context).languageCode == 'ar' ? 'استبدال نقاط' : 'Points redeemed'));
    final isEarn = log.isEarn;
    final backgroundColor = isEarn
        ? Colors.green.withValues(alpha: 0.08)
        : Colors.red.withValues(alpha: 0.08);
    final accentColor = isEarn ? Colors.green.shade700 : theme.colorScheme.error;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        _LoyaltyLayout.padH(context),
        _LoyaltyLayout.listItemGap,
        _LoyaltyLayout.padH(context),
        _LoyaltyLayout.listItemGap,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: _LoyaltyLayout.cardPadding,
          vertical: Dimensions.paddingSizeSmall,
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(_LoyaltyLayout.listItemRadius),
        ),
        child: Row(
          children: [
            Icon(
              isEarn ? Icons.add_rounded : Icons.remove_rounded,
              color: accentColor,
              size: 22,
            ),
            const SizedBox(width: Dimensions.paddingSizeDefault),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    description,
                    style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeDefault),
                  ),
                  if (dateStr.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      dateStr,
                      style: rubikRegular.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: isEarn ? Colors.green.shade700 : theme.hintColor,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Text(
              '${log.points > 0 ? '+' : ''}${log.points}',
              style: rubikSemiBold.copyWith(
                fontSize: Dimensions.fontSizeDefault,
                color: accentColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:hexacom_user/features/product/providers/product_provider.dart';
import 'package:hexacom_user/features/rate_review/providers/rate_review_provider.dart';
import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class TabBarWidget extends StatelessWidget {
  final int? productId;
  const TabBarWidget({
    super.key,
    required this.child, required this.productId,
  });

  final Widget child;

  Widget _tabButton({
    required BuildContext context,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDesktop,
  }) {
    final bg = isSelected
        ? Theme.of(context).primaryColor.withValues(alpha: 0.10)
        : Theme.of(context).hintColor.withValues(alpha: 0.05);

    final border = isSelected
        ? Theme.of(context).primaryColor.withValues(alpha: 0.35)
        : Theme.of(context).hintColor.withValues(alpha: 0.10);

    final textColor = isSelected ? Theme.of(context).primaryColor : Theme.of(context).disabledColor;

    final textStyle = (isDesktop ? rubikBold : rubikMedium).copyWith(
      fontSize: isDesktop ? Dimensions.fontSizeExtraLarge : Dimensions.fontSizeLarge,
      color: textColor,
      height: 1.1,
    );

    return InkWell(
      hoverColor: Colors.transparent,
      borderRadius: BorderRadius.circular(Dimensions.radiusSizeFifty),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 22 : 16,
          vertical: isDesktop ? 12 : 10,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(Dimensions.radiusSizeFifty),
          border: Border.all(color: border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: textStyle),
            if (isSelected) ...[
              const SizedBox(width: 10),
              Container(
                height: 6,
                width: 6,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ProductProvider productProvider = Provider.of<ProductProvider>(context, listen: false);
    final RateReviewProvider rateReviewProvider = Provider.of<RateReviewProvider>(context, listen: false);
    final bool isDesktopSize = ResponsiveHelper.isDesktop(context);

    return SizedBox(
      width: Dimensions.webScreenWidth,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(
              top: isDesktopSize ? 10 : 0,
              bottom: isDesktopSize ? 10 : 6,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _tabButton(
                  context: context,
                  label: getTranslated('description', context),
                  isSelected: productProvider.tabIndex == 0,
                  onTap: () => productProvider.setTabIndex(0),
                  isDesktop: isDesktopSize,
                ),
                const SizedBox(width: 12),
                _tabButton(
                  context: context,
                  label: getTranslated('review', context),
                  isSelected: productProvider.tabIndex == 1,
                  onTap: () async {
                    productProvider.setTabIndex(1);
                    await rateReviewProvider.getProductReviews(productId, 1);
                  },
                  isDesktop: isDesktopSize,
                ),
              ],
            ),
          ),

          !ResponsiveHelper.isTab(context) ? const SizedBox(height: Dimensions.paddingSizeLarge) : const SizedBox.shrink(),

          child,

          const SizedBox(height: Dimensions.paddingSizeDefault),
        ],
      ),
    );
  }
}

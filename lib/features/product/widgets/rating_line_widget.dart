import 'package:hexacom_user/features/product/providers/product_provider.dart';
import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
class RatingLineWidget extends StatelessWidget {
  const RatingLineWidget({super.key});

  @override
  Widget build(BuildContext context) {

    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        final total = productProvider.productDetailsModel?.overallRating?.totalReview ?? 0;
        final counts = productProvider.productDetailsModel?.overallRating?.ratingGroupCount;

        double pct(int count) => total <= 0 ? 0 : (count * 100) / total;

        final fiveCount = counts?.fiveStar ?? 0;
        final fourCount = counts?.fourStar ?? 0;
        final threeCount = counts?.threeStar ?? 0;
        final twoCount = counts?.twoStar ?? 0;
        final oneCount = counts?.oneStar ?? 0;

        final five = pct(fiveCount);
        final four = pct(fourCount);
        final three = pct(threeCount);
        final two = pct(twoCount);
        final one = pct(oneCount);

        return Column(children: [
          _RatingLineWidget(rating: five, title: 'excellent', count: fiveCount),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          _RatingLineWidget(rating: four, title: 'good', count: fourCount),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          _RatingLineWidget(rating: three, title: 'average', count: threeCount),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          _RatingLineWidget(rating: two, title: 'below_average', count: twoCount),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          _RatingLineWidget(rating: one, title: 'poor', count: oneCount),

        ]);
      }
    );
  }


}

class _RatingLineWidget extends StatelessWidget {
  final double rating;
  final String title;
  final int count;
  const _RatingLineWidget({ required this.rating, required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(
        flex:ResponsiveHelper.isDesktop(context) ? 3 : 4,
        child: Text(getTranslated(title, context),style: rubikRegular.copyWith(
          color: Theme.of(context).hintColor.withValues(alpha: 0.7),
          fontSize: Dimensions.fontSizeDefault,
        )),
      ),

      Expanded(
        flex: ResponsiveHelper.isDesktop(context) ? 8 : 9,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: rating / 100,
            minHeight: 8,
            backgroundColor: Theme.of(context).hintColor.withValues(alpha: 0.12),
            valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
          ),
        ),
      ),
      const SizedBox(width: Dimensions.paddingSizeExtraSmall),

      Expanded(
        flex: ResponsiveHelper.isDesktop(context) ? 2 : 3,
        child: Text(
          '${rating.toInt()}% ($count)',
          textAlign: TextAlign.end,
          style: rubikRegular.copyWith(
            color: Theme.of(context).hintColor.withValues(alpha: 0.7),
            fontSize: Dimensions.fontSizeDefault,
          ),
        ),
      ),
    ]);
  }
}

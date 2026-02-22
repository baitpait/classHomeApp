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
        double five = ((productProvider.productDetailsModel?.overallRating?.ratingGroupCount?.fiveStar ?? 0) * 100) / (productProvider.productDetailsModel?.overallRating?.totalReview ?? 0);
        double four = ((productProvider.productDetailsModel?.overallRating?.ratingGroupCount?.fourStar ?? 0) * 100) / (productProvider.productDetailsModel?.overallRating?.totalReview ?? 0);
        double three = ((productProvider.productDetailsModel?.overallRating?.ratingGroupCount?.threeStar ?? 0) * 100) / (productProvider.productDetailsModel?.overallRating?.totalReview ?? 0);
        double two = ((productProvider.productDetailsModel?.overallRating?.ratingGroupCount?.twoStar ?? 0) * 100) / (productProvider.productDetailsModel?.overallRating?.totalReview ?? 0);
        double one = ((productProvider.productDetailsModel?.overallRating?.ratingGroupCount?.oneStar ?? 0) * 100) / (productProvider.productDetailsModel?.overallRating?.totalReview ?? 0);

        return Column(children: [
          _RatingLineWidget(rating: five, title: 'excellent'),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          _RatingLineWidget(rating: four, title: 'good'),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          _RatingLineWidget(rating: three, title: 'average'),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          _RatingLineWidget(rating: two, title: 'below_average'),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          _RatingLineWidget(rating: one, title: 'poor'),

        ]);
      }
    );
  }


}

class _RatingLineWidget extends StatelessWidget {
  final double rating;
  final String title;
  const _RatingLineWidget({ required this.rating, required this.title});

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

      Expanded(flex:ResponsiveHelper.isDesktop(context) ? 8 : 9,child: LinearProgressIndicator(value: rating/100)),
      const SizedBox(width: Dimensions.paddingSizeExtraSmall),

      Expanded(
        flex:ResponsiveHelper.isDesktop(context) ? 1 : 2,
        child: Text('${rating.toInt()}%',style: rubikRegular.copyWith(
          color: Theme.of(context).hintColor.withValues(alpha: 0.7),
          fontSize: Dimensions.fontSizeDefault,
        )),
      ),
    ]);
  }
}

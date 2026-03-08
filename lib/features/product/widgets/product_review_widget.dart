import 'package:hexacom_user/common/widgets/rating_bar_widget.dart';
import 'package:hexacom_user/features/product/providers/product_provider.dart';
import 'package:hexacom_user/features/product/widgets/rating_line_widget.dart';
import 'package:hexacom_user/features/product/widgets/review_widget.dart';
import 'package:hexacom_user/features/rate_review/providers/rate_review_provider.dart';
import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/utill/color_resources.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class ProductReviewListWidget extends StatelessWidget {
  final int? productId;
  const ProductReviewListWidget({
    super.key, this.productId
  });


  @override
  Widget build(BuildContext context) {

    final Size size = MediaQuery.sizeOf(context);

    final ProductProvider productProvider = Provider.of<ProductProvider>(context, listen: false);

    return Consumer<RateReviewProvider>(builder: (context, rateReviewProvider, _) {
      return rateReviewProvider.productReviewList == null ?
      const ReviewShimmer() :
      rateReviewProvider.productReviewList!.reviews!.isNotEmpty ?
      Column(children: [
        SizedBox(
          width: 500,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
            margin: ResponsiveHelper.isDesktop(context) ? const EdgeInsets.only(top: Dimensions.paddingSizeLarge) : null,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
                color: Theme.of(context).cardColor,
                boxShadow: [
                  BoxShadow(color: Theme.of(context).hintColor.withValues(alpha: 0.1),spreadRadius: 2,blurRadius: 2)
                ]
            ),
            child: Column(children: [
              const SizedBox(height: Dimensions.paddingSizeExtraLarge),

              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
                  color: ResponsiveHelper.isDesktop(context) ? Theme.of(context).hintColor.withValues(alpha: 0.03) : Theme.of(context).hintColor.withValues(alpha: 0.05),
                ),
                padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall, horizontal: Dimensions.paddingSizeExtraLarge),
                child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [

                  Text('${productProvider.product!.rating!.isNotEmpty ? double.parse(productProvider.product!.rating!.first.average!).toStringAsFixed(1) : 0.0}',style: TextStyle(fontSize: 30,fontWeight: FontWeight.w700,color: Theme.of(context).primaryColor)),
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  RatingBarWidget(rating: productProvider.product!.rating!.isNotEmpty ? double.parse(productProvider.product!.rating![0].average!) : 0.0, size: 20,color: ColorResources.getRatingColor(context)),
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  const SizedBox(width: Dimensions.paddingSizeDefault),

                  Text('${rateReviewProvider.productReviewList?.reviews?.length} ${getTranslated((rateReviewProvider.productReviewList?.reviews?.length ?? 0) > 1 ? 'reviews' : 'review', context)}',style: rubikRegular.copyWith(fontSize: Dimensions.fontSizeSmall,color: Theme.of(context).hintColor.withValues(alpha: 0.6))),

                ]),
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              SizedBox(
                width: size.width,
                child: const Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: RatingLineWidget(),
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),
            ]),
          ),
        ),

        ListView.builder(
          itemCount: rateReviewProvider.productReviewList?.reviews?.length,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          reverse: true,
          padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
          itemBuilder: (context, index) {
            return rateReviewProvider.productReviewList != null ? ReviewWidget(
              reviewModel: rateReviewProvider.productReviewList!.reviews![index],
            ) : const ReviewShimmer();
          },
        ),

        if((rateReviewProvider.productReviewList?.reviews?.length ?? 0) < (rateReviewProvider.productReviewList?.totalSize ?? 0))...[
          const SizedBox(height: Dimensions.paddingSizeSmall),

          InkWell(
            onTap: () {
              int calculateOffset = int.parse(rateReviewProvider.productReviewList?.offset ?? '0') + 1;
              rateReviewProvider.getProductReviews(productId, calculateOffset);
            },
            child: Text(getTranslated('see_more_reviews', context), style: rubikRegular.copyWith(color: Theme.of(context).primaryColor.withValues())),
          )
        ]


      ]) :
      Center(child: Text(
        getTranslated('no_review_found', context),
        style: TextStyle(fontSize: ResponsiveHelper.isDesktop(context) ? 20 : 16),
      ));
    });
  }
}

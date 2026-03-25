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

  Widget _buildSummaryCard(BuildContext context, Size size, RateReviewProvider rateReviewProvider, ProductProvider productProvider) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 520),
      child: Container(
        padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
          color: Theme.of(context).cardColor,
          border: Border.all(color: Theme.of(context).hintColor.withValues(alpha: 0.08)),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).hintColor.withValues(alpha: 0.06),
              blurRadius: 18,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: Column(children: [
          Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: Dimensions.paddingSizeDefault,
                  horizontal: Dimensions.paddingSizeLarge,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
                  color: Theme.of(context).hintColor.withValues(alpha: 0.05),
                ),
                child: Column(children: [
                  Text(
                    '${productProvider.product?.rating?.isNotEmpty == true ? double.parse(productProvider.product!.rating!.first.average!).toStringAsFixed(1) : 0.0}',
                    style: rubikBold.copyWith(
                      fontSize: 34,
                      color: Theme.of(context).primaryColor,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  RatingBarWidget(
                    rating: productProvider.product?.rating?.isNotEmpty == true
                        ? double.parse(productProvider.product!.rating![0].average!)
                        : 0.0,
                    size: 18,
                    color: ColorResources.getRatingColor(context),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${rateReviewProvider.productReviewList?.totalSize ?? rateReviewProvider.productReviewList?.reviews?.length ?? 0} ${getTranslated(((rateReviewProvider.productReviewList?.totalSize ?? 0) > 1 ? 'reviews' : 'review'), context)}',
                    style: rubikRegular.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: Theme.of(context).hintColor.withValues(alpha: 0.65),
                    ),
                  ),
                ]),
              ),
            ),
          ]),

          const SizedBox(height: Dimensions.paddingSizeLarge),

          SizedBox(
            width: size.width,
            child: const RatingLineWidget(),
          ),
        ]),
      ),
    );
  }

  Widget _buildReviewsList(BuildContext context, RateReviewProvider rateReviewProvider, {required bool isDesktop}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListView.builder(
          itemCount: rateReviewProvider.productReviewList?.reviews?.length,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          reverse: true,
          // On desktop we want perfect top alignment with the summary card.
          // On mobile we keep some breathing room.
          padding: isDesktop ? EdgeInsets.zero : const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
          itemBuilder: (context, index) {
            return rateReviewProvider.productReviewList != null
                ? ReviewWidget(reviewModel: rateReviewProvider.productReviewList!.reviews![index])
                : const ReviewShimmer();
          },
        ),
        if ((rateReviewProvider.productReviewList?.reviews?.length ?? 0) < (rateReviewProvider.productReviewList?.totalSize ?? 0)) ...[
          const SizedBox(height: Dimensions.paddingSizeSmall),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: InkWell(
              onTap: () {
                final calculateOffset = (rateReviewProvider.productReviewList?.offset ?? 0) + 1;
                rateReviewProvider.getProductReviews(productId, calculateOffset);
              },
              borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: Dimensions.paddingSizeSmall,
                  horizontal: Dimensions.paddingSizeDefault,
                ),
                child: Text(
                  getTranslated('see_more_reviews', context),
                  style: rubikMedium.copyWith(color: Theme.of(context).primaryColor.withValues()),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {

    final Size size = MediaQuery.sizeOf(context);
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    final ProductProvider productProvider = Provider.of<ProductProvider>(context, listen: false);

    return Consumer<RateReviewProvider>(builder: (context, rateReviewProvider, _) {
      return rateReviewProvider.productReviewList == null ?
      const ReviewShimmer() :
      rateReviewProvider.productReviewList!.reviews!.isNotEmpty ?
      (isDesktop
          ? Padding(
              padding: const EdgeInsets.only(top: Dimensions.paddingSizeLarge),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: isRtl
                    ? [
                        // RTL (Arabic): summary on the right, list on the left.
                        Expanded(child: _buildReviewsList(context, rateReviewProvider, isDesktop: isDesktop)),
                        const SizedBox(width: Dimensions.paddingSizeLarge),
                        _buildSummaryCard(context, size, rateReviewProvider, productProvider),
                      ]
                    : [
                        // LTR (English): summary on the left, list on the right.
                        _buildSummaryCard(context, size, rateReviewProvider, productProvider),
                        const SizedBox(width: Dimensions.paddingSizeLarge),
                        Expanded(child: _buildReviewsList(context, rateReviewProvider, isDesktop: isDesktop)),
                      ],
              ),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
                  child: _buildSummaryCard(context, size, rateReviewProvider, productProvider),
                ),
                _buildReviewsList(context, rateReviewProvider, isDesktop: isDesktop),
              ],
            )) :
      Center(child: Text(
        getTranslated('no_review_found', context),
        style: TextStyle(fontSize: ResponsiveHelper.isDesktop(context) ? 20 : 16),
      ));
    });
  }
}

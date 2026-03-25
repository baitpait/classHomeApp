import 'package:hexacom_user/common/widgets/custom_image_widget.dart';
import 'package:hexacom_user/common/widgets/custom_single_child_list_widget.dart';
import 'package:hexacom_user/features/product/domain/models/review_model.dart';
import 'package:hexacom_user/features/product/widgets/image_preview_screen.dart';
import 'package:hexacom_user/helper/date_converter_helper.dart';
import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/features/splash/providers/splash_provider.dart';
import 'package:hexacom_user/utill/color_resources.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/routes.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer_animation/shimmer_animation.dart';


class ReviewWidget extends StatelessWidget {
  final Review reviewModel;
  const ReviewWidget({super.key, required this.reviewModel});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final customer = reviewModel.customer;
    final name = customer != null
        ? '${customer.fName ?? ''} ${customer.lName ?? ''}'.trim()
        : getTranslated('user_not_available', context);
    final hasCustomerImage = (customer?.image != null) && (customer!.image!.toString().trim().isNotEmpty);
    final avatarBg = Theme.of(context).primaryColor.withValues(alpha: 0.10);
    final avatarFg = Theme.of(context).primaryColor;
    final initials = name.isNotEmpty ? name.characters.first : '?';

    return Container(
      margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
      padding: EdgeInsets.all(ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeLarge : Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
          border: Border.all(color: Theme.of(context).hintColor.withValues(alpha: 0.08)),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).hintColor.withValues(alpha: 0.06),
              blurRadius: 14,
              offset: const Offset(0, 6),
            )
          ]
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          if (hasCustomerImage)
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: CustomImageWidget(
                image: '${Provider.of<SplashProvider>(context, listen: false).baseUrls!.customerImageUrl}/${customer.image}',
                width: 44,
                height: 44,
                fit: BoxFit.cover,
              ),
            )
          else
            CircleAvatar(
              radius: 22,
              backgroundColor: avatarBg,
              child: Text(
                initials,
                style: rubikSemiBold.copyWith(color: avatarFg),
              ),
            ),

          const SizedBox(width: Dimensions.paddingSizeSmall),

          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                name,
                style: rubikSemiBold.copyWith(fontSize: Dimensions.fontSizeDefault),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Row(children: [
                Icon(Icons.star_rounded, color: ColorResources.getRatingColor(context), size: 18),
                const SizedBox(width: 6),
                Text(
                  '${reviewModel.rating ?? 0}',
                  style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                ),
              ]),
            ]),
          ),

          const SizedBox(width: Dimensions.paddingSizeSmall),
          Text(
            reviewModel.createdAt != null ? DateConverterHelper.convertToAgo(reviewModel.createdAt!) : '',
            style: rubikRegular.copyWith(
              fontSize: Dimensions.fontSizeSmall,
              color: Theme.of(context).hintColor.withValues(alpha: 0.7),
            ),
          ),
        ]),

        const SizedBox(height: Dimensions.paddingSizeDefault),

        if ((reviewModel.comment ?? '').trim().isNotEmpty)
          Text(
            reviewModel.comment!.trim(),
            style: rubikRegular.copyWith(
              fontSize: ResponsiveHelper.isDesktop(context) ? Dimensions.fontSizeLarge : Dimensions.fontSizeDefault,
              color: Theme.of(context).hintColor.withValues(alpha: 0.78),
              height: 1.35,
            ),
          ),

        if ((reviewModel.attachment?.isNotEmpty ?? false)) ...[
          const SizedBox(height: Dimensions.paddingSizeDefault),
          const SizedBox(height: Dimensions.paddingSizeSmall),
        ],

        CustomSingleChildListWidget(
            itemCount: reviewModel.attachment?.length ?? 0,
            scrollDirection: Axis.horizontal,
            itemBuilder: (index){
              return Row(children: [
                InkWell(
                  onTap: (){
                    if(ResponsiveHelper.isDesktop(context)){
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return Dialog(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault)),
                            insetPadding: EdgeInsets.symmetric(horizontal: size.width * 0.3, vertical: size.height * 0.2),
                            backgroundColor: Colors.transparent,
                            surfaceTintColor: Colors.transparent,
                            child: ImagePreviewScreen(images: reviewModel.attachment ?? [], selectedIndex: index),
                          );
                        },
                      );
                    }else{
                      RouteHelper.getImagePreviewRoute(context, reviewModel.attachment ?? [], index, RouteAction.push);
                    }
                  },
                  child: Container(
                    height: 75,width: 75,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
                        border: Border.all(color: Theme.of(context).hintColor.withValues(alpha: 0.10))
                    ),
                    child: CustomImageWidget(image: '${Provider.of<SplashProvider>(context,listen: false).baseUrls?.reviewImageUrl}/${reviewModel.attachment?[index]}'),
                  ),
                ),
                const SizedBox(width: Dimensions.paddingSizeSmall)
              ]);
            }
        ),
      ]),
    );
  }
}


class ReviewShimmer extends StatelessWidget {
  const ReviewShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: ColorResources.getSearchBg(context),
      ),
      child: Shimmer(
        duration: const Duration(seconds: 2),
        enabled: true,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(height: 30, width: 30, decoration: BoxDecoration(color: Theme.of(context).shadowColor, shape: BoxShape.circle)),
            const SizedBox(width: 5),
            Container(height: 15, width: 100, color: Theme.of(context).shadowColor),
            const Expanded(child: SizedBox()),
            Icon(Icons.star, color: Theme.of(context).primaryColor, size: 18),
            const SizedBox(width: 5),
            Container(height: 15, width: 20, color: Theme.of(context).shadowColor),
          ]),
          const SizedBox(height: 5),

          Container(height: 15, width: MediaQuery.sizeOf(context).width, color: Theme.of(context).shadowColor),
          const SizedBox(height: 3),

          Container(height: 15, width: MediaQuery.sizeOf(context).width, color: Theme.of(context).shadowColor),
        ]),
      ),
    );
  }
}


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
    return Container(
      margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
      padding: EdgeInsets.all(ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeLarge : Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
          color: ResponsiveHelper.isDesktop(context) ? Theme.of(context).hintColor.withValues(alpha: 0.01) : Theme.of(context).hintColor.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall)
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: CustomImageWidget(
              image: '${Provider.of<SplashProvider>(context, listen: false).baseUrls!.customerImageUrl}/${
                  reviewModel.customer != null ? reviewModel.customer!.image : getTranslated('user_not_available', context)
              }',
              width: 50, height: 50, fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: Dimensions.paddingSizeSmall),

          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              reviewModel.customer != null ?
              '${reviewModel.customer!.fName} ${reviewModel.customer!.lName}' : getTranslated('user_not_available', context),
              style: rubikSemiBold.copyWith(fontSize: Dimensions.fontSizeSmall),
              maxLines: 1, overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 5),

            Row(mainAxisAlignment: MainAxisAlignment.start, children: [
              Icon(Icons.star, color: ColorResources.getRatingColor(context), size: 16),
              const SizedBox(width: Dimensions.paddingSizeSmall),
            
              Text(reviewModel.rating!.toStringAsFixed(1), style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeSmall)),
            ]),
          ])),
          
          Text(DateConverterHelper.convertToAgo(reviewModel.createdAt!), style: rubikRegular.copyWith(
            fontSize: Dimensions.fontSizeSmall,
          )),
        ]),
        const SizedBox(height: Dimensions.paddingSizeSmall),

        Padding(
          padding: const EdgeInsets.only(left: 60),
          child: Text(reviewModel.comment!, style: rubikRegular.copyWith(
            fontSize: ResponsiveHelper.isDesktop(context) ? Dimensions.fontSizeLarge : Dimensions.fontSizeDefault ,
            color: Theme.of(context).hintColor.withValues(alpha: 0.6),
            fontStyle: FontStyle.italic,
          )),
        ),
        const SizedBox(height: Dimensions.paddingSizeSmall),

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
                        border: Border.all(color: Theme.of(context).hintColor.withValues(alpha: 0.05))
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


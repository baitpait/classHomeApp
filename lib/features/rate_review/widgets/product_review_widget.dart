import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:hexacom_user/common/enums/footer_type_enum.dart';
import 'package:hexacom_user/common/widgets/custom_image_widget.dart';
import 'package:hexacom_user/features/rate_review/providers/rate_review_provider.dart';
import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/common/widgets/footer_web_widget.dart';
import 'package:flutter/material.dart';
import 'package:hexacom_user/common/models/review_body_model.dart';
import 'package:hexacom_user/common/models/order_details_model.dart';
import 'package:hexacom_user/helper/price_converter_helper.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/features/splash/providers/splash_provider.dart';
import 'package:hexacom_user/utill/color_resources.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:hexacom_user/common/widgets/custom_button_widget.dart';
import 'package:hexacom_user/helper/custom_snackbar_helper.dart';
import 'package:hexacom_user/common/widgets/custom_text_field_widget.dart';
import 'package:provider/provider.dart';

class ProductReviewWidget extends StatefulWidget {
  final List<OrderDetailsModel>? orderDetailsList;
  const ProductReviewWidget({super.key, required this.orderDetailsList});

  @override
  State<ProductReviewWidget> createState() => _ProductReviewWidgetState();
}

class _ProductReviewWidgetState extends State<ProductReviewWidget> {

  @override
  void initState() {
    Provider.of<RateReviewProvider>(context, listen: false).setProductWiseRating(0, 0, orderDetailsList: widget.orderDetailsList);
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return SingleChildScrollView(
      child: Column(
        children: [
          Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: !ResponsiveHelper.isDesktop(context) && height < 600 ? height : height - 400),
              child: SizedBox(
                width: Dimensions.webScreenWidth,
                child: Consumer<RateReviewProvider>(
                  builder: (context, rateReviewProvider, child) {
                    return ListView.builder(
                      itemCount: widget.orderDetailsList!.length,
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                      itemBuilder: (context, index) {
                        return Container(
                          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                          margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                          decoration: BoxDecoration(
                            boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.2), spreadRadius: 1, blurRadius: 2, offset: const Offset(0, 1))],
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
                          ),
                          child: Column(
                            children: [

                              // Product details
                              Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: CustomImageWidget(
                                      image: '${Provider.of<SplashProvider>(context, listen: false).baseUrls!.productImageUrl}/${widget.orderDetailsList![index].productDetails!.image![0]}',
                                      height: 70,
                                      width: 85,
                                      fit: BoxFit.cover,

                                    ),
                                  ),
                                  const SizedBox(width: Dimensions.paddingSizeSmall),
                                  Expanded(child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(widget.orderDetailsList![index].productDetails!.name!, style: rubikMedium, maxLines: 2, overflow: TextOverflow.ellipsis),
                                      const SizedBox(height: 10),

                                      Text(PriceConverterHelper.convertPrice(widget.orderDetailsList![index].productDetails!.price), style: rubikBold),
                                    ],
                                  )),
                                ],
                              ),
                              const Divider(height: 20),

                              // Rate
                              Text(
                                getTranslated('rate_the_food', context),
                                style: rubikMedium.copyWith(color: ColorResources.getGreyBunkerColor(context)), overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: Dimensions.paddingSizeSmall),
                              SizedBox(
                                height: 30,
                                child: ListView.builder(
                                  itemCount: 5,
                                  shrinkWrap: true,
                                  scrollDirection: Axis.horizontal,
                                  itemBuilder: (context, i) {
                                    return InkWell(
                                      child: Icon(
                                        rateReviewProvider.ratingList[index] < (i + 1) ? Icons.star_border : Icons.star,
                                        size: 25,
                                        color: rateReviewProvider.ratingList[index] < (i + 1)
                                            ? ColorResources.getGreyColor(context)
                                            : Theme.of(context).primaryColor,
                                      ),
                                      onTap: () {
                                        if(!rateReviewProvider.submitList[index]) {
                                          rateReviewProvider.setRating(index, i + 1);
                                        }
                                      },
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: Dimensions.paddingSizeLarge),
                              Text(
                                getTranslated('share_your_opinion', context),
                                style: rubikMedium.copyWith(color: ColorResources.getGreyBunkerColor(context)), overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: Dimensions.paddingSizeLarge),
                              CustomTextFieldWidget(
                                maxLines: 3,
                                capitalization: TextCapitalization.sentences,
                                isEnabled: !rateReviewProvider.submitList[index],
                                hintText: getTranslated('write_your_review_here', context),
                                fillColor: ColorResources.getSearchBg(context),
                                onChanged: (text) {
                                  rateReviewProvider.setReview(index, text);
                                },
                              ),
                              const SizedBox(height: 20),

                              SizedBox(height: 70, child: CustomScrollView(scrollDirection: Axis.horizontal, slivers: [
                                SliverList.builder(
                                  itemCount: rateReviewProvider.productWiseReview[index].image!.isNotEmpty && rateReviewProvider.productWiseReview[index].image!.length < 4 ?
                                  rateReviewProvider.productWiseReview[index].image!.length + 1
                                      : rateReviewProvider.productWiseReview[index].image!.isNotEmpty && rateReviewProvider.productWiseReview[index].image!.length >= 4 ? 4
                                      : 1,
                                  itemBuilder: (context, ind) {

                                    return
                                      ind == rateReviewProvider.productWiseReview[index].image!.length
                                          && rateReviewProvider.productWiseReview[index].image!.length < 4
                                          || rateReviewProvider.productWiseReview[index].image!.isEmpty
                                          ? Container(width: 70, height: 70, margin: const EdgeInsets.only(right: Dimensions.paddingSizeSmall), child: InkWell(
                                        onTap: () {
                                          rateReviewProvider.pickImage(context, false, rateReviewProvider.productWiseReview[index].productId);
                                        },
                                        child: DottedBorder(
                                          options: RoundedRectDottedBorderOptions(
                                            padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                                            radius: const Radius.circular(Dimensions.radiusSizeSmall),
                                            dashPattern: const [4, 4],
                                            color: Theme.of(context).hintColor.withValues(alpha:0.7),
                                          ),
                                          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                                            Icon(Icons.camera_alt_outlined, color: Theme.of(context).hintColor, size: Dimensions.paddingSizeDefault),

                                            Text(getTranslated('upload_image', context), textAlign: TextAlign.center, style: rubikRegular.copyWith(
                                              color: Theme.of(context).hintColor, fontSize: Dimensions.fontSizeSmall,
                                            )),
                                          ]),
                                        ),
                                      ))
                                          :
                                      Container(margin: const EdgeInsets.only(right: Dimensions.paddingSizeSmall), child: Stack(children: [

                                        Container(width: 70, height: 70,
                                          decoration: const BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.all(Radius.circular(Dimensions.radiusSizeSmall)),
                                          ),
                                          child: ClipRRect(
                                            borderRadius: const BorderRadius.all(Radius.circular(Dimensions.radiusSizeSmall)),
                                            child: !ResponsiveHelper.isMobilePhone()? CustomImageWidget(
                                              image: rateReviewProvider.productWiseReview[index].image![ind].path,
                                              width: 70, height: 70,
                                            ) : Image.file(
                                              File(rateReviewProvider.productWiseReview[index].image![ind].path),
                                              width: 70, height: 70, fit: BoxFit.cover,
                                            ),
                                          ) ,
                                        ),

                                        Positioned(top:0, right:0, child: InkWell(
                                          onTap: () => rateReviewProvider.removeImage(ind, rateReviewProvider.productWiseReview[index].productId),
                                          child: Container(
                                            decoration: const BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.all(Radius.circular(Dimensions.paddingSizeDefault))
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(2),
                                              child: Icon(Icons.clear, color: Theme.of(context).primaryColor, size: Dimensions.paddingSizeDefault),
                                            ),
                                          ),
                                        )),

                                      ]));

                                  },
                                ),
                              ])),
                              const SizedBox(height: Dimensions.paddingSizeLarge),

                              // Submit button
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
                                child: Column(
                                  children: [
                                    !rateReviewProvider.loadingList[index] ? CustomButtonWidget(
                                      btnTxt: getTranslated(rateReviewProvider.submitList[index] ? 'submitted' : 'submit', context),
                                      backgroundColor: rateReviewProvider.submitList[index] ? ColorResources.getGreyColor(context) : Theme.of(context).primaryColor,
                                      onTap: () {
                                        if(!rateReviewProvider.submitList[index]) {
                                          if (rateReviewProvider.ratingList[index] == 0) {
                                            showCustomSnackBar('Give a rating', context);
                                          } else if (rateReviewProvider.reviewList[index].isEmpty) {
                                            showCustomSnackBar('Write a review', context);
                                          } else {
                                            FocusScopeNode currentFocus = FocusScope.of(context);
                                            if (!currentFocus.hasPrimaryFocus) {
                                              currentFocus.unfocus();
                                            }
                                            ReviewBodyModel reviewBody = ReviewBodyModel(
                                              productId: widget.orderDetailsList![index].productId.toString(),
                                              rating: rateReviewProvider.ratingList[index].toString(),
                                              comment: rateReviewProvider.reviewList[index],
                                              orderId: widget.orderDetailsList![index].orderId.toString(),
                                            );
                                            rateReviewProvider.submitProductReview(index, reviewBody).then((value) {
                                              if (value.isSuccess) {
                                                showCustomSnackBar(value.message, context, isError: false);
                                                rateReviewProvider.setReview(index, '');
                                              } else {
                                                showCustomSnackBar(value.message, context);
                                              }
                                            });
                                          }
                                        }
                                      },
                                    ) : Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor))),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ),

          const FooterWebWidget(footerType: FooterType.nonSliver),

        ],
      ),
    );
  }
}

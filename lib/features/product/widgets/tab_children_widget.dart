import 'package:hexacom_user/common/widgets/custom_button_widget.dart';
import 'package:hexacom_user/features/product/providers/product_provider.dart';
import 'package:hexacom_user/features/product/widgets/product_review_widget.dart';
import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class TabChildrenWidget extends StatefulWidget {
  final int? productId;
  const TabChildrenWidget({super.key, this.productId});

  @override
  State<TabChildrenWidget> createState() => _TabChildrenWidgetState();
}

class _TabChildrenWidgetState extends State<TabChildrenWidget> {
  // Always show the full description without truncation / "see more".
  bool showSeeMoreButton = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(builder: (context, productProvider, _){
      final isDesktop = ResponsiveHelper.isDesktop(context);

      return productProvider.product == null ? const SizedBox() : productProvider.tabIndex == 0 ? (productProvider.product!.description == null || productProvider.product!.description!.isEmpty)
          ? Center(child: Text(getTranslated('no_description_found', context), style: rubikRegular.copyWith(
        fontSize: ResponsiveHelper.isDesktop(context) ? 20 : 16,
      ))) : Stack(children: [


        if(productProvider.product?.description?.isNotEmpty ?? false) Container(
          height: (productProvider.product != null && productProvider.product!.description != null && productProvider.product!.description!.length > 300) && showSeeMoreButton
              ? (isDesktop ? 180 : 120)
              : null,
          padding: EdgeInsets.all(isDesktop ? Dimensions.paddingSizeLarge : Dimensions.paddingSizeSmall),
          width: Dimensions.webScreenWidth,
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: HtmlWidget(
              onTapUrl: (url)=> launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
              productProvider.product!.description ?? '',
              textStyle: rubikRegular.copyWith(
                fontSize: isDesktop ? Dimensions.fontSizeLarge : Dimensions.fontSizeDefault,
                height: 1.45,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ),
        ),


        if((productProvider.product!.description?.isNotEmpty ?? false) &&  productProvider.product!.description!.length > 300 && showSeeMoreButton) Positioned.fill(child: Align(
          alignment: Alignment.bottomCenter, child: Container(
          decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [
            Theme.of(context).cardColor.withValues(alpha: 0),
            Theme.of(context).cardColor,
          ])),
          width: Dimensions.webScreenWidth, height: 55,
        ),
        )),

        if((productProvider.product!.description?.isNotEmpty ?? false) && productProvider.product!.description!.length > 300 && showSeeMoreButton) Positioned.fill(child: Align(
          alignment: Alignment.bottomCenter, child: Container(
            margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
            height: isDesktop ? 40 : 36,
            width: isDesktop ? 140 : 120,
            child: CustomButtonWidget(
              backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.90),
              radius: Dimensions.radiusSizeFifty,
              style: rubikMedium.copyWith(color: Colors.white),
              btnTxt: getTranslated('see_more', context),
              onTap: (){
                setState(() {
                  showSeeMoreButton = false;
                });
              },
            ),
          ),
        )),

      ]) : ProductReviewListWidget(productId: widget.productId);
    });
  }
}

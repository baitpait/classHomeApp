import 'package:hexacom_user/features/auth/domain/enums/from_page_enum.dart';
import 'package:hexacom_user/features/menu/domain/models/menu_model.dart';
import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/features/auth/providers/auth_provider.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/images.dart';
import 'package:hexacom_user/utill/routes.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:hexacom_user/common/widgets/custom_alert_dialog_widget.dart';
import 'package:hexacom_user/common/widgets/text_hover_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileHoverWidget extends StatelessWidget {
  const ProfileHoverWidget({super.key});

  @override
  Widget build(BuildContext context) {
    List<MenuModel> list = [
      MenuModel(icon: Images.profile, title: getTranslated('profile', context), route: ()=> RouteHelper.getProfileRoute(context)),
      MenuModel(icon: Images.order, title: getTranslated('my_orders', context), route: ()=> RouteHelper.getOrderListScreen(context)),
      MenuModel(icon: Images.profile, title: getTranslated('log_out', context), route: ()=> RouteHelper.getLoginRoute(context, FromPage.mainRoute.name)),
    ];


    return Selector<AuthProvider, bool>(
      selector: (context, authProvider) => authProvider.isLoading,
      builder: (context, isLoading, child) {
        final theme = Theme.of(context);
        return Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor.withValues(alpha: 0.08),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: list.map((item) => InkWell(
            onTap: (){
              if(item.title == getTranslated('log_out', context)){


                Future.delayed(const Duration(seconds: 0), () => ResponsiveHelper.showDialogOrBottomSheet(context, CustomAlertDialogWidget(
                  isLoading: isLoading ,
                  title: getTranslated('want_to_sign_out', context),
                  icon: Icons.contact_support_outlined,
                  onPressRight: (){
                    Provider.of<AuthProvider>(context, listen: false).clearSharedData();
                    if(ResponsiveHelper.isWeb()) {
                      RouteHelper.getDashboardRoute(context, 'home', action: RouteAction.pushNamedAndRemoveUntil);
                    }else {
                      RouteHelper.getDashboardRoute(context, 'home', action: RouteAction.pushNamedAndRemoveUntil);
                    }
                  },

                )));

              }else{
                 item.route();
              }

            },
            child: TextHoverWidget(builder: (isHover)=> Container(
              margin: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeSmall,
                vertical: Dimensions.paddingSizeExtraSmall,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeLarge,
                vertical: Dimensions.paddingSizeSmall,
              ),
              decoration: BoxDecoration(
                color: isHover ? theme.primaryColor.withValues(alpha: 0.06) : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  item.title ?? '',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  style: rubikMedium.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    color: (item.title == getTranslated('log_out', context))
                        ? theme.colorScheme.error
                        : theme.textTheme.bodyLarge?.color,
                  ),
                ),
              ),
            )),
          )).toList(),
        ));
      }
    );
  }
}

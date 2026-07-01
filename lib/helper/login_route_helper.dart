import 'package:hexacom_user/features/auth/domain/enums/from_page_enum.dart';
import 'package:hexacom_user/main.dart';
import 'package:hexacom_user/utill/routes.dart';

class LoginRouteHelper{

  static navigateToRoute(String fromPage){
    if(fromPage == FromPage.profile.name){
      RouteHelper.getProfileRoute(Get.context!, action: RouteAction.pushNamedAndRemoveUntil);
    }else if(fromPage == FromPage.orderList.name){
      RouteHelper.getOrderListScreen(Get.context!, action: RouteAction.pushNamedAndRemoveUntil);
    }else if(fromPage == FromPage.address.name){
      RouteHelper.getAddressRoute(Get.context!, action: RouteAction.pushNamedAndRemoveUntil);
    }else if(fromPage == FromPage.chat.name){
      RouteHelper.getChatRoute(Get.context!, action: RouteAction.pushNamedAndRemoveUntil);
    }else if(fromPage == FromPage.coupon.name){
      RouteHelper.getNotificationRoute(Get.context!, action: RouteAction.pushNamedAndRemoveUntil);
    }else if(fromPage == FromPage.checkOut.name){
     //RouteHelper.getCheckoutRoute(context, amount: amount, deliveryCharge: deliveryCharge)
      RouteHelper.getMainRoute(Get.context, action: RouteAction.pushNamedAndRemoveUntil);
    }else if(fromPage == FromPage.menu.name){
      RouteHelper.getDashboardRoute(Get.context!, 'home', action: RouteAction.pushNamedAndRemoveUntil);
    }else if(fromPage == FromPage.wishListScreen.name){
      RouteHelper.getDashboardRoute(Get.context!, 'favourite', action: RouteAction.pushNamedAndRemoveUntil);
    }else{
      RouteHelper.getMainRoute(Get.context, action: RouteAction.pushNamedAndRemoveUntil);
    }

  }
}
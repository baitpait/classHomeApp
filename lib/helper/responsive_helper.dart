import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class ResponsiveHelper {

  static bool isMobilePhone() {
    if (!kIsWeb) {
      return true;
    }else {
      return false;
    }
  }

  static bool isWeb() {
    return kIsWeb;
  }

  static bool isMobile(context) {
    final width = MediaQuery.sizeOf(context).width;
    return width < 650 || !kIsWeb;
  }

  static bool isTab(context) {
    final width = MediaQuery.sizeOf(context).width;
    return width < 1200 && width >= 600;
  }

  static bool isDesktop(context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= 1200;
  }

  static Future showDialogOrBottomSheet(BuildContext context, Widget view) async {
    if(ResponsiveHelper.isDesktop(context)) {
     await showDialog(context: context, builder: (ctx)=> view);
    }else{
     await showModalBottomSheet(backgroundColor: Colors.transparent, context: context, builder: (ctx)=> view);
    }
  }
}
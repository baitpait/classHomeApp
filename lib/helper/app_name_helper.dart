import 'package:flutter/material.dart';
import 'package:hexacom_user/features/splash/providers/splash_provider.dart';
import 'package:provider/provider.dart';

String getAppName(BuildContext context, {String fallback = 'كلاس هوم'}) {
  final splashProvider = Provider.of<SplashProvider>(context, listen: false);
  final name = splashProvider.configModel?.ecommerceName;
  if (name != null && name.trim().isNotEmpty) {
    return name;
  }
  return fallback;
}


import 'dart:async';

import 'package:hexacom_user/common/widgets/custom_toast.dart';
import 'package:hexacom_user/main.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:flutter/material.dart';

bool _successMessageVisible = false;
Timer? _successResetTimer;

void showCustomSnackBar(String? message, BuildContext context, {bool isError = true, Duration? duration}) {
  final bool isSuccess = !isError;

  // Suppress duplicate success messages (e.g., "added to cart") while one is already visible.
  if (isSuccess && _successMessageVisible) {
    return;
  }

  final Duration effectiveDuration = duration ?? const Duration(seconds: 4);

  if (isSuccess) {
    _successMessageVisible = true;
    _successResetTimer?.cancel();
    _successResetTimer = Timer(effectiveDuration, () {
      _successMessageVisible = false;
    });
  }

  // Always show from top using overlay (mobile + desktop)
  CustomToast().show(
    message ?? '',
    navigatorKey: navigatorKey,
    isError: isError,
    duration: effectiveDuration,
    borderRadius: Dimensions.paddingSizeSmall,
    position: ToastPosition.topCenter,
  );
}
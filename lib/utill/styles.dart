import 'package:flutter/material.dart';
import 'package:hexacom_user/utill/dimensions.dart';

/// Use theme font (Exo for non-Arabic, Cairo for Arabic). Do not set fontFamily
/// so that Theme.of(context).textTheme / theme.fontFamily applies.
const rubikRegular = TextStyle(
  fontSize: Dimensions.fontSizeDefault,
  fontWeight: FontWeight.w400,
);

const rubikMedium = TextStyle(
  fontSize: Dimensions.fontSizeDefault,
  fontWeight: FontWeight.w500,
);

const rubikSemiBold = TextStyle(
  fontSize: Dimensions.fontSizeDefault,
  fontWeight: FontWeight.w600,
);

const rubikBold = TextStyle(
  fontSize: Dimensions.fontSizeDefault,
  fontWeight: FontWeight.w700,
);

/// Section title (e.g. "New Arrival", "Offer Product")
const rubikTitle = TextStyle(
  fontSize: Dimensions.fontSizeOverLarge,
  fontWeight: FontWeight.w600,
);

/// Smaller body / caption
const rubikCaption = TextStyle(
  fontSize: Dimensions.fontSizeSmall,
  fontWeight: FontWeight.w400,
);
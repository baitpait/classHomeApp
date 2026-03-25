
import 'package:flutter/material.dart';
import 'package:hexacom_user/features/order/domain/models/delivery_man_model.dart';
class OrderMapProvider extends ChangeNotifier {
  OrderMapProvider();

  /// Stub method kept for API compatibility; map tracking is disabled.
  void setMapMarker({DeliveryManModel? deliveryManModel}) {}

  /// Stub to mirror previous API; nothing to dispose now.
  void disposeGoogleMapController() {}
}
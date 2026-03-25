import 'package:flutter/material.dart';

class MenuModel {
  String icon;
  String? title;
  Function route;
  /// Optional Material icon for web; when set, used instead of [icon] asset on desktop.
  IconData? iconData;

  /// When true (web menu), tile uses danger styling — use for irreversible actions.
  final bool destructive;

  MenuModel({
    required this.icon,
    required this.title,
    required this.route,
    this.iconData,
    this.destructive = false,
  });
}
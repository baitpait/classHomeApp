import 'package:flutter/material.dart';

class OsmIframeMapWidget extends StatelessWidget {
  final double latitude;
  final double longitude;
  final double zoom;

  const OsmIframeMapWidget({
    super.key,
    required this.latitude,
    required this.longitude,
    this.zoom = 15,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).dividerColor.withValues(alpha: 0.08),
      alignment: Alignment.center,
      child: Text(
        'Map preview is available on Web only.',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).hintColor),
        textAlign: TextAlign.center,
      ),
    );
  }
}


import 'dart:html' as html;
import 'dart:ui_web' as ui;

import 'package:flutter/material.dart';

class OsmIframeMapWidget extends StatefulWidget {
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
  State<OsmIframeMapWidget> createState() => _OsmIframeMapWidgetState();
}

class _OsmIframeMapWidgetState extends State<OsmIframeMapWidget> {
  late final String _viewType;

  @override
  void initState() {
    super.initState();
    _viewType = 'osm-iframe-${widget.latitude}-${widget.longitude}-${DateTime.now().microsecondsSinceEpoch}';

    final src = _buildOsmEmbedUrl(
      latitude: widget.latitude,
      longitude: widget.longitude,
      zoom: widget.zoom,
    );

    ui.platformViewRegistry.registerViewFactory(_viewType, (int viewId) {
      final iframe = html.IFrameElement()
        ..src = src
        ..style.border = '0'
        ..style.width = '100%'
        ..style.height = '100%'
        ..referrerPolicy = 'no-referrer-when-downgrade'
        ..allowFullscreen = true;

      return iframe;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: HtmlElementView(viewType: _viewType),
    );
  }

  String _buildOsmEmbedUrl({
    required double latitude,
    required double longitude,
    required double zoom,
  }) {
    final z = zoom.clamp(1, 19);
    final delta = _zoomToDeltaDegrees(z.toDouble());
    final left = (longitude - delta).clamp(-180, 180);
    final right = (longitude + delta).clamp(-180, 180);
    final top = (latitude + delta).clamp(-90, 90);
    final bottom = (latitude - delta).clamp(-90, 90);

    final bbox = '$left,$bottom,$right,$top';
    final marker = '$latitude,$longitude';
    return 'https://www.openstreetmap.org/export/embed.html?bbox=$bbox&layer=mapnik&marker=$marker';
  }

  double _zoomToDeltaDegrees(double zoom) {
    // Rough bbox size for a pleasant preview.
    // zoom 15 ~= neighborhood; higher zoom => smaller bbox.
    final base = 0.02;
    final factor = (15 - zoom).clamp(-6, 10);
    final scale = (factor >= 0) ? (1 + (factor * 0.35)) : (1 / (1 + (-factor * 0.45)));
    return base * scale;
  }
}


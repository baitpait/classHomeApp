import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/styles.dart';


class CustomToast {
  static final CustomToast _instance = CustomToast._internal();
  factory CustomToast() => _instance;
  CustomToast._internal();

  OverlayEntry? _overlayEntry;
  Timer? _toastTimer;


  void show(
      String message, {
        bool isError = true,
        Duration duration = const Duration(seconds: 5),
        required GlobalKey<NavigatorState> navigatorKey,
        ToastPosition position = ToastPosition.topRight,
        bool animate = true,
        double? borderRadius,
      }) {
    _toastTimer?.cancel();
    _overlayEntry?.remove();

    _overlayEntry = OverlayEntry(
      builder: (context) => _AnimatedToastWidget(
        message: message,
        isError: isError,
        position: position,
        animate: animate,
        borderRadius: borderRadius,
      ),
    );

    final overlay = navigatorKey.currentState?.overlay;
    if (overlay == null) return;
    overlay.insert(_overlayEntry!);


    _toastTimer = Timer(duration, () {
      _overlayEntry?.remove();
      _overlayEntry = null;
    });
  }



}

class _AnimatedToastWidget extends StatefulWidget {
  final String message;
  final bool isError;
  final ToastPosition position;
  final bool animate;
  final double? borderRadius;

  const _AnimatedToastWidget({
    required this.message,
    this.isError = true,
    this.position = ToastPosition.topRight,
    this.animate = true,
    this.borderRadius,
  });

  @override
  State<_AnimatedToastWidget> createState() => _AnimatedToastWidgetState();
}

class _AnimatedToastWidgetState extends State<_AnimatedToastWidget>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Animation<Offset>? _animation;

  @override
  void initState() {
    super.initState();
    if (widget.animate) {
      _controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 350),
      );

      // Slide down from top
      _animation = Tween<Offset>(
        begin: const Offset(0, -1),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: _controller!, curve: Curves.easeOutCubic));

      _controller?.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = widget.borderRadius ?? 28.0;
    final isError = widget.isError;
    final backgroundColor = isError ? Colors.red.shade700 : Colors.green.shade700;

    final toastContent = Material(
      color: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(minHeight: 52, maxWidth: 400),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: (isError ? Colors.red : Colors.green).withValues(alpha: 0.35),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.25),
                shape: BoxShape.circle,
              ),
              child: Icon(
                widget.isError ? Icons.close_rounded : Icons.check_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                widget.message,
                style: rubikBold.copyWith(
                  color: Colors.white,
                  fontSize: Dimensions.fontSizeDefault,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    Widget child = widget.animate && _animation != null
        ? SlideTransition(position: _animation!, child: toastContent)
        : toastContent;

    if (widget.position.centerHorizontally) {
      return Positioned(
        top: widget.position.top,
        bottom: widget.position.bottom,
        left: widget.position.left,
        right: widget.position.right,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: child,
          ),
        ),
      );
    }

    return Positioned(
      top: widget.position.top,
      bottom: widget.position.bottom,
      left: widget.position.left,
      right: widget.position.right,
      child: child,
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}

class ToastPosition {
  final double? top;
  final double? bottom;
  final double? left;
  final double? right;
  final bool centerHorizontally;

  const ToastPosition({
    this.top,
    this.bottom,
    this.left,
    this.right,
    this.centerHorizontally = false,
  });

  static const topCenter = ToastPosition(top: 24, left: 24, right: 24);
  static const bottomCenter = ToastPosition(bottom: 50, left: 50, right: 50);
  static const topRight = ToastPosition(top: 150, right: 50);
  static const bottomRight = ToastPosition(bottom: 50, right: 20);
  /// Centered popup in the middle of the screen (phone + desktop).
  static const popup = ToastPosition(top: 0, bottom: 0, left: 0, right: 0, centerHorizontally: true);
}
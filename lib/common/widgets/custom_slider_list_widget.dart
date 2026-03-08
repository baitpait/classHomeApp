import 'package:hexacom_user/features/home/widgets/arrow_icon_button_widget.dart';
import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/main.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:flutter/material.dart';

class CustomSliderListWidget extends StatefulWidget {
  final ScrollController controller;
  final double  verticalPosition;
  final double  horizontalPosition;
  final bool isShowForwardButton;
  final Widget child;
  const CustomSliderListWidget({
    super.key,required this.controller, required this.verticalPosition,
    this.horizontalPosition = 0,
    required this.child, this.isShowForwardButton = true,
  });

  @override
  State<CustomSliderListWidget> createState() => _CustomSliderListWidgetState();
}

class _CustomSliderListWidgetState extends State<CustomSliderListWidget> {


  bool showBackButton = false;
  bool showForwardButton = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_checkScrollPosition);
    if (widget.isShowForwardButton) {
      showForwardButton = true;
    }
  }

  @override
  void dispose() {
    if(ResponsiveHelper.isDesktop(Get.context!)) {
      widget.controller.dispose();
    }
    super.dispose();
  }

  void _checkScrollPosition() {
    final atStart = widget.controller.position.pixels <= 0;
    final atEnd = widget.controller.position.pixels >= widget.controller.position.maxScrollExtent;
    final newBack = !atStart;
    final newForward = !atEnd;
    if (showBackButton != newBack || showForwardButton != newForward) {
      setState(() {
        showBackButton = newBack;
        showForwardButton = newForward;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!ResponsiveHelper.isDesktop(context)) {
      return widget.child;
    }

    final bool isRtl = Directionality.of(context) == TextDirection.rtl;
    final double delta = Dimensions.webScreenWidth;

    return Stack(
      children: [
        widget.child,

        if (showBackButton)
          Positioned(
            top: widget.verticalPosition,
            left: isRtl ? null : widget.horizontalPosition,
            right: isRtl ? widget.horizontalPosition : null,
            child: ArrowIconButtonWidget(
              // Back button (always logical "previous")
              isRight: false,
              onTap: () => widget.controller.animateTo(
                widget.controller.offset - delta,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
              ),
            ),
          ),

        if (showForwardButton)
          Positioned(
            top: widget.verticalPosition,
            right: isRtl ? null : widget.horizontalPosition,
            left: isRtl ? widget.horizontalPosition : null,
            child: ArrowIconButtonWidget(
              // Forward button (always logical "next")
              isRight: true,
              onTap: () => widget.controller.animateTo(
                widget.controller.offset + delta,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
              ),
            ),
          ),
      ],
    );
  }
}


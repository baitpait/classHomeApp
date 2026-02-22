import 'package:hexacom_user/common/widgets/on_hover.dart';
import 'package:flutter/material.dart';

class ArrowIconButtonWidget extends StatelessWidget {
  final bool isRight;
  final void Function()? onTap;
  const ArrowIconButtonWidget({super.key, this.isRight = true, this.onTap});

  @override
  Widget build(BuildContext context) {
    // In RTL (e.g. Arabic), flip arrow so left shows ← and right shows →
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final showForwardIcon = isRtl ? !isRight : isRight;
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        height: 40, width: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).cardColor,
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
        ),
        child: OnHover(child: Icon(showForwardIcon ? Icons.arrow_forward : Icons.arrow_back, color: Theme.of(context).primaryColor, size: 25)),
      ),
    );
  }
}

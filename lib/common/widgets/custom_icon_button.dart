import 'package:flutter/material.dart';
import 'package:hexacom_user/utill/dimensions.dart';

class CustomFilterButton extends StatelessWidget {
  final Function()? onTap;
  final bool isFiltered;
  const CustomFilterButton({super.key, this.onTap, this.isFiltered = false});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
              border: Border.all(color: Theme.of(context).primaryColor),
            ),
            child: Icon(Icons.filter_list, color: Theme.of(context).primaryColor, size: Dimensions.paddingSizeLarge),
          ),

          if(isFiltered) Positioned(
            top: 8, right: 7,
            child: Container(
              height: 10, width: 10,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.error,
                shape: BoxShape.circle,
              ),
            ),

          ),
        ],
      ),
    );
  }
}

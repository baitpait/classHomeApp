import 'package:hexacom_user/provider/theme_provider.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ThemeSwitchButtonWidget extends StatefulWidget {
  final bool fromWebBar;
  const ThemeSwitchButtonWidget({super.key, this.fromWebBar = true});

  @override
  State<ThemeSwitchButtonWidget> createState() => _ThemeSwitchButtonWidgetState();
}

class _ThemeSwitchButtonWidgetState extends State<ThemeSwitchButtonWidget> with SingleTickerProviderStateMixin{


  @override
  void initState() {
    super.initState();

  }




  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return InkWell(
          hoverColor: Colors.transparent,
          onTap: ()=> themeProvider.toggleTheme(),
          child: AnimatedContainer(
            curve: Curves.easeInOutCirc,
            duration: const Duration(seconds: 1),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
              Icon(
                themeProvider.darkTheme ? Icons.dark_mode : Icons.light_mode,
                size: widget.fromWebBar ? Dimensions.paddingSizeLarge : 35,
                color: widget.fromWebBar ? null : Colors.white,
              ),
            ],
            ),
          ),
        );
      }
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hexacom_user/common/models/config_model.dart';
import 'package:hexacom_user/features/splash/providers/splash_provider.dart';
import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/utill/images.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

/// Floating WhatsApp action: same rules as admin [ConfigModel.whatsapp], shown app-wide.
///
/// [routeChangeListenable] should be the app [GoRouter.routerDelegate] so bottom inset
/// updates when leaving tab shell routes (MaterialApp.builder sits above [InheritedGoRouter]).
class GlobalWhatsappFabOverlay extends StatelessWidget {
  const GlobalWhatsappFabOverlay({super.key, required this.routeChangeListenable});

  final Listenable routeChangeListenable;

  static String? whatsappLaunchUrl(ConfigModel? config) {
    final whatsapp = config?.whatsapp;
    if (!(whatsapp?.status ?? false)) return null;
    final raw = (whatsapp?.number ?? '').trim();
    if (raw.isEmpty) return null;
    final normalized = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (normalized.isEmpty) return null;
    return 'https://wa.me/$normalized';
  }

  static double _bottomInset(BuildContext context) {
    const base = 24.0;
    const pillClearance = 78.0;
    if (ResponsiveHelper.isDesktop(context)) return base;
    try {
      final loc = GoRouterState.of(context).matchedLocation;
      final onTabShell = loc == '/main' || loc == '/';
      return onTabShell ? base + pillClearance : base;
    } catch (_) {
      return base + pillClearance;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: routeChangeListenable,
      builder: (context, _) {
        return Selector<SplashProvider, String?>(
          selector: (_, splash) => whatsappLaunchUrl(splash.configModel),
          shouldRebuild: (prev, next) => prev != next,
          builder: (context, url, _) {
            if (url == null) return const SizedBox.shrink();
            final bottom = _bottomInset(context);
            return Positioned(
              right: 24,
              bottom: bottom,
              child: FloatingActionButton(
                heroTag: 'global-whatsapp-fab',
                onPressed: () async {
                  if (await canLaunchUrlString(url)) {
                    await launchUrlString(url);
                  }
                },
                backgroundColor: const Color(0xFF25D366),
                shape: const CircleBorder(),
                child: Image.asset(
                  Images.whatsapp,
                  width: 32,
                  height: 32,
                  color: Colors.white,
                ),
              ),
            );
          },
        );
      },
    );
  }
}

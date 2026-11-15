import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/session/presentation/session_screen.dart';
import '../../features/quotes/presentation/quotes_screen.dart';
import '../../features/discover/presentation/discover_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/home',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShellScaffold(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                name: 'home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/session',
                name: 'session',
                builder: (context, state) => const SessionScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/quotes',
                name: 'quotes',
                builder: (context, state) => const QuotesScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/discover',
                name: 'discover',
                builder: (context, state) => const DiscoverScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

/// Mockup'taki alt sekme çubuğu (`nav`):
/// `h-[88px] bg-white/90 backdrop-blur border-t border-sand px-3 pt-2.5 flex justify-around`
class AppShellScaffold extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AppShellScaffold({
    super.key,
    required this.navigationShell,
  });

  static const _tabs = [
    (icon: LucideIcons.home, label: 'Ana Sayfa'),
    (icon: LucideIcons.timer, label: 'Seans'),
    (icon: LucideIcons.quote, label: 'Alıntılar'),
    (icon: LucideIcons.lightbulb, label: 'Keşfet'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        bottom: false,
        child: navigationShell,
      ),
      bottomNavigationBar: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.90),
              border: const Border(
                top: BorderSide(color: AppColors.sand),
              ),
            ),
            child: SafeArea(
              top: false,
              child: SizedBox(
                height: 64,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(_tabs.length, (index) {
                      final tab = _tabs[index];
                      final isSelected = navigationShell.currentIndex == index;
                      final color = isSelected
                          ? AppColors.terra
                          : AppColors.navInactive;

                      return InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () {
                          navigationShell.goBranch(
                            index,
                            initialLocation:
                                index == navigationShell.currentIndex,
                          );
                        },
                        child: SizedBox(
                          width: 80,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                tab.icon,
                                size: 22,
                                color: color,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                tab.label,
                                style: AppTypography.sans(
                                  fontSize: 10.5,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                  color: color,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

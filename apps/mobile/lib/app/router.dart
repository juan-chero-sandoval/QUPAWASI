import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../presentation/common/not_found_view.dart';
import '../presentation/common/placeholder_views.dart';
import '../presentation/suggestions/suggestions_view.dart';
import '../presentation/home/home_view.dart';
import '../presentation/map/map_view.dart';
import '../presentation/onboarding/welcome_view.dart';
import '../presentation/profile/profile_view.dart';
import '../presentation/recycling/record_detail_view.dart';
import '../presentation/recycling/record_form_view.dart';
import '../presentation/recycling/qr_deposit_view.dart';
import '../presentation/recycling/recycling_view.dart';
import '../presentation/rewards/rewards_view.dart';
import '../presentation/settings/app_settings_view_model.dart';
import '../presentation/shell/app_shell.dart';
import 'routes.dart';

/// Router con cinco pestañas (una pila por pestaña) y rutas auxiliares.
///
/// Los parámetros viajan como texto en la ruta o query string; las vistas
/// recargan la entidad por ID, sin depender de objetos en `extra`.
GoRouter createRouter({
  required AppSettingsViewModel settings,
  String initialLocation = AppRoutes.home,
}) {
  final rootKey = GlobalKey<NavigatorState>(debugLabel: 'root');
  return GoRouter(
    navigatorKey: rootKey,
    initialLocation: initialLocation,
    refreshListenable: settings,
    redirect: (context, state) {
      final atWelcome = state.matchedLocation == AppRoutes.welcome;
      if (!settings.onboardingCompleted) {
        return atWelcome ? null : AppRoutes.welcome;
      }
      return atWelcome ? AppRoutes.home : null;
    },
    errorBuilder: (context, state) =>
        NotFoundView(location: state.uri.toString()),
    routes: [
      GoRoute(path: '/', redirect: (_, _) => AppRoutes.home),
      GoRoute(
        path: AppRoutes.welcome,
        builder: (context, state) => const WelcomeView(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (context, state) => const HomeView(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.recycling,
                builder: (context, state) =>
                    RecyclingView(filter: state.uri.queryParameters['filter']),
                routes: [
                  // `new` va antes que la ruta dinámica `:recordId`.
                  GoRoute(
                    path: 'new',
                    builder: (context, state) => QrDepositView(
                      pointId: state.uri.queryParameters['pointId'],
                    ),
                  ),
                  GoRoute(
                    path: ':recordId',
                    builder: (context, state) => RecordDetailView(
                      recordId: state.pathParameters['recordId']!,
                    ),
                    routes: [
                      GoRoute(
                        path: 'edit',
                        builder: (context, state) => RecordFormView.edit(
                          recordId: state.pathParameters['recordId']!,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.map,
                builder: (context, state) =>
                    MapView(pointId: state.uri.queryParameters['pointId']),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.rewards,
                builder: (context, state) => RewardsView(
                  category: state.uri.queryParameters['category'],
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                builder: (context, state) => const ProfileView(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.ranking,
        parentNavigatorKey: rootKey,
        builder: (context, state) => const RankingView(),
      ),
      GoRoute(
        path: AppRoutes.suggestions,
        parentNavigatorKey: rootKey,
        builder: (context, state) => const SuggestionsView(),
      ),
    ],
  );
}

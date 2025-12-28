import 'package:go_router/go_router.dart';
import '../features/home/home_screen.dart';
import '../features/groups/group_detail_screen.dart';
import '../features/groups/app_picker_screen.dart';
import '../features/settings/settings_screen.dart';

final appRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (_, __) => const HomeScreen(),
      routes: [
        GoRoute(path: 'settings', builder: (_, __) => const SettingsScreen()),
        GoRoute(
          path: 'group/:id',
          builder: (_, state) =>
              GroupDetailScreen(groupId: state.pathParameters['id']!),
          routes: [
            GoRoute(
              path: 'pick-apps',
              builder: (_, state) =>
                  AppPickerScreen(groupId: state.pathParameters['id']!),
            ),
          ],
        ),
      ],
    ),
  ],
);

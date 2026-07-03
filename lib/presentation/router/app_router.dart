import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../pages/home/home_page.dart';
import '../pages/inventory/inventory_page.dart';
import '../pages/inventory/color_detail_page.dart';
import '../pages/inventory/bulk_inventory_page.dart';
import '../pages/recognition/upload_page.dart';
import '../pages/recognition/recognition_result_page.dart';
import '../pages/patterns/patterns_page.dart';
import '../pages/patterns/pattern_detail_page.dart';
import '../pages/ai_generate/ai_generate_page.dart';
import '../pages/ai_generate/crop_page.dart';
import '../pages/ai_generate/preview_page.dart';
import '../pages/profile/profile_page.dart';

/// 底部导航栏结构
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/home',
    routes: [
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomePage(),
            ),
          ),
          GoRoute(
            path: '/inventory',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: InventoryPage(),
            ),
            routes: [
              GoRoute(
                path: 'detail/:colorId',
                builder: (context, state) => ColorDetailPage(
                  colorId: int.parse(state.pathParameters['colorId']!),
                ),
              ),
              GoRoute(
                path: 'bulk',
                builder: (context, state) => const BulkInventoryPage(),
              ),
            ],
          ),
          GoRoute(
            path: '/patterns',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: PatternsPage(),
            ),
            routes: [
              GoRoute(
                path: 'detail/:patternId',
                builder: (context, state) => PatternDetailPage(
                  patternId: state.pathParameters['patternId']!,
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/ai-generate',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: AiGeneratePage(),
            ),
          ),
          GoRoute(
            path: '/profile',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ProfilePage(),
            ),
          ),
        ],
      ),
      // 全屏路由（无底部导航栏）
      GoRoute(
        path: '/recognition/upload',
        builder: (context, state) => const UploadPage(),
      ),
      GoRoute(
        path: '/recognition/result',
        builder: (context, state) => const RecognitionResultPage(),
      ),
      GoRoute(
        path: '/ai-generate/crop',
        builder: (context, state) => const CropPage(),
      ),
      GoRoute(
        path: '/ai-generate/preview',
        builder: (context, state) => const PreviewPage(),
      ),
    ],
  );
});

/// 主导航外壳 — 底部 TabBar
class MainShell extends ConsumerWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  int _currentIndex(String location) {
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/inventory')) return 1;
    if (location.startsWith('/patterns')) return 2;
    if (location.startsWith('/ai-generate')) return 3;
    if (location.startsWith('/profile')) return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).uri.toString();
    final index = _currentIndex(location);

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        type: BottomNavigationBarType.fixed,
        onTap: (i) {
          switch (i) {
            case 0: context.go('/home');
            case 1: context.go('/inventory');
            case 2: context.go('/patterns');
            case 3: context.go('/ai-generate');
            case 4: context.go('/profile');
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: '首页'),
          BottomNavigationBarItem(icon: Icon(Icons.inventory_2_outlined), label: '库存'),
          BottomNavigationBarItem(icon: Icon(Icons.picture_as_pdf_outlined), label: '图纸'),
          BottomNavigationBarItem(icon: Icon(Icons.auto_awesome_outlined), label: 'AI生成'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: '我的'),
        ],
      ),
    );
  }
}

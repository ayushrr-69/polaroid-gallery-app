import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../screens/gallery/gallery_screen.dart';
import '../screens/favorites/favorites_screen.dart';
import '../screens/albums/albums_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../widgets/frosted_nav_bar.dart';

/// Main scaffold with IndexedStack + FrostedNavBar.
/// Uses [Theme.of(context).colorScheme] for dynamic theming.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    GalleryScreen(),
    FavoritesScreen(),
    AlbumsScreen(),
  ];

  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    await [
      Permission.photos,
      Permission.storage,
      Permission.location,
    ].request();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      extendBody: true,
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        title: Text(
          'CURATOR',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: cs.onSurface,
            fontWeight: FontWeight.w600,
            letterSpacing: 2.0,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
            icon: Icon(Icons.settings_outlined, color: cs.onSurfaceVariant),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: PageView(
        controller: _pageController,
        physics: const BouncingScrollPhysics(),
        onPageChanged: (index) {
          setState(() => _currentIndex = index);
        },
        children: _screens,
      ),
      bottomNavigationBar: FrostedNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
          );
        },
      ),
      floatingActionButton: _buildFab(context),
    );
  }

  Widget? _buildFab(BuildContext context) {
    if (_currentIndex == 0) {
      return _FrostedFab(
        icon: Icons.add_a_photo_rounded,
        onPressed: () => Navigator.pushNamed(context, '/curate'),
      );
    }
    if (_currentIndex == 2) {
      return _FrostedFab(
        icon: Icons.create_new_folder_rounded,
        onPressed: () => Navigator.pushNamed(context, '/create-album'),
      );
    }
    return null;
  }
}

class _FrostedFab extends StatelessWidget {
  const _FrostedFab({
    required this.icon,
    required this.onPressed,
  });

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.25),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.05),
            blurRadius: 16,
            spreadRadius: -4,
            blurStyle: BlurStyle.inner,
          ),
        ],
      ),
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onPressed,
              splashColor: cs.primary.withValues(alpha: 0.2),
              highlightColor: cs.primary.withValues(alpha: 0.1),
              child: SizedBox(
                width: 56,
                height: 56,
                child: Icon(
                  icon,
                  color: cs.primary,
                  size: 28,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

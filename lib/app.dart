import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/theme_provider.dart';
import 'navigation/app_shell.dart';
import 'screens/curate/curate_screen.dart';
import 'screens/create_album/create_album_screen.dart';
import 'state/gallery_provider.dart';

/// Root of the app. Uses [ListenableBuilder] to reactively rebuild
/// when [ThemeProvider] settings change (dark/light, accent, font).
class CuratorApp extends StatefulWidget {
  const CuratorApp({super.key});

  /// Access the ThemeProvider from anywhere via [CuratorApp.themeOf(context)].
  static ThemeProvider themeOf(BuildContext context) {
    return context.findAncestorStateOfType<_CuratorAppState>()!._themeProvider;
  }

  @override
  State<CuratorApp> createState() => _CuratorAppState();
}

class _CuratorAppState extends State<CuratorApp> {
  final _themeProvider = ThemeProvider();

  @override
  void dispose() {
    _themeProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _themeProvider,
      builder: (context, _) {
        return ChangeNotifierProvider(
          create: (_) => GalleryProvider(),
          child: MaterialApp(
            title: 'Curator Gallery',
            debugShowCheckedModeBanner: false,
            themeMode: _themeProvider.themeMode,
            theme: _themeProvider.lightTheme,
            darkTheme: _themeProvider.darkTheme,
            home: const AppShell(),
            routes: {
              '/curate': (context) => const CurateScreen(),
              '/create-album': (context) => const CreateAlbumScreen(),
            },
          ),
        );
      },
    );
  }
}

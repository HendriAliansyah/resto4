// lib/views/settings/settings_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:resto2/providers/theme_provider.dart';
import 'package:resto2/utils/constants.dart';
import 'package:resto2/views/widgets/app_drawer.dart';
import 'package:resto2/views/widgets/loading_indicator.dart';

class SettingsPage extends HookConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedThemeMode = ref.watch(themeModeProvider);
    final themeNotifier = ref.read(themeModeProvider.notifier);
    final previewThemeMode = ref.watch(previewThemeModeProvider);
    final isLoading = useState(false);
    final previewNotifierRef = useRef(
      ref.read(previewThemeModeProvider.notifier),
    );

    useEffect(() {
      final previewNotifier = previewNotifierRef.value;
      // Initialize the preview with the currently saved theme.
      Future.microtask(() {
        previewNotifier.state = savedThemeMode;
      });

      // THE DEFINITIVE FIX:
      // When the widget is disposed, schedule the state reset for the next microtask.
      // This ensures the widget tree is no longer building/disposing when the state is modified.
      return () {
        Future.microtask(() {
          previewNotifier.state = null;
        });
      };
    }, []); // Empty array ensures this runs only on mount and dispose.

    void handleSaveChanges() async {
      if (previewThemeMode == null) return;
      isLoading.value = true;
      try {
        await themeNotifier.setThemeMode(previewThemeMode);
        if (context.mounted) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(
                content: Text('Theme preference saved!'),
                behavior: SnackBarBehavior.floating,
                duration: Duration(seconds: 2),
              ),
            );
        }
      } finally {
        if (context.mounted) {
          isLoading.value = false;
        }
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      drawer: const AppDrawer(),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Text('Appearance', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            'Choose how the app looks.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          SegmentedButton<ThemeMode>(
            segments: const [
              ButtonSegment<ThemeMode>(
                value: ThemeMode.system,
                label: Text('System'),
                icon: Icon(Icons.brightness_auto_outlined),
              ),
              ButtonSegment<ThemeMode>(
                value: ThemeMode.light,
                label: Text('Light'),
                icon: Icon(Icons.light_mode_outlined),
              ),
              ButtonSegment<ThemeMode>(
                value: ThemeMode.dark,
                label: Text('Dark'),
                icon: Icon(Icons.dark_mode_outlined),
              ),
            ],
            selected: {previewThemeMode ?? savedThemeMode},
            onSelectionChanged: (newSelection) {
              ref.read(previewThemeModeProvider.notifier).state =
                  newSelection.first;
            },
          ),
          const SizedBox(height: 32),
          if (isLoading.value)
            const Center(child: LoadingIndicator())
          else
            ElevatedButton(
              onPressed:
                  previewThemeMode == savedThemeMode ? null : handleSaveChanges,
              child: const Text(UIStrings.saveChanges),
            ),
        ],
      ),
    );
  }
}

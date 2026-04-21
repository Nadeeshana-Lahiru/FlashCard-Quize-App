import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        centerTitle: true,
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
            children: [
              _buildSectionHeader("Appearance & Display"),
              const SizedBox(height: 12),
              _buildGlassCard(
                context,
                Column(
                  children: [
                    _buildThemeTile(
                      context,
                      title: 'Light Theme',
                      icon: Icons.light_mode,
                      mode: ThemeMode.light,
                      currentMode: provider.themeMode,
                      onChanged: provider.setThemeMode,
                    ),
                    _buildDivider(),
                    _buildThemeTile(
                      context,
                      title: 'Dark Theme',
                      icon: Icons.dark_mode,
                      mode: ThemeMode.dark,
                      currentMode: provider.themeMode,
                      onChanged: provider.setThemeMode,
                    ),
                    _buildDivider(),
                    _buildThemeTile(
                      context,
                      title: 'System Default',
                      icon: Icons.settings_suggest,
                      mode: ThemeMode.system,
                      currentMode: provider.themeMode,
                      onChanged: provider.setThemeMode,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),
              _buildSectionHeader("App Information"),
              const SizedBox(height: 12),
              _buildGlassCard(
                context,
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withAlpha(40),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.info_outline, color: colorScheme.primary),
                  ),
                  title: const Text("App Version", style: TextStyle(fontWeight: FontWeight.w600)),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      provider.appVersion,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.grey,
          letterSpacing: 1.2,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildGlassCard(BuildContext context, Widget child) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(80),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withAlpha(40),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: child,
      ),
    );
  }

  Widget _buildThemeTile(
    BuildContext context, {
    required String title,
    required IconData icon,
    required ThemeMode mode,
    required ThemeMode currentMode,
    required Function(ThemeMode) onChanged,
  }) {
    final isSelected = mode == currentMode;
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Icon(icon, color: isSelected ? colorScheme.primary : Colors.grey),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? colorScheme.primary : null,
        ),
      ),
      trailing: isSelected
          ? Icon(Icons.check_circle, color: colorScheme.primary)
          : const Icon(Icons.circle_outlined, color: Colors.grey),
      onTap: () => onChanged(mode),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, indent: 60, endIndent: 20, thickness: 0.5);
  }
}

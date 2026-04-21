import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    _nameController.text = settings.userName;
    _bioController.text = settings.userBio;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    FocusScope.of(context).unfocus();
    Provider.of<SettingsProvider>(context, listen: false)
        .updateProfile(_nameController.text.trim(), _bioController.text.trim());
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              CircleAvatar(
                radius: 60,
                backgroundColor: Theme.of(context).colorScheme.primary.withAlpha(50),
                child: Icon(Icons.person, size: 60, color: Theme.of(context).colorScheme.primary),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: "Your Name",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  prefixIcon: const Icon(Icons.badge_outlined),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(100),
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _bioController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: "Bio / Goals",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  alignLabelWithHint: true,
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(100),
                ),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: _saveProfile,
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text("Save Profile", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 32),
              Consumer<SettingsProvider>(
                builder: (context, settings, child) {
                  return _buildHeatmapSection(context, settings);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeatmapSection(BuildContext context, SettingsProvider settings) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(50),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Theme.of(context).colorScheme.outline.withAlpha(50)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.bar_chart, color: Colors.blueAccent),
                const SizedBox(width: 8),
                Text(
                  "Activity Heatmap (Last 30 Days)",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: List.generate(30, (index) {
                final date = DateTime.now().subtract(Duration(days: 29 - index));
                final dateString = date.toIso8601String().split('T')[0];
                final count = settings.reviewHeatmap[dateString] ?? 0;
                
                Color blockColor = Theme.of(context).colorScheme.surfaceContainerHighest;
                if (count > 0 && count <= 5) {
                  blockColor = Colors.green.withAlpha(100);
                } else if (count > 5 && count <= 15) {
                  blockColor = Colors.green.withAlpha(180);
                } else if (count > 15) {
                  blockColor = Colors.green;
                }

                return Tooltip(
                  message: "$dateString: $count reviews",
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: blockColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController _apiKeyController = TextEditingController();
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _apiKeyController.text =
        prefs.getString(AppConstants.keyApiKey) ?? '';
    setState(() {
      _isDarkMode = prefs.getString(AppConstants.keyThemeMode) == 'dark';
    });
  }

  Future<void> _saveApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyApiKey, _apiKeyController.text);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('API Key saved')),
      );
    }
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // API Settings
          ListTile(
            leading: const Icon(Icons.key),
            title: const Text('Melody.ml API Key'),
            subtitle: const Text('Configure your API key'),
            onTap: () => _showApiKeyDialog(),
          ),
          const Divider(),
          // Theme Settings
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode),
            title: const Text('Dark Mode'),
            value: _isDarkMode,
            onChanged: (value) async {
              setState(() {
                _isDarkMode = value;
              });
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString(
                AppConstants.keyThemeMode,
                value ? 'dark' : 'light',
              );
            },
          ),
          const Divider(),
          // About
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About'),
            subtitle: Text('SoundScribe v${AppConstants.appVersion}'),
            onTap: () => _showAboutDialog(),
          ),
        ],
      ),
    );
  }

  void _showApiKeyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('API Key'),
        content: TextField(
          controller: _apiKeyController,
          decoration: const InputDecoration(
            labelText: 'Melody.ml API Key',
            border: OutlineInputBorder(),
          ),
          obscureText: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              _saveApiKey();
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: AppConstants.appName,
      applicationVersion: AppConstants.appVersion,
      applicationLegalese: '© 2026 SoundScribe',
      children: [
        const SizedBox(height: 16),
        const Text(
          'AI-powered music transcription app that converts audio to guitar tabs.',
        ),
      ],
    );
  }
}

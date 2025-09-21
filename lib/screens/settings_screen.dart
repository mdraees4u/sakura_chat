// lib/screens/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/audio_provider.dart';
import '../providers/chat_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _enableNotifications = true;

  // JLPT Level descriptions
  final Map<String, String> jlptDescriptions = {
    'N5': 'Beginner - Basic phrases, hiragana/katakana, ~100 kanji',
    'N4': 'Elementary - Daily conversations, ~300 kanji',
    'N3': 'Intermediate - Common situations, ~650 kanji',
    'N2': 'Upper-Intermediate - Complex topics, ~1000 kanji',
    'N1': 'Advanced - Native-like fluency, ~2000 kanji',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
      ),
      body: ListView(
        children: [
          _buildThemeSection(),
          _buildAudioSection(),
          _buildLearningSection(),
          _buildChatSection(),
          _buildAboutSection(),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  Widget _buildThemeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Appearance'),
        Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  RadioListTile<ThemeMode>(
                    title: const Text('System Theme'),
                    subtitle: const Text('Follow system settings'),
                    value: ThemeMode.system,
                    groupValue: themeProvider.themeMode,
                    onChanged: (value) {
                      if (value != null) {
                        themeProvider.setThemeMode(value);
                      }
                    },
                  ),
                  RadioListTile<ThemeMode>(
                    title: const Text('Light Theme'),
                    subtitle: const Text('Always use light theme'),
                    value: ThemeMode.light,
                    groupValue: themeProvider.themeMode,
                    onChanged: (value) {
                      if (value != null) {
                        themeProvider.setThemeMode(value);
                      }
                    },
                  ),
                  RadioListTile<ThemeMode>(
                    title: const Text('Dark Theme'),
                    subtitle: const Text('Always use dark theme'),
                    value: ThemeMode.dark,
                    groupValue: themeProvider.themeMode,
                    onChanged: (value) {
                      if (value != null) {
                        themeProvider.setThemeMode(value);
                      }
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAudioSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Audio & Pronunciation'),
        Consumer2<AudioProvider, ChatProvider>(
          builder: (context, audioProvider, chatProvider, child) {
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  ListTile(
                    title: const Text('Default Playback Speed'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${audioProvider.playbackSpeed.toStringAsFixed(2)}x'),
                        Text(
                          'Range: 0.10x - 1.50x',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    trailing: SizedBox(
                      width: 180,
                      child: Slider(
                        value: audioProvider.playbackSpeed,
                        min: 0.10,
                        max: 1.50,
                        divisions: 14,
                        label: '${audioProvider.playbackSpeed.toStringAsFixed(2)}x',
                        onChanged: (value) {
                          audioProvider.setPlaybackSpeed(value);
                        },
                      ),
                    ),
                  ),
                  SwitchListTile(
                    title: const Text('Auto-play Audio'),
                    subtitle: const Text('Automatically play bot messages'),
                    value: chatProvider.autoPlayAudio,
                    onChanged: (value) {
                      chatProvider.setAutoPlayAudio(value);
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildLearningSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Learning Preferences'),
        Consumer<ChatProvider>(
          builder: (context, chatProvider, child) {
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  ListTile(
                    title: const Text('Focus Category'),
                    subtitle: Text(chatProvider.focusCategory == 'all'
                        ? 'All Categories'
                        : chatProvider.focusCategory.toUpperCase()),
                    trailing: DropdownButton<String>(
                      value: chatProvider.focusCategory,
                      items: const [
                        DropdownMenuItem(value: 'all', child: Text('All')),
                        DropdownMenuItem(value: 'business', child: Text('Business')),
                        DropdownMenuItem(value: 'daily', child: Text('Daily Life')),
                        DropdownMenuItem(value: 'social', child: Text('Social')),
                        DropdownMenuItem(value: 'greeting', child: Text('Greetings')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          chatProvider.setFocusCategory(value);
                        }
                      },
                    ),
                  ),
                  ExpansionTile(
                    title: const Text('JLPT Level'),
                    subtitle: Text('Current: ${chatProvider.jlptLevel}'),
                    children: [
                      for (final level in ['N5', 'N4', 'N3', 'N2', 'N1'])
                        RadioListTile<String>(
                          title: Text(level),
                          subtitle: Text(
                            jlptDescriptions[level]!,
                            style: const TextStyle(fontSize: 12),
                          ),
                          value: level,
                          groupValue: chatProvider.jlptLevel,
                          onChanged: (value) {
                            if (value != null) {
                              chatProvider.setJlptLevel(value);
                            }
                          },
                        ),
                    ],
                  ),
                  SwitchListTile(
                    title: const Text('Daily Reminders'),
                    subtitle: const Text('Get notifications to practice'),
                    value: _enableNotifications,
                    onChanged: (value) {
                      setState(() {
                        _enableNotifications = value;
                      });
                      if (value) {
                        // Schedule notifications
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Daily reminders enabled at 9:00 AM'),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildChatSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Chat Settings'),
        Consumer<ChatProvider>(
          builder: (context, chatProvider, child) {
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  ListTile(
                    title: const Text('Clear Chat History'),
                    subtitle: const Text('Delete all messages'),
                    leading: const Icon(Icons.delete_outline),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Clear Chat History?'),
                          content: const Text(
                            'This will delete all messages. This action cannot be undone.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                chatProvider.clearChat();
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Chat history cleared'),
                                  ),
                                );
                              },
                              child: const Text(
                                'Clear',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  ListTile(
                    title: const Text('Export Chat History'),
                    subtitle: const Text('Save conversations as text file'),
                    leading: const Icon(Icons.download),
                    onTap: () async {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => const Center(
                          child: CircularProgressIndicator(),
                        ),
                      );

                      final success = await chatProvider.saveChatToFile();

                      Navigator.pop(context); // Close loading dialog

                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Chat history exported successfully!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Failed to export. Please check permissions.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAboutSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('About'),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              const ListTile(
                title: Text('Version'),
                subtitle: Text('1.0.0'),
                leading: Icon(Icons.info_outline),
              ),
              ListTile(
                title: const Text('How to Use'),
                subtitle: const Text('Learn about app features'),
                leading: const Icon(Icons.help_outline),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  _showHowToUseDialog(context);
                },
              ),
              ListTile(
                title: const Text('JLPT Information'),
                subtitle: const Text('Learn about JLPT levels'),
                leading: const Icon(Icons.school_outlined),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  _showJLPTInfoDialog(context);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  void _showHowToUseDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('How to Use SakuraChat'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('🎌 Japanese Keyboard:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('• Tap the keyboard icon to open Japanese keyboard'),
              Text('• All characters have English labels'),
              Text('• Switch between Hiragana, Katakana, Kanji'),
              SizedBox(height: 12),
              Text('🔊 Audio Features:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('• Tap speaker icon next to any text'),
              Text('• Adjust speed: 0.10x - 1.50x'),
              Text('• Works for both Japanese and English'),
              SizedBox(height: 12),
              Text('💬 Suggestions:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('• Every suggestion shows Japanese|English'),
              Text('• Tap to send instantly'),
              SizedBox(height: 12),
              Text('💾 Save Conversations:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('• Export chat history as .txt file'),
              Text('• Includes both languages'),
              Text('• Saved to Downloads folder'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }

  void _showJLPTInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('JLPT Levels Explained'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final entry in jlptDescriptions.entries) ...[
                Text(
                  entry.key,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(entry.value),
                const SizedBox(height: 12),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
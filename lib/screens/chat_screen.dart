

// lib/screens/chat_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../providers/theme_provider.dart';
import '../providers/chat_provider.dart';
import '../providers/audio_provider.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/suggestion_bar.dart';
import '../widgets/japanese_keyboard.dart';
import 'settings_screen.dart';
import 'progress_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  bool _showCustomKeyboard = false;
  bool _isOnline = false;
  final Connectivity _connectivity = Connectivity();

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      setState(() {
        _isOnline = result != ConnectivityResult.none;
      });
      // Update pending translations when coming online
      if (_isOnline) {
        _updatePendingTranslations();
      }
    });
  }

  Future<void> _checkConnectivity() async {
    final result = await _connectivity.checkConnectivity();
    setState(() {
      _isOnline = result != ConnectivityResult.none;
    });
  }

  void _updatePendingTranslations() {
    // This will update all messages that have "Translation pending..." text
    final chatProvider = context.read<ChatProvider>();
    chatProvider.updatePendingTranslations(_isOnline);
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage(String text, {String? translation}) {
    if (text.trim().isEmpty) return;

    context.read<ChatProvider>().sendUserMessage(
      text,
      translation: translation,
      isOnline: _isOnline,
    );
    _controller.clear();
    _scrollToBottom();
  }

  void _showSpeedDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Audio Speed'),
          content: Consumer<AudioProvider>(
            builder: (context, audioProvider, child) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Playback Speed: ${audioProvider.playbackSpeed.toStringAsFixed(2)}x',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  Slider(
                    value: audioProvider.playbackSpeed,
                    min: 0.10,
                    max: 1.50,
                    divisions: 14,
                    label: '${audioProvider.playbackSpeed.toStringAsFixed(2)}x',
                    onChanged: (value) {
                      audioProvider.setPlaybackSpeed(value);
                    },
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Slow', style: Theme.of(context).textTheme.bodySmall),
                      Text('Normal', style: Theme.of(context).textTheme.bodySmall),
                      Text('Fast', style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Transform(
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateX(-0.1),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.spa, size: 24),
              ),
            ),
            const SizedBox(width: 12),
            const Text('SakuraChat'),
            const SizedBox(width: 8),
            // Online/Offline indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _isOnline ? Colors.green : Colors.orange,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    _isOnline ? Icons.wifi : Icons.wifi_off,
                    size: 14,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _isOnline ? 'Online' : 'Offline',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.speed),
            tooltip: 'Audio Speed',
            onPressed: _showSpeedDialog,
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart),
            tooltip: 'Progress',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProgressScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Consumer<ChatProvider>(
                  builder: (context, chatProvider, child) {
                    // Auto-play audio if enabled
                    if (chatProvider.messages.isNotEmpty &&
                        !chatProvider.messages.last.isUser &&
                        chatProvider.autoPlayAudio) {
                      Future.delayed(const Duration(milliseconds: 500), () {
                        if (mounted) {
                          context.read<AudioProvider>().playText(
                              chatProvider.messages.last.japanese
                          );
                        }
                      });
                    }

                    return ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: chatProvider.messages.length +
                          (chatProvider.isTyping ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index < chatProvider.messages.length) {
                          return ChatBubble(
                            message: chatProvider.messages[index],
                            onDelete: () => chatProvider.deleteMessage(index),
                          );
                        } else {
                          return const TypingIndicator();
                        }
                      },
                    );
                  },
                ),
              ),
              SuggestionBar(
                onSuggestionTap: (suggestion) {
                  // Parse suggestion if it contains translation
                  if (suggestion.contains('|')) {
                    final parts = suggestion.split('|');
                    _sendMessage(parts[0].trim(), translation: parts[1].trim());
                  } else {
                    _sendMessage(suggestion);
                  }
                },
              ),
              _buildInputBar(),
            ],
          ),
          if (_showCustomKeyboard)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: JapaneseKeyboard(
                onTextInput: (text) {
                  setState(() {
                    _controller.text += text;
                  });
                },
                onBackspace: () {
                  setState(() {
                    if (_controller.text.isNotEmpty) {
                      _controller.text = _controller.text.substring(
                        0,
                        _controller.text.length - 1,
                      );
                    }
                  });
                },
                onSpace: () {
                  setState(() {
                    _controller.text += ' ';
                  });
                },
                onEnter: () {
                  _sendMessage(_controller.text);
                },
                onClose: () {
                  setState(() {
                    _showCustomKeyboard = false;
                  });
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _showCustomKeyboard = true;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: _showCustomKeyboard
                          ? Theme.of(context).primaryColor
                          : Theme.of(context).dividerColor,
                      width: _showCustomKeyboard ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.keyboard,
                        size: 18,
                        color: _showCustomKeyboard
                            ? Theme.of(context).primaryColor
                            : Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _controller.text.isEmpty
                            ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '日本語で入力...',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              'Type in Japanese...',
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 11,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        )
                            : Text(
                          _controller.text,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Transform(
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateZ(-0.05),
              child: FloatingActionButton(
                mini: true,
                onPressed: _controller.text.isEmpty
                    ? null
                    : () => _sendMessage(_controller.text),
                elevation: 4,
                backgroundColor: _controller.text.isEmpty
                    ? Colors.grey[400]
                    : Theme.of(context).primaryColor,
                child: const Icon(Icons.send, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: Theme.of(context).primaryColor,
            radius: 18,
            child: const Icon(Icons.spa, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 8),
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                    bottomLeft: Radius.circular(4),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    for (int i = 0; i < 3; i++)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withOpacity(
                              _animation.value * 0.7 + 0.3,
                            ),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

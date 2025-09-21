// lib/widgets/chat_bubble.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/chat_message.dart';
import '../providers/audio_provider.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final VoidCallback? onDelete;

  const ChatBubble({
    super.key,
    required this.message,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment:
        isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor,
              radius: 18,
              child: const Icon(Icons.spa, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: GestureDetector(
              onLongPress: () => _showMessageOptions(context),
              child: Transform(
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateY(isUser ? 0.02 : -0.02),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isUser
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).cardColor,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isUser ? 16 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.japanese,
                        style: TextStyle(
                          fontSize: 16,
                          color: isUser ? Colors.white : null,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'NotoSansJP',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        message.english,
                        style: TextStyle(
                          fontSize: 14,
                          color: isUser
                              ? Colors.white.withOpacity(0.9)
                              : Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatTime(message.timestamp),
                        style: TextStyle(
                          fontSize: 10,
                          color: isUser
                              ? Colors.white.withOpacity(0.7)
                              : Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (!isUser) ...[
            const SizedBox(width: 4),
            Consumer<AudioProvider>(
              builder: (context, audioProvider, child) {
                final isPlayingThis = audioProvider.isPlaying &&
                    audioProvider.currentText == message.japanese;

                return Transform(
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateZ(0.1),
                  child: IconButton(
                    icon: Icon(
                      isPlayingThis ? Icons.stop : Icons.volume_up,
                      color: Theme.of(context).primaryColor,
                    ),
                    iconSize: 20,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 36,
                      minHeight: 36,
                    ),
                    onPressed: () {
                      if (isPlayingThis) {
                        audioProvider.stop();
                      } else {
                        audioProvider.playText(message.japanese);
                      }
                    },
                  ),
                );
              },
            ),
          ],
          if (isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
              radius: 18,
              child: Icon(
                Icons.person,
                color: Theme.of(context).primaryColor,
                size: 20,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  void _showMessageOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.copy),
                title: const Text('Copy Japanese'),
                onTap: () {
                  Clipboard.setData(ClipboardData(text: message.japanese));
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Copied to clipboard')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.translate),
                title: const Text('Copy Translation'),
                onTap: () {
                  Clipboard.setData(ClipboardData(text: message.english));
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Copied to clipboard')),
                  );
                },
              ),
              if (onDelete != null)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text(
                    'Delete Message',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    onDelete!();
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}









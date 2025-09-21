// lib/widgets/suggestion_bar.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';

class SuggestionBar extends StatelessWidget {
  final Function(String) onSuggestionTap;

  const SuggestionBar({
    super.key,
    required this.onSuggestionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        if (chatProvider.messages.isEmpty) {
          return _buildWelcomeSuggestions(context);
        }

        final lastMessage = chatProvider.messages.last;
        if (lastMessage.isUser ||
            lastMessage.suggestedReplies == null ||
            lastMessage.suggestedReplies!.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: lastMessage.suggestedReplies!.length,
            itemBuilder: (context, index) {
              final suggestion = lastMessage.suggestedReplies![index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 300 + (index * 100)),
                  curve: Curves.easeOutBack,
                  child: ElevatedButton(
                    onPressed: () => onSuggestionTap(suggestion),
                    style: ElevatedButton.styleFrom(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      suggestion,
                      style: const TextStyle(fontFamily: 'NotoSansJP'),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildWelcomeSuggestions(BuildContext context) {
    final welcomeSuggestions = [
      'こんにちは',
      'はじめまして',
      '練習しましょう',
    ];

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: welcomeSuggestions.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: OutlinedButton(
              onPressed: () => onSuggestionTap(welcomeSuggestions[index]),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: Theme.of(context).primaryColor.withOpacity(0.5),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.add_comment,
                    size: 16,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    welcomeSuggestions[index],
                    style: TextStyle(
                      fontFamily: 'NotoSansJP',
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
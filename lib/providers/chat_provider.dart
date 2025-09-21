// lib/providers/chat_provider.dart

import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:convert';
import '../models/chat_message.dart';
import '../services/conversation_engine.dart';
import '../database/database_helper.dart';
import '../services/gemini_service.dart';
import 'package:intl/intl.dart';

class ChatProvider extends ChangeNotifier {
  final List<ChatMessage> _messages = [];
  List<ChatMessage> get messages => _messages;

  final ConversationEngine _engine = ConversationEngine();
  final GeminiService _geminiService = GeminiService();

  bool _isTyping = false;
  bool get isTyping => _isTyping;

  // Learning preferences
  String _focusCategory = 'all';
  String _jlptLevel = 'N5';
  bool _autoPlayAudio = false;

  String get focusCategory => _focusCategory;
  String get jlptLevel => _jlptLevel;
  bool get autoPlayAudio => _autoPlayAudio;

  // Track messages needing translation
  final Map<int, bool> _pendingTranslations = {};

  ChatProvider() {
    _initializeWelcomeMessage();
    _initializeGemini();
  }

  Future<void> _initializeGemini() async {
    try {
      await _geminiService.initialize();
      debugPrint('Gemini service initialized successfully');
    } catch (e) {
      debugPrint('Gemini initialization failed: $e');
      // App will work in offline mode
    }
  }

  void _initializeWelcomeMessage() {
    _messages.add(ChatMessage(
      japanese: 'こんにちは！日本語の勉強を始めましょう。',
      english: 'Hello! Let\'s start studying Japanese.',
      isUser: false,
      timestamp: DateTime.now(),
      suggestedReplies: [
        'こんにちは|Hello',
        'はじめまして|Nice to meet you',
        'よろしくお願いします|Please treat me well',
        '日本語を勉強したいです|I want to study Japanese',
        'がんばります|I\'ll do my best'
      ],
    ));
    notifyListeners();
  }

  void setFocusCategory(String category) {
    _focusCategory = category;
    notifyListeners();
  }

  void setJlptLevel(String level) {
    _jlptLevel = level;
    notifyListeners();
  }

  void setAutoPlayAudio(bool value) {
    _autoPlayAudio = value;
    notifyListeners();
  }

  void addMessage(ChatMessage message) {
    _messages.add(message);
    notifyListeners();
  }

  void sendUserMessage(String text, {String? translation, bool isOnline = false}) {
    String japanese = text;
    String english = translation ?? 'Translation pending...';

    // If text contains | separator (from suggestion), parse it
    if (text.contains('|') && translation == null) {
      final parts = text.split('|');
      japanese = parts[0].trim();
      english = parts[1].trim();
    } else if (translation == null) {
      // User typed manually
      if (isOnline) {
        // Use Gemini for translation
        _translateText(text).then((translatedText) {
          // Update the message with translation
          if (_messages.isNotEmpty) {
            final lastIndex = _messages.length - 1;
            if (_messages[lastIndex].japanese == text) {
              _messages[lastIndex] = ChatMessage(
                japanese: text,
                english: translatedText,
                isUser: true,
                timestamp: _messages[lastIndex].timestamp,
              );
              notifyListeners();
            }
          }
        });
      } else {
        // Offline - mark for later translation
        english = 'Waiting for internet (offline)';
        final messageIndex = _messages.length;
        _pendingTranslations[messageIndex] = true;
      }
    }

    // Add user message
    addMessage(ChatMessage(
      japanese: japanese,
      english: english,
      isUser: true,
      timestamp: DateTime.now(),
    ));

    _isTyping = true;
    notifyListeners();

    // Generate bot response
    Future.delayed(const Duration(milliseconds: 800), () async {
      if (isOnline) {
        // Try to use Gemini for intelligent response
        await _generateSmartResponse(japanese);
      } else {
        // Use offline engine
        _generateOfflineResponse(japanese);
      }
    });
  }

  Future<void> _generateSmartResponse(String userInput) async {
    try {
      final response = await _geminiService.generateChatResponse(
        userInput: userInput,
        conversationHistory: _getConversationHistory(),
        level: _jlptLevel,
        category: _focusCategory,
      );

      addMessage(ChatMessage(
        japanese: response['japanese'] ?? 'すみません、もう一度お願いします。',
        english: response['english'] ?? 'Sorry, please try again.',
        isUser: false,
        timestamp: DateTime.now(),
        suggestedReplies: List<String>.from(response['suggestions'] ?? []),
      ));

      _isTyping = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Smart response failed: $e');
      // Fallback to offline engine
      _generateOfflineResponse(userInput);
    }
  }

  void _generateOfflineResponse(String userInput) {
    final response = _engine.generateResponse(
      userInput,
      level: _jlptLevel,
      category: _focusCategory == 'all' ? null : _focusCategory,
      isOnline: false,
    );

    addMessage(response);
    _isTyping = false;
    notifyListeners();
  }

  String _getConversationHistory() {
    // Get last 5 messages for context
    final recent = _messages.take(5).map((msg) {
      return '${msg.isUser ? "User" : "Bot"}: ${msg.japanese}';
    }).join('\n');
    return recent;
  }

  Future<String> _translateText(String text) async {
    try {
      // Use Gemini for translation
      final translation = await _geminiService.translateText(
        text,
        sourceLang: _isJapanese(text) ? 'ja' : 'en',
        targetLang: _isJapanese(text) ? 'en' : 'ja',
      );
      return translation;
    } catch (e) {
      debugPrint('Translation failed: $e');
      return 'Translation unavailable';
    }
  }

  bool _isJapanese(String text) {
    return RegExp(r'[\u3040-\u309F\u30A0-\u30FF\u4E00-\u9FAF]').hasMatch(text);
  }

  List<String> _enhanceSuggestions(List<String> suggestions, bool isOnline) {
    if (!isOnline) return suggestions;

    // Ensure all suggestions have translations
    return suggestions.map((suggestion) {
      if (suggestion.contains('|')) {
        return suggestion;
      } else {
        // Would call translation API here
        return '$suggestion|Translation';
      }
    }).toList();
  }

  void updatePendingTranslations(bool isOnline) {
    if (!isOnline) return;

    // Update all pending translations
    _pendingTranslations.forEach((index, pending) {
      if (pending && index < _messages.length) {
        final message = _messages[index];
        if (message.english.contains('pending') || message.english.contains('offline')) {
          _translateText(message.japanese).then((translation) {
            _messages[index] = ChatMessage(
              japanese: message.japanese,
              english: translation,
              isUser: message.isUser,
              timestamp: message.timestamp,
              suggestedReplies: message.suggestedReplies,
            );
            notifyListeners();
          });
        }
      }
    });
    _pendingTranslations.clear();
  }

  void clearChat() {
    _messages.clear();
    _pendingTranslations.clear();
    _initializeWelcomeMessage();
    notifyListeners();
  }

  void deleteMessage(int index) {
    if (index >= 0 && index < _messages.length) {
      _messages.removeAt(index);
      // Update pending translations indices
      final newPending = <int, bool>{};
      _pendingTranslations.forEach((key, value) {
        if (key > index) {
          newPending[key - 1] = value;
        } else if (key < index) {
          newPending[key] = value;
        }
      });
      _pendingTranslations
        ..clear()
        ..addAll(newPending);
      notifyListeners();
    }
  }

  Future<String> exportChatHistory() async {
    final StringBuffer buffer = StringBuffer();
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');

    buffer.writeln('=== SakuraChat Conversation History ===');
    buffer.writeln('Exported: ${dateFormat.format(DateTime.now())}');
    buffer.writeln('JLPT Level: $_jlptLevel');
    buffer.writeln('Focus: $_focusCategory');
    buffer.writeln('=' * 50);
    buffer.writeln();

    for (final message in _messages) {
      final sender = message.isUser ? 'You' : 'SakuraChat';
      final time = dateFormat.format(message.timestamp);

      buffer.writeln('[$time] $sender:');
      buffer.writeln('Japanese: ${message.japanese}');
      buffer.writeln('English: ${message.english}');

      if (!message.isUser && message.suggestedReplies != null) {
        buffer.writeln('Suggestions:');
        for (final reply in message.suggestedReplies!) {
          if (reply.contains('|')) {
            final parts = reply.split('|');
            buffer.writeln('  • ${parts[0]} (${parts[1]})');
          } else {
            buffer.writeln('  • $reply');
          }
        }
      }
      buffer.writeln('-' * 50);
      buffer.writeln();
    }

    return buffer.toString();
  }

  Future<bool> saveChatToFile() async {
    try {
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        final manageStatus = await Permission.manageExternalStorage.request();
        if (!manageStatus.isGranted) return false;
      }

      final content = await exportChatHistory();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final fileName = 'SakuraChat_$timestamp.txt';

      Directory? directory;
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory != null) {
        final file = File('${directory.path}/$fileName');
        await file.writeAsString(content);

        await Share.shareXFiles(
          [XFile(file.path)],
          subject: 'SakuraChat History',
          text: 'Saved to Downloads: $fileName',
        );

        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error saving: $e');
      return false;
    }
  }

  @override
  void dispose() {
    _geminiService.dispose();
    super.dispose();
  }
}
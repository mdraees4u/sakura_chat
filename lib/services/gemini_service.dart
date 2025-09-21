// lib/services/gemini_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiService {
  static final GeminiService _instance = GeminiService._internal();
  factory GeminiService() => _instance;
  GeminiService._internal();

  String? _apiKey;

  // Gemini API endpoint - using latest model
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent';

  // Rate limiting
  DateTime? _lastRequestTime;
  static const int _minRequestInterval = 100; // milliseconds
  int _requestCount = 0;
  static const int _maxRequestsPerMinute = 60;

  // Initialize service
  Future<void> initialize() async {
    try {
      // Load from environment file
      if (!dotenv.isInitialized) {
        await dotenv.load(fileName: '.env');
      }

      // Get API key from environment (you can encrypt it if needed)
      _apiKey = dotenv.env['GEMINI_API_KEY'] ?? dotenv.env['GEMINI_API_KEY_ENCRYPTED'];

      if (_apiKey == null || _apiKey!.isEmpty) {
        debugPrint('Gemini API key not found in .env file');
        throw Exception('API key not configured');
      }

      // If the key is base64 encoded, decode it
      if (_apiKey!.contains('=') && !_apiKey!.startsWith('AIza')) {
        try {
          _apiKey = utf8.decode(base64.decode(_apiKey!));
        } catch (e) {
          // Not base64 encoded, use as is
          debugPrint('Using API key as plain text');
        }
      }

      debugPrint('Gemini service initialized successfully');
    } catch (e) {
      debugPrint('Failed to initialize Gemini service: $e');
      rethrow;
    }
  }

  // Rate limiting check
  bool _canMakeRequest() {
    final now = DateTime.now();

    if (_lastRequestTime != null) {
      final timeDiff = now.difference(_lastRequestTime!).inMilliseconds;
      if (timeDiff < _minRequestInterval) {
        return false;
      }
    }

    if (_lastRequestTime == null ||
        now.difference(_lastRequestTime!).inMinutes >= 1) {
      _requestCount = 0;
    }

    if (_requestCount >= _maxRequestsPerMinute) {
      return false;
    }

    return true;
  }

  // Translate text using Gemini
  Future<String> translateText(String text, {
    String sourceLang = 'ja',
    String targetLang = 'en',
  }) async {
    if (text.isEmpty || text.length > 5000) {
      return 'Invalid input';
    }

    if (!_canMakeRequest()) {
      await Future.delayed(const Duration(milliseconds: 200));
      if (!_canMakeRequest()) {
        return 'Please wait...';
      }
    }

    if (_apiKey == null) {
      return 'Translation not available (offline)';
    }

    try {
      _lastRequestTime = DateTime.now();
      _requestCount++;

      final uri = Uri.parse('$_baseUrl?key=$_apiKey');

      String prompt;
      if (sourceLang == 'ja' && targetLang == 'en') {
        prompt = 'Translate this Japanese text to English (only the translation, nothing else): "$text"';
      } else {
        prompt = 'Translate this English text to natural Japanese (only the translation, nothing else): "$text"';
      }

      final requestBody = {
        'contents': [{
          'parts': [{'text': prompt}]
        }],
        'generationConfig': {
          'temperature': 0.3,
          'topK': 40,
          'topP': 0.95,
          'maxOutputTokens': 256,
        },
        'safetySettings': [
          {'category': 'HARM_CATEGORY_HARASSMENT', 'threshold': 'BLOCK_MEDIUM_AND_ABOVE'},
          {'category': 'HARM_CATEGORY_HATE_SPEECH', 'threshold': 'BLOCK_MEDIUM_AND_ABOVE'},
          {'category': 'HARM_CATEGORY_SEXUALLY_EXPLICIT', 'threshold': 'BLOCK_MEDIUM_AND_ABOVE'},
          {'category': 'HARM_CATEGORY_DANGEROUS_CONTENT', 'threshold': 'BLOCK_MEDIUM_AND_ABOVE'}
        ]
      };

      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['candidates'] != null &&
            data['candidates'].isNotEmpty &&
            data['candidates'][0]['content'] != null) {
          final translation = data['candidates'][0]['content']['parts'][0]['text'];
          return _cleanTranslation(translation.toString().trim());
        }
        return 'Translation not available';
      } else if (response.statusCode == 429) {
        return 'Too many requests';
      } else {
        debugPrint('API error: ${response.statusCode} - ${response.body}');
        return 'Translation failed';
      }
    } catch (e) {
      debugPrint('Translation error: $e');
      return 'Translation error';
    }
  }

  // Generate chat response
  Future<Map<String, dynamic>> generateChatResponse({
    required String userInput,
    required String conversationHistory,
    required String level,
    required String category,
  }) async {
    if (!_canMakeRequest()) {
      return {
        'japanese': 'しばらくお待ちください。',
        'english': 'Please wait a moment.',
        'suggestions': ['はい|Yes', 'わかりました|I understand']
      };
    }

    if (_apiKey == null) {
      return {
        'japanese': 'オフラインモードです。',
        'english': 'Offline mode.',
        'suggestions': []
      };
    }

    try {
      _lastRequestTime = DateTime.now();
      _requestCount++;

      final uri = Uri.parse('$_baseUrl?key=$_apiKey');

      final prompt = '''
You are a helpful Japanese language tutor for $level level learners.
Topic: $category
User said: "$userInput"

Respond naturally in Japanese with English translation.
Also provide 5 appropriate reply suggestions.

Format your response as JSON:
{
  "japanese": "your response in Japanese",
  "english": "English translation",
  "suggestions": [
    "suggestion1 in Japanese|English translation",
    "suggestion2 in Japanese|English translation",
    "suggestion3 in Japanese|English translation",
    "suggestion4 in Japanese|English translation",
    "suggestion5 in Japanese|English translation"
  ]
}''';

      final requestBody = {
        'contents': [{'parts': [{'text': prompt}]}],
        'generationConfig': {
          'temperature': 0.7,
          'maxOutputTokens': 512,
        }
      };

      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['candidates'] != null && data['candidates'].isNotEmpty) {
          final content = data['candidates'][0]['content']['parts'][0]['text'];

          try {
            // Try to parse as JSON
            final jsonStart = content.indexOf('{');
            final jsonEnd = content.lastIndexOf('}') + 1;
            if (jsonStart >= 0 && jsonEnd > jsonStart) {
              final jsonStr = content.substring(jsonStart, jsonEnd);
              final chatResponse = json.decode(jsonStr);
              return {
                'japanese': chatResponse['japanese'] ?? 'こんにちは',
                'english': chatResponse['english'] ?? 'Hello',
                'suggestions': List<String>.from(chatResponse['suggestions'] ?? []),
              };
            }
          } catch (e) {
            debugPrint('JSON parsing error: $e');
          }
        }
      }

      // Fallback response
      return {
        'japanese': 'すみません、もう一度お願いします。',
        'english': 'Sorry, please try again.',
        'suggestions': ['はい|Yes', 'いいえ|No', 'わかりません|I don\'t understand']
      };
    } catch (e) {
      debugPrint('Chat generation error: $e');
      return {
        'japanese': 'エラーが発生しました。',
        'english': 'An error occurred.',
        'suggestions': []
      };
    }
  }

  String _cleanTranslation(String translation) {
    // Remove markdown formatting
    translation = translation.replaceAll('*', '');
    translation = translation.replaceAll('_', '');
    translation = translation.replaceAll('`', '');
    translation = translation.replaceAll('#', '');

    // Remove quotes if wrapped
    if (translation.startsWith('"') && translation.endsWith('"')) {
      translation = translation.substring(1, translation.length - 1);
    }

    // Remove explanatory prefixes
    final prefixes = ['Translation:', 'English:', 'Japanese:', 'Answer:'];
    for (final prefix in prefixes) {
      if (translation.startsWith(prefix)) {
        translation = translation.substring(prefix.length).trim();
      }
    }

    return translation.trim();
  }

  void dispose() {
    _apiKey = null;
    _requestCount = 0;
    _lastRequestTime = null;
  }
}
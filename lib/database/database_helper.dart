// lib/database/database_helper.dart

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';
import 'dart:convert';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('sakurachat.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    // Vocabulary table
    await db.execute('''
      CREATE TABLE vocabulary (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        japanese TEXT NOT NULL,
        reading TEXT NOT NULL,
        english TEXT NOT NULL,
        category TEXT NOT NULL,
        level TEXT NOT NULL,
        frequency INTEGER DEFAULT 0,
        examples TEXT,
        audio_url TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Sentences table
    await db.execute('''
      CREATE TABLE sentences (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        japanese TEXT NOT NULL,
        romaji TEXT,
        english TEXT NOT NULL,
        category TEXT NOT NULL,
        context TEXT,
        difficulty INTEGER DEFAULT 1,
        audio_url TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Conversations table
    await db.execute('''
      CREATE TABLE conversations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        scenario_name TEXT NOT NULL,
        category TEXT NOT NULL,
        difficulty INTEGER DEFAULT 1,
        dialogue_json TEXT NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // User Progress table
    await db.execute('''
      CREATE TABLE user_progress (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        vocabulary_id INTEGER,
        sentence_id INTEGER,
        conversation_id INTEGER,
        mastery_level INTEGER DEFAULT 0,
        review_count INTEGER DEFAULT 0,
        last_reviewed TIMESTAMP,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (vocabulary_id) REFERENCES vocabulary (id),
        FOREIGN KEY (sentence_id) REFERENCES sentences (id),
        FOREIGN KEY (conversation_id) REFERENCES conversations (id)
      )
    ''');

    // Chat History table
    await db.execute('''
      CREATE TABLE chat_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        japanese_text TEXT NOT NULL,
        english_text TEXT NOT NULL,
        is_user INTEGER NOT NULL,
        conversation_context TEXT,
        timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ''');
  }

  // Initialize with sample data
  Future<void> initializeSampleData() async {
    final db = await database;

    // Check if data already exists
    final count = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM vocabulary')
    );

    if (count != null && count > 0) return;

    // Insert sample vocabulary
    final batch = db.batch();

    // Business vocabulary
    final businessVocab = [
      {
        'japanese': '会議',
        'reading': 'かいぎ',
        'english': 'meeting',
        'category': 'business',
        'level': 'N3',
        'examples': json.encode(['会議は何時ですか？', '会議に参加する']),
      },
      {
        'japanese': '契約',
        'reading': 'けいやく',
        'english': 'contract',
        'category': 'business',
        'level': 'N2',
        'examples': json.encode(['契約を結ぶ', '契約書を読む']),
      },
      {
        'japanese': '提案',
        'reading': 'ていあん',
        'english': 'proposal',
        'category': 'business',
        'level': 'N2',
        'examples': json.encode(['新しい提案があります', '提案を検討する']),
      },
    ];

    for (final vocab in businessVocab) {
      batch.insert('vocabulary', vocab);
    }

    // Daily life vocabulary
    final dailyVocab = [
      {
        'japanese': '買い物',
        'reading': 'かいもの',
        'english': 'shopping',
        'category': 'daily',
        'level': 'N4',
        'examples': json.encode(['買い物に行く', 'スーパーで買い物する']),
      },
      {
        'japanese': '電車',
        'reading': 'でんしゃ',
        'english': 'train',
        'category': 'daily',
        'level': 'N5',
        'examples': json.encode(['電車に乗る', '電車が遅れている']),
      },
      {
        'japanese': '予約',
        'reading': 'よやく',
        'english': 'reservation',
        'category': 'daily',
        'level': 'N3',
        'examples': json.encode(['レストランを予約する', '予約を取る']),
      },
    ];

    for (final vocab in dailyVocab) {
      batch.insert('vocabulary', vocab);
    }

    // Social vocabulary
    final socialVocab = [
      {
        'japanese': '友達',
        'reading': 'ともだち',
        'english': 'friend',
        'category': 'social',
        'level': 'N5',
        'examples': json.encode(['友達と会う', '新しい友達を作る']),
      },
      {
        'japanese': '趣味',
        'reading': 'しゅみ',
        'english': 'hobby',
        'category': 'social',
        'level': 'N4',
        'examples': json.encode(['趣味は何ですか？', '趣味を楽しむ']),
      },
    ];

    for (final vocab in socialVocab) {
      batch.insert('vocabulary', vocab);
    }

    // Sample sentences
    final sentences = [
      {
        'japanese': '明日の会議は何時からですか？',
        'romaji': 'Ashita no kaigi wa nanji kara desu ka?',
        'english': 'What time does tomorrow\'s meeting start?',
        'category': 'business',
        'context': 'office',
        'difficulty': 2,
      },
      {
        'japanese': 'このプロジェクトはいつまでに完成させる必要がありますか？',
        'romaji': 'Kono purojekuto wa itsu made ni kansei saseru hitsuyou ga arimasu ka?',
        'english': 'When does this project need to be completed?',
        'category': 'business',
        'context': 'project_management',
        'difficulty': 3,
      },
      {
        'japanese': '駅までどのくらいかかりますか？',
        'romaji': 'Eki made dono kurai kakarimasu ka?',
        'english': 'How long does it take to get to the station?',
        'category': 'daily',
        'context': 'transportation',
        'difficulty': 1,
      },
      {
        'japanese': '週末は何をする予定ですか？',
        'romaji': 'Shuumatsu wa nani wo suru yotei desu ka?',
        'english': 'What are your plans for the weekend?',
        'category': 'social',
        'context': 'casual_conversation',
        'difficulty': 1,
      },
    ];

    for (final sentence in sentences) {
      batch.insert('sentences', sentence);
    }

    // Sample conversations
    final conversations = [
      {
        'scenario_name': 'Job Interview',
        'category': 'business',
        'difficulty': 3,
        'dialogue_json': json.encode({
          'dialogue': [
            {
              'speaker': 'interviewer',
              'japanese': 'どうして我が社で働きたいと思いましたか？',
              'english': 'Why do you want to work for our company?',
            },
            {
              'speaker': 'candidate',
              'japanese': '貴社の革新的な技術に興味があります。',
              'english': 'I\'m interested in your company\'s innovative technology.',
            },
          ]
        }),
      },
      {
        'scenario_name': 'Restaurant Order',
        'category': 'daily',
        'difficulty': 1,
        'dialogue_json': json.encode({
          'dialogue': [
            {
              'speaker': 'waiter',
              'japanese': 'ご注文はお決まりですか？',
              'english': 'Are you ready to order?',
            },
            {
              'speaker': 'customer',
              'japanese': 'はい、ラーメンを一つください。',
              'english': 'Yes, I\'ll have one ramen, please.',
            },
          ]
        }),
      },
    ];

    for (final conversation in conversations) {
      batch.insert('conversations', conversation);
    }

    await batch.commit();
  }

  // Query methods
  Future<List<Map<String, dynamic>>> getVocabularyByCategory(String category) async {
    final db = await database;
    return await db.query(
      'vocabulary',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'frequency DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getSentencesByDifficulty(int difficulty) async {
    final db = await database;
    return await db.query(
      'sentences',
      where: 'difficulty <= ?',
      whereArgs: [difficulty],
      orderBy: 'difficulty ASC',
    );
  }

  Future<void> saveChatMessage(String japanese, String english, bool isUser, String context) async {
    final db = await database;
    await db.insert('chat_history', {
      'japanese_text': japanese,
      'english_text': english,
      'is_user': isUser ? 1 : 0,
      'conversation_context': context,
    });
  }

  Future<List<Map<String, dynamic>>> getChatHistory({int limit = 50}) async {
    final db = await database;
    return await db.query(
      'chat_history',
      orderBy: 'timestamp DESC',
      limit: limit,
    );
  }

  Future<void> updateUserProgress(int vocabularyId, int masteryLevel) async {
    final db = await database;

    final existing = await db.query(
      'user_progress',
      where: 'vocabulary_id = ?',
      whereArgs: [vocabularyId],
    );

    if (existing.isEmpty) {
      await db.insert('user_progress', {
        'vocabulary_id': vocabularyId,
        'mastery_level': masteryLevel,
        'review_count': 1,
        'last_reviewed': DateTime.now().toIso8601String(),
      });
    } else {
      await db.update(
        'user_progress',
        {
          'mastery_level': masteryLevel,
          'review_count': (existing.first['review_count'] as int) + 1,
          'last_reviewed': DateTime.now().toIso8601String(),
        },
        where: 'vocabulary_id = ?',
        whereArgs: [vocabularyId],
      );
    }
  }

  Future<Map<String, dynamic>> getUserStats() async {
    final db = await database;

    final totalVocab = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM vocabulary')
    ) ?? 0;

    final learnedVocab = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM user_progress WHERE mastery_level >= 3')
    ) ?? 0;

    final totalSentences = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM sentences')
    ) ?? 0;

    final totalChats = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM chat_history')
    ) ?? 0;

    return {
      'totalVocabulary': totalVocab,
      'learnedVocabulary': learnedVocab,
      'totalSentences': totalSentences,
      'totalChats': totalChats,
      'masteryPercentage': totalVocab > 0 ? (learnedVocab / totalVocab * 100).round() : 0,
    };
  }

  Future<Map<String, dynamic>> getItemsForReview() async {
    final db = await database;

    // Get items that need review based on spaced repetition intervals
    final items = await db.rawQuery('''
      SELECT v.*, p.mastery_level, p.last_reviewed
      FROM vocabulary v
      JOIN user_progress p ON v.id = p.vocabulary_id
      WHERE datetime(p.last_reviewed) <= datetime('now', '-' || 
        CASE 
          WHEN p.mastery_level = 0 THEN '0'
          WHEN p.mastery_level = 1 THEN '1'
          WHEN p.mastery_level = 2 THEN '3'
          WHEN p.mastery_level = 3 THEN '7'
          WHEN p.mastery_level = 4 THEN '14'
          ELSE '30'
        END || ' days')
      ORDER BY p.last_reviewed ASC
      LIMIT 20
    ''');

    return {'items': items};
  }

  Future<List<Map<String, dynamic>>> searchContent(String query) async {
    final db = await database;
    final searchTerm = '%$query%';

    final vocabularyResults = await db.query(
      'vocabulary',
      where: 'japanese LIKE ? OR english LIKE ? OR reading LIKE ?',
      whereArgs: [searchTerm, searchTerm, searchTerm],
      limit: 20,
    );

    final sentenceResults = await db.query(
      'sentences',
      where: 'japanese LIKE ? OR english LIKE ?',
      whereArgs: [searchTerm, searchTerm],
      limit: 20,
    );

    return [
      ...vocabularyResults.map((v) => {...v, 'type': 'vocabulary'}),
      ...sentenceResults.map((s) => {...s, 'type': 'sentence'}),
    ];
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
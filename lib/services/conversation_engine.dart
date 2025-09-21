// lib/services/conversation_engine.dart

import 'dart:math';
import '../models/chat_message.dart';

class ConversationEngine {
  final Random _random = Random();
  int _conversationDepth = 0;
  String _lastTopic = 'greeting';

  // Track conversation flow for intelligent responses
  List<String> _conversationHistory = [];

  // JLPT Level-based responses
  final Map<String, Map<String, List<ConversationScenario>>> _scenariosByLevel = {
    'N5': {
      'greeting': [
        ConversationScenario(
          context: 'Basic Greeting',
          responses: [
            Response(
              japanese: 'こんにちは！はじめまして。',
              english: 'Hello! Nice to meet you.',
              suggestions: [
                'はじめまして|Nice to meet you',
                'こんにちは|Hello',
                'よろしくお願いします|Please treat me well'
              ],
            ),
            Response(
              japanese: 'げんきですか？',
              english: 'How are you?',
              suggestions: [
                'げんきです|I am fine',
                'まあまあです|So-so',
                'つかれています|I am tired',
                'とてもげんきです|Very well'
              ],
            ),
            Response(
              japanese: 'おなまえは？',
              english: 'What is your name?',
              suggestions: [
                'わたしは[name]です|I am [name]',
                'なまえは[name]です|My name is [name]',
                '[name]とよんでください|Please call me [name]'
              ],
            ),
          ],
        ),
      ],
      'daily': [
        ConversationScenario(
          context: 'Time',
          responses: [
            Response(
              japanese: 'いまなんじですか？',
              english: 'What time is it now?',
              suggestions: [
                'ごじです|It\'s 5 o\'clock',
                'ごじはんです|It\'s 5:30',
                'わかりません|I don\'t know',
                'けいたいをみます|I\'ll check my phone'
              ],
            ),
            Response(
              japanese: 'きょうはなんようびですか？',
              english: 'What day is it today?',
              suggestions: [
                'げつようびです|It\'s Monday',
                'きんようびです|It\'s Friday',
                'どようびです|It\'s Saturday',
                'にちようびです|It\'s Sunday'
              ],
            ),
          ],
        ),
        ConversationScenario(
          context: 'Food',
          responses: [
            Response(
              japanese: 'なにをたべますか？',
              english: 'What will you eat?',
              suggestions: [
                'すしをたべます|I\'ll eat sushi',
                'ラーメンがすきです|I like ramen',
                'おべんとうをかいました|I bought a bento',
                'まだきめていません|I haven\'t decided yet'
              ],
            ),
            Response(
              japanese: 'おなかがすきましたか？',
              english: 'Are you hungry?',
              suggestions: [
                'はい、とてもすきました|Yes, very hungry',
                'すこしすきました|A little hungry',
                'いいえ、すきません|No, not hungry',
                'たべたばかりです|I just ate'
              ],
            ),
          ],
        ),
      ],
      'numbers': [
        ConversationScenario(
          context: 'Counting',
          responses: [
            Response(
              japanese: 'いくつありますか？',
              english: 'How many are there?',
              suggestions: [
                'ひとつ|One',
                'ふたつ|Two',
                'みっつ|Three',
                'たくさん|Many',
                'すこし|A few'
              ],
            ),
            Response(
              japanese: 'いくらですか？',
              english: 'How much is it?',
              suggestions: [
                'ひゃくえん|100 yen',
                'せんえん|1000 yen',
                'たかいです|It\'s expensive',
                'やすいです|It\'s cheap'
              ],
            ),
          ],
        ),
      ],
    },
    'N4': {
      'business': [
        ConversationScenario(
          context: 'Work',
          responses: [
            Response(
              japanese: 'しごとはどうですか？',
              english: 'How is work?',
              suggestions: [
                'いそがしいです|It\'s busy',
                'たいへんです|It\'s tough',
                'おもしろいです|It\'s interesting',
                'つまらないです|It\'s boring',
                'やりがいがあります|It\'s rewarding'
              ],
            ),
            Response(
              japanese: 'なんじにしごとがおわりますか？',
              english: 'What time does work end?',
              suggestions: [
                'ろくじにおわります|It ends at 6',
                'ざんぎょうがあります|I have overtime',
                'きょうははやくかえれます|I can go home early today',
                'まだわかりません|I don\'t know yet'
              ],
            ),
          ],
        ),
      ],
      'shopping': [
        ConversationScenario(
          context: 'Store',
          responses: [
            Response(
              japanese: 'なにをさがしていますか？',
              english: 'What are you looking for?',
              suggestions: [
                'プレゼントをさがしています|I\'m looking for a present',
                'ようふくがほしいです|I want clothes',
                'たべものをかいたいです|I want to buy food',
                'みているだけです|Just looking'
              ],
            ),
            Response(
              japanese: 'このサイズはありますか？',
              english: 'Do you have this size?',
              suggestions: [
                'もっとおおきいサイズ|Bigger size',
                'もっとちいさいサイズ|Smaller size',
                'ちょうどいいです|It\'s just right',
                'しちゃくしてもいいですか|May I try it on?'
              ],
            ),
          ],
        ),
      ],
      'transportation': [
        ConversationScenario(
          context: 'Train',
          responses: [
            Response(
              japanese: 'つぎのでんしゃはなんじですか？',
              english: 'What time is the next train?',
              suggestions: [
                'ごふんごです|In 5 minutes',
                'じゅっぷんまちます|Wait 10 minutes',
                'いまきます|It\'s coming now',
                'おくれています|It\'s delayed'
              ],
            ),
            Response(
              japanese: 'どこでのりかえますか？',
              english: 'Where do you transfer?',
              suggestions: [
                'しんじゅくでのりかえます|Transfer at Shinjuku',
                'ちょくせつです|It\'s direct',
                'にかいのりかえます|Transfer twice',
                'ちずをみます|I\'ll look at the map'
              ],
            ),
          ],
        ),
      ],
    },
    'N3': {
      'business': [
        ConversationScenario(
          context: 'Meeting',
          responses: [
            Response(
              japanese: '会議の準備はできましたか？',
              english: 'Are you ready for the meeting?',
              suggestions: [
                'はい、準備完了です|Yes, preparation is complete',
                'もう少し時間が必要です|I need a bit more time',
                '資料を確認しています|I\'m checking the materials',
                'プレゼンの練習をしています|I\'m practicing the presentation'
              ],
            ),
            Response(
              japanese: 'プロジェクトの進捗はいかがですか？',
              english: 'How is the project progress?',
              suggestions: [
                '順調に進んでいます|It\'s progressing smoothly',
                '予定より遅れています|It\'s behind schedule',
                '問題が発生しました|A problem occurred',
                '来週には完成予定です|It should be complete next week'
              ],
            ),
            Response(
              japanese: 'クライアントからの反応はどうでしたか？',
              english: 'How was the client\'s reaction?',
              suggestions: [
                'とても満足していました|They were very satisfied',
                'いくつか修正が必要です|Some revisions are needed',
                '追加の要望がありました|They had additional requests',
                '再度提案が必要です|We need to propose again'
              ],
            ),
          ],
        ),
      ],
      'social': [
        ConversationScenario(
          context: 'Weekend Plans',
          responses: [
            Response(
              japanese: '週末の予定は決まりましたか？',
              english: 'Have you decided your weekend plans?',
              suggestions: [
                '友達と映画を見に行きます|I\'ll go see a movie with friends',
                '家族と過ごします|I\'ll spend time with family',
                'まだ決めていません|I haven\'t decided yet',
                '仕事があります|I have work',
                '旅行に行く予定です|I plan to go on a trip'
              ],
            ),
            Response(
              japanese: '最近どこか面白い場所に行きましたか？',
              english: 'Have you been anywhere interesting recently?',
              suggestions: [
                '新しいカフェに行きました|I went to a new cafe',
                '展覧会を見てきました|I saw an exhibition',
                '温泉に行ってきました|I went to hot springs',
                '特にどこも行っていません|I haven\'t been anywhere special'
              ],
            ),
          ],
        ),
      ],
      'restaurant': [
        ConversationScenario(
          context: 'Ordering',
          responses: [
            Response(
              japanese: 'ご注文はお決まりですか？',
              english: 'Have you decided on your order?',
              suggestions: [
                'おすすめは何ですか？|What do you recommend?',
                '本日の特別料理は？|What\'s today\'s special?',
                'もう少し時間をください|Please give me more time',
                'アレルギーがあります|I have allergies',
                'ベジタリアンメニューはありますか？|Do you have vegetarian menu?'
              ],
            ),
            Response(
              japanese: 'お飲み物はいかがですか？',
              english: 'How about drinks?',
              suggestions: [
                '生ビールをお願いします|Draft beer please',
                'お茶をください|Tea please',
                '水で結構です|Water is fine',
                'ワインリストを見せてください|Please show me the wine list',
                '後で注文します|I\'ll order later'
              ],
            ),
          ],
        ),
      ],
    },
  };

// Extended offline suggestions pool (150+)
  final List<String> _offlineSuggestions = [
    // Basic responses
    'はい|Yes',
    'いいえ|No',
    'わかりました|I understand',
    'わかりません|I don\'t understand',
    'もう一度お願いします|Please say it again',
    'ゆっくり話してください|Please speak slowly',
    'ちょっと待ってください|Please wait a moment',
    'すみません|Excuse me',
    'ありがとうございます|Thank you',
    'どういたしまして|You\'re welcome',
    'ごめんなさい|I\'m sorry',
    'だいじょうぶです|It\'s okay',
    'たすけてください|Please help',
    'しつもんがあります|I have a question',
    'せつめいしてください|Please explain',

    // Time expressions
    'いま|Now',
    'あとで|Later',
    'きょう|Today',
    'あした|Tomorrow',
    'きのう|Yesterday',
    'らいしゅう|Next week',
    'せんしゅう|Last week',
    'まいにち|Every day',
    'ときどき|Sometimes',
    'いつも|Always',

    // Location
    'ここ|Here',
    'そこ|There',
    'どこ|Where',
    'みぎ|Right',
    'ひだり|Left',
    'まえ|Front',
    'うしろ|Behind',
    'ちかく|Near',
    'とおく|Far',

    // Feelings
    'うれしいです|I\'m happy',
    'かなしいです|I\'m sad',
    'つかれました|I\'m tired',
    'おなかがすきました|I\'m hungry',
    'のどがかわきました|I\'m thirsty',
    'ねむいです|I\'m sleepy',
    'げんきです|I\'m fine',
    'びょうきです|I\'m sick',
    'いそがしいです|I\'m busy',
    'ひまです|I\'m free',

    // Activities
    'べんきょうします|I study',
    'しごとをします|I work',
    'あそびます|I play',
    'ねます|I sleep',
    'たべます|I eat',
    'のみます|I drink',
    'いきます|I go',
    'きます|I come',
    'かえります|I return',
    'まちます|I wait',

    // Questions
    'なんですか？|What is it?',
    'だれですか？|Who is it?',
    'いつですか？|When is it?',
    'どうしてですか？|Why?',
    'どうやって？|How?',
    'いくらですか？|How much?',
    'どのくらい？|How long/much?',
    'ほんとうですか？|Really?',
    'たいへんですね|That\'s tough',
    'よかったですね|That\'s good',
    'ざんねんですね|That\'s too bad',
    'おめでとうございます|Congratulations',
    'がんばってください|Good luck',
    'がんばります|I\'ll do my best',

    // Shopping
    'これをください|I\'ll take this',
    'みせてください|Please show me',
    'ほかのいろはありますか？|Do you have other colors?',
    'もっとやすいのはありますか？|Do you have cheaper ones?',
    'かんがえさせてください|Let me think about it',
    'レシートをください|Receipt please',
    'クレジットカードでいいですか？|Is credit card okay?',
    'げんきんでおねがいします|Cash please',
    'ふくろはいりません|I don\'t need a bag',

    // Restaurant
    'よやくをしました|I have a reservation',
    'にめいです|For two people',
    'きんえんせきをおねがいします|Non-smoking please',
    'メニューをみせてください|Please show me the menu',
    'オススメはなんですか？|What\'s recommended?',
    'からいですか？|Is it spicy?',
    'アレルギーがあります|I have allergies',
    'おいしそうですね|It looks delicious',
    'おなかいっぱいです|I\'m full',
    'おかいけいをおねがいします|Check please',

    // Transportation
    'えきはどこですか？|Where is the station?',
    'きっぷをかいたいです|I want to buy a ticket',
    'のりばはどこですか？|Where is the platform?',
    'このでんしゃはどこいきですか？|Where does this train go?',
    'つぎはどこですか？|What\'s next?',
    'おりるえきをおしえてください|Please tell me where to get off',
    'タクシーをよんでください|Please call a taxi',
    'くうこうまでおねがいします|To the airport please',

    // Hotel
    'チェックインをおねがいします|Check-in please',
    'よやくしています|I have a reservation',
    'なんじにチェックアウトですか？|What time is checkout?',
    'あさごはんはありますか？|Is there breakfast?',
    'WiFiのパスワードはなんですか？|What\'s the WiFi password?',
    'もうふをもらえますか？|Can I have a blanket?',
    'へやをかえたいです|I want to change rooms',

    // Emergency
    'たすけて！|Help!',
    'いしゃをよんでください|Please call a doctor',
    'びょういんはどこですか？|Where is the hospital?',
    'けいさつをよんでください|Please call the police',
    'パスポートをなくしました|I lost my passport',
    'みちにまよいました|I\'m lost',
    'にほんごがわかりません|I don\'t understand Japanese',
    'えいごをはなせますか？|Can you speak English?',

    // Social
    'はじめまして|Nice to meet you',
    'ひさしぶりですね|Long time no see',
    'おげんきですか？|How are you?',
    'さいきんどうですか？|How have you been lately?',
    'またあいましょう|Let\'s meet again',
    'れんらくします|I\'ll contact you',
    'でんわばんごうをおしえてください|Please tell me your phone number',
    'メールアドレスはなんですか？|What\'s your email address?',
    'いっしょにいきませんか？|Won\'t you go together?',
    'じかんはありますか？|Do you have time?',

    // Work/Study
    'かいぎはなんじからですか？|What time is the meeting?',
    'しりょうをじゅんびしました|I prepared the materials',
    'しめきりはいつですか？|When is the deadline?',
    'てつだってもらえますか？|Can you help me?',
    'しつもんしてもいいですか？|May I ask a question?',
    'せつめいしてください|Please explain',
    'りかいできました|I understood',
    'もうすこしじかんがひつようです|I need more time',
    'かんせいしました|It\'s complete',
    'しっぱいしました|I failed',

    // Opinions
    'いいとおもいます|I think it\'s good',
    'そうおもいません|I don\'t think so',
    'さんせいです|I agree',
    'はんたいです|I disagree',
    'たぶん|Maybe',
    'きっと|Surely',
    'かもしれません|It might be',
    'ちがうとおもいます|I think it\'s different',
    'ただしいとおもいます|I think it\'s correct',

    // Hobbies
    'しゅみはなんですか？|What are your hobbies?',
    'どくしょがすきです|I like reading',
    'えいがをみるのがすきです|I like watching movies',
    'りょうりをつくります|I cook',
    'スポーツをします|I play sports',
    'おんがくをききます|I listen to music',
    'りょこうがすきです|I like traveling',
    'しゃしんをとります|I take photos',
    'えをかきます|I draw pictures',
    'ゲームをします|I play games',

    // Weather
    'きょうのてんきはどうですか？|How\'s the weather today?',
    'あめがふっています|It\'s raining',
    'ゆきがふっています|It\'s snowing',
    'はれています|It\'s sunny',
    'くもっています|It\'s cloudy',
    'あついです|It\'s hot',
    'さむいです|It\'s cold',
    'すずしいです|It\'s cool',
    'あたたかいです|It\'s warm',
    'かぜがつよいです|The wind is strong'
  ];

  ChatMessage generateResponse(String userInput, {
    String? level = 'N3',
    String? category,
    bool isOnline = false,
    int? messageIndex,
  }) {
    _conversationHistory.add(userInput);
    _conversationDepth++;

    // Determine category if not specified
    if (category == null) {
      category = _determineCategory(userInput);
    }

    // For online mode, responses would be more varied
    if (isOnline) {
      // This would connect to translation API
      // For now, returning enhanced responses
      return _generateIntelligentResponse(userInput, level!, category);
    }

    // Offline mode - use extensive local database
    return _generateOfflineResponse(userInput, level!, category);
  }

  ChatMessage _generateOfflineResponse(String input, String level, String category) {
    final levelScenarios = _scenariosByLevel[level] ?? _scenariosByLevel['N5']!;
    final categoryScenarios = levelScenarios[category] ?? levelScenarios.values.first;

    if (categoryScenarios.isEmpty) {
      return _getFallbackResponse(level);
    }

    // Select response based on conversation depth
    final scenario = categoryScenarios[_random.nextInt(categoryScenarios.length)];
    final responseIndex = _conversationDepth % scenario.responses.length;
    final response = scenario.responses[responseIndex];

    // Mix preset suggestions with random ones from pool
    List<String> suggestions = List.from(response.suggestions);

    // Add random suggestions from pool to reach minimum of 5
    while (suggestions.length < 5) {
      final randomSuggestion = _offlineSuggestions[
      _random.nextInt(_offlineSuggestions.length)
      ];
      if (!suggestions.contains(randomSuggestion)) {
        suggestions.add(randomSuggestion);
      }
    }

    return ChatMessage(
      japanese: response.japanese,
      english: response.english,
      isUser: false,
      timestamp: DateTime.now(),
      suggestedReplies: suggestions,
    );
  }

  ChatMessage _generateIntelligentResponse(String input, String level, String category) {
    // For online mode - would use AI/API
    // This is enhanced logic for demo

    final responses = _getContextualResponses(input, level, category);
    final selectedResponse = responses[_random.nextInt(responses.length)];

    // Generate varied suggestions based on context
    List<String> suggestions = _generateContextualSuggestions(
      input,
      level,
      category,
      _conversationHistory,
    );

    return ChatMessage(
      japanese: selectedResponse['japanese']!,
      english: selectedResponse['english']!,
      isUser: false,
      timestamp: DateTime.now(),
      suggestedReplies: suggestions,
    );
  }

  List<Map<String, String>> _getContextualResponses(String input, String level, String category) {
    // Returns contextually appropriate responses
    List<Map<String, String>> responses = [];

    // Check conversation history for context
    if (_conversationHistory.length > 2) {
      // Continue topic from previous messages
      responses.add({
        'japanese': 'そのことについてもっと教えてください。',
        'english': 'Please tell me more about that.',
      });
    }

    // Add level-appropriate responses
    if (level == 'N5') {
      responses.addAll([
        {
          'japanese': 'わかりやすく説明してくれてありがとう。',
          'english': 'Thank you for explaining clearly.',
        },
        {
          'japanese': 'ゆっくり練習しましょう。',
          'english': 'Let\'s practice slowly.',
        },
      ]);
    } else if (level == 'N3' || level == 'N2') {
      responses.addAll([
        {
          'japanese': 'なるほど、それは興味深いですね。',
          'english': 'I see, that\'s interesting.',
        },
        {
          'japanese': 'あなたの意見を聞かせてください。',
          'english': 'Please let me hear your opinion.',
        },
      ]);
    }

    // Add default response if list is empty
    if (responses.isEmpty) {
      responses.add({
        'japanese': 'そうですね。',
        'english': 'I see.',
      });
    }

    return responses;
  }

  List<String> _generateContextualSuggestions(
      String input,
      String level,
      String category,
      List<String> history,
      ) {
    List<String> suggestions = [];

    // Add contextually relevant suggestions
    if (category == 'greeting' && history.length <= 2) {
      suggestions.addAll([
        'よろしくお願いします|Please treat me well',
        'どこから来ましたか？|Where are you from?',
        '日本は初めてですか？|Is this your first time in Japan?',
      ]);
    } else if (category == 'business') {
      suggestions.addAll([
        'わかりました|I understand',
        '確認させてください|Let me confirm',
        '質問があります|I have a question',
      ]);
    }

    // Add level-appropriate general suggestions
    int needed = 6 - suggestions.length;
    for (int i = 0; i < needed && i < _offlineSuggestions.length; i++) {
      final randomIndex = _random.nextInt(_offlineSuggestions.length);
      if (randomIndex < _offlineSuggestions.length) {
        suggestions.add(_offlineSuggestions[randomIndex]);
      }
    }

    return suggestions;
  }

  ChatMessage _getFallbackResponse(String level) {
    return ChatMessage(
      japanese: 'すみません、もう一度言ってください。',
      english: 'Sorry, please say that again.',
      isUser: false,
      timestamp: DateTime.now(),
      suggestedReplies: [
        'わかりました|I understand',
        'もう一度お願いします|Once more please',
        'ゆっくり話してください|Please speak slowly',
        '別の言い方で|In another way',
        '例えば？|For example?'
      ],
    );
  }

  String _determineCategory(String input) {
    final lowerInput = input.toLowerCase();

    // Check for keywords in order of priority
    if (lowerInput.contains('こんにちは') ||
        lowerInput.contains('はじめ') ||
        lowerInput.contains('hello') ||
        _conversationDepth == 0) {
      return 'greeting';
    }

    if (lowerInput.contains('仕事') ||
        lowerInput.contains('会議') ||
        lowerInput.contains('work')) {
      return 'business';
    }

    if (lowerInput.contains('買') ||
        lowerInput.contains('店') ||
        lowerInput.contains('shop')) {
      return 'shopping';
    }

    if (lowerInput.contains('電車') ||
        lowerInput.contains('駅') ||
        lowerInput.contains('train')) {
      return 'transportation';
    }

    if (lowerInput.contains('食') ||
        lowerInput.contains('レストラン') ||
        lowerInput.contains('restaurant')) {
      return 'restaurant';
    }

    if (lowerInput.contains('時') ||
        lowerInput.contains('今') ||
        lowerInput.contains('time')) {
      return 'daily';
    }

    // Default based on conversation depth
    if (_conversationDepth < 3) return 'greeting';
    if (_conversationDepth < 10) return 'daily';
    return 'social';
  }
}

class ConversationScenario {
  final String context;
  final List<Response> responses;

  ConversationScenario({
    required this.context,
    required this.responses,
  });
}

class Response {
  final String japanese;
  final String english;
  final List<String> suggestions;

  Response({
    required this.japanese,
    required this.english,
    required this.suggestions,
  });
}

// lib/widgets/japanese_keyboard.dart

import 'package:flutter/material.dart';

enum KeyboardMode {
  hiragana,
  katakana,
  kanji,
  symbols,
}

class JapaneseKeyboard extends StatefulWidget {
  final Function(String) onTextInput;
  final VoidCallback onBackspace;
  final VoidCallback onSpace;
  final VoidCallback onEnter;
  final VoidCallback? onClose;

  const JapaneseKeyboard({
    super.key,
    required this.onTextInput,
    required this.onBackspace,
    required this.onSpace,
    required this.onEnter,
    this.onClose,
  });

  @override
  State<JapaneseKeyboard> createState() => _JapaneseKeyboardState();
}

class _JapaneseKeyboardState extends State<JapaneseKeyboard> {
  KeyboardMode _mode = KeyboardMode.hiragana;
  bool _showDakuten = false;
  bool _showNumbers = false;

  // Hiragana characters with romanization
  final List<List<Map<String, String>>> hiraganaRows = [
    // Row 1 - Vowels and K-line
    [
      {'char': 'あ', 'roman': 'a'}, {'char': 'か', 'roman': 'ka'},
      {'char': 'さ', 'roman': 'sa'}, {'char': 'た', 'roman': 'ta'},
      {'char': 'な', 'roman': 'na'}, {'char': 'は', 'roman': 'ha'},
      {'char': 'ま', 'roman': 'ma'}, {'char': 'や', 'roman': 'ya'},
      {'char': 'ら', 'roman': 'ra'}, {'char': 'わ', 'roman': 'wa'},
    ],
    // Row 2
    [
      {'char': 'い', 'roman': 'i'}, {'char': 'き', 'roman': 'ki'},
      {'char': 'し', 'roman': 'shi'}, {'char': 'ち', 'roman': 'chi'},
      {'char': 'に', 'roman': 'ni'}, {'char': 'ひ', 'roman': 'hi'},
      {'char': 'み', 'roman': 'mi'}, {'char': '', 'roman': ''},
      {'char': 'り', 'roman': 'ri'}, {'char': '', 'roman': ''},
    ],
    // Row 3
    [
      {'char': 'う', 'roman': 'u'}, {'char': 'く', 'roman': 'ku'},
      {'char': 'す', 'roman': 'su'}, {'char': 'つ', 'roman': 'tsu'},
      {'char': 'ぬ', 'roman': 'nu'}, {'char': 'ふ', 'roman': 'fu'},
      {'char': 'む', 'roman': 'mu'}, {'char': 'ゆ', 'roman': 'yu'},
      {'char': 'る', 'roman': 'ru'}, {'char': 'を', 'roman': 'wo'},
    ],
    // Row 4
    [
      {'char': 'え', 'roman': 'e'}, {'char': 'け', 'roman': 'ke'},
      {'char': 'せ', 'roman': 'se'}, {'char': 'て', 'roman': 'te'},
      {'char': 'ね', 'roman': 'ne'}, {'char': 'へ', 'roman': 'he'},
      {'char': 'め', 'roman': 'me'}, {'char': '', 'roman': ''},
      {'char': 'れ', 'roman': 're'}, {'char': '', 'roman': ''},
    ],
    // Row 5
    [
      {'char': 'お', 'roman': 'o'}, {'char': 'こ', 'roman': 'ko'},
      {'char': 'そ', 'roman': 'so'}, {'char': 'と', 'roman': 'to'},
      {'char': 'の', 'roman': 'no'}, {'char': 'ほ', 'roman': 'ho'},
      {'char': 'も', 'roman': 'mo'}, {'char': 'よ', 'roman': 'yo'},
      {'char': 'ろ', 'roman': 'ro'}, {'char': 'ん', 'roman': 'n'},
    ],
  ];

  // Dakuten/Handakuten variations
  final List<List<Map<String, String>>> dakutenRows = [
    // Row 1 - G, Z, D, B lines
    [
      {'char': 'が', 'roman': 'ga'}, {'char': 'ざ', 'roman': 'za'},
      {'char': 'だ', 'roman': 'da'}, {'char': 'ば', 'roman': 'ba'},
      {'char': 'ぱ', 'roman': 'pa'}, {'char': 'ゃ', 'roman': 'ya'},
      {'char': 'ぁ', 'roman': 'a'}, {'char': '。', 'roman': '.'},
      {'char': '、', 'roman': ','}, {'char': '？', 'roman': '?'},
    ],
    [
      {'char': 'ぎ', 'roman': 'gi'}, {'char': 'じ', 'roman': 'ji'},
      {'char': 'ぢ', 'roman': 'ji'}, {'char': 'び', 'roman': 'bi'},
      {'char': 'ぴ', 'roman': 'pi'}, {'char': 'ゅ', 'roman': 'yu'},
      {'char': 'ぃ', 'roman': 'i'}, {'char': '「', 'roman': '「'},
      {'char': '」', 'roman': '」'}, {'char': '！', 'roman': '!'},
    ],
    [
      {'char': 'ぐ', 'roman': 'gu'}, {'char': 'ず', 'roman': 'zu'},
      {'char': 'づ', 'roman': 'zu'}, {'char': 'ぶ', 'roman': 'bu'},
      {'char': 'ぷ', 'roman': 'pu'}, {'char': 'ょ', 'roman': 'yo'},
      {'char': 'ぅ', 'roman': 'u'}, {'char': 'ー', 'roman': '-'},
      {'char': '・', 'roman': '·'}, {'char': '〜', 'roman': '~'},
    ],
    [
      {'char': 'げ', 'roman': 'ge'}, {'char': 'ぜ', 'roman': 'ze'},
      {'char': 'で', 'roman': 'de'}, {'char': 'べ', 'roman': 'be'},
      {'char': 'ぺ', 'roman': 'pe'}, {'char': 'っ', 'roman': 'tsu'},
      {'char': 'ぇ', 'roman': 'e'}, {'char': '（', 'roman': '('},
      {'char': '）', 'roman': ')'}, {'char': '：', 'roman': ':'},
    ],
    [
      {'char': 'ご', 'roman': 'go'}, {'char': 'ぞ', 'roman': 'zo'},
      {'char': 'ど', 'roman': 'do'}, {'char': 'ぼ', 'roman': 'bo'},
      {'char': 'ぽ', 'roman': 'po'}, {'char': 'ゎ', 'roman': 'wa'},
      {'char': 'ぉ', 'roman': 'o'}, {'char': '『', 'roman': '『'},
      {'char': '』', 'roman': '』'}, {'char': '；', 'roman': ';'},
    ],
  ];

  // Numbers with Japanese readings
  final List<Map<String, String>> numberKeys = [
    {'char': '1', 'roman': 'ichi'}, {'char': '2', 'roman': 'ni'},
    {'char': '3', 'roman': 'san'}, {'char': '4', 'roman': 'yon'},
    {'char': '5', 'roman': 'go'}, {'char': '6', 'roman': 'roku'},
    {'char': '7', 'roman': 'nana'}, {'char': '8', 'roman': 'hachi'},
    {'char': '9', 'roman': 'kyū'}, {'char': '0', 'roman': 'zero'},
  ];

  // Katakana characters (similar structure)
  final List<List<Map<String, String>>> katakanaRows = [
    [
      {'char': 'ア', 'roman': 'a'}, {'char': 'カ', 'roman': 'ka'},
      {'char': 'サ', 'roman': 'sa'}, {'char': 'タ', 'roman': 'ta'},
      {'char': 'ナ', 'roman': 'na'}, {'char': 'ハ', 'roman': 'ha'},
      {'char': 'マ', 'roman': 'ma'}, {'char': 'ヤ', 'roman': 'ya'},
      {'char': 'ラ', 'roman': 'ra'}, {'char': 'ワ', 'roman': 'wa'},
    ],
    [
      {'char': 'イ', 'roman': 'i'}, {'char': 'キ', 'roman': 'ki'},
      {'char': 'シ', 'roman': 'shi'}, {'char': 'チ', 'roman': 'chi'},
      {'char': 'ニ', 'roman': 'ni'}, {'char': 'ヒ', 'roman': 'hi'},
      {'char': 'ミ', 'roman': 'mi'}, {'char': '', 'roman': ''},
      {'char': 'リ', 'roman': 'ri'}, {'char': '', 'roman': ''},
    ],
    [
      {'char': 'ウ', 'roman': 'u'}, {'char': 'ク', 'roman': 'ku'},
      {'char': 'ス', 'roman': 'su'}, {'char': 'ツ', 'roman': 'tsu'},
      {'char': 'ヌ', 'roman': 'nu'}, {'char': 'フ', 'roman': 'fu'},
      {'char': 'ム', 'roman': 'mu'}, {'char': 'ユ', 'roman': 'yu'},
      {'char': 'ル', 'roman': 'ru'}, {'char': 'ヲ', 'roman': 'wo'},
    ],
    [
      {'char': 'エ', 'roman': 'e'}, {'char': 'ケ', 'roman': 'ke'},
      {'char': 'セ', 'roman': 'se'}, {'char': 'テ', 'roman': 'te'},
      {'char': 'ネ', 'roman': 'ne'}, {'char': 'ヘ', 'roman': 'he'},
      {'char': 'メ', 'roman': 'me'}, {'char': '', 'roman': ''},
      {'char': 'レ', 'roman': 're'}, {'char': '', 'roman': ''},
    ],
    [
      {'char': 'オ', 'roman': 'o'}, {'char': 'コ', 'roman': 'ko'},
      {'char': 'ソ', 'roman': 'so'}, {'char': 'ト', 'roman': 'to'},
      {'char': 'ノ', 'roman': 'no'}, {'char': 'ホ', 'roman': 'ho'},
      {'char': 'モ', 'roman': 'mo'}, {'char': 'ヨ', 'roman': 'yo'},
      {'char': 'ロ', 'roman': 'ro'}, {'char': 'ン', 'roman': 'n'},
    ],
  ];

  // Common Kanji with meanings
  final List<Map<String, String>> kanjiKeys = [
    {'char': '私', 'roman': 'I/me'}, {'char': '人', 'roman': 'person'},
    {'char': '日', 'roman': 'day'}, {'char': '本', 'roman': 'book'},
    {'char': '語', 'roman': 'language'}, {'char': '会', 'roman': 'meet'},
    {'char': '社', 'roman': 'company'}, {'char': '時', 'roman': 'time'},
    {'char': '間', 'roman': 'between'}, {'char': '年', 'roman': 'year'},
    {'char': '月', 'roman': 'month'}, {'char': '火', 'roman': 'fire'},
    {'char': '水', 'roman': 'water'}, {'char': '木', 'roman': 'tree'},
    {'char': '金', 'roman': 'gold'}, {'char': '土', 'roman': 'earth'},
    {'char': '学', 'roman': 'study'}, {'char': '校', 'roman': 'school'},
    {'char': '先', 'roman': 'ahead'}, {'char': '生', 'roman': 'life'},
    {'char': '友', 'roman': 'friend'}, {'char': '達', 'roman': 'reach'},
    {'char': '家', 'roman': 'house'}, {'char': '族', 'roman': 'family'},
    {'char': '仕', 'roman': 'serve'}, {'char': '事', 'roman': 'thing'},
    {'char': '電', 'roman': 'electric'}, {'char': '話', 'roman': 'talk'},
    {'char': '車', 'roman': 'car'}, {'char': '国', 'roman': 'country'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 350,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildModeSelector(),
          if (_showNumbers) _buildNumberRow(),
          Expanded(
            child: _buildKeyboardLayout(),
          ),
          _buildControlRow(),
        ],
      ),
    );
  }

  Widget _buildModeSelector() {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
      ),
      child: Row(
        children: [
          _buildModeButton('あ', KeyboardMode.hiragana, 'Hiragana'),
          _buildModeButton('ア', KeyboardMode.katakana, 'Katakana'),
          _buildModeButton('漢', KeyboardMode.kanji, 'Kanji'),
          _buildModeButton('記号', KeyboardMode.symbols, 'Symbols'),
          IconButton(
            icon: Icon(
              Icons.numbers,
              color: _showNumbers ? Theme.of(context).primaryColor : null,
            ),
            onPressed: () {
              setState(() {
                _showNumbers = !_showNumbers;
              });
            },
            tooltip: 'Numbers',
          ),
        ],
      ),
    );
  }

  Widget _buildModeButton(String label, KeyboardMode mode, String tooltip) {
    final isSelected = _mode == mode;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: ElevatedButton(
          onPressed: () {
            setState(() {
              _mode = mode;
              if (mode == KeyboardMode.symbols) {
                _showDakuten = false;
              }
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: isSelected
                ? Theme.of(context).primaryColor
                : Theme.of(context).cardColor,
            elevation: isSelected ? 3 : 1,
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : null,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNumberRow() {
    return Container(
      height: 45,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Row(
        children: numberKeys.map((numKey) =>
            Expanded(child: _buildCharacterKey(numKey))
        ).toList(),
      ),
    );
  }

  Widget _buildKeyboardLayout() {
    switch (_mode) {
      case KeyboardMode.hiragana:
        return _buildCharacterGrid(_showDakuten ? dakutenRows : hiraganaRows);
      case KeyboardMode.katakana:
        return _buildCharacterGrid(katakanaRows);
      case KeyboardMode.kanji:
        return _buildKanjiGrid();
      case KeyboardMode.symbols:
        return _buildCharacterGrid(dakutenRows); // Symbols are in dakuten rows
    }
  }

  Widget _buildCharacterGrid(List<List<Map<String, String>>> rows) {
    return Column(
      children: [
        if (_mode == KeyboardMode.hiragana || _mode == KeyboardMode.katakana)
          Container(
            height: 30,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () => setState(() => _showDakuten = false),
                  child: Text(
                    'Basic',
                    style: TextStyle(
                      color: !_showDakuten ? Theme.of(context).primaryColor : null,
                      fontWeight: !_showDakuten ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
                const Text(' | '),
                TextButton(
                  onPressed: () => setState(() => _showDakuten = true),
                  child: Text(
                    'Dakuten ゛゜',
                    style: TextStyle(
                      color: _showDakuten ? Theme.of(context).primaryColor : null,
                      fontWeight: _showDakuten ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: Column(
            children: rows.map((row) =>
                Expanded(
                  child: Row(
                    children: row.map((keyData) =>
                        Expanded(child: _buildCharacterKey(keyData))
                    ).toList(),
                  ),
                ),
            ).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildKanjiGrid() {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 6,
          childAspectRatio: 0.9,
          crossAxisSpacing: 3,
          mainAxisSpacing: 3,
        ),
        itemCount: kanjiKeys.length,
        itemBuilder: (context, index) {
          return _buildCharacterKey(kanjiKeys[index]);
        },
      ),
    );
  }

  Widget _buildCharacterKey(Map<String, String> keyData) {
    if (keyData['char']!.isEmpty) {
      return const SizedBox();
    }

    return Padding(
      padding: const EdgeInsets.all(1),
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(6),
        color: Theme.of(context).scaffoldBackgroundColor,
        child: InkWell(
          onTap: () => widget.onTextInput(keyData['char']!),
          borderRadius: BorderRadius.circular(6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                keyData['char']!,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (keyData['roman']!.isNotEmpty)
                Text(
                  keyData['roman']!,
                  style: TextStyle(
                    fontSize: 9,
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlRow() {
    return Container(
      height: 45,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          _buildControlKey(Icons.space_bar, widget.onSpace, flex: 4, label: 'Space'),
          _buildControlKey(Icons.backspace, widget.onBackspace, flex: 2, label: 'Delete'),
          _buildControlKey(Icons.keyboard_return, widget.onEnter, flex: 2, label: 'Enter'),
          if (widget.onClose != null)
            _buildControlKey(Icons.keyboard_hide, widget.onClose!, flex: 1, label: 'Hide'),
        ],
      ),
    );
  }

  Widget _buildControlKey(
      IconData icon,
      VoidCallback onPressed, {
        int flex = 1,
        String? label,
      }) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Material(
          elevation: 2,
          borderRadius: BorderRadius.circular(8),
          color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: Theme.of(context).primaryColor,
                ),
                if (label != null && flex > 1) ...[
                  const SizedBox(width: 4),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
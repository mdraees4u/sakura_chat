class ChatMessage {
  final String japanese;
  final String english;
  final bool isUser;
  final DateTime timestamp;
  final List<String>? suggestedReplies;

  ChatMessage({
    required this.japanese,
    required this.english,
    required this.isUser,
    required this.timestamp,
    this.suggestedReplies,
  });

  Map<String, dynamic> toMap() {
    return {
      'japanese': japanese,
      'english': english,
      'isUser': isUser ? 1 : 0,
      'timestamp': timestamp.toIso8601String(),
      'suggestedReplies': suggestedReplies?.join('|||'),
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      japanese: map['japanese'],
      english: map['english'],
      isUser: map['isUser'] == 1,
      timestamp: DateTime.parse(map['timestamp']),
      suggestedReplies: map['suggestedReplies']?.split('|||'),
    );
  }
}
// lib/models/user_progress.dart

class UserProgress {
  final int? id;
  final int? vocabularyId;
  final int? sentenceId;
  final int? conversationId;
  final int masteryLevel;
  final int reviewCount;
  final DateTime? lastReviewed;
  final DateTime? createdAt;

  UserProgress({
    this.id,
    this.vocabularyId,
    this.sentenceId,
    this.conversationId,
    required this.masteryLevel,
    required this.reviewCount,
    this.lastReviewed,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vocabulary_id': vocabularyId,
      'sentence_id': sentenceId,
      'conversation_id': conversationId,
      'mastery_level': masteryLevel,
      'review_count': reviewCount,
      'last_reviewed': lastReviewed?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
    };
  }

  factory UserProgress.fromMap(Map<String, dynamic> map) {
    return UserProgress(
      id: map['id'],
      vocabularyId: map['vocabulary_id'],
      sentenceId: map['sentence_id'],
      conversationId: map['conversation_id'],
      masteryLevel: map['mastery_level'],
      reviewCount: map['review_count'],
      lastReviewed: map['last_reviewed'] != null
          ? DateTime.parse(map['last_reviewed'])
          : null,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : null,
    );
  }

  // Calculate next review date based on spaced repetition
  DateTime getNextReviewDate() {
    if (lastReviewed == null) return DateTime.now();

    final daysToAdd = switch (masteryLevel) {
      0 => 0,
      1 => 1,
      2 => 3,
      3 => 7,
      4 => 14,
      _ => 30,
    };

    return lastReviewed!.add(Duration(days: daysToAdd));
  }
}
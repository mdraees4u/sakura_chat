// lib/models/vocabulary.dart

import 'dart:convert';

class Vocabulary {
  final int? id;
  final String japanese;
  final String reading;
  final String english;
  final String category;
  final String level;
  final int frequency;
  final List<String>? examples;
  final String? audioUrl;
  final DateTime? createdAt;

  Vocabulary({
    this.id,
    required this.japanese,
    required this.reading,
    required this.english,
    required this.category,
    required this.level,
    this.frequency = 0,
    this.examples,
    this.audioUrl,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'japanese': japanese,
      'reading': reading,
      'english': english,
      'category': category,
      'level': level,
      'frequency': frequency,
      'examples': examples != null ? json.encode(examples) : null,
      'audio_url': audioUrl,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  factory Vocabulary.fromMap(Map<String, dynamic> map) {
    return Vocabulary(
      id: map['id'],
      japanese: map['japanese'],
      reading: map['reading'],
      english: map['english'],
      category: map['category'],
      level: map['level'],
      frequency: map['frequency'] ?? 0,
      examples: map['examples'] != null
          ? List<String>.from(json.decode(map['examples']))
          : null,
      audioUrl: map['audio_url'],
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : null,
    );
  }
}
import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Note extends Equatable {
  final String id;
  final String userId;
  final String title;
  final String content;
  final DateTime date;
  final String? imageUrl;
  final String? imageBase64;
  final bool isFavorite;

  const Note({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.date,
    this.imageUrl,
    this.imageBase64,
    this.isFavorite = false,
  });

  factory Note.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Note(
      id: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      imageUrl: data['imageUrl'],
      imageBase64: data['imageBase64'],
      isFavorite: data['isFavorite'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'title': title,
      'content': content,
      'date': Timestamp.fromDate(date),
      'imageUrl': imageUrl,
      'imageBase64': imageBase64,
      'isFavorite': isFavorite,
    };
  }

  Note copyWith({
    String? id,
    String? userId,
    String? title,
    String? content,
    DateTime? date,
    String? imageUrl,
    String? imageBase64,
    bool? isFavorite,
  }) {
    return Note(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      content: content ?? this.content,
      date: date ?? this.date,
      imageUrl: imageUrl ?? this.imageUrl,
      imageBase64: imageBase64 ?? this.imageBase64,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  @override
  List<Object?> get props => [id, userId, title, content, date, imageUrl, imageBase64, isFavorite];
}
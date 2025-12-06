import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../screens/home/models/note.dart';

abstract class NotesRepository {
  Stream<List<Note>> getNotesStream(String userId);
  Future<void> addNote(Note note);
  Future<void> updateNote(Note note);
  Future<void> deleteNote(String id);
  Future<String?> uploadImage(String path);
}

class FirestoreNotesRepository implements NotesRepository {
  final FirebaseFirestore _firestore;

  FirestoreNotesRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<List<Note>> getNotesStream(String userId) {
    return _firestore
        .collection('notes')
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Note.fromFirestore(doc);
      }).toList();
    });
  }

  @override
  Future<void> addNote(Note note) async {
    await _firestore.collection('notes').add(note.toFirestore());
  }

  @override
  Future<void> updateNote(Note note) async {
    await _firestore.collection('notes').doc(note.id).update(note.toFirestore());
  }

  @override
  Future<void> deleteNote(String id) async {
    await _firestore.collection('notes').doc(id).delete();
  }

  @override
  Future<String?> uploadImage(String path) async {
    try {
      final file = File(path);
      if (!await file.exists()) {
        print('File not found at path: $path');
        return null;
      }
      final bytes = await file.readAsBytes();
      String base64Image = base64Encode(bytes);
      return base64Image;
    } catch (e) {
      print('Error converting image to Base64: $e');
      return null;
    }
  }
}
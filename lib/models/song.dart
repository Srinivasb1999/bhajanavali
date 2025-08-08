import 'package:cloud_firestore/cloud_firestore.dart';

class Song {
  final String id;
  final String title;
  final String? god;
  final String? author;
  final List<String>? raaga; // Changed from raga to raaga and made it a List
  final String? lyrics;
  final String? audioUrl;
  final String? imageUrl;
  final DateTime? createdAt;

  Song({
    required this.id,
    required this.title,
    this.god,
    this.author,
    this.raaga,
    this.lyrics,
    this.audioUrl,
    this.imageUrl,
    this.createdAt,
  });

  factory Song.fromFirestore(Map<String, dynamic> data, String id) {
    // Handle createdAt field - it might not exist
    DateTime? createdAt;
    if (data['createdAt'] != null) {
      if (data['createdAt'] is Timestamp) {
        createdAt = data['createdAt'].toDate();
      } else if (data['createdAt'] is String) {
        try {
          createdAt = DateTime.parse(data['createdAt']);
        } catch (e) {
          // Silently handle parsing errors
        }
      }
    }
    
    // Handle raaga field - it could be String or List
    List<String>? raaga;
    if (data['raaga'] != null) {
      if (data['raaga'] is List) {
        raaga = List<String>.from(data['raaga']);
      } else if (data['raaga'] is String) {
        raaga = [data['raaga']]; // Convert single string to list
      }
    }
    
    return Song(
      id: id,
      title: data['title'] ?? '',
      god: data['god'],
      author: data['author'],
      raaga: raaga,
      lyrics: data['lyrics'],
      audioUrl: data['audioUrl'],
      imageUrl: data['imageUrl'],
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'god': god,
      'author': author,
      'raaga': raaga,
      'lyrics': lyrics,
      'audioUrl': audioUrl,
      'imageUrl': imageUrl,
      'createdAt': createdAt,
    };
  }

  // Helper method to get the first raga for display
  String? get firstRaga => raaga?.isNotEmpty == true ? raaga!.first : null;
}

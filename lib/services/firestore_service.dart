import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/song.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all songs
  Stream<List<Song>> getSongs() {
    return _firestore
        .collection('songs')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Song.fromFirestore(doc.data(), doc.id);
      }).toList();
    }).handleError((error) {
      print('Error fetching songs: $error');
      return <Song>[];
    });
  }

  // Get songs filtered by god
  Stream<List<Song>> getSongsByGod(String god) {
    return _firestore
        .collection('songs')
        .where('god', isEqualTo: god)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Song.fromFirestore(doc.data(), doc.id);
      }).toList();
    }).handleError((error) {
      print('Error fetching songs by god: $error');
      return <Song>[];
    });
  }

  // Get songs filtered by raaga (checking if the array contains the raaga)
  Stream<List<Song>> getSongsByRaga(String raaga) {
    return _firestore
        .collection('songs')
        .where('raaga', arrayContains: raaga)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Song.fromFirestore(doc.data(), doc.id);
      }).toList();
    }).handleError((error) {
      print('Error fetching songs by raaga: $error');
      return <Song>[];
    });
  }

  // Get songs filtered by both god and raaga
  Stream<List<Song>> getSongsByGodAndRaga(String god, String raaga) {
    return _firestore
        .collection('songs')
        .where('god', isEqualTo: god)
        .where('raaga', arrayContains: raaga)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Song.fromFirestore(doc.data(), doc.id);
      }).toList();
    }).handleError((error) {
      print('Error fetching songs by god and raaga: $error');
      return <Song>[];
    });
  }

  // Get unique gods from songs collection
  Future<List<String>> getUniqueGods() async {
    try {
      final snapshot = await _firestore.collection('songs').get();
      final gods = snapshot.docs
          .map((doc) => doc.data()['god'] as String?)
          .where((god) => god != null && god.isNotEmpty)
          .map((god) => god!) // Convert String? to String
          .toSet()
          .toList();
      gods.sort();
      return gods;
    } catch (error) {
      print('Error fetching unique gods: $error');
      return [];
    }
  }

  // Get unique raagas from songs collection
  Future<List<String>> getUniqueRagas() async {
    try {
      final snapshot = await _firestore.collection('songs').get();
      final raagas = <String>{};
      
      for (final doc in snapshot.docs) {
        final raagaData = doc.data()['raaga'];
        if (raagaData != null && raagaData is List) {
          for (final raaga in raagaData) {
            if (raaga is String && raaga.isNotEmpty) {
              raagas.add(raaga);
            }
          }
        }
      }
      
      final raagasList = raagas.toList();
      raagasList.sort();
      return raagasList;
    } catch (error) {
      print('Error fetching unique raagas: $error');
      return [];
    }
  }
}

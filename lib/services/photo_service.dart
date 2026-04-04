import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/photo.dart';
import 'auth_service.dart';

/// Handles Firestore operations for the user's uploaded photos.
class PhotoService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Returns a stream of all photos uploaded by the current user.
  static Stream<List<Photo>> streamPhotos() {
    final user = AuthService.currentUser;
    if (user == null) return Stream.value([]);

    return _db
        .collection('users')
        .doc(user.uid)
        .collection('photos')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        
        // Handle Timestamp to DateTime mapping for Firestore
        DateTime date;
        if (data['createdAt'] is Timestamp) {
          date = (data['createdAt'] as Timestamp).toDate();
        } else if (data['date'] is String) {
          date = DateTime.tryParse(data['date']) ?? DateTime.now();
        } else {
          date = DateTime.now();
        }

        return Photo(
          id: doc.id,
          title: data['title'] ?? 'Untitled',
          imageUrl: data['imageUrl'] ?? '',
          isFavorite: data['isFavorite'] ?? false,
          location: data['location'],
          caption: data['caption'],
          aspectRatio: (data['aspectRatio'] as num?)?.toDouble() ?? 1.0,
          date: date,
        );
      }).toList();
    });
  }

  /// Optional: Method to delete a photo from Firestore
  static Future<void> deletePhoto(String photoId) async {
    final user = AuthService.currentUser;
    if (user == null) return;

    await _db
        .collection('users')
        .doc(user.uid)
        .collection('photos')
        .doc(photoId)
        .delete();
  }
}

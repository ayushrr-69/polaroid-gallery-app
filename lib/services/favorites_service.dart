import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/photo.dart';
import 'auth_service.dart';

/// Manages Firestore-based favorites for the authenticated user.
class FavoritesService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Returns the favorites collection reference for the current user.
  static CollectionReference<Map<String, dynamic>>? _favoritesRef() {
    final user = AuthService.currentUser;
    if (user == null) return null;
    return _firestore.collection('users').doc(user.uid).collection('favorites');
  }

  /// Adds a photo to the current user's favorites in Firestore.
  static Future<void> addFavorite(Photo photo) async {
    final ref = _favoritesRef();
    if (ref == null) return;

    try {
      await ref.doc(photo.id).set({
        'imageUrl': photo.imageUrl,
        'title': photo.title,
        'caption': photo.caption,
        'location': photo.location,
        'aspectRatio': photo.aspectRatio,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error adding favorite: $e');
    }
  }

  /// Removes a photo from the current user's favorites in Firestore.
  static Future<void> removeFavorite(String photoId) async {
    final ref = _favoritesRef();
    if (ref == null) return;

    try {
      await ref.doc(photoId).delete();
    } catch (e) {
      debugPrint('Error removing favorite: $e');
    }
  }

  /// Toggles a photo's favorite status. Returns the new isFavorite state.
  static Future<bool> toggleFavorite(Photo photo) async {
    final ref = _favoritesRef();
    if (ref == null) return !photo.isFavorite;

    try {
      final doc = await ref.doc(photo.id).get();
      if (doc.exists) {
        await ref.doc(photo.id).delete();
        return false;
      } else {
        await ref.doc(photo.id).set({
          'imageUrl': photo.imageUrl,
          'title': photo.title,
          'caption': photo.caption,
          'location': photo.location,
          'aspectRatio': photo.aspectRatio,
          'createdAt': FieldValue.serverTimestamp(),
        });
        return true;
      }
    } catch (e) {
      debugPrint('Error toggling favorite: $e');
      return photo.isFavorite;
    }
  }

  /// Returns a real-time stream of the current user's favorite photo IDs.
  static Stream<Set<String>> favoritesStream() {
    final ref = _favoritesRef();
    if (ref == null) return Stream.value(<String>{});

    return ref.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => doc.id).toSet();
    });
  }

  /// Returns a real-time stream of the current user's favorite photos.
  static Stream<List<Photo>> favoritesPhotosStream() {
    final ref = _favoritesRef();
    if (ref == null) return Stream.value(<Photo>[]);

    return ref.orderBy('createdAt', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Photo(
          id: doc.id,
          title: data['title'] as String? ?? '',
          imageUrl: data['imageUrl'] as String? ?? '',
          isFavorite: true,
          location: data['location'] as String?,
          caption: data['caption'] as String?,
          aspectRatio: (data['aspectRatio'] as num?)?.toDouble() ?? 1.0,
          date: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        );
      }).toList();
    });
  }

  /// Fetches all favorite IDs once (for initial sync).
  static Future<Set<String>> getFavoriteIds() async {
    final ref = _favoritesRef();
    if (ref == null) return <String>{};

    try {
      final snapshot = await ref.get();
      return snapshot.docs.map((doc) => doc.id).toSet();
    } catch (e) {
      debugPrint('Error fetching favorites: $e');
      return <String>{};
    }
  }
}

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/photo.dart';
import '../models/album.dart';
import '../services/auth_service.dart';
import '../services/favorites_service.dart';
import '../services/photo_service.dart';

/// Centralized state management for the entire gallery application.
class GalleryProvider extends ChangeNotifier {
  List<Photo> _photos = [];
  List<Album> _albums = [];
  Set<String> _cloudFavoriteIds = {};
  StreamSubscription? _favoritesSubscription;
  StreamSubscription? _photosSubscription;

  List<Photo> get photos => List.unmodifiable(_photos);
  List<Album> get albums => List.unmodifiable(_albums);

  GalleryProvider() {
    _loadData();
    _listenToAuthChanges();
  }

  /// Listen to auth state changes to sync favorites and photos
  void _listenToAuthChanges() {
    AuthService.authStateChanges.listen((user) {
      if (user != null) {
        _startFavoritesSync();
        _startPhotosSync();
      } else {
        _stopFavoritesSync();
        _stopPhotosSync();
      }
    });
  }

  /// Start listening to Firestore photos stream
  void _startPhotosSync() {
    _photosSubscription?.cancel();
    _photosSubscription = PhotoService.streamPhotos().listen((cloudPhotos) {
      // If we have cloud photos, they define the gallery.
      // If we have none but are signed in, the gallery is empty (except maybe seeds).
      _photos = cloudPhotos;
      
      // Apply favored state from our other stream
      for (var i = 0; i < _photos.length; i++) {
        _photos[i] = _photos[i].copyWith(
          isFavorite: _cloudFavoriteIds.contains(_photos[i].id),
        );
      }
      notifyListeners();
    });
  }

  /// Stop Firestore photo sync and revert to default/local state
  void _stopPhotosSync() {
    _photosSubscription?.cancel();
    _photosSubscription = null;
    _photos = [];
    _clearLocalData(); // Clean up on logout
    _seedWelcomePhoto(); // Revert to only default image
  }

  Future<void> _clearLocalData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('photos');
    await prefs.remove('albums');
  }

  /// Start listening to Firestore favorites stream
  void _startFavoritesSync() {
    _favoritesSubscription?.cancel();
    _favoritesSubscription = FavoritesService.favoritesStream().listen((ids) {
      _cloudFavoriteIds = ids;
      // Update local photo favorite states to match cloud
      for (var i = 0; i < _photos.length; i++) {
        final isFav = _cloudFavoriteIds.contains(_photos[i].id);
        if (_photos[i].isFavorite != isFav) {
          _photos[i] = _photos[i].copyWith(isFavorite: isFav);
        }
      }
      _saveData();
      notifyListeners();
    });
  }

  /// Stop Firestore favorites sync when signed out
  void _stopFavoritesSync() {
    _favoritesSubscription?.cancel();
    _favoritesSubscription = null;
    _cloudFavoriteIds = {};
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    
    final photosJson = prefs.getString('photos');
    if (photosJson != null && photosJson != '[]') {
      final List<dynamic> decoded = jsonDecode(photosJson);
      _photos = decoded.map((e) => Photo.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      // Seed gallery with welcome image on first run
      await _seedWelcomePhoto();
    }

    final albumsJson = prefs.getString('albums');
    if (albumsJson != null) {
      final List<dynamic> decoded = jsonDecode(albumsJson);
      _albums = decoded.map((e) => Album.fromJson(e as Map<String, dynamic>)).toList();
    }

    // If signed in, sync favorites from cloud
    if (AuthService.isSignedIn) {
      _startFavoritesSync();
    }
    
    notifyListeners();
  }

  Future<void> _seedWelcomePhoto() async {
    try {
      String finalPath;
      if (kIsWeb) {
        finalPath = 'assets/images/welcome.png';
      } else {
        final directory = await getApplicationDocumentsDirectory();
        finalPath = '${directory.path}/welcome_curator.png';
        
        // Copy asset to local file system
        final byteData = await rootBundle.load('assets/images/welcome.png');
        final file = File(finalPath);
        await file.writeAsBytes(byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
      }

      final welcomePhoto = Photo(
        id: 'welcome_001',
        title: 'Welcome to Curator',
        imageUrl: finalPath,
        date: DateTime.now(),
        location: 'Curator Gallery',
        caption: 'Start your professional journey here.',
        aspectRatio: 1080 / 1350,
      );

      _photos = [welcomePhoto];
      await _saveData();
    } catch (e) {
      debugPrint('Error seeding welcome photo: $e');
    }
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    final photosJson = jsonEncode(_photos.map((p) => p.toJson()).toList());
    final albumsJson = jsonEncode(_albums.map((a) => a.toJson()).toList());
    
    await prefs.setString('photos', photosJson);
    await prefs.setString('albums', albumsJson);
  }

  void addPhoto(Photo photo) {
    _photos.insert(0, photo); // add to top
    _saveData();
    notifyListeners();
  }

  void deletePhoto(String id) {
    _photos.removeWhere((p) => p.id == id);
    // Also remove from albums
    for (var album in _albums) {
      album.photos.removeWhere((p) => p.id == id);
    }
    // Remove from cloud favorites if signed in
    if (AuthService.isSignedIn) {
      FavoritesService.removeFavorite(id);
    }
    _saveData();
    notifyListeners();
  }

  void toggleFavorite(String id) {
    final index = _photos.indexWhere((p) => p.id == id);
    if (index != -1) {
      final newFavState = !_photos[index].isFavorite;
      _photos[index] = _photos[index].copyWith(isFavorite: newFavState);
      
      // Sync to Firestore if signed in
      if (AuthService.isSignedIn) {
        if (newFavState) {
          FavoritesService.addFavorite(_photos[index]);
        } else {
          FavoritesService.removeFavorite(id);
        }
      }

      // Also update in albums
      for (var i = 0; i < _albums.length; i++) {
        final aIdx = _albums[i].photos.indexWhere((p) => p.id == id);
        if (aIdx != -1) {
          _albums[i].photos[aIdx] = _albums[i].photos[aIdx].copyWith(
            isFavorite: newFavState,
          );
        }
      }
      _saveData();
      notifyListeners();
    }
  }

  /// Sync all current local favorites to Firestore (called on first sign-in)
  Future<void> syncLocalFavoritesToCloud() async {
    if (!AuthService.isSignedIn) return;
    for (final photo in _photos.where((p) => p.isFavorite)) {
      await FavoritesService.addFavorite(photo);
    }
  }

  // Album methods
  void addAlbum(Album album) {
    _albums.insert(0, album);
    _saveData();
    notifyListeners();
  }

  void updateAlbum(Album album) {
    final index = _albums.indexWhere((a) => a.id == album.id);
    if (index != -1) {
      _albums[index] = album;
      _saveData();
      notifyListeners();
    }
  }

  void deleteAlbum(String id) {
    _albums.removeWhere((a) => a.id == id);
    _saveData();
    notifyListeners();
  }

  @override
  void dispose() {
    _favoritesSubscription?.cancel();
    super.dispose();
  }
}

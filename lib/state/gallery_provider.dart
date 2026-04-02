import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/photo.dart';
import '../models/album.dart';

/// Centralized state management for the entire gallery application.
class GalleryProvider extends ChangeNotifier {
  List<Photo> _photos = [];
  List<Album> _albums = [];

  List<Photo> get photos => List.unmodifiable(_photos);
  List<Album> get albums => List.unmodifiable(_albums);

  GalleryProvider() {
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    
    final photosJson = prefs.getString('photos');
    if (photosJson != null) {
      final List<dynamic> decoded = jsonDecode(photosJson);
      _photos = decoded.map((e) => Photo.fromJson(e as Map<String, dynamic>)).toList();
    }

    final albumsJson = prefs.getString('albums');
    if (albumsJson != null) {
      final List<dynamic> decoded = jsonDecode(albumsJson);
      _albums = decoded.map((e) => Album.fromJson(e as Map<String, dynamic>)).toList();
    }
    
    notifyListeners();
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
    _saveData();
    notifyListeners();
  }

  void toggleFavorite(String id) {
    final index = _photos.indexWhere((p) => p.id == id);
    if (index != -1) {
      _photos[index] = _photos[index].copyWith(
        isFavorite: !_photos[index].isFavorite,
      );
      // Also update in albums just to be perfectly synced
      for (var i = 0; i < _albums.length; i++) {
        final aIdx = _albums[i].photos.indexWhere((p) => p.id == id);
        if (aIdx != -1) {
          _albums[i].photos[aIdx] = _albums[i].photos[aIdx].copyWith(
            isFavorite: _photos[index].isFavorite,
          );
        }
      }
      _saveData();
      notifyListeners();
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
}

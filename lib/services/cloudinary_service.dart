import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

/// Handles image picking, compression, and Cloudinary upload.
class CloudinaryService {
  static const String _cloudName = 'dfb1hg0lm';
  static const String _uploadPreset = 'flutter_upload';
  static const String _uploadUrl =
      'https://api.cloudinary.com/v1_1/$_cloudName/image/upload';

  static final ImagePicker _picker = ImagePicker();

  /// Pick an image from the device gallery. Returns the file path or null.
  static Future<String?> pickImage() async {
    try {
      final XFile? file = await _picker.pickImage(source: ImageSource.gallery);
      return file?.path;
    } catch (e) {
      debugPrint('Image pick failed: $e');
      return null;
    }
  }

  /// Compress an image file.
  ///
  /// [highQuality] = true:  quality 85, max 2048px → ~1-2 MB
  /// [highQuality] = false: quality 60, max 1080px → ~300-800 KB
  static Future<File?> compressImage(
    String sourcePath, {
    required bool highQuality,
  }) async {
    try {
      final dir = await getTemporaryDirectory();
      final targetPath =
          '${dir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final int quality = highQuality ? 85 : 60;
      final int minDimension = highQuality ? 2048 : 1080;

      final XFile? result = await FlutterImageCompress.compressAndGetFile(
        sourcePath,
        targetPath,
        quality: quality,
        minWidth: minDimension,
        minHeight: minDimension,
      );

      if (result != null) {
        return File(result.path);
      }
      return null;
    } catch (e) {
      debugPrint('Image compression failed: $e');
      return null;
    }
  }

  /// Upload an image file to Cloudinary. Returns the secure URL.
  static Future<String> uploadToCloudinary(File imageFile) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(_uploadUrl));
      request.fields['upload_preset'] = _uploadPreset;
      request.files.add(
        await http.MultipartFile.fromPath('file', imageFile.path),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final secureUrl = data['secure_url'] as String?;
        debugPrint('Cloudinary upload success: $secureUrl');
        if (secureUrl == null) throw Exception('Secure URL is null');
        return secureUrl;
      } else {
        debugPrint('Cloudinary upload failed: ${response.statusCode} ${response.body}');
        throw Exception('Cloudinary Error: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      debugPrint('Cloudinary upload error: $e');
      rethrow;
    }
  }

  /// Full pipeline: compress + upload. Returns the secure URL.
  static Future<String> compressAndUpload(
    String sourcePath, {
    required bool highQuality,
  }) async {
    // 1. Compress
    final compressed = await compressImage(
      sourcePath,
      highQuality: highQuality,
    );

    if (compressed == null) {
      debugPrint('Compression returned null, uploading original');
      return uploadToCloudinary(File(sourcePath));
    }

    final sizeKB = await compressed.length() / 1024;
    debugPrint('Compressed size: ${sizeKB.toStringAsFixed(0)} KB');

    // 2. Upload
    final url = await uploadToCloudinary(compressed);

    // 3. Cleanup temp file
    try {
      await compressed.delete();
    } catch (_) {}

    return url;
  }
}

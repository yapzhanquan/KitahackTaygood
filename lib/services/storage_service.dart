import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:uuid/uuid.dart';

/// Handles image upload to Firebase Storage with client-side compression.
class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  static const _uuid = Uuid();

  /// Maximum file size in bytes (10 MB).
  static const int maxFileSize = 10 * 1024 * 1024;

  /// Compress and upload a check-in photo.
  /// Returns the download URL of the uploaded file.
  Future<String> uploadCheckInPhoto({
    required String userId,
    required String projectId,
    required File imageFile,
  }) async {
    // Compress the image first
    final compressed = await _compressImage(imageFile);
    final fileToUpload = compressed ?? imageFile;

    // Validate size
    final fileSize = await fileToUpload.length();
    if (fileSize > maxFileSize) {
      throw Exception(
          'File too large (${(fileSize / 1024 / 1024).toStringAsFixed(1)} MB). Max 10 MB.');
    }

    // Upload to Storage
    final fileName = '${_uuid.v4()}.jpg';
    final ref = _storage.ref().child('checkins/$userId/$projectId/$fileName');

    final uploadTask = ref.putFile(
      fileToUpload,
      SettableMetadata(contentType: 'image/jpeg'),
    );

    final snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  /// Compress image to reduce upload size and bandwidth.
  Future<File?> _compressImage(File file) async {
    final filePath = file.absolute.path;
    final lastDot = filePath.lastIndexOf('.');
    final targetPath =
        '${filePath.substring(0, lastDot)}_compressed.jpg';

    final result = await FlutterImageCompress.compressAndGetFile(
      filePath,
      targetPath,
      quality: 70,
      minWidth: 1200,
      minHeight: 1200,
    );

    return result != null ? File(result.path) : null;
  }
}

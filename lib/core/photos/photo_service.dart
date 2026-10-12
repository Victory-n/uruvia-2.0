import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show FileOptions;

import '../services/supabase_client.dart';

/// Where a photo lives in storage.
class StoredFile {
  const StoredFile(this.bucket, this.path);
  final String bucket;
  final String path;

  @override
  bool operator ==(Object other) => other is StoredFile && other.bucket == bucket && other.path == path;

  @override
  int get hashCode => Object.hash(bucket, path);
}

const accountFilesBucket = 'account-files';
const avatarsBucket = 'avatars';

/// A random, collision-proof file name stem.
String newFileStem() {
  final rnd = Random.secure();
  final tail = List.generate(8, (_) => rnd.nextInt(36).toRadixString(36)).join();
  return '${DateTime.now().microsecondsSinceEpoch.toRadixString(36)}$tail';
}

/// Picks a photo (camera or gallery), shrinks it, and stores it privately.
/// Screens call this through the PhotoField widget, never Supabase directly.
class PhotoService {
  const PhotoService();

  /// Returns null when the person closes the picker without choosing.
  Future<({Uint8List bytes, String contentType, String ext})?> pick(ImageSource source) async {
    final file = await ImagePicker().pickImage(source: source, maxWidth: 1280, maxHeight: 1280, imageQuality: 80);
    if (file == null) return null;
    final bytes = await file.readAsBytes();
    final name = file.name.toLowerCase();
    if (name.endsWith('.png')) return (bytes: bytes, contentType: 'image/png', ext: 'png');
    if (name.endsWith('.webp')) return (bytes: bytes, contentType: 'image/webp', ext: 'webp');
    return (bytes: bytes, contentType: 'image/jpeg', ext: 'jpg');
  }

  Future<String> upload({
    required String bucket,
    required String folder,
    required Uint8List bytes,
    required String contentType,
    required String ext,
  }) async {
    final path = '$folder/${newFileStem()}.$ext';
    await supabase.storage.from(bucket).uploadBinary(path, bytes, fileOptions: FileOptions(contentType: contentType));
    return path;
  }

  Future<String> signedUrl(StoredFile f) => supabase.storage.from(f.bucket).createSignedUrl(f.path, 6 * 3600);

  Future<Uint8List> download(StoredFile f) => supabase.storage.from(f.bucket).download(f.path);

  Future<void> remove(StoredFile f) async {
    await supabase.storage.from(f.bucket).remove([f.path]);
  }
}

final photoServiceProvider = Provider<PhotoService>((ref) => const PhotoService());

/// A short-lived link for showing a stored photo. Kept for the session so lists do not re-sign every row.
final signedUrlProvider = FutureProvider.family<String?, StoredFile>((ref, file) async {
  try {
    return await ref.watch(photoServiceProvider).signedUrl(file);
  } catch (_) {
    return null;
  }
});

import 'dart:convert';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../exceptions/app_exceptions.dart';

/// Service for managing the database encryption key.
///
/// Uses flutter_secure_storage to store the encryption key in
/// Android Keystore, ensuring it's protected by hardware security.
class EncryptionService {
  static const _keyName = 'db_encryption_key';
  static const _keyLength = 32; // 256 bits for AES-256

  final FlutterSecureStorage _storage;

  EncryptionService({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(
                encryptedSharedPreferences: true,
              ),
            );

  /// Gets the existing encryption key or creates a new one if not found.
  ///
  /// The key is stored securely in Android Keystore and persists across
  /// app installations (unless the user clears app data).
  ///
  /// Throws [StorageException] if unable to read/write the key.
  Future<String> getOrCreateKey() async {
    try {
      String? key = await _storage.read(key: _keyName);

      if (key == null) {
        key = _generateSecureKey();
        await _storage.write(key: _keyName, value: key);
      }

      return key;
    } on Exception catch (e, stackTrace) {
      throw StorageException(
        'Failed to access encryption key: ${e.toString()}',
        stackTrace,
      );
    }
  }

  /// Generates a cryptographically secure random key.
  ///
  /// Returns a base64-encoded 32-byte (256-bit) key.
  String _generateSecureKey() {
    final random = Random.secure();
    final bytes = List<int>.generate(_keyLength, (_) => random.nextInt(256));
    return base64Url.encode(bytes);
  }

  /// Checks if an encryption key exists.
  ///
  /// Useful for determining if this is the first app launch.
  Future<bool> hasKey() async {
    try {
      final key = await _storage.read(key: _keyName);
      return key != null;
    } on Exception {
      return false;
    }
  }

  /// Deletes the encryption key.
  ///
  /// WARNING: This will make existing encrypted data unrecoverable!
  /// Only use for testing or when user explicitly requests data wipe.
  Future<void> deleteKey() async {
    try {
      await _storage.delete(key: _keyName);
    } on Exception catch (e, stackTrace) {
      throw StorageException(
        'Failed to delete encryption key: ${e.toString()}',
        stackTrace,
      );
    }
  }
}

/// Riverpod provider for the encryption service.
final encryptionServiceProvider = Provider<EncryptionService>((ref) {
  return EncryptionService();
});

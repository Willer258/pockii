import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pockii/core/services/encryption_service.dart';
import 'package:pockii/core/exceptions/app_exceptions.dart';

import '../../../mocks/mock_secure_storage.dart';

void main() {
  late EncryptionService encryptionService;
  late MockFlutterSecureStorage mockStorage;

  setUp(() {
    mockStorage = MockFlutterSecureStorage();
    encryptionService = EncryptionService(storage: mockStorage);
  });

  group('EncryptionService', () {
    group('getOrCreateKey', () {
      test('returns existing key if found in storage', () async {
        const existingKey = 'existing-encryption-key-base64';
        when(() => mockStorage.read(key: 'db_encryption_key'))
            .thenAnswer((_) async => existingKey);

        final result = await encryptionService.getOrCreateKey();

        expect(result, existingKey);
        verify(() => mockStorage.read(key: 'db_encryption_key')).called(1);
        verifyNever(() => mockStorage.write(key: any(named: 'key'), value: any(named: 'value')));
      });

      test('generates and stores new key if not found', () async {
        when(() => mockStorage.read(key: 'db_encryption_key'))
            .thenAnswer((_) async => null);
        when(() => mockStorage.write(key: any(named: 'key'), value: any(named: 'value')))
            .thenAnswer((_) async {});

        final result = await encryptionService.getOrCreateKey();

        expect(result, isNotNull);
        expect(result.isNotEmpty, true);
        // Base64 encoded 32 bytes = 44 characters (with padding)
        expect(result.length, greaterThanOrEqualTo(40));

        verify(() => mockStorage.read(key: 'db_encryption_key')).called(1);
        verify(() => mockStorage.write(key: 'db_encryption_key', value: any(named: 'value'))).called(1);
      });

      test('generates different keys on subsequent calls when no key exists', () async {
        when(() => mockStorage.read(key: 'db_encryption_key'))
            .thenAnswer((_) async => null);
        when(() => mockStorage.write(key: any(named: 'key'), value: any(named: 'value')))
            .thenAnswer((_) async {});

        final key1 = await encryptionService.getOrCreateKey();

        // Reset mock to simulate fresh call
        reset(mockStorage);
        when(() => mockStorage.read(key: 'db_encryption_key'))
            .thenAnswer((_) async => null);
        when(() => mockStorage.write(key: any(named: 'key'), value: any(named: 'value')))
            .thenAnswer((_) async {});

        final key2 = await encryptionService.getOrCreateKey();

        // Keys should be different (random generation)
        expect(key1, isNot(equals(key2)));
      });

      test('throws StorageException on read failure', () async {
        when(() => mockStorage.read(key: 'db_encryption_key'))
            .thenThrow(Exception('Storage read failed'));

        expect(
          () => encryptionService.getOrCreateKey(),
          throwsA(isA<StorageException>()),
        );
      });

      test('throws StorageException on write failure', () async {
        when(() => mockStorage.read(key: 'db_encryption_key'))
            .thenAnswer((_) async => null);
        when(() => mockStorage.write(key: any(named: 'key'), value: any(named: 'value')))
            .thenThrow(Exception('Storage write failed'));

        expect(
          () => encryptionService.getOrCreateKey(),
          throwsA(isA<StorageException>()),
        );
      });
    });

    group('hasKey', () {
      test('returns true when key exists', () async {
        when(() => mockStorage.read(key: 'db_encryption_key'))
            .thenAnswer((_) async => 'some-key');

        final result = await encryptionService.hasKey();

        expect(result, true);
      });

      test('returns false when key does not exist', () async {
        when(() => mockStorage.read(key: 'db_encryption_key'))
            .thenAnswer((_) async => null);

        final result = await encryptionService.hasKey();

        expect(result, false);
      });

      test('returns false on storage exception', () async {
        when(() => mockStorage.read(key: 'db_encryption_key'))
            .thenThrow(Exception('Storage error'));

        final result = await encryptionService.hasKey();

        expect(result, false);
      });
    });

    group('deleteKey', () {
      test('deletes key from storage', () async {
        when(() => mockStorage.delete(key: 'db_encryption_key'))
            .thenAnswer((_) async {});

        await encryptionService.deleteKey();

        verify(() => mockStorage.delete(key: 'db_encryption_key')).called(1);
      });

      test('throws StorageException on delete failure', () async {
        when(() => mockStorage.delete(key: 'db_encryption_key'))
            .thenThrow(Exception('Delete failed'));

        expect(
          () => encryptionService.deleteKey(),
          throwsA(isA<StorageException>()),
        );
      });
    });
  });
}

import 'package:pockii/core/database/app_database.dart';
import 'package:pockii/core/database/daos/app_settings_dao.dart';
import 'package:pockii/core/database/daos/transactions_dao.dart';
import 'package:pockii/core/services/clock_service.dart';
import 'package:pockii/core/services/pattern_unlock_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockTransactionsDao extends Mock implements TransactionsDao {}

class MockAppSettingsDao extends Mock implements AppSettingsDao {}

class MockClock extends Mock implements Clock {}

class MockTransaction extends Mock implements Transaction {}

void main() {
  late MockTransactionsDao mockTransactionsDao;
  late MockAppSettingsDao mockSettingsDao;
  late MockClock mockClock;
  late PatternUnlockService service;

  setUp(() {
    mockTransactionsDao = MockTransactionsDao();
    mockSettingsDao = MockAppSettingsDao();
    mockClock = MockClock();

    service = PatternUnlockService(
      transactionsDao: mockTransactionsDao,
      settingsDao: mockSettingsDao,
      clock: mockClock,
    );

    // Default: no celebration shown
    when(() => mockSettingsDao.getValue(any())).thenAnswer((_) async => null);
    when(() => mockSettingsDao.setValue(any(), any()))
        .thenAnswer((_) async => 1);
  });

  group('PatternUnlockService', () {
    group('getDaysWithData', () {
      test('returns 0 when no transactions exist', () async {
        when(() => mockTransactionsDao.getFirstTransaction())
            .thenAnswer((_) async => null);

        final result = await service.getDaysWithData();

        expect(result, equals(0));
      });

      test('returns 1 when first transaction is today', () async {
        final now = DateTime(2026, 1, 15);
        when(() => mockClock.now()).thenReturn(now);

        final mockTransaction = MockTransaction();
        when(() => mockTransaction.date).thenReturn(now);
        when(() => mockTransactionsDao.getFirstTransaction())
            .thenAnswer((_) async => mockTransaction);

        final result = await service.getDaysWithData();

        expect(result, equals(1));
      });

      test('returns correct days when transaction was 10 days ago', () async {
        final now = DateTime(2026, 1, 15);
        final firstDate = DateTime(2026, 1, 5);
        when(() => mockClock.now()).thenReturn(now);

        final mockTransaction = MockTransaction();
        when(() => mockTransaction.date).thenReturn(firstDate);
        when(() => mockTransactionsDao.getFirstTransaction())
            .thenAnswer((_) async => mockTransaction);

        final result = await service.getDaysWithData();

        expect(result, equals(11)); // 10 days difference + 1
      });

      test('returns 30 when exactly 29 days have passed', () async {
        final now = DateTime(2026, 1, 30);
        final firstDate = DateTime(2026, 1, 1);
        when(() => mockClock.now()).thenReturn(now);

        final mockTransaction = MockTransaction();
        when(() => mockTransaction.date).thenReturn(firstDate);
        when(() => mockTransactionsDao.getFirstTransaction())
            .thenAnswer((_) async => mockTransaction);

        final result = await service.getDaysWithData();

        expect(result, equals(30)); // 29 days difference + 1
      });
    });

    group('isUnlocked', () {
      test('returns false when no transactions', () async {
        when(() => mockTransactionsDao.getFirstTransaction())
            .thenAnswer((_) async => null);

        final result = await service.isUnlocked();

        expect(result, isFalse);
      });

      test('returns false when less than 30 days of data', () async {
        final now = DateTime(2026, 1, 15);
        final firstDate = DateTime(2026, 1, 10);
        when(() => mockClock.now()).thenReturn(now);

        final mockTransaction = MockTransaction();
        when(() => mockTransaction.date).thenReturn(firstDate);
        when(() => mockTransactionsDao.getFirstTransaction())
            .thenAnswer((_) async => mockTransaction);

        final result = await service.isUnlocked();

        expect(result, isFalse);
      });

      test('returns true when exactly 30 days of data', () async {
        final now = DateTime(2026, 1, 30);
        final firstDate = DateTime(2026, 1, 1);
        when(() => mockClock.now()).thenReturn(now);

        final mockTransaction = MockTransaction();
        when(() => mockTransaction.date).thenReturn(firstDate);
        when(() => mockTransactionsDao.getFirstTransaction())
            .thenAnswer((_) async => mockTransaction);

        final result = await service.isUnlocked();

        expect(result, isTrue);
      });

      test('returns true when more than 30 days of data', () async {
        final now = DateTime(2026, 2, 15);
        final firstDate = DateTime(2026, 1, 1);
        when(() => mockClock.now()).thenReturn(now);

        final mockTransaction = MockTransaction();
        when(() => mockTransaction.date).thenReturn(firstDate);
        when(() => mockTransactionsDao.getFirstTransaction())
            .thenAnswer((_) async => mockTransaction);

        final result = await service.isUnlocked();

        expect(result, isTrue);
      });
    });

    group('getDaysRemaining', () {
      test('returns 30 when no transactions', () async {
        when(() => mockTransactionsDao.getFirstTransaction())
            .thenAnswer((_) async => null);

        final result = await service.getDaysRemaining();

        expect(result, equals(30));
      });

      test('returns correct remaining days', () async {
        final now = DateTime(2026, 1, 10);
        final firstDate = DateTime(2026, 1, 1);
        when(() => mockClock.now()).thenReturn(now);

        final mockTransaction = MockTransaction();
        when(() => mockTransaction.date).thenReturn(firstDate);
        when(() => mockTransactionsDao.getFirstTransaction())
            .thenAnswer((_) async => mockTransaction);

        final result = await service.getDaysRemaining();

        expect(result, equals(20)); // 30 - 10 days
      });

      test('returns 0 when already unlocked', () async {
        final now = DateTime(2026, 2, 15);
        final firstDate = DateTime(2026, 1, 1);
        when(() => mockClock.now()).thenReturn(now);

        final mockTransaction = MockTransaction();
        when(() => mockTransaction.date).thenReturn(firstDate);
        when(() => mockTransactionsDao.getFirstTransaction())
            .thenAnswer((_) async => mockTransaction);

        final result = await service.getDaysRemaining();

        expect(result, equals(0));
      });
    });

    group('getProgress', () {
      test('returns 0.0 when no transactions', () async {
        when(() => mockTransactionsDao.getFirstTransaction())
            .thenAnswer((_) async => null);

        final result = await service.getProgress();

        expect(result, equals(0.0));
      });

      test('returns correct progress percentage', () async {
        final now = DateTime(2026, 1, 15);
        final firstDate = DateTime(2026, 1, 1);
        when(() => mockClock.now()).thenReturn(now);

        final mockTransaction = MockTransaction();
        when(() => mockTransaction.date).thenReturn(firstDate);
        when(() => mockTransactionsDao.getFirstTransaction())
            .thenAnswer((_) async => mockTransaction);

        final result = await service.getProgress();

        expect(result, equals(0.5)); // 15 / 30 = 0.5
      });

      test('caps progress at 1.0', () async {
        final now = DateTime(2026, 3, 1);
        final firstDate = DateTime(2026, 1, 1);
        when(() => mockClock.now()).thenReturn(now);

        final mockTransaction = MockTransaction();
        when(() => mockTransaction.date).thenReturn(firstDate);
        when(() => mockTransactionsDao.getFirstTransaction())
            .thenAnswer((_) async => mockTransaction);

        final result = await service.getProgress();

        expect(result, equals(1.0));
      });

      test('returns 1.0 at exactly 30 days', () async {
        final now = DateTime(2026, 1, 30);
        final firstDate = DateTime(2026, 1, 1);
        when(() => mockClock.now()).thenReturn(now);

        final mockTransaction = MockTransaction();
        when(() => mockTransaction.date).thenReturn(firstDate);
        when(() => mockTransactionsDao.getFirstTransaction())
            .thenAnswer((_) async => mockTransaction);

        final result = await service.getProgress();

        expect(result, equals(1.0));
      });
    });

    group('shouldShowCelebration', () {
      test('returns false when not unlocked', () async {
        when(() => mockTransactionsDao.getFirstTransaction())
            .thenAnswer((_) async => null);

        final result = await service.shouldShowCelebration();

        expect(result, isFalse);
      });

      test('returns true when unlocked and celebration not shown', () async {
        final now = DateTime(2026, 2, 1);
        final firstDate = DateTime(2026, 1, 1);
        when(() => mockClock.now()).thenReturn(now);

        final mockTransaction = MockTransaction();
        when(() => mockTransaction.date).thenReturn(firstDate);
        when(() => mockTransactionsDao.getFirstTransaction())
            .thenAnswer((_) async => mockTransaction);

        final result = await service.shouldShowCelebration();

        expect(result, isTrue);
      });

      test('returns false when celebration already shown', () async {
        final now = DateTime(2026, 2, 1);
        final firstDate = DateTime(2026, 1, 1);
        when(() => mockClock.now()).thenReturn(now);

        final mockTransaction = MockTransaction();
        when(() => mockTransaction.date).thenReturn(firstDate);
        when(() => mockTransactionsDao.getFirstTransaction())
            .thenAnswer((_) async => mockTransaction);
        when(() => mockSettingsDao.getValue(PatternUnlockKeys.celebrationShown))
            .thenAnswer((_) async => 'true');

        final result = await service.shouldShowCelebration();

        expect(result, isFalse);
      });
    });

    group('markCelebrationShown', () {
      test('saves celebration shown flag', () async {
        await service.markCelebrationShown();

        verify(() => mockSettingsDao.setValue(
              PatternUnlockKeys.celebrationShown,
              'true',
            )).called(1);
      });
    });

    group('resetCelebrationForTesting', () {
      test('resets celebration shown flag', () async {
        await service.resetCelebrationForTesting();

        verify(() => mockSettingsDao.setValue(
              PatternUnlockKeys.celebrationShown,
              'false',
            )).called(1);
      });
    });
  });

  group('PatternUnlockKeys', () {
    test('celebrationShown key is defined', () {
      expect(PatternUnlockKeys.celebrationShown,
          equals('pattern_unlock_celebration_shown'));
    });
  });

  group('patternUnlockDaysRequired', () {
    test('is 30 days', () {
      expect(patternUnlockDaysRequired, equals(30));
    });
  });
}

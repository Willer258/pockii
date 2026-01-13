import 'package:pockii/core/database/daos/app_settings_dao.dart';
import 'package:pockii/core/services/clock_service.dart';
import 'package:pockii/core/services/notification_limiter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAppSettingsDao extends Mock implements AppSettingsDao {}

class MockClock extends Mock implements Clock {}

void main() {
  late MockAppSettingsDao mockSettingsDao;
  late MockClock mockClock;
  late NotificationLimiter limiter;

  final testDate = DateTime(2026, 1, 15, 10, 30);

  setUp(() {
    mockSettingsDao = MockAppSettingsDao();
    mockClock = MockClock();
    limiter = NotificationLimiter(settingsDao: mockSettingsDao, clock: mockClock);

    // Default: no existing settings
    when(() => mockSettingsDao.getValue(any())).thenAnswer((_) async => null);
    when(() => mockSettingsDao.setValue(any(), any())).thenAnswer((_) async => 1);
    when(() => mockClock.now()).thenReturn(testDate);
  });

  group('NotificationLimiter', () {
    group('canSendNotification', () {
      test('allows first notification', () async {
        final result = await limiter.canSendNotification();

        expect(result, equals(NotificationLimitResult.allowed));
      });

      test('allows second notification', () async {
        // First notification sent
        when(() => mockSettingsDao.getValue(NotificationLimiterKeys.dailyCount))
            .thenAnswer((_) async => '1');
        when(() => mockSettingsDao.getValue(NotificationLimiterKeys.lastCountDate))
            .thenAnswer((_) async => testDate.toIso8601String());

        final result = await limiter.canSendNotification();

        expect(result, equals(NotificationLimitResult.allowed));
      });

      test('queues third normal notification', () async {
        // Two notifications sent
        when(() => mockSettingsDao.getValue(NotificationLimiterKeys.dailyCount))
            .thenAnswer((_) async => '2');
        when(() => mockSettingsDao.getValue(NotificationLimiterKeys.lastCountDate))
            .thenAnswer((_) async => testDate.toIso8601String());

        final result = await limiter.canSendNotification();

        expect(result, equals(NotificationLimitResult.queued));
      });

      test('allows critical notification when at normal limit', () async {
        // Two notifications sent (at normal limit)
        when(() => mockSettingsDao.getValue(NotificationLimiterKeys.dailyCount))
            .thenAnswer((_) async => '2');
        when(() => mockSettingsDao.getValue(NotificationLimiterKeys.lastCountDate))
            .thenAnswer((_) async => testDate.toIso8601String());

        final result = await limiter.canSendNotification(
          priority: NotificationPriority.critical,
        );

        expect(result, equals(NotificationLimitResult.criticalAllowed));
      });

      test('queues critical notification when at absolute limit', () async {
        // Three notifications sent (at absolute limit)
        when(() => mockSettingsDao.getValue(NotificationLimiterKeys.dailyCount))
            .thenAnswer((_) async => '3');
        when(() => mockSettingsDao.getValue(NotificationLimiterKeys.lastCountDate))
            .thenAnswer((_) async => testDate.toIso8601String());

        final result = await limiter.canSendNotification(
          priority: NotificationPriority.critical,
        );

        expect(result, equals(NotificationLimitResult.queued));
      });
    });

    group('recordNotificationSent', () {
      test('increments daily count', () async {
        when(() => mockSettingsDao.getValue(NotificationLimiterKeys.lastCountDate))
            .thenAnswer((_) async => testDate.toIso8601String());

        await limiter.recordNotificationSent();

        verify(() => mockSettingsDao.setValue(
              NotificationLimiterKeys.dailyCount,
              '1',
            )).called(1);
      });

      test('increments from existing count', () async {
        when(() => mockSettingsDao.getValue(NotificationLimiterKeys.dailyCount))
            .thenAnswer((_) async => '1');
        when(() => mockSettingsDao.getValue(NotificationLimiterKeys.lastCountDate))
            .thenAnswer((_) async => testDate.toIso8601String());

        await limiter.recordNotificationSent();

        verify(() => mockSettingsDao.setValue(
              NotificationLimiterKeys.dailyCount,
              '2',
            )).called(1);
      });
    });

    group('daily reset', () {
      test('resets count on new day', () async {
        // Yesterday's count
        final yesterday = DateTime(2026, 1, 14, 10, 30);

        // Track if count has been reset
        var countResetCalled = false;

        when(() => mockSettingsDao.getValue(NotificationLimiterKeys.dailyCount))
            .thenAnswer((_) async => countResetCalled ? '0' : '2');
        when(() => mockSettingsDao.getValue(NotificationLimiterKeys.lastCountDate))
            .thenAnswer((_) async => yesterday.toIso8601String());
        when(() => mockSettingsDao.setValue(NotificationLimiterKeys.dailyCount, '0'))
            .thenAnswer((_) async {
              countResetCalled = true;
              return 1;
            });

        final result = await limiter.canSendNotification();

        expect(result, equals(NotificationLimitResult.allowed));
        verify(() => mockSettingsDao.setValue(
              NotificationLimiterKeys.dailyCount,
              '0',
            )).called(1);
      });

      test('does not reset on same day', () async {
        when(() => mockSettingsDao.getValue(NotificationLimiterKeys.dailyCount))
            .thenAnswer((_) async => '1');
        when(() => mockSettingsDao.getValue(NotificationLimiterKeys.lastCountDate))
            .thenAnswer((_) async => testDate.toIso8601String());

        await limiter.canSendNotification();

        verifyNever(() => mockSettingsDao.setValue(
              NotificationLimiterKeys.dailyCount,
              '0',
            ));
      });
    });

    group('queueNotification', () {
      test('adds notification to queue', () async {
        await limiter.queueNotification(
          type: 'test_type',
          title: 'Test Title',
          body: 'Test Body',
        );

        verify(() => mockSettingsDao.setValue(
              NotificationLimiterKeys.queuedNotifications,
              any(that: contains('test_type')),
            )).called(1);
      });

      test('adds to existing queue', () async {
        // Existing queue with one notification
        when(() => mockSettingsDao.getValue(NotificationLimiterKeys.queuedNotifications))
            .thenAnswer((_) async =>
                '[{"type":"existing","title":"Old","body":"Old body","queuedAt":"2026-01-15T09:00:00.000"}]');

        await limiter.queueNotification(
          type: 'new_type',
          title: 'New Title',
          body: 'New Body',
        );

        verify(() => mockSettingsDao.setValue(
              NotificationLimiterKeys.queuedNotifications,
              any(that: allOf(contains('existing'), contains('new_type'))),
            )).called(1);
      });
    });

    group('getAndClearQueuedNotifications', () {
      test('returns empty list when no queue', () async {
        final result = await limiter.getAndClearQueuedNotifications();

        expect(result, isEmpty);
      });

      test('returns queued notifications up to limit', () async {
        // Three queued notifications, but daily limit is 2
        when(() => mockSettingsDao.getValue(NotificationLimiterKeys.queuedNotifications))
            .thenAnswer((_) async => '''[
              {"type":"type1","title":"Title 1","body":"Body 1","queuedAt":"2026-01-14T10:00:00.000"},
              {"type":"type2","title":"Title 2","body":"Body 2","queuedAt":"2026-01-14T11:00:00.000"},
              {"type":"type3","title":"Title 3","body":"Body 3","queuedAt":"2026-01-14T12:00:00.000"}
            ]''');
        when(() => mockSettingsDao.getValue(NotificationLimiterKeys.lastCountDate))
            .thenAnswer((_) async => testDate.toIso8601String());

        final result = await limiter.getAndClearQueuedNotifications();

        expect(result.length, equals(2));
        expect(result[0].type, equals('type1'));
        expect(result[1].type, equals('type2'));
      });

      test('leaves remaining notifications in queue', () async {
        // Three queued notifications
        when(() => mockSettingsDao.getValue(NotificationLimiterKeys.queuedNotifications))
            .thenAnswer((_) async => '''[
              {"type":"type1","title":"Title 1","body":"Body 1","queuedAt":"2026-01-14T10:00:00.000"},
              {"type":"type2","title":"Title 2","body":"Body 2","queuedAt":"2026-01-14T11:00:00.000"},
              {"type":"type3","title":"Title 3","body":"Body 3","queuedAt":"2026-01-14T12:00:00.000"}
            ]''');
        when(() => mockSettingsDao.getValue(NotificationLimiterKeys.lastCountDate))
            .thenAnswer((_) async => testDate.toIso8601String());

        await limiter.getAndClearQueuedNotifications();

        // Should save queue with only type3 remaining
        verify(() => mockSettingsDao.setValue(
              NotificationLimiterKeys.queuedNotifications,
              any(that: allOf(contains('type3'), isNot(contains('type1')))),
            )).called(1);
      });

      test('returns fewer if daily count already high', () async {
        // One notification already sent today, queue has 2
        when(() => mockSettingsDao.getValue(NotificationLimiterKeys.dailyCount))
            .thenAnswer((_) async => '1');
        when(() => mockSettingsDao.getValue(NotificationLimiterKeys.lastCountDate))
            .thenAnswer((_) async => testDate.toIso8601String());
        when(() => mockSettingsDao.getValue(NotificationLimiterKeys.queuedNotifications))
            .thenAnswer((_) async => '''[
              {"type":"type1","title":"Title 1","body":"Body 1","queuedAt":"2026-01-14T10:00:00.000"},
              {"type":"type2","title":"Title 2","body":"Body 2","queuedAt":"2026-01-14T11:00:00.000"}
            ]''');

        final result = await limiter.getAndClearQueuedNotifications();

        // Only 1 slot available (limit 2 - count 1)
        expect(result.length, equals(1));
      });

      test('returns empty if limit already reached', () async {
        // Two notifications already sent today
        when(() => mockSettingsDao.getValue(NotificationLimiterKeys.dailyCount))
            .thenAnswer((_) async => '2');
        when(() => mockSettingsDao.getValue(NotificationLimiterKeys.lastCountDate))
            .thenAnswer((_) async => testDate.toIso8601String());
        when(() => mockSettingsDao.getValue(NotificationLimiterKeys.queuedNotifications))
            .thenAnswer((_) async => '''[
              {"type":"type1","title":"Title 1","body":"Body 1","queuedAt":"2026-01-14T10:00:00.000"}
            ]''');

        final result = await limiter.getAndClearQueuedNotifications();

        expect(result, isEmpty);
      });
    });

    group('getDailyCount', () {
      test('returns 0 when no count exists', () async {
        final result = await limiter.getDailyCount();

        expect(result, equals(0));
      });

      test('returns stored count', () async {
        when(() => mockSettingsDao.getValue(NotificationLimiterKeys.dailyCount))
            .thenAnswer((_) async => '2');
        when(() => mockSettingsDao.getValue(NotificationLimiterKeys.lastCountDate))
            .thenAnswer((_) async => testDate.toIso8601String());

        final result = await limiter.getDailyCount();

        expect(result, equals(2));
      });
    });

    group('getQueuedCount', () {
      test('returns 0 when no queue', () async {
        final result = await limiter.getQueuedCount();

        expect(result, equals(0));
      });

      test('returns queue length', () async {
        when(() => mockSettingsDao.getValue(NotificationLimiterKeys.queuedNotifications))
            .thenAnswer((_) async => '''[
              {"type":"type1","title":"Title 1","body":"Body 1","queuedAt":"2026-01-14T10:00:00.000"},
              {"type":"type2","title":"Title 2","body":"Body 2","queuedAt":"2026-01-14T11:00:00.000"}
            ]''');

        final result = await limiter.getQueuedCount();

        expect(result, equals(2));
      });
    });

    group('hasQueuedNotifications', () {
      test('returns false when no queue', () async {
        final result = await limiter.hasQueuedNotifications();

        expect(result, isFalse);
      });

      test('returns true when queue has items', () async {
        when(() => mockSettingsDao.getValue(NotificationLimiterKeys.queuedNotifications))
            .thenAnswer((_) async =>
                '[{"type":"type1","title":"Title 1","body":"Body 1","queuedAt":"2026-01-14T10:00:00.000"}]');

        final result = await limiter.hasQueuedNotifications();

        expect(result, isTrue);
      });
    });
  });

  group('QueuedNotification', () {
    test('fromJson parses correctly', () {
      final json = {
        'type': 'test_type',
        'title': 'Test Title',
        'body': 'Test Body',
        'queuedAt': '2026-01-15T10:30:00.000',
        'payload': 'test_payload',
      };

      final notification = QueuedNotification.fromJson(json);

      expect(notification.type, equals('test_type'));
      expect(notification.title, equals('Test Title'));
      expect(notification.body, equals('Test Body'));
      expect(notification.queuedAt, equals(DateTime(2026, 1, 15, 10, 30)));
      expect(notification.payload, equals('test_payload'));
    });

    test('toJson serializes correctly', () {
      final notification = QueuedNotification(
        type: 'test_type',
        title: 'Test Title',
        body: 'Test Body',
        queuedAt: DateTime(2026, 1, 15, 10, 30),
        payload: 'test_payload',
      );

      final json = notification.toJson();

      expect(json['type'], equals('test_type'));
      expect(json['title'], equals('Test Title'));
      expect(json['body'], equals('Test Body'));
      expect(json['queuedAt'], contains('2026-01-15'));
      expect(json['payload'], equals('test_payload'));
    });

    test('handles null payload', () {
      final notification = QueuedNotification(
        type: 'test_type',
        title: 'Test Title',
        body: 'Test Body',
        queuedAt: DateTime(2026, 1, 15, 10, 30),
      );

      final json = notification.toJson();
      expect(json['payload'], isNull);

      final parsed = QueuedNotification.fromJson(json);
      expect(parsed.payload, isNull);
    });
  });

  group('NotificationLimiter constants', () {
    test('daily limit is 2', () {
      expect(NotificationLimiter.dailyLimit, equals(2));
    });

    test('absolute limit is 3', () {
      expect(NotificationLimiter.absoluteLimit, equals(3));
    });
  });
}

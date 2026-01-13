import 'package:pockii/core/services/notification_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockFlutterLocalNotificationsPlugin extends Mock
    implements FlutterLocalNotificationsPlugin {}

class FakeNotificationDetails extends Fake implements NotificationDetails {}

class FakeInitializationSettings extends Fake implements InitializationSettings {}

void main() {
  late MockFlutterLocalNotificationsPlugin mockPlugin;
  late NotificationService notificationService;

  setUpAll(() {
    registerFallbackValue(FakeNotificationDetails());
    registerFallbackValue(FakeInitializationSettings());
  });

  setUp(() {
    mockPlugin = MockFlutterLocalNotificationsPlugin();
    notificationService = NotificationService(plugin: mockPlugin);

    // Setup mock for initialize
    when(() => mockPlugin.initialize(
          any(),
          onDidReceiveNotificationResponse: any(named: 'onDidReceiveNotificationResponse'),
        )).thenAnswer((_) async => true);
  });

  group('NotificationService', () {
    group('initialize', () {
      test('initializes the plugin with correct settings', () async {
        await notificationService.initialize();

        verify(() => mockPlugin.initialize(
              any(),
              onDidReceiveNotificationResponse: any(named: 'onDidReceiveNotificationResponse'),
            )).called(1);
      });

      test('only initializes once', () async {
        await notificationService.initialize();
        await notificationService.initialize();

        verify(() => mockPlugin.initialize(
              any(),
              onDidReceiveNotificationResponse: any(named: 'onDidReceiveNotificationResponse'),
            )).called(1);
      });
    });

    group('showBudgetWarning', () {
      test('shows notification with correct content', () async {
        when(() => mockPlugin.show(
              any(),
              any(),
              any(),
              any(),
              payload: any(named: 'payload'),
            )).thenAnswer((_) async {});

        await notificationService.showBudgetWarning(remainingFcfa: 105000);

        verify(() => mockPlugin.show(
              NotificationIds.budgetWarning,
              'Budget attention',
              'Il te reste 105 000 FCFA',
              any(),
              payload: 'budget_warning',
            )).called(1);
      });

      test('formats large amounts correctly', () async {
        when(() => mockPlugin.show(
              any(),
              any(),
              any(),
              any(),
              payload: any(named: 'payload'),
            )).thenAnswer((_) async {});

        await notificationService.showBudgetWarning(remainingFcfa: 1250000);

        verify(() => mockPlugin.show(
              NotificationIds.budgetWarning,
              'Budget attention',
              'Il te reste 1 250 000 FCFA',
              any(),
              payload: 'budget_warning',
            )).called(1);
      });
    });

    group('showBudgetCritical', () {
      test('shows notification with correct content', () async {
        when(() => mockPlugin.show(
              any(),
              any(),
              any(),
              any(),
              payload: any(named: 'payload'),
            )).thenAnswer((_) async {});

        await notificationService.showBudgetCritical(remainingFcfa: 25000);

        verify(() => mockPlugin.show(
              NotificationIds.budgetCritical,
              'Budget critique',
              'Il te reste 25 000 FCFA',
              any(),
              payload: 'budget_critical',
            )).called(1);
      });
    });

    group('showSubscriptionReminder', () {
      test('shows notification for subscription due today', () async {
        when(() => mockPlugin.show(
              any(),
              any(),
              any(),
              any(),
              payload: any(named: 'payload'),
            )).thenAnswer((_) async {});

        await notificationService.showSubscriptionReminder(
          subscriptionName: 'Netflix',
          amountFcfa: 5000,
          daysUntilDue: 0,
        );

        verify(() => mockPlugin.show(
              any(),
              'Rappel abonnement',
              "Netflix - 5 000 FCFA aujourd'hui",
              any(),
              payload: 'subscription_reminder',
            )).called(1);
      });

      test('shows notification for subscription due tomorrow', () async {
        when(() => mockPlugin.show(
              any(),
              any(),
              any(),
              any(),
              payload: any(named: 'payload'),
            )).thenAnswer((_) async {});

        await notificationService.showSubscriptionReminder(
          subscriptionName: 'Gym',
          amountFcfa: 15000,
          daysUntilDue: 1,
        );

        verify(() => mockPlugin.show(
              any(),
              'Rappel abonnement',
              'Gym - 15 000 FCFA demain',
              any(),
              payload: 'subscription_reminder',
            )).called(1);
      });

      test('shows notification for subscription due in multiple days', () async {
        when(() => mockPlugin.show(
              any(),
              any(),
              any(),
              any(),
              payload: any(named: 'payload'),
            )).thenAnswer((_) async {});

        await notificationService.showSubscriptionReminder(
          subscriptionName: 'Tontine',
          amountFcfa: 50000,
          daysUntilDue: 3,
        );

        verify(() => mockPlugin.show(
              any(),
              'Rappel abonnement',
              'Tontine - 50 000 FCFA dans 3 jours',
              any(),
              payload: 'subscription_reminder',
            )).called(1);
      });
    });

    group('showGroupedSubscriptionReminder', () {
      test('shows grouped notification', () async {
        when(() => mockPlugin.show(
              any(),
              any(),
              any(),
              any(),
              payload: any(named: 'payload'),
            )).thenAnswer((_) async {});

        await notificationService.showGroupedSubscriptionReminder(
          count: 3,
          totalAmountFcfa: 75000,
        );

        verify(() => mockPlugin.show(
              NotificationIds.subscriptionGroup,
              '3 abonnements',
              'Total 75 000 FCFA',
              any(),
              payload: 'subscription_group',
            )).called(1);
      });
    });

    group('showStreakCelebration', () {
      test('shows 7-day milestone notification', () async {
        when(() => mockPlugin.show(
              any(),
              any(),
              any(),
              any(),
              payload: any(named: 'payload'),
            )).thenAnswer((_) async {});

        await notificationService.showStreakCelebration(streakDays: 7);

        verify(() => mockPlugin.show(
              NotificationIds.streakCelebration,
              '7 jours de suite!',
              'Tu geres! Continue comme ca.',
              any(),
              payload: 'streak_celebration',
            )).called(1);
      });

      test('shows 14-day milestone notification', () async {
        when(() => mockPlugin.show(
              any(),
              any(),
              any(),
              any(),
              payload: any(named: 'payload'),
            )).thenAnswer((_) async {});

        await notificationService.showStreakCelebration(streakDays: 14);

        verify(() => mockPlugin.show(
              NotificationIds.streakCelebration,
              '14 jours!',
              'Tu deviens un pro du budget!',
              any(),
              payload: 'streak_celebration',
            )).called(1);
      });

      test('shows 30-day milestone notification', () async {
        when(() => mockPlugin.show(
              any(),
              any(),
              any(),
              any(),
              payload: any(named: 'payload'),
            )).thenAnswer((_) async {});

        await notificationService.showStreakCelebration(streakDays: 30);

        verify(() => mockPlugin.show(
              NotificationIds.streakCelebration,
              '30 jours!',
              'Maitre du budget! Incroyable!',
              any(),
              payload: 'streak_celebration',
            )).called(1);
      });

      test('shows generic notification for non-milestone days', () async {
        when(() => mockPlugin.show(
              any(),
              any(),
              any(),
              any(),
              payload: any(named: 'payload'),
            )).thenAnswer((_) async {});

        await notificationService.showStreakCelebration(streakDays: 25);

        verify(() => mockPlugin.show(
              NotificationIds.streakCelebration,
              '25 jours!',
              'Continue ta serie!',
              any(),
              payload: 'streak_celebration',
            )).called(1);
      });
    });

    group('cancelAll', () {
      test('cancels all notifications', () async {
        when(() => mockPlugin.cancelAll()).thenAnswer((_) async {});

        await notificationService.cancelAll();

        verify(() => mockPlugin.cancelAll()).called(1);
      });
    });

    group('cancel', () {
      test('cancels specific notification by id', () async {
        when(() => mockPlugin.cancel(any())).thenAnswer((_) async {});

        await notificationService.cancel(123);

        verify(() => mockPlugin.cancel(123)).called(1);
      });
    });
  });
}

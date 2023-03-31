import 'dart:typed_data';

import 'package:first/services/reminders_services.dart';
import 'package:first/state/reminder.dart';
import 'package:first/utils/extensions.dart';

import '../utils.dart';

final mockReminder1DateTime = DateTime(2000, 1, 2, 3, 4, 5, 6, 7);
const mockReminder1Id = '1';
const mockReminder1Text = 'text1';
const mockReminder1IsDone = true;
final mockReminder1ImageData = 'image1'.toUint8List();
final mock1Reminder = Reminder(
  id: mockReminder1Id,
  text: mockReminder1Text,
  isDone: mockReminder1IsDone,
  creationDate: mockReminder1DateTime,
  hasImage: false,
);

final mockReminder2DateTime = DateTime(2001, 1, 2, 3, 4, 5, 6, 7);
const mockReminder2Id = '2';
const mockReminder2Text = 'text1';
const mockReminder2IsDone = true;
final mockReminder2ImageData = 'image2'.toUint8List();
final mock2Reminder = Reminder(
  id: mockReminder2Id,
  text: mockReminder2Text,
  isDone: mockReminder2IsDone,
  creationDate: mockReminder2DateTime,
  hasImage: false,
);

final Iterable<Reminder> mockReminders = [
  mock1Reminder,
  mock2Reminder,
];

const mockReminderId = 'mocckId';

class MockRemindersService implements RemindersService {
  @override
  Future<ReminderId> createReminder(
          {required String userId,
          required String text,
          required DateTime creationDate}) =>
      mockReminderId.toFuture(oneSecond);

  @override
  Future<void> deleteAllDocuments({required String userId}) =>
      Future.delayed(oneSecond);

  @override
  Future<void> deleteReminderWithId(ReminderId id, {required String userId}) =>
      Future.delayed(oneSecond);

  @override
  Future<Iterable<Reminder>> loadReminders({required String userId}) =>
      mockReminders.toFuture(oneSecond);

  @override
  Future<void> modify({
    required String userId,
    required bool isDone,
    required ReminderId reminderId,
  }) =>
      Future.delayed(oneSecond);

  @override
  Future<Uint8List?> getReminderImage({
    required String userId,
    required ReminderId reminderId,
  }) async {
    switch (reminderId) {
      case mockReminder1Id:
        return mockReminder1ImageData;
      case mockReminder2Id:
        return mockReminder2ImageData;
      default:
        return null;
    }
  }

  @override
  Future<void> setReminderHasImage({
    required ReminderId reminderId,
    required String userId,
  }) async {
    mockReminders.firstWhere((element) => element.id == reminderId).hasImage =
        true;
  }
}

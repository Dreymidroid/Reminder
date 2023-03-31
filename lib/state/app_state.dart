import 'dart:typed_data';
import 'package:first/auth/auth_error.dart';
import 'package:first/services/auth_services.dart';
import 'package:first/services/image_upload_service.dart';
import 'package:first/state/reminder.dart';
import 'package:first/utils/extensions.dart';
import 'package:mobx/mobx.dart';
import '../services/reminders_services.dart';

part 'app_state.g.dart';

class AppState = _AppState with _$AppState;

abstract class _AppState with Store {
  final AuthService authProvider;
  final RemindersService reminderProvider;
  final ImageUploadService imageUploadService;

  _AppState({
    required this.authProvider,
    required this.reminderProvider,
    required this.imageUploadService,
  });

  @observable
  AppScreen currentScreen = AppScreen.login;

  @observable
  bool isLoading = false;

  @observable
  AuthError? authError;

  @observable
  ObservableList<Reminder> reminders = ObservableList<Reminder>();

  @computed
  ObservableList<Reminder> get sortedReminders =>
      ObservableList.of(reminders.sorted());

  @action
  void goTo(AppScreen screen) {
    currentScreen = screen;
  }

  @action
  Future<bool> deleteReminder(Reminder reminder) async {
    isLoading = true;
    final userId = authProvider.userId;
    if (userId == null) {
      isLoading = false;
      return false;
    }

    try {
      await reminderProvider.deleteReminderWithId(
        reminder.id,
        userId: userId,
      );
      // || Deleting Locally
      reminders.removeWhere((element) => element.id == reminder.id);
    } catch (_) {
      return false;
    } finally {
      isLoading = false;
    }
    return true;
  }

  @action
  Future<bool> deleteAccount() async {
    isLoading = true;
    final userId = authProvider.userId;
    if (userId == null) {
      isLoading = false;
      return false;
    }

    try {
      await authProvider.deleteAccAndSignOut();
      await reminderProvider.deleteAllDocuments(
        userId: userId,
      );
      reminders.clear();
      currentScreen = AppScreen.login;
    } on AuthError catch (e) {
      authError = e;
      return false;
    } catch (e) {
      authError = AuthError(
        dialogText: e.toString(),
        dialogTitle: "Title",
      );
      return false;
    } finally {
      isLoading = false;
    }
    return true;
  }

  @action
  Future<void> logOut() async {
    isLoading = true;
    await authProvider.signOut();
    reminders.clear();
    isLoading = false;
    currentScreen = AppScreen.login;
  }

  @action
  Future<bool> createReminder(String text) async {
    isLoading = true;
    final userId = authProvider.userId;
    if (userId == null) {
      isLoading = false;
      return false;
    }

    final creationDate = DateTime.now();
    // || Create Firebase Reminder
    final cloudReminderId = await reminderProvider.createReminder(
      userId: userId,
      text: text,
      creationDate: creationDate,
    );

    final reminder = Reminder(
      id: cloudReminderId,
      text: text,
      isDone: false,
      creationDate: creationDate,
      hasImage: false,
    );
    reminders.add(reminder);
    isLoading = false;
    return true;
  }

  @action
  Future<bool> modifyReminder({
    required ReminderId reminderId,
    required isDone,
  }) async {
    final userId = authProvider.userId;
    if (userId == null) {
      isLoading = false;
      return false;
    }

    await reminderProvider.modify(
      userId: userId,
      isDone: isDone,
      reminderId: reminderId,
    );

    // || Updating Reminder Locally
    reminders.firstWhere((element) => element.id == reminderId).isDone = isDone;

    return true;
  }

  @action
  Future<void> initialize() async {
    isLoading = true;
    final userId = authProvider.userId;
    if (userId != null) {
      await _loadReminders();
      currentScreen = AppScreen.reminders;
    } else {
      currentScreen = AppScreen.login;
    }
    isLoading = false;
  }

  @action
  Future<bool> _loadReminders() async {
    final userId = authProvider.userId;
    if (userId == null) {
      return false;
    }

    final reminders = await reminderProvider.loadReminders(
      userId: userId,
    );

    this.reminders = ObservableList.of(reminders);
    return true;
  }

  @action
  Future<bool> _registerOrLogin({
    required LoginOrRegisterFuction fn,
    required String email,
    required String password,
  }) async {
    authError = null;
    isLoading = true;
    try {
      final suceeded = await fn(
        email: email,
        password: password,
      );

      if (suceeded) {
        await _loadReminders();
      }

      return suceeded;
    } on AuthError catch (e) {
      authError = e;
      return false;
    } finally {
      isLoading = false;
      if (authProvider.userId != null) {
        currentScreen = AppScreen.reminders;
      }
    }
  }

  @action
  Future<bool> register({
    required String email,
    required String password,
  }) =>
      _registerOrLogin(
        fn: authProvider.register,
        email: email,
        password: password,
      );

  @action
  Future<bool> login({
    required String email,
    required String password,
  }) =>
      _registerOrLogin(
        fn: authProvider.login,
        email: email,
        password: password,
      );

  @action
  Future<bool> upload({
    required String filePath,
    required ReminderId forReminderId,
  }) async {
    final userId = authProvider.userId;
    if (userId == null) {
      isLoading = false;
      return false;
    }

    // || Set the reminder as loading
    final reminder = reminders.firstWhere(
      (element) => element.id == forReminderId,
    );
    reminder.isLoading = true;

    final imageId = await imageUploadService.uploadImage(
      filePath: filePath,
      userId: userId,
      imageId: forReminderId,
    );

    if (imageId == null) {
      reminder.isLoading = false;
      return false;
    }

    await reminderProvider.setReminderHasImage(
      reminderId: forReminderId,
      userId: userId,
    );
    reminder.isLoading = false;
    reminder.hasImage = true;
    return true;
  }

  Future<Uint8List?> getReminderImage({
    required ReminderId reminderId,
  }) async {
    final userId = authProvider.userId;
    if (userId == null) {
      return null;
    }

    final reminder = reminders.firstWhere(
      (element) => element.id == reminderId,
    );
    final existingImageData = reminder.imageData;
    if (existingImageData != null) {
      return existingImageData;
    }

    final image = await reminderProvider.getReminderImage(
      userId: userId,
      reminderId: reminderId,
    );
    reminder.imageData = image;
    return image;
  }
}

typedef LoginOrRegisterFuction = Future<bool> Function({
  required String email,
  required String password,
});

extension Sorted on List<Reminder> {
  List<Reminder> sorted() => [...this]..sort((lhs, rhs) {
      final isDone = lhs.isDone.toInteger().compareTo(rhs.isDone.toInteger());
      if (isDone != 0) {
        return isDone;
      }
      return lhs.creationDate.compareTo(rhs.creationDate);
    });
}

enum AppScreen { login, register, reminders }

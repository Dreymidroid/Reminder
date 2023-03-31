import 'package:first/state/app_state.dart';
import 'package:flutter_test/flutter_test.dart';

import 'mocks/mock_auth_service.dart';
import 'mocks/mock_image_upload_service.dart';
import 'mocks/mock_reminders_service.dart';

void main() {
  late AppState appState;
  setUp(() {
    appState = AppState(
      authProvider: MockAuthService(),
      reminderProvider: MockRemindersService(), imageUploadService: MockImageUploadService(),
    );
  });

  test('Initial State', () {
    expect(
      appState.currentScreen,
      AppScreen.login,
    );
    expect(
      appState.authError,
      null,
    );
    expect(
      appState.isLoading,
      false,
    );
    expect(
      appState.reminders.isEmpty,
      true,
    );
  });

  test('goTo Function: Going to Screens', () {
    appState.goTo(AppScreen.register);
    expect(
      appState.currentScreen,
      AppScreen.register,
    );
    appState.goTo(AppScreen.login);
    expect(
      appState.currentScreen,
      AppScreen.login,
    );
    appState.goTo(AppScreen.reminders);
    expect(
      appState.currentScreen,
      AppScreen.reminders,
    );
  });

  test('Initializing App State', () {

  });
}

extension Expectations on Object? {
  void expectNull() => expect(this, isNull);
  void expectNotNull() => expect(this, isNotNull);
}

extension BoolExpectations on bool? {
  void expectTrue() => expect(this, true);
  void expectFalse() => expect(this, false);
}

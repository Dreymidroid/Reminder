import 'package:first/dialogs/show_auth_error_dialog.dart';
import 'package:first/loading/loading_screen.dart';
import 'package:first/services/auth_services.dart';
import 'package:first/services/image_upload_service.dart';
import 'package:first/services/reminders_services.dart';
import 'package:first/state/app_state.dart';
import 'package:first/views/login_view.dart';
import 'package:first/views/register_view.dart';
import 'package:first/views/reminders_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    Provider(
      create: (_) => AppState(
        authProvider: FirebaseAuthService(),
        reminderProvider: FirestoreRemindersService(), imageUploadService: FirebaseImageUploadService(),
      )..initialize(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      home: ReactionBuilder(
        builder: (context) {
          return autorun((_) {
            print(context.read<AppState>().currentScreen);
            final isLoading = context.read<AppState>().isLoading;
            if (isLoading) {
              LoadingScreen.instance().show(
                context: context,
                text: 'Loading...',
              );
            } else {
              LoadingScreen.instance().hide();
            }

            final authError = context.read<AppState>().authError;
            if (authError != null) {
              showAuthError(
                context: context,
                error: authError,
              );
            }
          });
        },
        child: Observer(
            name: "Debugging Purposes",
            builder: (context) {
              switch (context.read<AppState>().currentScreen) {
                case AppScreen.login:
                  return const LoginView();
                case AppScreen.register:
                  return const RegisterView();
                case AppScreen.reminders:
                  return const RemindersView();
              }
            }),
      ),
    );
  }
}

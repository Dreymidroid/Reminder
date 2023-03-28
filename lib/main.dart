import 'package:first/dialogs/show_auth_error_dialog.dart';
import 'package:first/loading/loading_screen.dart';
import 'package:first/state/reminder.dart';
import 'package:first/views/login_view.dart';
import 'package:first/views/register_view.dart';
import 'package:first/views/reminders_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';
import 'package:provider/provider.dart';

void main() async {
  runApp(
    Provider(
      create: (_) => AppState()..initialize(),
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
            if (authError) {
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
                case AppScreen.reminder:
                  return const RemindersView();
              }
            }),
      ),
    );
  }
}

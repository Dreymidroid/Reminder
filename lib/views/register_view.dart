import 'package:first/dialogs/generic_dialog.dart';
import 'package:first/extensions/if_debugging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController emailCtrl;
  late final TextEditingController passwordCtrl;
  late final TextEditingController confirmPasswordCtrl;

  @override
  void initState() {
    super.initState();
    emailCtrl = TextEditingController(
      text: 'dadefemiwa@gmail.com'.ifDebugging,
    );
    passwordCtrl = TextEditingController(
      text: 'dadefemiwa@gmail.com'.ifDebugging,
    );
    confirmPasswordCtrl = TextEditingController(
      text: 'dadefemiwa@gmail.com'.ifDebugging,
    );
  }

  @override
  void dispose() {
    emailCtrl.dispose();
    passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(children: [
          TextField(
            controller: emailCtrl,
            decoration: const InputDecoration(
              hintText: 'Enter Email',
            ),
            keyboardType: TextInputType.emailAddress,
            keyboardAppearance: Brightness.dark,
          ),
          TextField(
            controller: passwordCtrl,
            decoration: const InputDecoration(
              hintText: 'Enter Password',
            ),
            obscureText: true,
            keyboardAppearance: Brightness.dark,
          ),
          TextField(
            controller: confirmPasswordCtrl,
            decoration: const InputDecoration(
              hintText: 'Confirm Password',
            ),
            obscureText: true,
            keyboardAppearance: Brightness.dark,
          ),
          TextButton(
            onPressed: () {
              final email = emailCtrl.text;
              if (passwordCtrl.text != confirmPasswordCtrl.text) {
                showGenericDialog(
                  context: context,
                  title: 'Password Mismatch',
                  content: 'The passwords do not match',
                  optionsBuilder: () => {'Ok': null},
                );
                return;
              }
              final password = passwordCtrl.text;
              context.read<AppState>().register(
                    email: email,
                    password: password,
                  );
            },
            child: const Text('Register'),
          ),
          TextButton(
            onPressed: () {
              context.read<AppState>().goTo(
                    AppScreen.login,
                  );
            },
            child: const Text('Already Registered ?'),
          )
        ]),
      ),
    );
  }
}

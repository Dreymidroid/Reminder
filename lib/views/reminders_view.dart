// ignore_for_file: use_build_context_synchronously

import 'package:first/views/main_popup_menu_button.dart';
import 'package:first/views/reminders_list_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../dialogs/show_textfield_dialog.dart';
import '../state/app_state.dart';

class RemindersView extends StatelessWidget {
  const RemindersView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reminders'),
        actions: [
          IconButton(
              onPressed: () async {
                final reminderText = await showTextFieldDialog(
                  context: context,
                  title: 'What do you need to remember',
                  hintText: 'Enter Reminder Text...',
                  optionsBuilder: () => {
                    TextFieldDialogButtonType.cancel: 'Cancel',
                    TextFieldDialogButtonType.confirm: 'Save',
                  },
                );

                if (reminderText == null) {
                  return;
                }
                context.read<AppState>().createReminder(
                      reminderText,
                    );
              },
              icon: const Icon(Icons.add)),
          const MainPopupMenuButton(),
        ],
      ),
      body: const RemindersListView(),
    );
  }
}


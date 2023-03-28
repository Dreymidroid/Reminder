// ignore_for_file: use_build_context_synchronously

import 'package:first/dialogs/delete_reminder_dialog.dart';
import 'package:first/views/main_popup_menu_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart' show Observer;
import 'package:provider/provider.dart';

import '../dialogs/show_textfield_dialog.dart';

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
      body: const ReminderListView(),
    );
  }
}

class ReminderListView extends StatelessWidget {
  const ReminderListView({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    return Observer(
      builder: (context) {
        return ListView.builder(
            itemCount: appState.sortedReminders.length,
            itemBuilder: (context, index) {
              final reminder = appState.sortedReminders[index];
              return Observer(builder: (context) {
                return CheckboxListTile(
                  controlAffinity: ListTileControlAffinity.leading,
                  value: reminder.isDone,
                  onChanged: (isDone) {
                    context.read<AppState>().modify(
                          reminder,
                          isDone: isDone ?? false,
                        );
                    reminder.isDone = isDone ?? false;
                  },
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(reminder.text),
                      ),
                      IconButton(
                        onPressed: () async {
                          final shouldDeleteReminder =
                              await showDeleteReminderDialog(context);
                          if (shouldDeleteReminder) {
                            context.read<AppState>().deleteReminder(reminder);
                          }
                        },
                        icon: const Icon(Icons.delete),
                      )
                    ],
                  ),
                );
              });
            });
      },
    );
  }
}

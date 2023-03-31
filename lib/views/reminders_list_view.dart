// ignore_for_file: use_build_context_synchronously

import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart' show Observer;
import 'package:provider/provider.dart';

import '../dialogs/delete_reminder_dialog.dart';
import '../state/app_state.dart';

final _imagePicker = ImagePicker();

class ReminderImageView extends StatelessWidget {
  final int reminderIndex;
  const ReminderImageView({
    super.key,
    required this.reminderIndex,
  });

  @override
  Widget build(BuildContext context) {
    final appState = context.read<AppState>();
    final reminder = appState.sortedReminders[reminderIndex];

    if (reminder.hasImage) {
      return FutureBuilder<Uint8List?>(
        future: appState.getReminderImage(
          reminderId: reminder.id,
        ),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
            case ConnectionState.active:
              return const Center(
                child: CircularProgressIndicator(),
              );
            case ConnectionState.done:
              if (snapshot.hasData) {
                return Image.memory(snapshot.data!);
              } else {
                return const Center(
                  child: Icon(
                    Icons.error,
                  ),
                );
              }
          }
        },
      );
    } else {
      return const SizedBox();
    }
  }
}

class RemindersListView extends StatelessWidget {
  const RemindersListView({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    return Observer(
      builder: (context) {
        return ListView.builder(
            itemCount: appState.sortedReminders.length,
            itemBuilder: (context, index) {
              return ReminderTile(
                reminderIndex: index,
                imagePicker: _imagePicker,
              );
            });
      },
    );
  }
}

class ReminderTile extends StatelessWidget {
  final int reminderIndex;
  final ImagePicker imagePicker;

  const ReminderTile({
    super.key,
    required this.reminderIndex,
    required this.imagePicker,
  });

  @override
  Widget build(BuildContext context) {
    final appState = context.read<AppState>();
    final reminder = appState.sortedReminders[reminderIndex];

    return Observer(
      builder: (context) {
        return CheckboxListTile(
          subtitle: ReminderImageView(
            reminderIndex: reminderIndex,
          ),
          controlAffinity: ListTileControlAffinity.leading,
          value: reminder.isDone,
          onChanged: (isDone) {
            context.read<AppState>().modifyReminder(
                  reminderId: reminder.id,
                  isDone: isDone ?? false,
                );
            reminder.isDone = isDone ?? false;
          },
          title: Row(
            children: [
              Expanded(
                child: Text(reminder.text),
              ),
              reminder.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : const SizedBox(),
              reminder.hasImage
                  ? const SizedBox()
                  : IconButton(
                      onPressed: () async {
                        final image = await imagePicker.pickImage(
                          source: ImageSource.gallery,
                        );

                        if (image != null) {
                          appState.upload(
                            filePath: image.path,
                            forReminderId: reminder.id,
                          );
                        }
                      },
                      icon: const Icon(Icons.upload),
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
      },
    );
  }
}

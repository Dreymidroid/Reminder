import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../state/reminder.dart';

typedef ReminderId = String;

abstract class RemindersService {
  Future<void> deleteReminderWithId(
    ReminderId id, {
    required String userId,
  });

  Future<void> deleteAllDocuments({
    required String userId,
  });

  Future<ReminderId> createReminder({
    required String userId,
    required String text,
    required DateTime creationDate,
  });

  Future<void> modify({
    required String userId,
    required bool isDone,
    required ReminderId reminderId,
  });

  Future<Iterable<Reminder>> loadReminders({
    required String userId,
  });

  Future<Uint8List?> getReminderImage({
    required String userId,
    required ReminderId reminderId,
  });

  Future<void> setReminderHasImage({
    required ReminderId reminderId,
    required String userId,
  });
}

class FirestoreRemindersService implements RemindersService {
  @override
  Future<ReminderId> createReminder({
    required String userId,
    required String text,
    required DateTime creationDate,
  }) async {
    final creationDate = DateTime.now();
    // || Create Firebase Reminder
    final firebaseReminder =
        await FirebaseFirestore.instance.collection(userId).add({
      _DocumentKeys.text: text,
      _DocumentKeys.creationDate: creationDate.toIso8601String(),
      _DocumentKeys.isDone: false,
      _DocumentKeys.hasImage: false,
    });

    return firebaseReminder.id;
  }

  @override
  Future<void> deleteAllDocuments({
    required String userId,
  }) async {
    final store = FirebaseFirestore.instance;
    final operation = store.batch();
    final collections = await store.collection(userId).get();

    for (final doc in collections.docs) {
      operation.delete(doc.reference);
      // || Delete Image for the reminder if it exists
      try {
        await FirebaseStorage.instance.ref(userId).child(doc.id).delete();
      } catch (_) {
        // || Ignore
      }
    }
    // || Carry out Deletion
    try {
    await operation.commit();
      
    } catch (_) {
      print("Errrrr");
    }
  }

  @override
  Future<void> deleteReminderWithId(
    ReminderId id, {
    required String userId,
  }) async {
    final collection =
        await FirebaseFirestore.instance.collection(userId).get();

    final firebaseReminder =
        collection.docs.firstWhere((element) => element.id == id);
    // || Deleting from Firebase
    await firebaseReminder.reference.delete();
    // || Deleting Image Firebase
    try {
      await FirebaseStorage.instance
          .ref(userId)
          .child(firebaseReminder.id)
          .delete();
    } catch (_) {
      // || Ignore
    }
  }

  @override
  Future<Iterable<Reminder>> loadReminders({
    required String userId,
  }) async {
    final collection =
        await FirebaseFirestore.instance.collection(userId).get();

    final reminders = collection.docs.map(
      (doc) => Reminder(
        id: doc.id,
        text: doc[_DocumentKeys.text] as String,
        isDone: doc[_DocumentKeys.isDone] as bool,
        creationDate: DateTime.parse(
          doc[_DocumentKeys.creationDate] as String,
        ),
        hasImage: doc[_DocumentKeys.hasImage] as bool,
      ),
    );

    return reminders;
  }

  Future<void> _modify({
    required ReminderId reminderId,
    required String userId,
    required Map<String, Object?> keyValues,
  }) async {
    // || Getting Collection from Firebase
    final collection =
        await FirebaseFirestore.instance.collection(userId).get();

    // || Getting Specific Reminder from Firebase
    final firebaseReminder = collection.docs
        .where((element) => element.id == reminderId)
        .first
        .reference;
    // || Updating Reminder on Firebase
    await firebaseReminder.update(keyValues);
  }

  @override
  Future<void> modify({
    required bool isDone,
    required String userId,
    required ReminderId reminderId,
  }) =>
      _modify(
        reminderId: reminderId,
        userId: userId,
        keyValues: {
          _DocumentKeys.isDone: isDone,
        },
      );

  @override
  Future<Uint8List?> getReminderImage({
    required String userId,
    required ReminderId reminderId,
  }) async {
    try {
      final ref = FirebaseStorage.instance.ref(userId).child(reminderId);
      final data = await ref.getData();
      return data;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> setReminderHasImage({
    required ReminderId reminderId,
    required String userId,
  }) =>
      _modify(
        reminderId: reminderId,
        userId: userId,
        keyValues: {
          _DocumentKeys.hasImage: true,
        },
      );
}

abstract class _DocumentKeys {
  static const text = 'text';
  static const creationDate = 'creation_date';
  static const isDone = 'is_done';
  static const hasImage = 'has_image';
}

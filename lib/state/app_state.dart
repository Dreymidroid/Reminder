import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:first/auth/auth_error.dart';
import 'package:first/state/reminder.dart';
import 'package:mobx/mobx.dart';

part of 'app_state.g.dart';

class AppState = _AppState with _$AppState;

abstract class _AppState with Store {

  @observable
  AppScreen currentScreen = AppScreen.login;

  @observable
  bool isLoading = false;

  @observable
  User? currentUser;

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
    final auth = FirebaseAuth.instance;
    final user = auth.currentUser;
    if (user == null ) {
      isLoading = false;
      return false;
    }
    final userId = user.uid;
    final collection = await FirebaseFirestore.instance.collection(userId).get();

    try {
      final firebaseReminder = collection.docs.firstWhere(
        (element) => element.id == reminder.id
        );
      // || Deleting from Firebase
      await firebaseReminder.reference.delete();

      // || Deleting Locally
      reminders.removeWhere(
        (element) => element.id == reminder.id
        );
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
    final auth = FirebaseAuth.instance;
    final user = auth.currentUser;
    if ( user == null ) {
      isLoading = false;
      return false;
    }
    final userId = user.uid;
    try {
      final store = FirebaseFirestore.instance;
      final operation = store.batch();
      final collection = await store.collection(userId).get();
      for (final document in collection.docs) {
        operation.delete(document.reference);
      }
      // || Delete Reminders on Firebase
      await operation.commit();
      // || Delete User
      await user.delete();
      // || Log User Out
      await auth.signOut();
      
    } on FirebaseAuthException catch (e) {
      authError = AuthError.from(e);
    } catch (_) {
      return false;
    } finally {
      isLoading = false;
    }
    return true;
  }

  @action
  Future<void> logOut() async {
    try {
      isLoading = true;
      await FirebaseAuth.instance.signOut();
    } catch (_) {
      
    }
    isLoading = false;
    currentScreen = AppScreen.login;
    reminders.clear();
  }
  
  @action
  Future<bool> createReminder(String text) async {
    isLoading = true;
    final userId = currentUser?.uid;
    if (userId == null) {
      isLoading = false;
      return false;
    }
    final creationDate = DateTime.now();
    // || Create Firebase Reminder
    final firebaseReminder = await FirebaseFirestore.instance.collection(userId).add(
      {
        _DocumentKeys.text: text,
        _DocumentKeys.creationDate: creationDate.toIso8601String(),
        _DocumentKeys.isDone: false
      }
    );

    final reminder = Reminder(id: firebaseReminder.id, text: text, isDone: false, creationDate: creationDate,);
    reminders.add(reminder);
    isLoading = false;
    return true;
  }

  @action
  Future<bool> modify(Reminder reminder, {
    required isDone,
  }) async {
    isLoading = true;
    final userId = currentUser?.uid;
    if (userId == null) {
      return false;
    }
    // || Getting Collection from Firebase
    final collection = await FirebaseFirestore.instance.collection(userId).get();

    // || Getting Specific Reminder from Firebase
    final firebaseReminder = collection.docs.where((element) => element.id == reminder.id).first.reference;
    // || Updating Reminder on Firebase
    await firebaseReminder.update({_DocumentKeys.isDone: isDone,});
    // || Updating Reminder Locally
    reminders.firstWhere((element) => element.id == reminder.id).isDone = isDone;

    return true;
  }

  @action
  Future<void> initialize() async {
    isLoading = true;
    currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      await _loadReminders();
      currentScreen = AppScreen.reminders;
    } else {
      currentScreen = AppScreen.login;
    }
  }

  @action
  Future<bool> _loadReminders() async {
    final userId = currentUser?.uid;
    if (userId == null) {
      return false;
    }

    final collection = await FirebaseFirestore.instance.collection(userId).get();

    final reminders = collection.docs.map((doc) => Reminder(
      id: doc.id,
      text: doc[_DocumentKeys.text] as String, 
      isDone: doc[_DocumentKeys.isDone] as bool, 
      creationDate: DateTime.parse(
        doc[_DocumentKeys.creationDate] as String,
      ),
      )
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
      await fn(
        email: email,
       password: password,
      );
      
      currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        await _loadReminders();
        currentScreen = AppScreen.reminders;
      } else {
        currentScreen = AppScreen.login;
      }
      isLoading = false;
      return true;
    } on FirebaseAuthException catch (e) {
      currentUser = null;
      authError = AuthError.from(e);
      return false;
    } finally {
      isLoading = false;
      if (currentUser != null) {
        currentScreen = AppScreen.reminders;
      }
    }
  }

  @action
  Future<bool> register({
    required String email,
    required String password,
  }) => _registerOrLogin(fn: FirebaseAuth.instance.createUserWithEmailAndPassword, email: email, password: password,);

  @action
  Future<bool> login({
    required String email,
    required String password,
  }) => _registerOrLogin(fn: FirebaseAuth.instance.signInWithEmailAndPassword, email: email, password: password,);
}

abstract class _DocumentKeys {
  static const text = 'text';
  static const creationDate = 'creation_date';
  static const isDone = 'is_done';
}

typedef LoginOrRegisterFuction = Future<UserCredential> Function({
  required String email,
  required String password,
});

extension ToInt on bool {
  int toInteger() => this ? 1 : 0;
}

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


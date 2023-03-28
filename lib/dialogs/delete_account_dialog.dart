import 'package:flutter/widgets.dart';

import 'generic_dialog.dart';

Future<bool> showDeleteAccountDialog(BuildContext context) {
  return showGenericDialog(
    context: context,
    title: 'Delete Account',
    content: 'Are You Sure?',
    optionsBuilder: () => {
      'Cancel': false,
      'Delete': true,
    },
  ).then((value) => value ?? false);
}
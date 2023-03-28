import 'package:first/auth/auth_error.dart';
import 'package:flutter/widgets.dart';

import 'generic_dialog.dart';

Future<void> showAuthError({
  required BuildContext context,
  required AuthError error,
}) {
  return showGenericDialog<void>(
    context: context,
    title: error.dialogTitle,
    content: error.dialogText,
    optionsBuilder: () => {
      'Ok': true,
    },
  );
}

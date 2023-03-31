import 'dart:typed_data';

extension ToInt on bool {
  int toInteger() => this ? 1 : 0;
}

extension FirebaseAuthParse on String {
  String get processedText {
    final list = split('-');
    return list.map((e) => e.toTitleCase).join(' ');
  }
}

extension ToTitleCase on String {
  String get toTitleCase {
    List<String> splitted = split("");
    String capitalized = "";

    for (var i = 0; i < splitted.length; i++) {
      if (i == 0) {
        capitalized = splitted[0].toUpperCase();
      } else {
        capitalized += splitted[i];
      }
    }
    return capitalized;
  }
}

extension ToList on String {
  Uint8List toUint8List() => Uint8List.fromList(codeUnits);
}
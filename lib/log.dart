import 'package:flutter/foundation.dart';

void printSafe(message) {
  if (kDebugMode) {
    print(message.toString());
  }
}

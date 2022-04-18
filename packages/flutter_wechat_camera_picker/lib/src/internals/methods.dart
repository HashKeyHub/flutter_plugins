///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2021/9/30 17:01
///
import 'dart:developer';

import 'package:flutter/foundation.dart';

import 'extensions.dart';
import 'type_defs.dart';

/// Log only in debug mode.
/// 只在调试模式打印
void realDebugPrint(dynamic message) {
  if (!kReleaseMode) {
    log('$message', name: 'CameraPicker - LOG');
  }
}

void handleErrorWithHandler(Object error, CameraErrorHandler? handler) {
  if (handler != null) {
    handler(error, error.nullableStackTrace);
    return;
  }
  throw error;
}

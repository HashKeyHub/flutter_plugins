// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// This is a temporary ignore to allow us to land a new set of linter rules in a
// series of manageable patches instead of one gigantic PR. It disables some of
// the new lints that are already failing on this plugin, for this plugin. It
// should be deleted and the failing lints addressed as soon as possible.
// ignore_for_file: public_member_api_docs

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:meta/meta.dart';
import 'package:platform/platform.dart';

import 'auth_strings.dart';
import 'error_codes.dart';
import 'auth_type.dart';

enum BiometricType { face, fingerprint, iris }

const MethodChannel _channel = MethodChannel('plugins.flutter.io/local_auth');

const EventChannel _eventChannel =
    EventChannel('plugins.flutter.io.event/local_auth');

Platform _platform = const LocalPlatform();

@visibleForTesting
void setMockPathProviderPlatform(Platform platform) {
  _platform = platform;
}

/// A Flutter plugin for authenticating the user identity locally.
class LocalAuthentication {
  /// callbackValue [onPositiveCallback]  -1000 -> 取消 -1001->失败  -1002->多次失败 -2000 ->设备不支持 -3000 -> 未设置指纹 -4000 -> 密码支付 -5000 -> 去设置开启

  // ignore: missing_return
  Future<AuthType> authenticateWithBiometrics({
    AndroidAuthMessages androidAuthStrings = const AndroidAuthMessages(),
    IOSAuthMessages iOSAuthStrings = const IOSAuthMessages(),

    /// 是否需要密码支付
    bool sensitiveTransaction = false,
    bool dark = false,
    ValueChanged<AuthType> listening,
  }) async {
    final Map<String, dynamic> args = <String, dynamic>{
      'sensitiveTransaction': sensitiveTransaction ? 1 : 0,
      'dark': dark ? 1 : 0,
    };
    if (_platform.isIOS) {
      args.addAll(iOSAuthStrings.args);
    } else if (_platform.isAndroid) {
      args.addAll(androidAuthStrings.args);
    } else {
      throw PlatformException(
          code: otherOperatingSystem,
          message: 'Local authentication does not support non-Android/iOS '
              'operating systems.',
          details: 'Your operating system is ${_platform.operatingSystem}');
    }
    try {
      await _channel.invokeMethod<int>('authenticateWithBiometrics', args);
      _eventChannel.receiveBroadcastStream().listen((one) {
        if (listening == null) {
          return;
        }
        switch (one) {
          case 0:
            listening(AuthType.failure);
            break;
          case 1:
            listening(AuthType.success);
            break;
          case -1000:
            listening(AuthType.negative);
            break;
          case -1001:
            listening(AuthType.failure);
            break;
          case -1002:
            listening(AuthType.multipleFailure);
            break;
          case -2000:
            listening(AuthType.notSupport);
            break;
          case -3000:
            listening(AuthType.notSetting);
            break;
          case -4000:
            listening(AuthType.payPassword);
            break;
          case -5000:
            listening(AuthType.goOpen);
            break;
        }
      }, onError: _onError);
    } on PlatformException catch (e) {
      print("${e}");
      if (listening != null) {
        listening(AuthType.failure);
      }
    }
  }

  void _onError(Object error) {
    print('返回的错误==${error}');
  }

  /// Returns true if device is capable of checking biometrics
  ///
  /// Returns a [Future] bool true or false:
  Future<bool> get canCheckBiometrics async =>
      (await _channel.invokeListMethod<String>('getAvailableBiometrics'))
          .isNotEmpty;

  /// Returns a list of enrolled biometrics
  ///
  /// Returns a [Future] List<BiometricType> with the following possibilities:
  /// - BiometricType.face
  /// - BiometricType.fingerprint
  /// - BiometricType.iris (not yet implemented)
  Future<List<BiometricType>> getAvailableBiometrics() async {
    final List<String> result =
        (await _channel.invokeListMethod<String>('getAvailableBiometrics'));
    final List<BiometricType> biometrics = <BiometricType>[];
    result.forEach((String value) {
      switch (value) {
        case 'face':
          biometrics.add(BiometricType.face);
          break;
        case 'fingerprint':
          biometrics.add(BiometricType.fingerprint);
          break;
        case 'iris':
          biometrics.add(BiometricType.iris);
          break;
        case 'undefined':
          break;
      }
    });
    return biometrics;
  }

  Future<bool> canAuthenticate() async {
    final response = await _channel.invokeMethod<int>('canAuthenticate');
    return response == 0 ? false : true;
  }

  Future<bool> stopAuthentication() {
    if (_platform.isAndroid) {
      return _channel.invokeMethod<bool>('stopAuthentication');
    }
    return Future<bool>.sync(() => true);
  }
}

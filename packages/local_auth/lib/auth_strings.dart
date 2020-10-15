// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// This is a temporary ignore to allow us to land a new set of linter rules in a
// series of manageable patches instead of one gigantic PR. It disables some of
// the new lints that are already failing on this plugin, for this plugin. It
// should be deleted and the failing lints addressed as soon as possible.
// ignore_for_file: public_member_api_docs

class AndroidAuthMessages {
  const AndroidAuthMessages({
    this.tips,
    this.notRecognized,
    this.failures,
    this.touchSetting,
    this.success,
    this.negativeBtn,
    this.positiveBtn,
  });

  /// 指纹识别提示
  final String tips;

  /// 指纹识别失败
  final String notRecognized;

  /// 尝试次数过多，请稍后重试。
  final String failures;

  /// touch 设置权限提示
  final String touchSetting;

  /// 指纹识别成功
  final String success;

  /// 取消按钮
  final String negativeBtn;

  /// 使用密码支付
  final String positiveBtn;

  Map<String, String> get args {
    return <String, String>{
      'tips': tips ?? "请验证指纹",
      'notRecognized': notRecognized ?? "指纹验证错误，请重试",
      'failures': failures ?? "多次验证不通过，请稍后再试",
      'touchSetting': touchSetting ?? "系统没有指纹ID信息，请先开启系统指纹ID服务",
      'success': success ?? "验证成功",
      'negativeBtn': negativeBtn ?? "取消",
      'positiveBtn': positiveBtn ?? "密码支付",
    };
  }
}

/// iOS side authentication messages.
///
/// Provides default values for all messages.
class IOSAuthMessages {
  const IOSAuthMessages({
    this.deviceLockout,
    this.faceLimit,
    this.faceSetting,
    this.faceFailures,
    this.faceTips,
    this.touchLimit,
    this.touchSetting,
    this.touchFailures,
    this.touchTips,
    this.negativeBtn,
    this.positiveBtn,
    this.payPassword,
    this.goSetting,
  });

  /// 生物验证次数过多,被锁
  final String deviceLockout;

  /// face 开启权限提示
  final String faceLimit;

  /// face 设置权限提示
  final String faceSetting;

  /// face 超出尝试次数
  final String faceFailures;

  /// face 超出尝试次数
  final String faceTips;

  /// touch 开启权限提示
  final String touchLimit;

  /// touch 设置权限提示
  final String touchSetting;

  /// touch 超出尝试次数
  final String touchFailures;

  /// touch 超出尝试次数
  final String touchTips;

  /// 取消按钮
  final String negativeBtn;

  /// 密码解锁
  final String positiveBtn;

  /// 使用密码支付
  final String payPassword;

  /// 开启权限
  final String goSetting;

  Map<String, String> get args {
    return <String, String>{
      'deviceLockout': deviceLockout ?? "设备密码错误多次，请解锁系统限制后再试",
      'faceLimit': faceLimit ?? "开启面容ID权限才能使用解锁哦",
      'faceSetting': faceSetting ?? "系统没有面容ID信息，请先开启系统面容ID服务",
      'faceFailures': faceFailures ?? "超出面容 ID 尝试次数",
      'faceTips': faceTips ?? "多次验证不通过，请稍后再试",
      'touchLimit': touchLimit ?? "开启指纹ID权限才能使用解锁哦",
      'touchSetting': touchSetting ?? "系统没有指纹ID信息，请先开启系统指纹ID服务",
      'touchFailures': touchFailures ?? "超出指纹 ID 尝试次数",
      'touchTips': touchTips ?? "通过Home键验证已有指纹",
      'negativeBtn': negativeBtn ?? "取消",
      'positiveBtn': positiveBtn ?? "输入密码",
      'payPassword': payPassword ?? "密码支付",
      'goSetting': goSetting ?? "去开启"
    };
  }
}

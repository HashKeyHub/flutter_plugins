// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
#import <LocalAuthentication/LocalAuthentication.h>
#import "FLTLocalAuthPlugin.h"
#import "Biology.h"
// callbackValue [onPositiveCallback]  -1000 -> 取消 -1001->失败  -1002->多次失败 -2000 ->设备不支持 -3000 -> 未设置指纹 -4000 -> 密码支付 -5000 -> 去设置开启

@interface FLTLocalAuthPlugin ()<FlutterStreamHandler>
@property(copy, nullable) NSDictionary<NSString *, NSNumber *> *lastCallArgs;
@property(nullable) FlutterResult lastResult;
@property(nonatomic,strong)FlutterEventSink eventSink;
@end

@implementation FLTLocalAuthPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
    
    FlutterMethodChannel *channel =
    [FlutterMethodChannel methodChannelWithName:@"plugins.flutter.io/local_auth"
                                binaryMessenger:[registrar messenger]];
    FLTLocalAuthPlugin *instance = [[FLTLocalAuthPlugin alloc] init];
    
    [registrar addMethodCallDelegate:instance channel:channel];
    FlutterEventChannel *eventChannel = [FlutterEventChannel eventChannelWithName:@"plugins.flutter.io.event/local_auth" binaryMessenger:[registrar messenger]];
    [eventChannel setStreamHandler:instance];
    
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    if ([@"authenticateWithBiometrics" isEqualToString:call.method]) {
        [self authenticateWithBiometrics:call.arguments withFlutterResult:result];
    } else if ([@"getAvailableBiometrics" isEqualToString:call.method]) {
        [self getAvailableBiometrics:result];
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (void)getAvailableBiometrics:(FlutterResult)result {
    LAContext *context = [[LAContext alloc] init];
    NSError *authError = nil;
    NSMutableArray<NSString *> *biometrics = [[NSMutableArray<NSString *> alloc] init];
    if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthentication
                             error:&authError]) {
        if (authError == nil) {
            if (@available(iOS 11.0.1, *)) {
                if (context.biometryType == LABiometryTypeFaceID) {
                    [biometrics addObject:@"face"];
                } else if (context.biometryType == LABiometryTypeTouchID) {
                    [biometrics addObject:@"fingerprint"];
                }
            } else {
                [biometrics addObject:@"fingerprint"];
            }
        }
    } else if (authError.code == LAErrorTouchIDNotEnrolled) {
        [biometrics addObject:@"undefined"];
    }
    
    result(biometrics);
}

- (void)authenticateWithBiometrics:(NSDictionary *)arguments
                 withFlutterResult:(FlutterResult)result {
    result(@(1000000));
    
    
    
    NSString *tips = @" ";
    if ([Biology getWhitchBiology] == 2) {
        tips = arguments[@"faceTips"];
        
    }
    else if ([Biology getWhitchBiology] == 1) {
        tips = arguments[@"touchTips"];
    }
    
    NSInteger sensitiveTransaction = ((NSNumber *)arguments[@"sensitiveTransaction"]).intValue;
    NSString *btn = sensitiveTransaction == 0 ? arguments[@"positiveBtn"] : arguments[@"payPassword"];
    [Biology biologyUnLockTips:tips negativeBtn:arguments[@"negativeBtn"] positiveBtn:btn sensitiveTransaction:sensitiveTransaction unLockSuccess:^{
        self.eventSink(@(1));
    } unLockFail:^(NSInteger code)  {
        [self event:code biometrics:arguments flutterResult:result];
    } unLockError:^(NSInteger code)  {
        [self event:code biometrics:arguments flutterResult:result];
    }];
}

-(void)event:(NSInteger)code biometrics:(NSDictionary *)arguments flutterResult:(FlutterResult)result{
    
    NSString *title1 = @" ";
    
    NSString *title2 = @" ";
    
    NSString *title3 = @" ";
    
    NSString *tips = @" ";
    
    if ([Biology getWhitchBiology] == 2) {
        
        title1 = arguments[@"faceLimit"];
        title2 = arguments[@"faceSetting"];
        title3 = arguments[@"faceFailures"];
        tips = arguments[@"faceTips"];
    }
    else if ([Biology getWhitchBiology] == 1) {
        title1 = arguments[@"touchLimit"];
        title2 = arguments[@"touchSetting"];
        title3 = arguments[@"touchFailures"];
        tips = arguments[@"touchTips"];
    }
    
    switch (code) {
        case LAErrorUserFallback:
        {
            self.eventSink(@(-4000));
            break;
        }
        case LAErrorPasscodeNotSet:
        {
            [Biology setBiologyshouldOpenTitle2:title2 negativeBtn:arguments[@"negativeBtn"] onNegative:^{
                self.eventSink(@(-1000));
            }];
            break;
        }
        case LAErrorTouchIDNotAvailable:
        {
            [Biology setBiologyOkTitle1:title1 negativeBtn:arguments[@"negativeBtn"] positiveBtn:arguments[@"goSetting"] onNegative:^{
                // 取消
                self.eventSink(@(-1000));
            } onPositive:^{
                // 去设置开启权限
                self.eventSink(@(-5000));
            }];
            break;
        }
        case LAErrorTouchIDNotEnrolled:
        {
            [Biology setBiologyshouldOpenTitle2:title2 negativeBtn:arguments[@"negativeBtn"] onNegative:^{
                self.eventSink(@(-1000));
            }];
            break;
        }
        case LAErrorTouchIDLockout:
        {
            [Biology biologyOutTitle3:title3 negativeBtn: arguments[@"negativeBtn"] positiveBtn:arguments[@"payPassword"] onNegative:^{
                /// 取消
                self.eventSink(@(-1000));
            } onPositive:^{
                // 密码支付
                self.eventSink(@(-4000));
            }];
            break;
        }
        case LAErrorAuthenticationFailed:
            self.eventSink(@(-1002));
            break;
        case LAErrorSystemCancel:
            self.lastCallArgs = arguments;
            self.lastResult = result;
            break;
        case LAErrorUserCancel:
            self.eventSink(@(-1000));
            break;
        default:
            break;
    }
}

- (FlutterError * _Nullable)onCancelWithArguments:(id _Nullable)arguments {
    self.eventSink = nil;
    return  nil;
}

- (FlutterError * _Nullable)onListenWithArguments:(id _Nullable)arguments eventSink:(nonnull FlutterEventSink)events {
    self.eventSink = events;
    return nil;
}

@end


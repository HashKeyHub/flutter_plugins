// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
#import <LocalAuthentication/LocalAuthentication.h>

#import "FLTLocalAuthPlugin.h"
#import "Biology.h"

@interface FLTLocalAuthPlugin ()
@property(copy, nullable) NSDictionary<NSString *, NSNumber *> *lastCallArgs;
@property(nullable) FlutterResult lastResult;
@end

@implementation FLTLocalAuthPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
    FlutterMethodChannel *channel =
    [FlutterMethodChannel methodChannelWithName:@"plugins.flutter.io/local_auth"
                                binaryMessenger:[registrar messenger]];
    FLTLocalAuthPlugin *instance = [[FLTLocalAuthPlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
    [registrar addApplicationDelegate:instance];
    
    
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
    if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
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
    
    [Biology biologyUnLockTips:tips negativeBtn:arguments[@"negativeBtn"] positiveBtn:arguments[@"positiveBtn"] unLockSuccess:^{
        result(@(1));
        
    } unLockFail:^(NSInteger code)  {
        
        switch (code) {
            case LAErrorPasscodeNotSet:
            case LAErrorTouchIDNotAvailable:
            case LAErrorTouchIDNotEnrolled:
            case LAErrorTouchIDLockout:
                break;
            case LAErrorSystemCancel:
                self.lastCallArgs = arguments;
                self.lastResult = result;
                break;
            default:
                break;
        }
    } unLockError:^(NSInteger code)  {
        
        switch (code) {
            case -2:
            {
                /// 取消
                result(@(-1000));
                break;
            }
            case -5 :
            {
                [Biology setBiologyshouldOpenTitle2:title2 negativeBtn:arguments[@"negativeBtn"] onNegative:^{
                    result(@(-1000));
                }];
                
                break;
            }
            case -6 :
            {
                [Biology setBiologyOkTitle1:title1 negativeBtn:arguments[@"negativeBtn"] positiveBtn:arguments[@"goSetting"] onNegative:^{
                    // 取消
                    result(@(-1000));
                } onPositive:^{
                    // 去设置开启权限
                    result(@(-5000));
                }];
                
                break;
            }
            case -7 :
            {
                
                [Biology setBiologyshouldOpenTitle2:title2 negativeBtn:arguments[@"negativeBtn"] onNegative:^{
                    result(@(-1000));
                }];
                
                break;
            }
            case -8 :
            {
                [Biology biologyOutTitle3:title3 negativeBtn: arguments[@"negativeBtn"] positiveBtn:arguments[@"payPassword"] onNegative:^{
                    /// 取消
                    result(@(-1000));
                    
                } onPositive:^{
                    // 密码支付
                    result(@(-4000));
                }];
                break;
            }
            default :
                break;
        }
    }];
}

//  -1000 -> 取消 -2000 ->设备不支持 -3000 -> 未设置指纹 -4000 -> 密码支付 -5000 -> 去设置开启

#pragma mark - AppDelegate
- (void)applicationDidBecomeActive:(UIApplication *)application {
    if (self.lastCallArgs != nil && self.lastResult != nil) {
        [self authenticateWithBiometrics:_lastCallArgs withFlutterResult:self.lastResult];
    }
}

@end


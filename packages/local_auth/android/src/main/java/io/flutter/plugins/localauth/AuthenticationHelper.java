// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
package io.flutter.plugins.localauth;

import android.app.Activity;
import android.app.Application;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import androidx.annotation.NonNull;
import androidx.biometric.BiometricPrompt;
import androidx.fragment.app.FragmentActivity;
import androidx.lifecycle.DefaultLifecycleObserver;
import androidx.lifecycle.Lifecycle;
import androidx.lifecycle.LifecycleOwner;
import org.jetbrains.annotations.NotNull;
import io.flutter.plugin.common.MethodCall;
import java.util.concurrent.Executor;

/**
 * Authenticates the user with fingerprint and sends corresponding response back to Flutter.
 *
 * <p>One instance per call is generated to ensure readable separation of executable paths across
 * method calls.
 */
@SuppressWarnings("deprecation")
class AuthenticationHelper extends BiometricPrompt.AuthenticationCallback
        implements Application.ActivityLifecycleCallbacks, DefaultLifecycleObserver {

    /**
     * The callback that handles the result of this authentication process.
     */
    interface AuthCompletionHandler {

        /**
         * Called when authentication was successful.
         */
        void onSuccess();

        /**
         * Called when authentication failed due to user. For instance, when user cancels the auth or
         * quits the app.
         */
        void onFailure();

        /**
         * Called when authentication fails due to non-user related problems such as system errors,
         * phone not having a FP reader etc.
         *
         * @param code  The error code to be returned to Flutter app.
         * @param error The description of the error.
         */
        void onError(String code, String error);
    }

    // This is null when not using v2 embedding;
    private final Lifecycle lifecycle;
    private final FragmentActivity activity;
    private final AuthCompletionHandler completionHandler;
    private final MethodCall call;
    private boolean activityPaused = false;

    AuthenticationHelper(
            Lifecycle lifecycle,
            FragmentActivity activity,
            MethodCall call,
            AuthCompletionHandler completionHandler) {
        this.lifecycle = lifecycle;
        this.activity = activity;
        this.call = call;
        this.completionHandler = completionHandler;
    }

    /**
     * Start the fingerprint listener.
     */
    void authenticate() {

        FingerPrintManager finger = new FingerPrintManager(call, activity, new FingerPrintCallback() {
            @Override
            public void onPositive() {

                completionHandler.onError("-4000", "密码支付");
            }

            @Override
            public void onSucceeded() {
                completionHandler.onSuccess();
            }

            //只有多次错误,走此方法
            @Override
            public void onError(@NotNull String errorMsg) {
                completionHandler.onError("-1002", "多次失败");
            }

            @Override
            public void onAuthHelp(@NotNull String helpStr) {
            }

            @Override
            public void onFailed() {
                completionHandler.onError("-1001", "失败");
            }

            @Override
            public void onCancel() {
                completionHandler.onError("-1000", "取消");
            }

            @Override
            public void onNoneFingerprints() {
                completionHandler.onError("-3000", "未设置指纹");
            }

            @Override
            public void onHardwareUnavailable() {
                completionHandler.onError("-2000", "设备不支持");
            }
        });
        finger.setSupportAndroidP(false);
        finger.authenticate();


    }

    /**
     * If the activity is paused, we keep track because fingerprint dialog simply returns "User
     * cancelled" when the activity is paused.
     */
    @Override
    public void onActivityPaused(Activity ignored) {

    }

    @Override
    public void onActivityResumed(Activity ignored) {
    }

    @Override
    public void onPause(@NonNull LifecycleOwner owner) {
        onActivityPaused(null);
    }

    @Override
    public void onResume(@NonNull LifecycleOwner owner) {
        onActivityResumed(null);
    }

    // Unused methods for activity lifecycle.
    @Override
    public void onActivityCreated(Activity activity, Bundle bundle) {
    }

    @Override
    public void onActivityStarted(Activity activity) {
    }

    @Override
    public void onActivityStopped(Activity activity) {
    }

    @Override
    public void onActivitySaveInstanceState(Activity activity, Bundle bundle) {
    }

    @Override
    public void onActivityDestroyed(Activity activity) {
    }

    @Override
    public void onDestroy(@NonNull LifecycleOwner owner) {
    }

    @Override
    public void onStop(@NonNull LifecycleOwner owner) {
    }

    @Override
    public void onStart(@NonNull LifecycleOwner owner) {
    }

    @Override
    public void onCreate(@NonNull LifecycleOwner owner) {
    }

    private static class UiThreadExecutor implements Executor {
        final Handler handler = new Handler(Looper.getMainLooper());

        @Override
        public void execute(Runnable command) {
            handler.post(command);
        }
    }
}

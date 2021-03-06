// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.localauth;

import android.app.Activity;
import android.content.pm.PackageManager;
import android.os.Build;

import androidx.fragment.app.FragmentActivity;
import androidx.lifecycle.Lifecycle;

import io.flutter.Log;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.embedding.engine.plugins.lifecycle.FlutterLifecycleAdapter;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import io.flutter.plugins.localauth.AuthenticationHelper.AuthCompletionHandler;

import java.util.ArrayList;
import java.util.concurrent.atomic.AtomicBoolean;

/**
 * Flutter plugin providing access to local authentication.
 *
 * <p>Instantiate this in an add to app scenario to gracefully handle activity and context changes.
 */
@SuppressWarnings("deprecation")
public class LocalAuthPlugin implements MethodCallHandler, FlutterPlugin, ActivityAware {
    private static final String CHANNEL_NAME = "plugins.flutter.io/local_auth";
    private static final String EVENT_NAME = "plugins.flutter.io.event/local_auth";


    private Activity activity;
    private final AtomicBoolean authInProgress = new AtomicBoolean(false);
    private AuthenticationHelper authenticationHelper;

    // These are null when not using v2 embedding.
    private MethodChannel channel;

    private BiometricsEvent biometricsEvent = new BiometricsEvent();

    private EventChannel eventChannel;


    private Lifecycle lifecycle;

    public static void registerWith(Registrar registrar) {

        final MethodChannel channel = new MethodChannel(registrar.messenger(), CHANNEL_NAME);
        channel.setMethodCallHandler(new LocalAuthPlugin(registrar.activity()));
    }

    private LocalAuthPlugin(Activity activity) {
        this.activity = activity;
    }

    /**
     * Default constructor for LocalAuthPlugin.
     *
     * <p>Use this constructor when adding this plugin to an app with v2 embedding.
     */

    public LocalAuthPlugin() {
    }

    @Override
    public void onMethodCall(final MethodCall call, final Result result) {

        if (call.method.equals("canAuthenticate")) {
            authenticationHelper =
                    new AuthenticationHelper(
                            lifecycle,
                            (FragmentActivity) activity,
                            call,
                            new AuthCompletionHandler() {
                                @Override
                                public void onSuccess() {
                                    if (authInProgress.compareAndSet(true, false)) {
                                        biometricsEvent.getEventChannel().success(1);
                                    }
                                }

                                @Override
                                public void onFailure() {
                                }

                                @Override
                                public void onError(String code, String error) {

                                }
                            });
            result.success(authenticationHelper.canAuthentication() ? 1 : 0);
        } else if (call.method.equals("authenticateWithBiometrics")) {
            if (authInProgress.get()) {
                // Apps should not invoke another authentication request while one is in progress,
                // so we classify this as an error condition. If we ever find a legitimate use case for
                // this, we can try to cancel the ongoing auth and start a new one but for now, not worth
                // the complexity.
                result.error("auth_in_progress", "Authentication in progress", null);
                return;
            }

            if (activity == null || activity.isFinishing()) {
                result.error("no_activity", "local_auth plugin requires a foreground activity", null);
                return;
            }

            if (!(activity instanceof FragmentActivity)) {
                result.error(
                        "no_fragment_activity",
                        "local_auth plugin requires activity to be a FragmentActivity.",
                        null);
                return;
            }
            authInProgress.set(true);
            result.success(1000000);
            authenticationHelper =
                    new AuthenticationHelper(
                            lifecycle,
                            (FragmentActivity) activity,
                            call,
                            new AuthCompletionHandler() {
                                @Override
                                public void onSuccess() {
                                    if (authInProgress.compareAndSet(true, false)) {
                                        biometricsEvent.getEventChannel().success(1);
                                    }
                                }

                                @Override
                                public void onFailure() {
                                }

                                @Override
                                public void onError(String code, String error) {
                                    if (authInProgress.compareAndSet(true, false)) {

                                        biometricsEvent.getEventChannel().success(Integer.parseInt(code));

                                        if (Integer.parseInt(code) == -3000) {
                                            /// ???????????????

                                            NoSettingBiometricsID dialog = new NoSettingBiometricsID();
                                            dialog.setCall(call);

                                            dialog.show(((FragmentActivity) activity).getSupportFragmentManager(), "getSupportFragmentManager");

                                        }
                                        if (Integer.parseInt(code) == -1001 || Integer.parseInt(code) == -1002) {
                                            /// ??????
                                            authInProgress.compareAndSet(false, true);
                                        }
                                    }
                                }
                            });
            authenticationHelper.authenticate();
        } else if (call.method.equals("getAvailableBiometrics")) {
            try {
                if (activity == null || activity.isFinishing()) {
                    result.error("no_activity", "local_auth plugin requires a foreground activity", null);
                    return;
                }
                ArrayList<String> biometrics = new ArrayList<String>();
                PackageManager packageManager = activity.getPackageManager();
                if (Build.VERSION.SDK_INT >= 23) {
                    if (packageManager.hasSystemFeature(PackageManager.FEATURE_FINGERPRINT)) {
                        biometrics.add("fingerprint");
                    }
                }
                result.success(biometrics);
            } catch (Exception e) {
                result.error("no_biometrics_available", e.getMessage(), null);
            }
        } else if (call.method.equals(("stopAuthentication"))) {

            stopAuthentication(result);

        } else {

            result.notImplemented();
        }
    }


    private void stopAuthentication(Result result) {
        try {
            if (authenticationHelper != null && authInProgress.get()) {
                authenticationHelper.stopAuthentication();
                authenticationHelper = null;
                result.success(true);
                return;
            }
            result.success(false);
        } catch (Exception e) {
            result.success(false);
        }
    }


    @Override
    public void onAttachedToEngine(FlutterPluginBinding binding) {
        channel = new MethodChannel(binding.getBinaryMessenger(), CHANNEL_NAME);

        eventChannel = new EventChannel(binding.getBinaryMessenger(), EVENT_NAME);

        eventChannel.setStreamHandler(biometricsEvent);
    }

    @Override
    public void onDetachedFromEngine(FlutterPluginBinding binding) {
    }

    @Override
    public void onAttachedToActivity(ActivityPluginBinding binding) {
        activity = binding.getActivity();
        lifecycle = FlutterLifecycleAdapter.getActivityLifecycle(binding);
        channel.setMethodCallHandler(this);
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {
        lifecycle = null;
        activity = null;
    }

    @Override
    public void onReattachedToActivityForConfigChanges(ActivityPluginBinding binding) {
        activity = binding.getActivity();
        lifecycle = FlutterLifecycleAdapter.getActivityLifecycle(binding);
    }

    @Override
    public void onDetachedFromActivity() {
        activity = null;
        lifecycle = null;
        channel.setMethodCallHandler(null);
    }
}

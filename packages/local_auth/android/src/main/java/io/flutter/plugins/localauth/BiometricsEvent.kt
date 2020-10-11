package io.flutter.plugins.localauth

import android.util.Log
import io.flutter.plugin.common.EventChannel

class BiometricsEvent : EventChannel.StreamHandler {
    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventChannel = events
    }

    override fun onCancel(arguments: Any?) {
        eventChannel = null
    }

    var eventChannel: EventChannel.EventSink? = null

}
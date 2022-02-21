package com.example.flutter_install_plugin

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings
import android.util.Log
import androidx.annotation.NonNull
import androidx.core.content.FileProvider
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.PluginRegistry.Registrar
import io.flutter.plugin.common.BinaryMessenger
import java.io.File
import java.io.FileNotFoundException

/** FlutterInstallPlugin */
class FlutterInstallPlugin: FlutterPlugin, MethodCallHandler , ActivityAware {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private var apkFile: String? = null
  private var appId: String? = null
  private val installRequestCode = 1234
  private var activity:Activity? = null

  companion object {
    @JvmStatic
    fun registerWith(registrar: Registrar) {
      val plugin = FlutterInstallPlugin()

      plugin.onAttachedToEngine(registrar.messenger())

      val activity = registrar.activity()
      if (activity != null) {
        plugin.onActivityChanged(activity)
      }
    }
  }

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    onAttachedToEngine(flutterPluginBinding.binaryMessenger)
  }
  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding){
    onActivityChanged(binding.activity)
     binding.addActivityResultListener { requestCode, resultCode, intent ->
       Log.d("android plugin", "addActivityResultListener $resultCode")
       if (resultCode == Activity.RESULT_OK && requestCode == installRequestCode) {
         val file = File(apkFile)
         install24(activity, file, appId)
         true
       } else
         false
     }
  }

  fun onAttachedToEngine(messenger: BinaryMessenger) {
    channel = MethodChannel(messenger, "flutter_install_plugin")
    channel.setMethodCallHandler(this)
  }

  override fun onDetachedFromActivityForConfigChanges() = onActivityChanged(null)

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) =
          onActivityChanged(binding.activity)

  override fun onDetachedFromActivity() = onActivityChanged(null)

  fun onActivityChanged(activity: Activity?) {
    this.activity = activity
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: MethodChannel.Result) {
    when (call.method) {
      "getPlatformVersion" -> {
        result.success("Android ${android.os.Build.VERSION.RELEASE}")
      }
      "installApk" -> {
         apkFile = call.argument<String>("filePath")
         appId = call.argument<String>("appId")
        Log.d("android plugin", "installApk $apkFile $appId")
        try {
          installApk(apkFile, appId)
          result.success("Success")
        } catch (e: Throwable) {
          result.error(e.javaClass.simpleName, e.message, null)
        }
      }
      else -> result.notImplemented()
    }
  }

  private fun installApk(filePath: String?, appId: String?) {
    if (filePath == null) throw NullPointerException("fillPath is null!")
    if (activity == null) throw NullPointerException("activity is null!")

    val file = File(filePath)
    if (!file.exists()) throw FileNotFoundException("$filePath is not exist! or check permission")
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
      install24(activity, file, appId)
    } else {
      activity?.let { installBelow24(it, file) }
    }
  }


  private fun showSettingPackageInstall(activity: Activity) { // todo to test with android 26
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
      Log.d("SettingPackageInstall", ">= Build.VERSION_CODES.O")
      val intent = Intent(Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES)
      intent.data = Uri.parse("package:" + activity.packageName)
      activity.startActivityForResult(intent, installRequestCode)
    } else {
      throw RuntimeException("VERSION.SDK_INT < O")
    }

  }

  private fun canRequestPackageInstalls(activity: Activity): Boolean {
    return Build.VERSION.SDK_INT <= Build.VERSION_CODES.O || activity.packageManager.canRequestPackageInstalls()
  }

  private fun installBelow24(context: Context, file: File?) {
    val intent = Intent(Intent.ACTION_VIEW)
    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
    val uri = Uri.fromFile(file)
    intent.setDataAndType(uri, "application/vnd.android.package-archive")
    context.startActivity(intent)
  }

  /**
   * android24及以上安装需要通过 ContentProvider 获取文件Uri，
   * 需在应用中的AndroidManifest.xml 文件添加 provider 标签，
   * 并新增文件路径配置文件 res/xml/provider_path.xml
   * 在android 6.0 以上如果没有动态申请文件读写权限，会导致文件读取失败，你将会收到一个异常。
   * 插件中不封装申请权限逻辑，是为了使模块功能单一，调用者可以引入独立的权限申请插件
   */
  private fun install24(context: Context?, file: File?, appId: String?) {
    if (context == null) throw NullPointerException("context is null!")
    if (file == null) throw NullPointerException("file is null!")
    if (appId == null) throw NullPointerException("appId is null!")

    try {
      val intent = Intent(Intent.ACTION_VIEW)
      intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
      intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
      val uri: Uri = FileProvider.getUriForFile(context, "$appId.fileProvider.install", file)
      intent.setDataAndType(uri, "application/vnd.android.package-archive")
      context.startActivity(intent)
    } catch (e: Throwable) {
      Log.d("android plugin", "install24 error")
    }

  }




}

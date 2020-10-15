package io.flutter.plugins.localauth

import android.annotation.TargetApi
import android.os.Build
import android.util.Log
import androidx.fragment.app.FragmentActivity
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodCodec

/**
 * 项目名称: Example
 * 包名: com.github.example
 * 类名: FingerPrintManager
 * 描述:
 * @author: 清风徐来
 * 创建日期: 2019-09-20 16:32
 * 修改人: 清风徐来
 * 更新日期: 2019-09-20 16:32
 * 更新日志:
 * 版本: 1.0
 */
@TargetApi(Build.VERSION_CODES.M)
class FingerPrintManager constructor(
        private val call: MethodCall,
        private val holder: FragmentActivity,
        private val callback: FingerPrintCallback
) {
    /**
     * 使用Android 9的指纹识别
     */
    var supportAndroidP = true


    private val fingerPrint by lazy {
            FingerPrintForM(call,holder, callback)
    }

    /**
     * 指纹验证
     */
    fun authenticate() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            fingerPrint.authenticate()
        } else {
            callback.onHardwareUnavailable()
        }
    }
    
    fun stopAuthenticate(){
        fingerPrint.stopAuthenticates()
    }
}
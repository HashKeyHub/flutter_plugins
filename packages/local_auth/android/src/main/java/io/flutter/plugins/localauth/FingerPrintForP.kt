package io.flutter.plugins.localauth

import android.content.DialogInterface
import android.hardware.biometrics.BiometricPrompt
import android.os.Build
import android.os.CancellationSignal
import androidx.annotation.RequiresApi
import androidx.core.hardware.fingerprint.FingerprintManagerCompat
import androidx.fragment.app.FragmentActivity

/**
 * 项目名称: Example
 * 包名: com.github.example
 * 类名: FingerPrintForP
 * 描述: Android 9
 * @author: 清风徐来
 * 创建日期: 2019-09-20 11:27
 * 修改人: 清风徐来
 * 更新日期: 2019-09-20 11:27
 * 更新日志:
 * 版本: 1.0
 */
@RequiresApi(Build.VERSION_CODES.P)
class FingerPrintForP(
    private val holder: FragmentActivity,
    private val fingerPrintCallback: FingerPrintCallback
) : IFingerPrint {

    companion object {
        @Volatile
        private var instance: FingerPrintForP? = null

        fun getInstance(holder: FragmentActivity, fingerPrintCallback: FingerPrintCallback) =
            instance ?: synchronized(this) {
                instance ?: FingerPrintForP(holder, fingerPrintCallback).also {
                    instance = it
                }
            }
    }

    /**
     * 取消标识
     */
    private val cancellationSignal by lazy {
        CancellationSignal().apply {
            setOnCancelListener {
                fingerPrintCallback.onCancel()
            }
        }
    }
    /**
     * crypt
     */
    private val cryptObject by lazy {
        BiometricPrompt.CryptoObject(CipherCreator().createCipher())
    }

    override fun authenticate() {
        if (canAuthenticate()) {
            val biometricPrompt = BiometricPrompt.Builder(holder)
                .setTitle("指纹验证")
                .setNegativeButton("取消", holder.mainExecutor,
                    DialogInterface.OnClickListener { _, _ ->
                        fingerPrintCallback.onCancel()
                    }).build()
            biometricPrompt.authenticate(
                cryptObject,
                cancellationSignal,
                holder.mainExecutor,
                object : BiometricPrompt.AuthenticationCallback() {
                    override fun onAuthenticationError(errMsgId: Int, errString: CharSequence) {
                        fingerPrintCallback.onError(errString.toString())
                    }

                    override fun onAuthenticationFailed() {
                        fingerPrintCallback.onFailed()
                    }

                    override fun onAuthenticationHelp(helpMsgId: Int, helpString: CharSequence) {
                        fingerPrintCallback.onAuthHelp(helpString.toString())
                    }

                    override fun onAuthenticationSucceeded(result: BiometricPrompt.AuthenticationResult?) {
                        fingerPrintCallback.onSucceeded()
                    }
                })
        } else {
            fingerPrintCallback.onHardwareUnavailable()
        }
    }

    override fun canAuthenticate(): Boolean {
        if (!FingerprintManagerCompat.from(holder).isHardwareDetected) {
            fingerPrintCallback.onHardwareUnavailable()
            return false
        }
        //是否已添加指纹
        if (!FingerprintManagerCompat.from(holder).hasEnrolledFingerprints()) {
            fingerPrintCallback.onNoneFingerprints()
            return false
        }
        return true
    }
}
package io.flutter.plugins.localauth

import android.app.Dialog
import android.os.Build
import android.util.Log
import android.view.View
import androidx.annotation.RequiresApi
import androidx.core.hardware.fingerprint.FingerprintManagerCompat
import androidx.core.os.CancellationSignal
import androidx.fragment.app.FragmentActivity
import io.flutter.plugin.common.MethodCall
import kotlinx.android.synthetic.main.dialog_finger_print.*
import org.json.JSONObject

/**
 * 项目名称: Example
 * 包名: com.github.example
 * 类名: FingerPrintForM
 * 描述: Android 6
 * @author: 清风徐来
 * 创建日期: 2019-09-20 11:26
 * 修改人: 清风徐来
 * 更新日期: 2019-09-20 11:26
 * 更新日志:
 * 版本: 1.0
 */
@RequiresApi(Build.VERSION_CODES.M)
class FingerPrintForM constructor(
        private val call: MethodCall,
        private val holder: FragmentActivity,
        private val fingerPrintCallback: FingerPrintCallback
) : IFingerPrint {

    companion object {

        val TAG: String = FingerPrintForM::class.java.name

        @Volatile
        private var instance: FingerPrintForM? = null
    }

    /**
     * core
     */
    private val fingerprint by lazy {
        FingerprintManagerCompat.from(holder)
    }

    /**
     * 取消标识
     */
    private val cancellationSignal by lazy {
        CancellationSignal().apply {
            setOnCancelListener {

            }
        }
    }

    override fun authenticate() {

        val fingerprintDialog = FingerPrintDialog.newInstance(call).apply {

            onCancelListener = object : FingerPrintDialog.OnCancelListener {
                override fun onCancel(dialog: Dialog) {
                    fingerPrintCallback.onCancel()
                    cancellationSignal.cancel()
                }
            }

            onPositiveBtnListener = object : FingerPrintDialog.OnPositiveBtnListener {
                override fun onPositive(dialog: Dialog) {
                    fingerPrintCallback.onPositive()
                    cancellationSignal.cancel()
                }
            }
        }
        if (canAuthenticate()) {
            fingerprint.authenticate(null, 0, cancellationSignal, object :
                    FingerprintManagerCompat.AuthenticationCallback() {

                override fun onAuthenticationError(errMsgId: Int, errString: CharSequence) {

                    if (errMsgId == 7 || errMsgId == 9) {
                        fingerprintDialog?.positiveBtn?.visibility = View.VISIBLE;
                        fingerprintDialog?.tips?.visibility = View.VISIBLE
                        fingerprintDialog?.tips?.text = call.argument<String>("failures")
                        fingerPrintCallback?.onError(errString.toString())
                    }


                }

                override fun onAuthenticationFailed() {
                    fingerprintDialog.tips?.apply {
                        visibility = View.VISIBLE
                        text = call.argument<String>("notRecognized")
                    }
                    fingerPrintCallback.onFailed()
                }

                override fun onAuthenticationHelp(helpMsgId: Int, helpString: CharSequence) {
//                    fingerprintDialog.tips?.apply {
//                        visibility = View.VISIBLE
//                        text = helpString
//                    }
                    fingerPrintCallback.onAuthHelp(helpString.toString())
                }

                override fun onAuthenticationSucceeded(result: FingerprintManagerCompat.AuthenticationResult?) {
                    fingerprintDialog.tips?.apply {
                        text = call.argument<String>("success")
                        visibility = View.INVISIBLE
                    }
                    fingerPrintCallback.onSucceeded()
                    fingerprintDialog.dismiss()
                }
            }, null)
            fingerprintDialog.show(holder.supportFragmentManager, TAG)
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
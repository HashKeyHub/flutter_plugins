
package io.flutter.plugins.localauth
import android.app.Dialog
import android.graphics.Color
import android.graphics.drawable.ColorDrawable
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Button
import android.widget.TextView
import androidx.fragment.app.DialogFragment
import io.flutter.plugin.common.MethodCall
import kotlinx.android.synthetic.main.dialog_finger_print.view.*

/**
 * 项目名称: Example
 * 包名: com.github.example
 * 类名: FingerPrintDialog
 * 描述:
 * @author: 清风徐来
 * 创建日期: 2019-09-20 13:31
 * 修改人: 清风徐来
 * 更新日期: 2019-09-20 13:31
 * 更新日志:
 * 版本: 1.0
 */
class NoSettingBiometricsID : DialogFragment() {

    var call: MethodCall? = null
    
    var onCancelListener: OnCancelListener? = null

    var onPositiveBtnListener: OnPositiveBtnListener? = null

    override fun onCreateView(
            inflater: LayoutInflater,
            container: ViewGroup?,
            savedInstanceState: Bundle?
    ): View? {
        isCancelable = false
        dialog?.window?.setBackgroundDrawable(ColorDrawable(Color.TRANSPARENT));

        var one = inflater.inflate(R.layout.no_setting_biometrics_id, container).apply {

            negativeBtn.setOnClickListener {
                dismiss();
                dialog?.let { it1 -> onCancelListener?.onCancel(it1) }
            }
        }

        one.tips?.text = call?.argument("touchSetting") ?: " "
        one.negativeBtn?.text = call?.argument("negativeBtn") ?: " "
        return one

    }

    interface OnCancelListener {
        /**
         * onCancel
         */
        fun onCancel(dialog: Dialog)
    }

    interface OnPositiveBtnListener {

        fun onPositive(dialog: Dialog)
    }
}
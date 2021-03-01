package io.flutter.plugins.localauth

import android.app.Dialog
import android.graphics.Color
import android.graphics.drawable.ColorDrawable
import android.os.Bundle
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Button
import android.widget.ImageView
import android.widget.TextView
import androidx.fragment.app.DialogFragment
import io.flutter.plugin.common.MethodCall
import kotlinx.android.synthetic.main.dialog_finger_print.view.*
import androidx.vectordrawable.graphics.drawable.VectorDrawableCompat


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
class FingerPrintDialog : DialogFragment() {

    var call: MethodCall? = null

    companion object {
        fun newInstance(call: MethodCall): FingerPrintDialog {
            var one = FingerPrintDialog()
            one.call = call
            return one
        }
    }

    var onCancelListener: OnCancelListener? = null

    var onPositiveBtnListener: OnPositiveBtnListener? = null

    override fun onCreateView(
            inflater: LayoutInflater,
            container: ViewGroup?,
            savedInstanceState: Bundle?
    ): View? {
        isCancelable = false
        dialog?.window?.setBackgroundDrawable(ColorDrawable(Color.TRANSPARENT))

        var one = inflater.inflate(R.layout.dialog_finger_print, container).apply {


            negativeBtn.setOnClickListener {
                dismiss()
                dialog?.let { it1 -> onCancelListener?.onCancel(it1) }
            }

            positiveBtn.setOnClickListener {
                dismiss()
                dialog?.let { it1 -> onPositiveBtnListener?.onPositive(it1) }
            }
        }

        try {
            var dark = call?.argument("dark") ?: 0
            if (dark == 1) {
                one.setBackgroundResource(R.drawable.finger_dialog_background_dark)
                one.findViewById<ImageView>(R.id.imageView).setImageResource(R.drawable.icon_finger_dark)
                one.findViewById<TextView>(R.id.negativeBtn).setTextColor(Color.argb(127, 255, 255, 255))
                one.findViewById<TextView>(R.id.positiveBtn).setTextColor(Color.argb(127, 255, 255, 255))
                one.findViewById<View>(R.id.v_finger_print_divider).setBackgroundColor(Color.argb(13, 255, 255, 255))
                one.findViewById<View>(R.id.h_finger_print_divider).setBackgroundColor(Color.argb(13, 255, 255, 255))
            }
        } catch (e: Exception) {
        }

        one.tips?.text = call?.argument("tips") ?: " "
        one.negativeBtn?.text = call?.argument("negativeBtn") ?: " "
        one.positiveBtn?.text = call?.argument("positiveBtn") ?: " "
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
package io.flutter.plugins.localauth

/**
 * 项目名称: Example
 * 包名: com.github.example
 * 类名: FingerPrintCallback
 * 描述: 指纹回调
 * @author: 清风徐来
 * 创建日期: 2019-09-20 11:34
 * 修改人: 清风徐来
 * 更新日期: 2019-09-20 11:34
 * 更新日志:
 * 版本: 1.0
 */
interface FingerPrintCallback {
    /**
     * 指纹验证成功
     */
    fun onSucceeded()

    /**
     * 错误
     * @param errorMsg 错误信息
     */
    fun onError(errorMsg: String)

    /**
     * 认证帮助
     * @param helpStr
     */
    fun onAuthHelp(helpStr: String)

    /**
     * 失败
     */
    fun onFailed()

    /**
     * 主动取消
     */
    fun onCancel()

    /**
     * 没有设置指纹
     */
    fun onNoneFingerprints()

    /**
     * 硬件不支持
     */
    fun onHardwareUnavailable()

    /** 
     * 右边按钮EVENT
     */
    fun  onPositive(){
        
    }
}
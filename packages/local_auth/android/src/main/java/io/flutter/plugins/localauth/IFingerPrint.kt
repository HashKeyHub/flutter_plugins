package io.flutter.plugins.localauth

/**
 * 项目名称: Example
 * 包名: com.github.example
 * 类名: IFingerPrint
 * 描述:
 * @author: 清风徐来
 * 创建日期: 2019-09-20 11:27
 * 修改人: 清风徐来
 * 更新日期: 2019-09-20 11:27
 * 更新日志:
 * 版本: 1.0
 */
interface IFingerPrint {
    /**
     * 认证
     */
    fun authenticate()

    /**
     * 是否支持指纹认证
     */
    fun canAuthenticate(): Boolean

    
    fun stopAuthenticates()

}
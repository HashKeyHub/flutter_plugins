package io.flutter.plugins.localauth

import android.os.Build
import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyProperties
import androidx.annotation.RequiresApi
import java.security.Key
import java.security.KeyStore
import javax.crypto.Cipher
import javax.crypto.KeyGenerator

/**
 * 项目名称: Example
 * 包名: com.github.example
 * 类名: CipherCreator
 * 描述:
 * @author: 清风徐来
 * 创建日期: 2019-09-20 14:57
 * 修改人: 清风徐来
 * 更新日期: 2019-09-20 14:57
 * 更新日志:
 * 版本: 1.0
 */
@RequiresApi(Build.VERSION_CODES.M)
class CipherCreator {

    companion object {
        const val KEY_NAME = "com.example.github.CipherCreator"
        const val KEYSTORE_NAME = "AndroidKeyStore"
        const val KEY_ALGORITHM = KeyProperties.KEY_ALGORITHM_AES
        const val BLOCK_MODE = KeyProperties.BLOCK_MODE_CBC
        const val ENCRYPTION_PADDING = KeyProperties.ENCRYPTION_PADDING_PKCS7
        const val TRANSFORMATION = "$KEY_ALGORITHM/$BLOCK_MODE/$ENCRYPTION_PADDING"
    }

    private val keystore by lazy {
        KeyStore.getInstance(KEYSTORE_NAME).apply {
            load(null)
        }
    }

    fun createCipher(): Cipher {
        val key = getKey()
        return try {
            Cipher.getInstance(TRANSFORMATION).apply {
                init(Cipher.ENCRYPT_MODE or Cipher.DECRYPT_MODE, key)
            }
        } catch (e: Exception) {
            throw Exception("Could not create the cipher for fingerprint authentication.", e)
        }
    }

    private fun getKey(): Key {
        if (!keystore.isKeyEntry(KEY_NAME)) {
            createKey()
        }
        return keystore.getKey(KEY_NAME, null)
    }

    private fun createKey() {
        val keyGen = KeyGenerator.getInstance(KEY_ALGORITHM, KEYSTORE_NAME)
        val keyGenSpec = KeyGenParameterSpec.Builder(
            KEY_NAME,
            KeyProperties.PURPOSE_ENCRYPT or KeyProperties.PURPOSE_DECRYPT
        )
            .setBlockModes(BLOCK_MODE)
            .setEncryptionPaddings(ENCRYPTION_PADDING)
            .setUserAuthenticationRequired(true)
            .build()
        keyGen.init(keyGenSpec)
        keyGen.generateKey()
    }
}
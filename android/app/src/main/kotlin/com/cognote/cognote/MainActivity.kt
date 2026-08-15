package com.cognote.cognote

import android.app.Activity
import android.content.Intent
import android.database.Cursor
import android.net.Uri
import android.provider.OpenableColumns
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream

class MainActivity : FlutterActivity() {
    private var pendingImageResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            IMAGE_PICKER_CHANNEL,
        ).setMethodCallHandler { call, result ->
            if (call.method != "pickImage") {
                result.notImplemented()
                return@setMethodCallHandler
            }
            if (pendingImageResult != null) {
                result.error("busy", "An image picker request is already active", null)
                return@setMethodCallHandler
            }
            pendingImageResult = result
            val intent = Intent(Intent.ACTION_OPEN_DOCUMENT).apply {
                addCategory(Intent.CATEGORY_OPENABLE)
                type = "image/*"
                putExtra(
                    Intent.EXTRA_MIME_TYPES,
                    arrayOf("image/jpeg", "image/png", "image/webp"),
                )
            }
            try {
                startActivityForResult(intent, IMAGE_PICKER_REQUEST)
            } catch (error: RuntimeException) {
                pendingImageResult = null
                result.error("unavailable", "The system image picker is unavailable", null)
            }
        }
    }

    @Deprecated("Deprecated in Android")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode != IMAGE_PICKER_REQUEST) return
        val result = pendingImageResult ?: return
        pendingImageResult = null
        val uri = data?.data
        if (resultCode != Activity.RESULT_OK || uri == null) {
            result.success(null)
            return
        }
        Thread {
            copyPickedImage(uri, result)
        }.start()
    }

    private fun copyPickedImage(uri: Uri, result: MethodChannel.Result) {
        var destination: File? = null
        try {
            val providerMimeType = providerIo {
                contentResolver.getType(uri)
            }
            val mimeTypeHint = normalizedMimeTypeHint(providerMimeType)
            val extension = when (mimeTypeHint) {
                "image/jpeg" -> ".jpg"
                "image/png" -> ".png"
                "image/webp" -> ".webp"
                else -> ".img"
            }
            val outputFile = try {
                val directory = File(cacheDir, "picked-observation-images")
                if (!directory.exists() && !directory.mkdirs()) {
                    throw PickedImageException("storage")
                }
                storageIo { File.createTempFile("picked-", extension, directory) }
            } catch (error: PickedImageException) {
                throw error
            } catch (error: Exception) {
                throw PickedImageException("storage")
            }
            destination = outputFile
            val inputStream = providerIo { contentResolver.openInputStream(uri) }
                ?: throw PickedImageException("unreadable")
            val outputStream = try {
                storageIo { FileOutputStream(outputFile) }
            } catch (error: PickedImageException) {
                try {
                    inputStream.close()
                } catch (_: Exception) {
                    // Preserve the cache-target failure as the primary error.
                }
                throw PickedImageException("storage")
            }
            val copiedBytes = try {
                PickedImageStreamCopier.copy(
                    object : PickedImageStreamCopier.Source {
                        override fun read(buffer: ByteArray): Int = inputStream.read(buffer)

                        override fun close() = inputStream.close()
                    },
                    object : PickedImageStreamCopier.Target {
                        override fun write(buffer: ByteArray, offset: Int, length: Int) =
                            outputStream.write(buffer, offset, length)

                        override fun sync() = outputStream.fd.sync()

                        override fun close() = outputStream.close()
                    },
                    MAX_IMAGE_BYTES,
                )
            } catch (error: PickedImageStreamCopier.CopyFailure) {
                throw PickedImageException(error.code)
            }
            if (copiedBytes == 0L) {
                throw PickedImageException("unreadable")
            }
            val payload = mapOf(
                "path" to outputFile.absolutePath,
                "mimeType" to mimeTypeHint,
                "displayName" to displayName(uri, extension),
            )
            runOnUiThread { result.success(payload) }
        } catch (error: PickedImageException) {
            destination?.delete()
            runOnUiThread { result.error(error.code, "Unable to import image", null) }
        } catch (error: Exception) {
            destination?.delete()
            runOnUiThread { result.error("storage", "Unable to import image", null) }
        }
    }

    private fun <T> providerIo(operation: PickedImageStreamCopier.Operation<T>): T =
        try {
            PickedImageStreamCopier.fromProvider(operation)
        } catch (error: PickedImageStreamCopier.CopyFailure) {
            throw PickedImageException(error.code)
        }

    private fun <T> storageIo(operation: PickedImageStreamCopier.Operation<T>): T =
        try {
            PickedImageStreamCopier.onCacheTarget(operation)
        } catch (error: PickedImageStreamCopier.CopyFailure) {
            throw PickedImageException(error.code)
        }

    private fun normalizedMimeTypeHint(providerMimeType: String?): String? =
        when (providerMimeType?.trim()?.lowercase()) {
            "image/jpeg", "image/jpg" -> "image/jpeg"
            "image/png" -> "image/png"
            "image/webp" -> "image/webp"
            else -> null
        }

    private fun displayName(uri: Uri, fallback: String): String {
        var cursor: Cursor? = null
        return try {
            cursor = contentResolver.query(
                uri,
                arrayOf(OpenableColumns.DISPLAY_NAME),
                null,
                null,
                null,
            )
            if (cursor != null && cursor.moveToFirst()) {
                val index = cursor.getColumnIndex(OpenableColumns.DISPLAY_NAME)
                if (index >= 0) cursor.getString(index)?.takeIf { it.isNotBlank() }
                    ?: "所选图片$fallback"
                else "所选图片$fallback"
            } else {
                "所选图片$fallback"
            }
        } catch (error: RuntimeException) {
            "所选图片$fallback"
        } finally {
            cursor?.close()
        }
    }

    private class PickedImageException(val code: String) : Exception()

    companion object {
        private const val IMAGE_PICKER_CHANNEL =
            "com.cognote.cognote/observation_image_picker"
        private const val IMAGE_PICKER_REQUEST = 111
        private const val MAX_IMAGE_BYTES = 25L * 1024L * 1024L
    }
}

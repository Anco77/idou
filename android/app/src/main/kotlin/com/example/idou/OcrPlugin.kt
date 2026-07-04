package com.example.idou

import android.graphics.Bitmap
import android.graphics.Bitmap.Config
import com.google.mlkit.vision.common.InputImage
import com.google.mlkit.vision.text.TextRecognition
import com.google.mlkit.vision.text.latin.TextRecognizerOptions
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import java.nio.IntBuffer

class OcrPlugin(private val engine: FlutterEngine) : MethodCallHandler {
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        if (call.method != "recognizeText") {
            result.notImplemented()
            return
        }

        try {
            val bytes = call.argument<ByteArray>("bytes")
                ?: return result.error("OcrError", "bytes is null", null)
            val width = call.argument<Int>("width")
                ?: return result.error("OcrError", "width is null", null)
            val height = call.argument<Int>("height")
                ?: return result.error("OcrError", "height is null", null)

            val bitmap = Bitmap.createBitmap(width, height, Config.ARGB_8888)
            val buffer = IntBuffer.allocate(bytes.size / 4)
            for (i in bytes.indices step 4) {
                val r = bytes[i].toInt() and 0xFF
                val g = bytes[i + 1].toInt() and 0xFF
                val b = bytes[i + 2].toInt() and 0xFF
                val a = bytes[i + 3].toInt() and 0xFF
                buffer.put((a shl 24) or (r shl 16) or (g shl 8) or b)
            }
            buffer.rewind()
            bitmap.copyPixelsFromBuffer(buffer)

            val inputImage = InputImage.fromBitmap(bitmap, 0)
            val recognizer = TextRecognition.getClient(TextRecognizerOptions.DEFAULT_OPTIONS)

            recognizer.process(inputImage)
                .addOnSuccessListener { text ->
                    val blocks = mutableListOf<Map<String, Any?>>()
                    for (block in text.textBlocks) {
                        val box = block.boundingBox ?: continue
                        blocks.add(mapOf(
                            "text" to block.text,
                            "left" to box.left.toDouble(),
                            "top" to box.top.toDouble(),
                            "right" to box.right.toDouble(),
                            "bottom" to box.bottom.toDouble(),
                        ))
                    }
                    recognizer.close()
                    result.success(blocks)
                }
                .addOnFailureListener { e ->
                    recognizer.close()
                    result.error("OcrError", e.toString(), null)
                }
        } catch (e: Exception) {
            result.error("OcrError", e.toString(), null)
        }
    }
}

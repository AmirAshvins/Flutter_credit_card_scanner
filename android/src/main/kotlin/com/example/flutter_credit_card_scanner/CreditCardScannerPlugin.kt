package com.example.flutter_credit_card_scanner

import android.os.Handler
import android.os.Looper
import com.google.mlkit.vision.common.InputImage
import com.google.mlkit.vision.text.TextRecognition
import com.google.mlkit.vision.text.latin.TextRecognizerOptions
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class CreditCardScannerPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {
    private lateinit var channel: MethodChannel
    private val recognizer = TextRecognition.getClient(TextRecognizerOptions.DEFAULT_OPTIONS)
    private val mainHandler = Handler(Looper.getMainLooper())

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, "flutter_credit_card_scanner/recognize_text")
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        recognizer.close()
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        if (call.method != "recognize") {
            result.notImplemented()
            return
        }
        val bytes = call.argument<ByteArray>("image")
        val width = call.argument<Int>("width")
        val height = call.argument<Int>("height")
        val rotation = call.argument<Int>("rotation") ?: 0
        if (bytes == null || width == null || height == null) {
            result.error("bad_args", "Missing image data", null)
            return
        }
        val image = InputImage.fromByteArray(
            bytes,
            width,
            height,
            rotation,
            InputImage.IMAGE_FORMAT_NV21,
        )
        recognizer.process(image)
            .addOnSuccessListener { visionText ->
                val lines = visionText.textBlocks.flatMap { block -> block.lines.map { it.text } }
                mainHandler.post { result.success(lines) }
            }
            .addOnFailureListener { error ->
                mainHandler.post { result.error("recognize", error.message, null) }
            }
    }
}

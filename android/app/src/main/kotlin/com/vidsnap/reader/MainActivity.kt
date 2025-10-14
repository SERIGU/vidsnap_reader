package com.vidsnap.reader

import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * ========================================
 * VidSnap Reader - MainActivity (V2)
 * ========================================
 *  - Embedding V2 (100 %)
 *  - Inicializa PdfTools
 *  - Expone canal seguro "com.vidsnap.reader/pdf"
 *  - Maneja errores controlados
 */
class MainActivity : FlutterActivity() {

    companion object {
        private const val TAG = "VidSnap-MainActivity"
        private const val CHANNEL = "com.vidsnap.reader/pdf"
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        Log.i(TAG, "🔥 FlutterEngine configurado, inicializando PdfTools...")
        PdfTools.init(applicationContext)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                try {
                    when (call.method) {
                        "mergePdfs" -> {
                            val inputs = call.argument<List<String>>("inputs") ?: emptyList()
                            val out = call.argument<String>("outPath")!!
                            result.success(PdfTools.mergePdfs(inputs, out))
                        }

                        "compressPdf" -> {
                            val input = call.argument<String>("input")!!
                            val quality = call.argument<Int>("quality") ?: 2
                            val out = call.argument<String>("outPath")!!
                            result.success(PdfTools.compressPdf(input, quality, out))
                        }

                        "extractPages" -> {
                            val input = call.argument<String>("input")!!
                            val pages = call.argument<List<Int>>("pages") ?: emptyList()
                            val split = call.argument<Boolean>("split") ?: false
                            val dir = call.argument<String>("outDir")!!
                            result.success(PdfTools.extractPages(input, pages, split, dir))
                        }

                        "cleanPdf" -> {
                            val input = call.argument<String>("input")!!
                            val mode = call.argument<Int>("mode") ?: 1
                            val out = call.argument<String>("outPath")!!
                            result.success(PdfTools.cleanPdf(input, mode, out))
                        }

                        "scanToPdf" -> {
                            val images = call.argument<List<String>>("images") ?: emptyList()
                            val dpi = call.argument<Int>("dpi") ?: 200
                            val filter = call.argument<Int>("filter") ?: 1
                            val out = call.argument<String>("outPath")!!
                            result.success(PdfTools.scanToPdf(images, dpi, filter, out))
                        }

                        else -> result.notImplemented()
                    }
                } catch (e: Exception) {
                    Log.e(TAG, "❌ Error en canal PDF: ${e.message}", e)
                    result.error("ERR", e.message, e.stackTraceToString())
                }
            }

        Log.i(TAG, "✅ Canal PDF listo y escuchando.")
    }
}


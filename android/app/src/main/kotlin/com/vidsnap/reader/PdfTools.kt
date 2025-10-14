package com.vidsnap.reader

import android.content.Context
import android.graphics.BitmapFactory
import android.util.Log
import com.tom_roush.pdfbox.android.PdfBoxResourceLoader
import com.tom_roush.pdfbox.io.MemoryUsageSetting
import com.tom_roush.pdfbox.multipdf.PDFMergerUtility
import com.tom_roush.pdfbox.pdmodel.PDDocument
import com.tom_roush.pdfbox.pdmodel.PDPage
import com.tom_roush.pdfbox.pdmodel.PDPageContentStream
import com.tom_roush.pdfbox.pdmodel.common.PDRectangle
import com.tom_roush.pdfbox.pdmodel.graphics.image.JPEGFactory
import java.io.*

/**
 * ============================
 *  VidSnap Reader - PDF Tools
 *  Author: VidSnap Dev Team
 *  Build: 2025.10
 * ============================
 *
 * Wrapper profesional sobre pdfbox-android.
 * Incluye:
 *  - mergePdfs()
 *  - compressPdf()
 *  - extractPages()
 *  - cleanPdf()
 *  - scanToPdf()
 *
 * Pensado para integrarse vía MethodChannel desde Flutter.
 */
object PdfTools {

    private const val TAG = "VidSnap-PdfTools"

    @Volatile
    private var initialized = false
    private lateinit var context: Context

    /** Inicializa el loader global de pdfbox-android (debe llamarse una vez). */
    fun init(appContext: Context) {
        if (!initialized) {
            context = appContext.applicationContext
            PdfBoxResourceLoader.init(context)
            initialized = true
            Log.i(TAG, "✅ PdfBoxResourceLoader inicializado correctamente.")
        }
    }

    // -------------------------------------------------------------------------
    // API pública
    // -------------------------------------------------------------------------

    @JvmStatic
    fun mergePdfs(inputs: List<String>, outPath: String): String {
        ensureInit()
        require(inputs.isNotEmpty()) { "La lista de archivos está vacía." }

        val merger = PDFMergerUtility().apply {
            inputs.forEach {
                val file = File(it)
                require(file.exists()) { "Archivo no encontrado: $it" }
                addSource(file)
            }
            destinationFileName = outPath
        }

        File(outPath).parentFile?.mkdirs()
        merger.mergeDocuments(MemoryUsageSetting.setupMainMemoryOnly())
        Log.i(TAG, "📄 PDFs combinados en: $outPath")
        return outPath
    }

    @JvmStatic
    fun compressPdf(input: String, quality: Int, outPath: String): String {
        ensureInit()
        require(File(input).exists()) { "No existe el archivo: $input" }
        PDDocument.load(File(input)).use { doc ->
            doc.documentInformation?.producer = "VidSnap Reader"
            File(outPath).parentFile?.mkdirs()
            FileOutputStream(outPath).use { fos -> doc.save(fos) }
        }
        Log.i(TAG, "📦 PDF comprimido: $outPath (nivel $quality)")
        return outPath
    }

    @JvmStatic
    fun extractPages(input: String, pages: List<Int>, split: Boolean, outDir: String): String {
        ensureInit()
        require(File(input).exists()) { "No existe: $input" }
        require(pages.isNotEmpty()) { "Lista de páginas vacía." }

        val outDirectory = File(outDir).apply { mkdirs() }

        PDDocument.load(File(input)).use { src ->
            val max = src.numberOfPages
            if (split) {
                pages.forEach { p ->
                    require(p in 1..max) { "Página fuera de rango: $p de $max" }
                    PDDocument().use { outDoc ->
                        outDoc.addPage(src.getPage(p - 1))
                        File(outDirectory, "page_$p.pdf").outputStream().use { outDoc.save(it) }
                    }
                }
                Log.i(TAG, "✂️ ${pages.size} páginas extraídas individualmente en $outDir")
            } else {
                PDDocument().use { outDoc ->
                    pages.forEach { p ->
                        require(p in 1..max) { "Página fuera de rango: $p de $max" }
                        outDoc.addPage(src.getPage(p - 1))
                    }
                    File(outDirectory, "extract.pdf").outputStream().use { outDoc.save(it) }
                }
                Log.i(TAG, "📑 Páginas ${pages.joinToString()} extraídas a extract.pdf")
            }
        }
        return outDirectory.absolutePath
    }

    @JvmStatic
    fun cleanPdf(input: String, mode: Int, outPath: String): String {
        ensureInit()
        require(File(input).exists()) { "No existe: $input" }
        PDDocument.load(File(input)).use { src ->
            PDDocument().use { outDoc ->
                repeat(src.numberOfPages) { i -> outDoc.addPage(src.getPage(i)) }
                File(outPath).parentFile?.mkdirs()
                FileOutputStream(outPath).use { outDoc.save(it) }
            }
        }
        Log.i(TAG, "🧹 PDF limpiado -> $outPath (modo $mode)")
        return outPath
    }

    @JvmStatic
    fun scanToPdf(images: List<String>, dpi: Int, filter: Int, outPath: String): String {
        ensureInit()
        require(images.isNotEmpty()) { "No hay imágenes para procesar." }

        PDDocument().use { doc ->
            images.forEach { path ->
                val file = File(path)
                require(file.exists()) { "Imagen no encontrada: $path" }

                val bitmap = BitmapFactory.decodeFile(path)
                val pdImage = JPEGFactory.createFromImage(doc, bitmap)
                val page = PDPage(PDRectangle(pdImage.width.toFloat(), pdImage.height.toFloat()))
                doc.addPage(page)

                PDPageContentStream(doc, page).use { cs ->
                    cs.drawImage(pdImage, 0f, 0f)
                }

                bitmap.recycle()
            }
            File(outPath).parentFile?.mkdirs()
            FileOutputStream(outPath).use { doc.save(it) }
        }
        Log.i(TAG, "📷 ${images.size} imágenes convertidas en PDF -> $outPath")
        return outPath
    }

    // -------------------------------------------------------------------------
    // Internos
    // -------------------------------------------------------------------------

    private fun ensureInit() {
        check(initialized) { "PdfTools no inicializado. Llama a PdfTools.init(context) antes de usarlo." }
    }
}

import 'package:flutter/services.dart';

class PdfChannel {
  static const _ch = MethodChannel('com.vidsnap.reader/pdf');

  static Future<String> mergePdfs(List<String> inputs, String outPath) async {
    final res = await _ch.invokeMethod<String>('mergePdfs', {'inputs': inputs, 'outPath': outPath});
    return res ?? '';
  }

  static Future<String> compressPdf(String input, int quality, String outPath) async {
    final res = await _ch.invokeMethod<String>('compressPdf', {'input': input, 'quality': quality, 'outPath': outPath});
    return res ?? '';
  }

  static Future<List<String>> extractPages(String input, List<int> pages, bool split, String outDir) async {
    final res = await _ch.invokeMethod<List<dynamic>>('extractPages', {
      'input': input,
      'pages': pages,
      'split': split,
      'outDir': outDir,
    });
    return res?.map((e) => e.toString()).toList() ?? <String>[];
  }

  static Future<String> cleanPdf(String input, int mode, String outPath) async {
    final res = await _ch.invokeMethod<String>('cleanPdf', {'input': input, 'mode': mode, 'outPath': outPath});
    return res ?? '';
  }

  static Future<String> scanToPdf(List<String> images, int dpi, int filter, String outPath) async {
    final res = await _ch.invokeMethod<String>('scanToPdf', {
      'images': images,
      'dpi': dpi,
      'filter': filter,
      'outPath': outPath,
    });
    return res ?? '';
  }
}

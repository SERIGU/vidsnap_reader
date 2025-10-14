import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../../i18n/l10n.dart';
import '../../platform/pdf_channel.dart';
import '../../services/ad_service.dart';
import '../../services/range_parser.dart';

class ExtractPagesScreen extends StatefulWidget {
  const ExtractPagesScreen({super.key});
  @override State<ExtractPagesScreen> createState() => _ExtractPagesScreenState();
}

class _ExtractPagesScreenState extends State<ExtractPagesScreen> {
  String? input;
  String ranges = '';
  bool multiple = false;
  List<String> outputs = [];

  int _maxPages = 9999; // si luego expones metadatos, actualiza este valor

  Future<void> _run() async {
    final parsed = RangeParser.parse(ranges, maxPages: _maxPages).pages;
    final requirePro = parsed.length > 20 || multiple;
    if (requirePro) {
      final ok = await AdService.instance.requireRewarded();
      if (!ok) return;
    } else {
      final ok = await AdService.instance.maybeShowInterstitial();
      if (!ok) return;
    }
    final dir = await getTemporaryDirectory();
    final res = await PdfChannel.extractPages(input!, parsed, multiple, dir.path);
    setState(()=> outputs = res);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).t('operation_success'))));
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(t.t('extract_pages'))),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          ElevatedButton(
            onPressed: () async {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selector de archivos pendiente')));
            },
            child: Text(t.t('select_pdf')),
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(labelText: t.t('range_hint')),
            onChanged: (v)=> ranges = v,
          ),
          const SizedBox(height: 8),
          Row(children: [
            Checkbox(value: multiple, onChanged: (v)=> setState(()=> multiple = v ?? false)),
            Text(AppLocalizations.of(context).t(multiple ? 'multiple_files' : 'single_file')),
          ]),
          const Spacer(),
          ElevatedButton(onPressed: input != null && ranges.isNotEmpty ? _run : null, child: Text(t.t('run'))),
          if (outputs.isNotEmpty) ...[
            const SizedBox(height: 8),
            Expanded(child: ListView.builder(
              itemCount: outputs.length,
              itemBuilder: (_, i)=> Text(outputs[i]),
            ))
          ]
        ]),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../../i18n/l10n.dart';
import '../../platform/pdf_channel.dart';
import '../../services/ad_service.dart';

class MergeScreen extends StatefulWidget {
  const MergeScreen({super.key});
  @override State<MergeScreen> createState() => _MergeScreenState();
}

class _MergeScreenState extends State<MergeScreen> {
  final inputs = <String>[];
  String? output;

  Future<void> _run() async {
    final ok = await AdService.instance.maybeShowInterstitial();
    if (!ok) return;
    final dir = await getTemporaryDirectory();
    final out = '${dir.path}/merged_${DateTime.now().millisecondsSinceEpoch}.pdf';
    try {
      final res = await PdfChannel.mergePdfs(inputs, out);
      setState(()=> output = res);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).t('operation_success'))));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).t('operation_failed'))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(t.t('merge_pdfs'))),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Row(children: [
            ElevatedButton(
              onPressed: () async {
                // Aquí integraremos file picker luego.
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selector de archivos pendiente')));
              },
              child: Text(t.t('select_pdfs')),
            ),
            const SizedBox(width: 12),
            Text('${inputs.length} PDFs'),
          ]),
          const Spacer(),
          ElevatedButton(onPressed: inputs.length >= 2 ? _run : null, child: Text(t.t('run'))),
          if (output != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(output!)),
        ]),
      ),
    );
  }
}

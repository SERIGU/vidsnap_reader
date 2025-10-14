import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../../i18n/l10n.dart';
import '../../platform/pdf_channel.dart';
import '../../services/ad_service.dart';

class CompressScreen extends StatefulWidget {
  const CompressScreen({super.key});
  @override State<CompressScreen> createState() => _CompressScreenState();
}

class _CompressScreenState extends State<CompressScreen> {
  String? input;
  int quality = 2; // 1..3
  String? output;

  Future<void> _run() async {
    final ok = await AdService.instance.maybeShowInterstitial();
    if (!ok) return;
    final dir = await getTemporaryDirectory();
    final out = '${dir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final res = await PdfChannel.compressPdf(input!, quality, out);
    setState(()=> output = res);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).t('operation_success'))));
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(t.t('compress_pdf'))),
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
          Row(children: [
            Text(t.t('quality')),
            const SizedBox(width: 12),
            DropdownButton<int>(
              value: quality,
              items: const [
                DropdownMenuItem(value: 1, child: Text('Low')),
                DropdownMenuItem(value: 2, child: Text('Medium')),
                DropdownMenuItem(value: 3, child: Text('High')),
              ],
              onChanged: (v){ setState(()=> quality = v ?? 2); },
            ),
          ]),
          const Spacer(),
          ElevatedButton(onPressed: input != null ? _run : null, child: Text(t.t('run'))),
          if (output != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(output!)),
        ]),
      ),
    );
  }
}

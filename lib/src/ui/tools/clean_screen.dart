import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../../i18n/l10n.dart';
import '../../platform/pdf_channel.dart';
import '../../services/ad_service.dart';

class CleanScreen extends StatefulWidget {
  const CleanScreen({super.key});
  @override State<CleanScreen> createState() => _CleanScreenState();
}

class _CleanScreenState extends State<CleanScreen> {
  String? input;
  int mode = 1; // 1=Basic, 2=Pro
  String? output;

  Future<void> _run() async {
    if (mode >= 2) {
      final ok = await AdService.instance.requireRewarded();
      if (!ok) return;
    } else {
      final ok = await AdService.instance.maybeShowInterstitial();
      if (!ok) return;
    }
    final dir = await getTemporaryDirectory();
    final out = '${dir.path}/clean_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final res = await PdfChannel.cleanPdf(input!, mode, out);
    setState(()=> output = res);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).t('operation_success'))));
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(t.t('clean_pdf'))),
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
              value: mode,
              items: [
                DropdownMenuItem(value: 1, child: Text('${t.t('basic')}')),
                DropdownMenuItem(value: 2, child: Text('${t.t('pro')}')),
              ],
              onChanged: (v){ setState(()=> mode = v ?? 1); },
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

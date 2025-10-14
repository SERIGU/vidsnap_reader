import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import '../../i18n/l10n.dart';
import '../../platform/pdf_channel.dart';
import '../../services/ad_service.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});
  @override State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  CameraController? _controller;
  List<String> _shots = [];
  bool _busy = false;
  int dpi = 200;   // 300 => Pro
  int filter = 1;  // 1=Basic, 2=Pro

  @override
  void initState() {
    super.initState();
    _initCam();
  }

  Future<void> _initCam() async {
    final cams = await availableCameras();
    _controller = CameraController(cams.first, ResolutionPreset.high, enableAudio: false);
    await _controller!.initialize();
    if (mounted) setState((){});
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _capture() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    final x = await _controller!.takePicture();
    _shots.add(x.path);
    setState((){});
  }

  Future<void> _buildPdf() async {
    final needRewarded = (!AdService.instance.isPremium) && (_shots.length > 5 || dpi >= 300 || filter >= 2);
    if (needRewarded) {
      final ok = await AdService.instance.requireRewarded();
      if (!ok) return;
    } else {
      final ok = await AdService.instance.maybeShowInterstitial();
      if (!ok) return;
    }
    final dir = await getTemporaryDirectory();
    final out = '${dir.path}/scan_${DateTime.now().millisecondsSinceEpoch}.pdf';
    setState(()=> _busy = true);
    try {
      final res = await PdfChannel.scanToPdf(_shots, dpi, filter, out);
      if (!mounted) return;
      setState(()=> _busy = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${AppLocalizations.of(context).t('operation_success')}\n$res')));
    } catch (_) {
      if (!mounted) return;
      setState(()=> _busy = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).t('operation_failed'))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(t.t('scan_to_pdf'))),
      body: Column(children: [
        if (_controller == null || !_controller!.value.isInitialized)
          const Expanded(child: Center(child: CircularProgressIndicator()))
        else Expanded(child: CameraPreview(_controller!)),
        if (_shots.isNotEmpty) Padding(
          padding: const EdgeInsets.all(8),
          child: Text('${_shots.length} shots'),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ElevatedButton(onPressed: _controller?.value.isInitialized == true ? _capture : null, child: const Text('Capture')),
            DropdownButton<int>(
              value: dpi,
              items: const [DropdownMenuItem(value: 200, child: Text('200 dpi')), DropdownMenuItem(value: 300, child: Text('300 dpi (Pro)'))],
              onChanged: (v)=> setState(()=> dpi = v ?? 200),
            ),
            DropdownButton<int>(
              value: filter,
              items: const [DropdownMenuItem(value: 1, child: Text('Basic')), DropdownMenuItem(value: 2, child: Text('Pro'))],
              onChanged: (v)=> setState(()=> filter = v ?? 1),
            ),
            ElevatedButton(onPressed: _shots.isNotEmpty ? _buildPdf : null, child: Text(t.t('run'))),
          ],
        ),
        if (_busy) const LinearProgressIndicator(),
        const SizedBox(height: 8),
      ]),
    );
  }
}

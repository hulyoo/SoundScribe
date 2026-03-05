import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../data/models/transcription_result.dart';

class ResultPage extends StatefulWidget {
  final String audioPath;

  const ResultPage({super.key, required this.audioPath});

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  TranscriptionResult? _result;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _processAudio();
  }

  Future<void> _processAudio() async {
    // Simulate API call - replace with actual Melody.ml API
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _result = TranscriptionResult(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        audioPath: widget.audioPath,
        chords: [
          Chord(name: 'C', startTime: 0, duration: 4),
          Chord(name: 'G', startTime: 4, duration: 4),
          Chord(name: 'Am', startTime: 8, duration: 4),
          Chord(name: 'F', startTime: 12, duration: 4),
        ],
        melody: [],
        tempo: 120,
        key: 'C',
        createdAt: DateTime.now(),
      );
      _isLoading = false;
    });
  }

  Future<void> _generatePdf() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Center(
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text(
                  'Guitar Tab',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Text('Key: ${_result?.key ?? "C"}'),
                pw.Text('Tempo: ${_result?.tempo ?? 120} BPM'),
                pw.SizedBox(height: 40),
                pw.Text(
                  'Chords: ${_result?.chords.map((c) => c.name).join(" - ") ?? ""}',
                  style: const pw.TextStyle(fontSize: 18),
                ),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Result'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Transcription Result',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          _buildInfoRow('Key', _result?.key ?? 'C'),
                          _buildInfoRow('Tempo', '${_result?.tempo ?? 120} BPM'),
                          const SizedBox(height: 16),
                          Text(
                            'Chords',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _result?.chords
                                    .map((c) => Chip(label: Text(c.name)))
                                    .toList() ??
                                [],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _generatePdf,
                      icon: const Icon(Icons.picture_as_pdf),
                      label: const Text('Export PDF'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text('$label: '),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

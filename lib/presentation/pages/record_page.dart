import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'result_page.dart';

class RecordPage extends StatefulWidget {
  const RecordPage({super.key});

  @override
  State<RecordPage> createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage> {
  final AudioRecorder _recorder = AudioRecorder();
  bool _isRecording = false;
  bool _isProcessing = false;
  String? _audioPath;
  Duration _recordingDuration = Duration.zero;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    final status = await Permission.microphone.request();
    if (status.isDenied) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Microphone permission required')),
        );
      }
    }
  }

  Future<void> _startRecording() async {
    try {
      if (await _recorder.hasPermission()) {
        final directory = await getApplicationDocumentsDirectory();
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        _audioPath = '${directory.path}/recording_$timestamp.m4a';

        await _recorder.start(
          const RecordConfig(
            encoder: AudioEncoder.aacLc,
            bitRate: 128000,
            sampleRate: 44100,
          ),
          path: _audioPath!,
        );

        setState(() {
          _isRecording = true;
          _recordingDuration = Duration.zero;
        });

        _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          setState(() {
            _recordingDuration += const Duration(seconds: 1);
          });
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _stopRecording() async {
    try {
      _timer?.cancel();
      await _recorder.stop();
      setState(() {
        _isRecording = false;
        _isProcessing = true;
      });

      // Simulate AI processing (replace with actual API call)
      await Future.delayed(const Duration(seconds: 2));

      if (mounted && _audioPath != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ResultPage(audioPath: _audioPath!),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _recorder.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recording'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Waveform visualization placeholder
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isRecording
                    ? Theme.of(context).colorScheme.errorContainer
                    : Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
              child: Icon(
                _isRecording ? Icons.mic : Icons.mic_none,
                size: 100,
                color: _isRecording
                    ? Theme.of(context).colorScheme.error
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),
            // Recording duration
            Text(
              _formatDuration(_recordingDuration),
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: 8),
            Text(
              _isRecording ? 'Recording...' : 'Tap to start',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 48),
            // Record button
            FilledButton.icon(
              onPressed: _isProcessing
                  ? null
                  : (_isRecording ? _stopRecording : _startRecording),
              icon: Icon(_isRecording ? Icons.stop : Icons.mic),
              label: Text(_isRecording ? 'Stop' : 'Start'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
              ),
            ),
            if (_isProcessing) ...[
              const SizedBox(height: 24),
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              const Text('Processing with AI...'),
            ],
          ],
        ),
      ),
    );
  }
}

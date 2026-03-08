import 'dart:async';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import '../../core/constants/app_constants.dart';
import '../../infrastructure/api/melody_api_service.dart';
import '../../data/models/transcription_result.dart';
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
  double _amplitude = 0.0;

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

        // Timer for duration
        _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          setState(() {
            _recordingDuration += const Duration(seconds: 1);
          });
        });

        // Amplitude monitoring
        _startAmplitudeMonitoring();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _startAmplitudeMonitoring() {
    Timer.periodic(const Duration(milliseconds: 100), (timer) async {
      if (! _isRecording) {
        timer.cancel();
        return;
      }
      try {
        final amplitude = await _recorder.getAmplitude();
        setState(() {
          _amplitude = (amplitude.current + 60) / 60; // Normalize to 0-1
          _amplitude = _amplitude.clamp(0.0, 1.0);
        });
      } catch (e) {
        // Ignore amplitude errors
      }
    });
  }

  Future<void> _stopRecording() async {
    try {
      _timer?.cancel();
      await _recorder.stop();
      setState(() {
        _isRecording = false;
        _isProcessing = true;
        _amplitude = 0.0;
      });

      // Process with Melody.ml API
      if (_audioPath != null) {
        await _processAudio();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _processAudio() async {
    try {
      // Validate audio file exists and has content
      final audioFile = File(_audioPath!);
      if (!await audioFile.exists()) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Audio file not found')),
          );
        }
        return;
      }

      final fileSize = await audioFile.length();
      if (fileSize < 1000) { // Less than 1KB is likely empty/invalid
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No audio detected. Please record again.')),
          );
          setState(() {
            _isProcessing = false;
          });
        }
        return;
      }

      // Get API key from settings
      final prefs = await SharedPreferences.getInstance();
      final apiKey = prefs.getString(AppConstants.keyApiKey) ?? '';

      if (apiKey.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please configure Melody.ml API key in Settings first'),
            ),
          );
          setState(() {
            _isProcessing = false;
          });
        }
        return;
      }

      // Call Melody.ml API
      final apiService = MelodyApiService(apiKey: apiKey);
      final result = await apiService.transcribe(_audioPath!);

      if (mounted) {
        await _navigateToResult(result);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Transcription failed: $e')),
        );
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  TranscriptionResult _createMockResult() {
    return TranscriptionResult(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      audioPath: _audioPath ?? '',
      chords: [
        Chord(name: 'C', startTime: 0, duration: 4),
        Chord(name: 'G', startTime: 4, duration: 4),
        Chord(name: 'Am', startTime: 8, duration: 4),
        Chord(name: 'F', startTime: 12, duration: 4),
        Chord(name: 'C', startTime: 16, duration: 4),
        Chord(name: 'G', startTime: 20, duration: 4),
        Chord(name: 'Em', startTime: 24, duration: 4),
        Chord(name: 'D', startTime: 28, duration: 4),
      ],
      melody: [],
      tempo: 120,
      key: 'C',
      createdAt: DateTime.now(),
    );
  }

  Future<void> _navigateToResult(TranscriptionResult result) async {
    if (mounted && _audioPath != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResultPage(
            audioPath: _audioPath!,
            result: result,
          ),
        ),
      );
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
        actions: [
          if (_isRecording)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Waveform visualization
              _buildWaveform(),
              const SizedBox(height: 32),
              // Recording duration
              Text(
                _formatDuration(_recordingDuration),
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
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
              _buildRecordButton(),
              if (_isProcessing) ...[
                const SizedBox(height: 24),
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                const Text('Processing with AI...'),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWaveform() {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _isRecording
            ? Theme.of(context).colorScheme.errorContainer
            : Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Animated rings
          if (_isRecording) ...[
            _buildAmplitudeRing(0.8),
            _buildAmplitudeRing(0.6),
            _buildAmplitudeRing(0.4),
          ],
          Icon(
            _isRecording ? Icons.mic : Icons.mic_none,
            size: 80,
            color: _isRecording
                ? Theme.of(context).colorScheme.error
                : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }

  Widget _buildAmplitudeRing(double scale) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      width: 160 * scale + (_amplitude * 40),
      height: 160 * scale + (_amplitude * 40),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Theme.of(context).colorScheme.error.withOpacity(0.3),
          width: 2,
        ),
      ),
    );
  }

  Widget _buildRecordButton() {
    return GestureDetector(
      onTap: _isProcessing
          ? null
          : (_isRecording ? _stopRecording : _startRecording),
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _isRecording
              ? Theme.of(context).colorScheme.error
              : Theme.of(context).colorScheme.primary,
          boxShadow: [
            BoxShadow(
              color: (_isRecording
                      ? Theme.of(context).colorScheme.error
                      : Theme.of(context).colorScheme.primary)
                  .withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Icon(
          _isRecording ? Icons.stop : Icons.mic,
          color: Colors.white,
          size: 40,
        ),
      ),
    );
  }
}

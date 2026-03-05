import 'dart:io';
import 'package:dio/dio.dart';
import '../../data/models/transcription_result.dart';

/// Melody.ml API Service
/// Handles audio transcription to extract chords and melody
class MelodyApiService {
  final Dio _dio;
  final String apiKey;

  MelodyApiService({
    required this.apiKey,
    Dio? dio,
  }) : _dio = dio ?? Dio() {
    _dio.options.baseUrl = 'https://api.melody.ml';
    _dio.options.headers = {
      'Authorization': 'Bearer $apiKey',
      'Accept': 'application/json',
    };
  }

  /// Upload audio file for transcription
  /// Returns TranscriptionResult with chords and melody
  Future<TranscriptionResult> transcribe(String audioFilePath) async {
    try {
      final file = File(audioFilePath);
      if (!await file.exists()) {
        throw Exception('Audio file not found: $audioFilePath');
      }

      // Get file extension
      final extension = audioFilePath.split('.').last.toLowerCase();
      final mimeType = _getMimeType(extension);

      final formData = FormData.fromMap({
        'audio': await MultipartFile.fromFile(
          audioFilePath,
          filename: 'audio.$extension',
          contentType: DioMediaType.parse(mimeType),
        ),
        // Optional parameters
        'format': 'json',
        'include_chords': 'true',
        'include_melody': 'true',
      });

      final response = await _dio.post(
        '/v1/transcribe',
        data: formData,
        options: Options(
          sendTimeout: const Duration(minutes: 5),
          receiveTimeout: const Duration(minutes: 10),
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return _parseResponse(response.data);
      } else {
        throw Exception('Transcription failed: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Get transcription status by job ID
  Future<TranscriptionResult?> getTranscription(String jobId) async {
    try {
      final response = await _dio.get('/v1/transcriptions/$jobId');

      if (response.statusCode == 200) {
        return _parseResponse(response.data);
      }
      return null;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  TranscriptionResult _parseResponse(Map<String, dynamic> data) {
    // Parse the API response and convert to our model
    // Note: This parser assumes a specific API response format
    // You may need to adjust based on actual Melody.ml API documentation

    final chords = _parseChords(data['chords'] ?? data['result']?['chords']);
    final melody = _parseMelody(data['melody'] ?? data['result']?['melody']);

    return TranscriptionResult(
      id: data['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      audioPath: data['audio_path'] ?? '',
      chords: chords,
      melody: melody,
      tempo: data['tempo'] ?? data['result']?['tempo'] ?? 120,
      key: data['key'] ?? data['result']?['key'] ?? 'C',
      createdAt: data['created_at'] != null
          ? DateTime.tryParse(data['created_at']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  List<Chord> _parseChords(dynamic chordsData) {
    if (chordsData == null) return [];
    if (chordsData is! List) return [];

    return chordsData.map((chord) {
      if (chord is String) {
        // Simple format: ["C", "G", "Am"]
        return Chord(name: chord, startTime: 0, duration: 4);
      } else if (chord is Map) {
        // Detailed format: {"name": "C", "start": 0, "duration": 4}
        return Chord(
          name: chord['name']?.toString() ?? chord['chord']?.toString() ?? '?',
          startTime: _toDouble(chord['start'] ?? chord['start_time'] ?? 0),
          duration: _toDouble(chord['duration'] ?? 4),
        );
      }
      return Chord(name: '?', startTime: 0, duration: 4);
    }).toList();
  }

  List<Note> _parseMelody(dynamic melodyData) {
    if (melodyData == null) return [];
    if (melodyData is! List) return [];

    return melodyData.map((note) {
      if (note is Map) {
        return Note(
          pitch: note['pitch']?.toString() ?? note['note']?.toString() ?? '?',
          octave: note['octave'] ?? note['note_number'] ~/ 12 ?? 4,
          startTime: _toDouble(note['start'] ?? note['start_time'] ?? 0),
          duration: _toDouble(note['duration'] ?? 1),
        );
      }
      return Note(pitch: '?', octave: 4, startTime: 0, duration: 1);
    }).toList();
  }

  double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  String _getMimeType(String extension) {
    switch (extension.toLowerCase()) {
      case 'mp3':
        return 'audio/mpeg';
      case 'm4a':
        return 'audio/mp4';
      case 'wav':
        return 'audio/wav';
      case 'ogg':
        return 'audio/ogg';
      default:
        return 'audio/mpeg';
    }
  }

  Exception _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('Connection timeout. Please check your internet connection.');
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        if (statusCode == 401) {
          return Exception('Invalid API key. Please check your Melody.ml API key.');
        } else if (statusCode == 429) {
          return Exception('Rate limit exceeded. Please try again later.');
        } else if (statusCode == 500) {
          return Exception('Melody.ml server error. Please try again later.');
        }
        return Exception('Server error: $statusCode');
      case DioExceptionType.cancel:
        return Exception('Request cancelled.');
      default:
        return Exception('Network error: ${e.message}');
    }
  }
}

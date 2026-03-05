import 'dart:io';
import 'package:dio/dio.dart';
import '../data/models/transcription_result.dart';

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
    };
  }

  /// Upload audio file for transcription
  Future<TranscriptionResult> transcribe(String audioFilePath) async {
    try {
      final file = File(audioFilePath);
      if (!await file.exists()) {
        throw Exception('Audio file not found');
      }

      final formData = FormData.fromMap({
        'audio': await MultipartFile.fromFile(
          audioFilePath,
          filename: 'audio.mp3',
        ),
      });

      final response = await _dio.post(
        '/transcribe',
        data: formData,
        options: Options(
          sendTimeout: const Duration(minutes: 2),
          receiveTimeout: const Duration(minutes: 5),
        ),
      );

      if (response.statusCode == 200) {
        return _parseResponse(response.data);
      } else {
        throw Exception('Transcription failed: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw Exception('API Error: ${e.message}');
    }
  }

  TranscriptionResult _parseResponse(Map<String, dynamic> data) {
    // Parse the API response and convert to our model
    // This is a placeholder - actual parsing depends on Melody.ml API response format
    return TranscriptionResult(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      audioPath: '',
      chords: _parseChords(data['chords']),
      melody: _parseMelody(data['melody']),
      tempo: data['tempo'] ?? 120,
      key: data['key'] ?? 'C',
      createdAt: DateTime.now(),
    );
  }

  List<Chord> _parseChords(dynamic chordsData) {
    if (chordsData == null) return [];
    // Placeholder - implement based on actual API response
    return [];
  }

  List<Note> _parseMelody(dynamic melodyData) {
    if (melodyData == null) return [];
    // Placeholder - implement based on actual API response
    return [];
  }
}

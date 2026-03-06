class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'SoundScribe';
  static const String appVersion = '1.0.0';

  // API
  static const String melodyApiBaseUrl = 'https://api.melody.ml';
  static const String melodyApiKey = ''; // TODO: Set from environment

  // Audio Settings
  static const int sampleRate = 44100;
  static const int bitRate = 128000;
  static const String audioFormat = 'mp3';

  // Storage Keys
  static const String keyApiKey = 'melody_api_key';
  static const String keyThemeMode = 'theme_mode';
  static const String keyTranscriptions = 'transcriptions';

  // Timeouts
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration recordingMaxDuration = Duration(minutes: 5);
}

import 'package:flutter_test/flutter_test.dart';
import 'package:soundscribe/data/models/transcription_result.dart';

void main() {
  group('TranscriptionResult', () {
    test('should create TranscriptionResult from JSON', () {
      final json = {
        'id': 'test-123',
        'audioPath': '/path/to/audio.m4a',
        'chords': [
          {'name': 'C', 'startTime': 0, 'duration': 4},
          {'name': 'G', 'startTime': 4, 'duration': 4},
        ],
        'melody': [
          {'pitch': 'C', 'octave': 4, 'startTime': 0, 'duration': 1},
        ],
        'tempo': 120,
        'key': 'C',
        'createdAt': '2026-03-05T10:00:00.000Z',
      };

      final result = TranscriptionResult.fromJson(json);

      expect(result.id, 'test-123');
      expect(result.audioPath, '/path/to/audio.m4a');
      expect(result.chords.length, 2);
      expect(result.chords[0].name, 'C');
      expect(result.melody.length, 1);
      expect(result.tempo, 120);
      expect(result.key, 'C');
    });

    test('should convert TranscriptionResult to JSON', () {
      final result = TranscriptionResult(
        id: 'test-456',
        audioPath: '/path/to/audio.m4a',
        chords: [
          Chord(name: 'Am', startTime: 0, duration: 4),
        ],
        melody: [
          Note(pitch: 'A', octave: 4, startTime: 0, duration: 1),
        ],
        tempo: 100,
        key: 'A',
        createdAt: DateTime(2026, 3, 5),
      );

      final json = result.toJson();

      expect(json['id'], 'test-456');
      expect(json['audioPath'], '/path/to/audio.m4a');
      expect(json['chords'][0]['name'], 'Am');
      expect(json['tempo'], 100);
    });
  });

  group('Chord', () {
    test('should create Chord from JSON', () {
      final json = {
        'name': 'G7',
        'startTime': 8.0,
        'duration': 4.0,
      };

      final chord = Chord.fromJson(json);

      expect(chord.name, 'G7');
      expect(chord.startTime, 8.0);
      expect(chord.duration, 4.0);
    });

    test('should convert Chord to JSON', () {
      final chord = Chord(name: 'Dm', startTime: 12, duration: 4);

      final json = chord.toJson();

      expect(json['name'], 'Dm');
      expect(json['startTime'], 12);
      expect(json['duration'], 4);
    });
  });

  group('Note', () {
    test('should create Note from JSON', () {
      final json = {
        'pitch': 'E',
        'octave': 5,
        'startTime': 2.0,
        'duration': 0.5,
      };

      final note = Note.fromJson(json);

      expect(note.pitch, 'E');
      expect(note.octave, 5);
      expect(note.startTime, 2.0);
      expect(note.duration, 0.5);
    });

    test('should convert Note to JSON', () {
      final note = Note(pitch: 'F', octave: 4, startTime: 3, duration: 1);

      final json = note.toJson();

      expect(json['pitch'], 'F');
      expect(json['octave'], 4);
      expect(json['startTime'], 3);
      expect(json['duration'], 1);
    });
  });
}

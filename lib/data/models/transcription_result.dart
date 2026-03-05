class TranscriptionResult {
  final String id;
  final String audioPath;
  final List<Chord> chords;
  final List<Note> melody;
  final int tempo;
  final String key;
  final DateTime createdAt;

  TranscriptionResult({
    required this.id,
    required this.audioPath,
    required this.chords,
    required this.melody,
    required this.tempo,
    required this.key,
    required this.createdAt,
  });

  factory TranscriptionResult.fromJson(Map<String, dynamic> json) {
    return TranscriptionResult(
      id: json['id'] as String,
      audioPath: json['audioPath'] as String,
      chords: (json['chords'] as List)
          .map((e) => Chord.fromJson(e as Map<String, dynamic>))
          .toList(),
      melody: (json['melody'] as List)
          .map((e) => Note.fromJson(e as Map<String, dynamic>))
          .toList(),
      tempo: json['tempo'] as int,
      key: json['key'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'audioPath': audioPath,
      'chords': chords.map((e) => e.toJson()).toList(),
      'melody': melody.map((e) => e.toJson()).toList(),
      'tempo': tempo,
      'key': key,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class Chord {
  final String name;
  final double startTime;
  final double duration;

  Chord({
    required this.name,
    required this.startTime,
    required this.duration,
  });

  factory Chord.fromJson(Map<String, dynamic> json) {
    return Chord(
      name: json['name'] as String,
      startTime: (json['startTime'] as num).toDouble(),
      duration: (json['duration'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'startTime': startTime,
      'duration': duration,
    };
  }
}

class Note {
  final String pitch;
  final int octave;
  final double startTime;
  final double duration;

  Note({
    required this.pitch,
    required this.octave,
    required this.startTime,
    required this.duration,
  });

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      pitch: json['pitch'] as String,
      octave: json['octave'] as int,
      startTime: (json['startTime'] as num).toDouble(),
      duration: (json['duration'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pitch': pitch,
      'octave': octave,
      'startTime': startTime,
      'duration': duration,
    };
  }
}

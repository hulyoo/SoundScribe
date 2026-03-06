import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transcription_result.dart';

class TranscriptionRepository {
  static const String _storageKey = 'transcriptions';

  Future<void> save(TranscriptionResult result) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await getAll();
    list.insert(0, result);
    final jsonList = list.map((e) => e.toJson()).toList();
    await prefs.setString(_storageKey, jsonEncode(jsonList));
  }

  Future<List<TranscriptionResult>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);
    if (jsonString == null || jsonString.isEmpty) return [];
    try {
      final jsonList = jsonDecode(jsonString) as List;
      return jsonList.map((e) => TranscriptionResult.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> delete(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await getAll();
    list.removeWhere((e) => e.id == id);
    final jsonList = list.map((e) => e.toJson()).toList();
    await prefs.setString(_storageKey, jsonEncode(jsonList));
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
}

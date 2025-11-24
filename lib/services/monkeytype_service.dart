import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:portfolio/models/monkeytype.dart';

class MonkeytypeService {
  // Singleton instance
  static final MonkeytypeService _instance = MonkeytypeService._internal();
  static MonkeytypeService get instance => _instance;

  MonkeytypeService._internal();

  // Cache the future to prevent multiple API calls
  Future<MonkeytypeResponse?>? _cachedFuture;

  // API Key (should ideally be secure, but using environment variable for now)
  static const _apiKey = String.fromEnvironment('MONKEYTYPE_API_KEY', defaultValue: '');

  Future<MonkeytypeResponse?> getData() {
    // Return cached future if it exists
    if (_cachedFuture != null) {
      return _cachedFuture!;
    }

    // Otherwise, fetch and cache
    _cachedFuture = _fetchData();
    return _cachedFuture!;
  }

  Future<MonkeytypeResponse?> _fetchData() async {
    try {
      debugPrint("Fetching Monkeytype data...");

      // Fetch Time Mode (15s, 60s)
      final timeUri = Uri.parse("https://api.monkeytype.com/users/personalBests?mode=time");
      final timeResponse = await http.get(
        timeUri,
        headers: {"Authorization": "ApeKey $_apiKey", "Content-Type": "application/json"},
      );

      // Fetch Words Mode (10 words)
      final wordsUri = Uri.parse("https://api.monkeytype.com/users/personalBests?mode=words");
      final wordsResponse = await http.get(
        wordsUri,
        headers: {"Authorization": "ApeKey $_apiKey", "Content-Type": "application/json"},
      );

      if (timeResponse.statusCode == 200 && wordsResponse.statusCode == 200) {

        final timeJson = jsonDecode(timeResponse.body);
        final wordsJson = jsonDecode(wordsResponse.body);

        // Parse and merge data
        final timeData = MonkeytypeResponse.fromJson(timeJson).data;
        final wordsData = MonkeytypeResponse.fromJson(wordsJson).data;

        Map<String, List<PersonalBest>> mergedData = {};

        // Prefix keys to avoid collisions and identify mode
        timeData.forEach((key, value) {
          mergedData['time_$key'] = value;
        });

        wordsData.forEach((key, value) {
          mergedData['words_$key'] = value;
        });

        return MonkeytypeResponse(message: "Merged Data", data: mergedData);
      } else {
        debugPrint("Monkeytype API Error: Time=${timeResponse.statusCode}, Words=${wordsResponse.statusCode}");
        return null;
      }
    } catch (e) {
      debugPrint("Monkeytype Exception: $e");
      return null;
    }
  }

  // Method to force refresh if needed in the future
  void invalidateCache() {
    _cachedFuture = null;
  }
}

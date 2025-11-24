class MonkeytypeResponse {
  final String message;
  final Map<String, List<PersonalBest>> data;

  MonkeytypeResponse({
    required this.message,
    required this.data,
  });

  factory MonkeytypeResponse.fromJson(Map<String, dynamic> json) {
    var dataJson = json['data'] as Map<String, dynamic>? ?? {};
    Map<String, List<PersonalBest>> parsedData = {};
    
    dataJson.forEach((key, value) {
      if (value is List) {
        parsedData[key] = value
            .map((item) => PersonalBest.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    });

    return MonkeytypeResponse(
      message: json['message'] as String? ?? '',
      data: parsedData,
    );
  }
}

class PersonalBest {
  final double acc;
  final double consistency;
  final String difficulty;
  final bool lazyMode;
  final String language;
  final bool punctuation;
  final bool numbers;
  final double raw;
  final double wpm;
  final DateTime timestamp;

  PersonalBest({
    required this.acc,
    required this.consistency,
    required this.difficulty,
    required this.lazyMode,
    required this.language,
    required this.punctuation,
    required this.numbers,
    required this.raw,
    required this.wpm,
    required this.timestamp,
  });

  factory PersonalBest.fromJson(Map<String, dynamic> json) {
    return PersonalBest(
      acc: (json['acc'] as num?)?.toDouble() ?? 0.0,
      consistency: (json['consistency'] as num?)?.toDouble() ?? 0.0,
      difficulty: json['difficulty'] as String? ?? 'normal',
      lazyMode: json['lazyMode'] as bool? ?? false,
      language: json['language'] as String? ?? 'english',
      punctuation: json['punctuation'] as bool? ?? false,
      numbers: json['numbers'] as bool? ?? false,
      raw: (json['raw'] as num?)?.toDouble() ?? 0.0,
      wpm: (json['wpm'] as num?)?.toDouble() ?? 0.0,
      timestamp: json['timestamp'] != null
          ? DateTime.fromMillisecondsSinceEpoch((json['timestamp'] as num).toInt())
          : DateTime.now(),
    );
  }
}
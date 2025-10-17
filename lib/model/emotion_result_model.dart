// lib/emotion_result_model.dart

class EmotionResult {
  final String name;
  final String condition;
  final List<String> tags;
  final String description;
  final String mood;
  final String focusLevel;
  final String suggestedActivity;
  final String emotionResponse;

  EmotionResult({
    required this.name,
    required this.condition,
    required this.tags,
    required this.description,
    required this.mood,
    required this.focusLevel,
    required this.suggestedActivity,
    required this.emotionResponse,
  });

  // Fungsi ini mengubah data JSON dari server menjadi objek EmotionResult.
  // Jika ada data yang kosong dari server, ia akan menggunakan nilai default
  // seperti 'Data tidak ditemukan' untuk mencegah aplikasi error.
  factory EmotionResult.fromJson(Map<String, dynamic> json) {
    return EmotionResult(
      name: json['name'] as String? ?? 'Data tidak ditemukan',
      condition: json['condition'] as String? ?? 'Data tidak ditemukan',
      tags: List<String>.from(json['tags'] as List<dynamic>? ?? []),
      description:
          json['description'] as String? ?? 'Deskripsi tidak tersedia.',
      mood: json['mood'] as String? ?? '-',
      focusLevel: json['focus_level'] as String? ?? '0%',
      suggestedActivity: json['suggested_activity'] as String? ?? '-',
      emotionResponse: json['emotion_response'] as String? ?? '-',
    );
  }
}

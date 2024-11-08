import 'dart:convert';
import 'package:flutter/services.dart';

class ConfigManager {
  Map<String, dynamic> _config = {};

  ConfigManager();

  // Get
  dynamic get(String key) {
    return _config[key];
  }

  // Set
  void set(String key, dynamic value) {
    _config[key] = value;
  }

  // Load JSON file
  Future<void> loadConfig(String path) async {
    final String response = await rootBundle.loadString(path);
    _config = jsonDecode(response);
  }

  // Save config as JSON file
  String saveConfig() {
    return jsonEncode(_config);
  }

  // Update nested value
  void setNestedValue(List<String> path, dynamic value) {
    Map<String, dynamic> current = _config;
    for (int i = 0; i < path.length - 1; i++) {
      current = current.putIfAbsent(path[i], () => {}) as Map<String, dynamic>;
    }
    current[path.last] = value;
  }

  // TODO: template, cards, decks config | get set
  Map<String, dynamic>? getCardSize() {
    return _config['cardSize'];
  }
  void setCardSize(int width, int height) {
    _config['cardSize'] = {'width': width, 'height': height};
  }

  // Patterns
  List<List<String>> getPatterns() {
    return List<List<String>>.from(_config['patterns']);
  }

  void addPattern(List<String> pattern) {
    final patterns = _config['patterns'] as List<dynamic>;
    patterns.add(pattern);
  }
}

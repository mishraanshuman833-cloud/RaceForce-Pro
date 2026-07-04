// lib/data/repositories/standards_repository.dart

import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/standard_model.dart';

class StandardsRepository {
  static const String _assetPath = 'assets/data/running_standards.json';

  StandardsData? _cachedData;

  Future<StandardsData> loadStandards() async {
    if (_cachedData != null) return _cachedData!;

    final jsonString = await rootBundle.loadString(_assetPath);
    final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
    _cachedData = StandardsData.fromJson(jsonMap);
    return _cachedData!;
  }

  Future<ExamStandard?> getStandardById(String id) async {
    final data = await loadStandards();
    return data.getById(id);
  }

  Future<List<ExamStandard>> getAllStandards() async {
    final data = await loadStandards();
    return data.standards;
  }
}

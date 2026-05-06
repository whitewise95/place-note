import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/research_report.dart';

class ReportStorage {
  static const String _key = 'address_research_reports';

  Future<List<ResearchReport>> loadReports() async {
    final prefs = await SharedPreferences.getInstance();
    final payload = prefs.getString(_key);
    if (payload == null || payload.isEmpty) {
      return [];
    }

    final decoded = jsonDecode(payload) as List<dynamic>;
    return decoded
        .map((item) => ResearchReport.fromJson(item as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> saveReport(ResearchReport report) async {
    final prefs = await SharedPreferences.getInstance();
    final reports = await loadReports();
    final updated = [
      report.copyWith(isSaved: true),
      ...reports.where((item) => item.id != report.id),
    ];

    await prefs.setString(
      _key,
      jsonEncode(updated.map((item) => item.toJson()).toList()),
    );
  }

  Future<void> deleteReport(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final reports = await loadReports();
    final updated = reports.where((item) => item.id != id).toList();

    await prefs.setString(
      _key,
      jsonEncode(updated.map((item) => item.toJson()).toList()),
    );
  }
}

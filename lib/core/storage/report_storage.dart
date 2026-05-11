import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/research_report.dart';
import '../../data/models/text_folder.dart';

class ReportStorage {
  static const String _key = 'address_research_reports';
  static const String _foldersKey = 'text_folders';

  Future<List<TextFolder>> loadFolders() async {
    final prefs = await SharedPreferences.getInstance();
    final payload = prefs.getString(_foldersKey);
    if (payload == null || payload.isEmpty) {
      return [TextFolder.inbox()];
    }

    final decoded = jsonDecode(payload) as List<dynamic>;
    final folders = decoded
        .map((item) => TextFolder.fromJson(item as Map<String, dynamic>))
        .toList();

    final hasInbox = folders.any((folder) => folder.id == TextFolder.inboxId);
    final updated = hasInbox ? folders : [TextFolder.inbox(), ...folders];
    return updated..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  Future<void> saveFolder(TextFolder folder) async {
    final folders = await loadFolders();
    final updated = [
      ...folders.where((item) => item.id != folder.id),
      folder,
    ]..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    await _persistFolders(updated);
  }

  Future<void> deleteFolder(String id) async {
    if (id == TextFolder.inboxId) {
      return;
    }

    final folders = await loadFolders();
    await _persistFolders(folders.where((folder) => folder.id != id).toList());

    final reports = await loadReports();
    final moved = reports
        .map(
          (report) => report.folderId == id
              ? report.copyWith(folderId: TextFolder.inboxId)
              : report,
        )
        .toList();
    await _persistReports(moved);
  }

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
    final reports = await loadReports();
    final updated = [
      report.copyWith(isSaved: true),
      ...reports.where((item) => item.id != report.id),
    ];

    await _persistReports(updated);
  }

  Future<void> deleteReport(String id) async {
    final reports = await loadReports();
    final updated = reports.where((item) => item.id != id).toList();
    await _persistReports(updated);
  }

  Future<void> _persistReports(List<ResearchReport> reports) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(reports.map((item) => item.toJson()).toList()),
    );
  }

  Future<void> _persistFolders(List<TextFolder> folders) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _foldersKey,
      jsonEncode(folders.map((item) => item.toJson()).toList()),
    );
  }
}

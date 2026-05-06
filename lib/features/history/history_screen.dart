import 'package:flutter/material.dart';

import '../../app.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/status_pill.dart';
import '../../data/models/research_report.dart';
import '../report/report_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  static const String routeName = '/history';

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final TextEditingController searchController = TextEditingController();
  List<ResearchReport> reports = [];
  bool isLoading = true;
  bool hasLoaded = false;

  @override
  void initState() {
    super.initState();
    searchController.addListener(() => setState(() {}));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!hasLoaded) {
      hasLoaded = true;
      _load();
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => isLoading = true);
    final loaded = await RepositoryScope.of(context).findHistories();
    if (!mounted) {
      return;
    }

    setState(() {
      reports = loaded;
      isLoading = false;
    });
  }

  Future<void> _delete(ResearchReport report) async {
    await RepositoryScope.of(context).delete(report.id);
    await _load();
  }

  List<ResearchReport> get filteredReports {
    final keyword = searchController.text.trim().toLowerCase();
    if (keyword.isEmpty) {
      return reports;
    }

    return reports.where((report) {
      return report.normalizedAddress.toLowerCase().contains(keyword) ||
          report.rawAddress.toLowerCase().contains(keyword);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = filteredReports;

    return Scaffold(
      appBar: AppBar(title: const Text('분석 이력')),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 12),
              child: TextField(
                controller: searchController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search_rounded),
                  hintText: '주소 검색',
                ),
              ),
            ),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filtered.isEmpty
                      ? const EmptyState(
                          title: '검색 결과가 없습니다',
                          message: '저장된 분석 이력이 있으면 주소로 다시 찾을 수 있습니다.',
                        )
                      : RefreshIndicator(
                          onRefresh: _load,
                          child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(18, 0, 18, 28),
                            itemCount: filtered.length,
                            itemBuilder: (context, index) {
                              final report = filtered[index];
                              return _HistoryTile(
                                report: report,
                                onOpen: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) => ReportScreen(
                                        report: report,
                                        autosave: false,
                                      ),
                                    ),
                                  );
                                },
                                onDelete: () => _delete(report),
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({
    required this.report,
    required this.onOpen,
    required this.onDelete,
  });

  final ResearchReport report;
  final VoidCallback onOpen;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      onTap: onOpen,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.mint,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.location_on_rounded, color: AppTheme.teal),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  report.normalizedAddress,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppTheme.navy,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    StatusPill(
                      label: _formatDate(report.createdAt),
                      color: AppTheme.muted,
                      icon: Icons.schedule_rounded,
                    ),
                    const StatusPill(
                      label: 'Local',
                      color: AppTheme.teal,
                      icon: Icons.storage_rounded,
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: '삭제',
            onPressed: () => _confirmDelete(context),
            icon: const Icon(Icons.delete_outline_rounded),
            color: AppTheme.muted,
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('이력 삭제'),
        content: const Text('이 분석 이력을 삭제할까요?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      onDelete();
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

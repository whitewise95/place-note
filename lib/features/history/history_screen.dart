import 'dart:io';

import 'package:flutter/material.dart';

import '../../app.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/status_pill.dart';
import '../../data/models/research_report.dart';
import '../../data/models/text_folder.dart';
import '../report/report_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({
    this.folder,
    super.key,
  });

  static const String routeName = '/history';

  final TextFolder? folder;

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
    final scopedReports = widget.folder == null
        ? reports
        : reports
            .where((report) => report.folderId == widget.folder!.id)
            .toList();

    if (keyword.isEmpty) {
      return scopedReports;
    }

    return scopedReports.where((report) {
      return report.normalizedAddress.toLowerCase().contains(keyword) ||
          report.rawAddress.toLowerCase().contains(keyword);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = filteredReports;

    return Scaffold(
      appBar: AppBar(title: Text(widget.folder?.name ?? '전체 텍스트')),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 12),
              child: TextField(
                controller: searchController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search_rounded),
                  hintText: '저장한 텍스트 검색',
                ),
              ),
            ),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filtered.isEmpty
                      ? const EmptyState(
                          title: '검색 결과가 없습니다',
                          message: '저장된 텍스트가 있으면 다시 찾을 수 있습니다.',
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

class _HistoryTile extends StatefulWidget {
  const _HistoryTile({
    required this.report,
    required this.onOpen,
    required this.onDelete,
  });

  final ResearchReport report;
  final VoidCallback onOpen;
  final VoidCallback onDelete;

  @override
  State<_HistoryTile> createState() => _HistoryTileState();
}

class _HistoryTileState extends State<_HistoryTile> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: AnimatedScale(
        scale: isHovered ? 1.01 : 1,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOut,
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: isHovered ? AppTheme.surfaceAlt : AppTheme.elevatedSurface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isHovered ? AppTheme.caramel : AppTheme.line,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.brown.withValues(alpha: isHovered ? 0.16 : 0.1),
                blurRadius: isHovered ? 24 : 16,
                offset: Offset(0, isHovered ? 12 : 8),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: widget.onOpen,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _HistoryThumb(report: widget.report),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.report.normalizedAddress,
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
                                label: _formatDate(widget.report.createdAt),
                                color: AppTheme.muted,
                                icon: Icons.schedule_rounded,
                              ),
                              const StatusPill(
                                label: 'Local',
                                color: AppTheme.sage,
                                icon: Icons.storage_rounded,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    _HoverActions(
                      isHovered: isHovered,
                      onOpen: widget.onOpen,
                      onDelete: () => _confirmDelete(context),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('텍스트 삭제'),
        content: const Text('이 저장 항목을 삭제할까요?'),
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
      widget.onDelete();
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class _HoverActions extends StatelessWidget {
  const _HoverActions({
    required this.isHovered,
    required this.onOpen,
    required this.onDelete,
  });

  final bool isHovered;
  final VoidCallback onOpen;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: isHovered ? 1 : 0.72,
      duration: const Duration(milliseconds: 140),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        padding: EdgeInsets.all(isHovered ? 4 : 0),
        decoration: BoxDecoration(
          color: isHovered ? AppTheme.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isHovered ? AppTheme.line : Colors.transparent,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 140),
              height: isHovered ? 40 : 0,
              child: ClipRect(
                child: AnimatedOpacity(
                  opacity: isHovered ? 1 : 0,
                  duration: const Duration(milliseconds: 100),
                  child: IconButton(
                    tooltip: '열기',
                    onPressed: onOpen,
                    icon: const Icon(Icons.open_in_new_rounded),
                    color: AppTheme.acorn,
                  ),
                ),
              ),
            ),
            IconButton(
              tooltip: '삭제',
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline_rounded),
              color: isHovered ? AppTheme.caramel : AppTheme.muted,
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryThumb extends StatelessWidget {
  const _HistoryThumb({required this.report});

  final ResearchReport report;

  @override
  Widget build(BuildContext context) {
    final path = report.imagePath;
    final hasImage = path != null && File(path).existsSync();

    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: AppTheme.surfaceAlt,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: hasImage
          ? Image.file(
              File(path),
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.text_snippet_rounded,
                color: AppTheme.acorn,
              ),
            )
          : const Icon(Icons.text_snippet_rounded, color: AppTheme.acorn),
    );
  }
}

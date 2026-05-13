import 'dart:io';

import 'package:flutter/material.dart';

import '../../app.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/status_pill.dart';
import '../../data/models/research_report.dart';
import '../history/history_screen.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({
    required this.report,
    this.autosave = true,
    super.key,
  });

  final ResearchReport report;
  final bool autosave;

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  late ResearchReport report;
  bool isSaving = false;
  bool isSaved = false;

  @override
  void initState() {
    super.initState();
    report = widget.report;
    isSaved = report.isSaved || !widget.autosave;
    if (widget.autosave) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _save());
    }
  }

  Future<void> _save() async {
    setState(() => isSaving = true);
    await RepositoryScope.of(context).save(report);
    if (!mounted) {
      return;
    }

    setState(() {
      isSaving = false;
      isSaved = true;
      report = report.copyWith(isSaved: true);
    });
  }

  Future<void> _openHistory() async {
    await Navigator.of(context).pushNamed(HistoryScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('저장된 텍스트'),
        actions: [
          IconButton(
            tooltip: '저장 목록',
            onPressed: _openHistory,
            icon: const Icon(Icons.history_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 32),
          children: [
            _AddressHeader(
                report: report, isSaved: isSaved, isSaving: isSaving),
            if (report.imagePath != null &&
                File(report.imagePath!).existsSync()) ...[
              const SizedBox(height: 14),
              _SavedImagePreview(imagePath: report.imagePath!),
            ],
            const SizedBox(height: 20),
            if (!isSaved)
              ElevatedButton.icon(
                onPressed: isSaving ? null : _save,
                icon: const Icon(Icons.save_rounded),
                label: const Text('폴더에 저장'),
              )
            else
              OutlinedButton.icon(
                onPressed: _openHistory,
                icon: const Icon(Icons.folder_copy_rounded),
                label: const Text('저장 목록 보기'),
              ),
          ],
        ),
      ),
    );
  }
}

class _SavedImagePreview extends StatelessWidget {
  const _SavedImagePreview({required this.imagePath});

  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => _openImageViewer(context),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: AspectRatio(
            aspectRatio: 4 / 3,
            child: DecoratedBox(
              decoration: const BoxDecoration(color: AppTheme.surfaceAlt),
              child: Image.file(
                File(imagePath),
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _openImageViewer(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(14),
          backgroundColor: AppTheme.brown,
          child: SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.82,
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: InteractiveViewer(
                      minScale: 0.8,
                      maxScale: 4,
                      child: Center(
                        child: Image.file(
                          File(imagePath),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: IconButton.filled(
                    tooltip: '닫기',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AddressHeader extends StatelessWidget {
  const _AddressHeader({
    required this.report,
    required this.isSaved,
    required this.isSaving,
  });

  final ResearchReport report;
  final bool isSaved;
  final bool isSaving;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              const StatusPill(
                label: '선택 텍스트',
                color: AppTheme.teal,
                icon: Icons.text_snippet_rounded,
              ),
              StatusPill(
                label: isSaving ? '저장 중' : (isSaved ? '로컬 저장 완료' : '저장 대기'),
                color: isSaved ? AppTheme.sage : AppTheme.caramel,
                icon: isSaved
                    ? Icons.check_circle_rounded
                    : Icons.schedule_rounded,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            report.normalizedAddress,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: AppTheme.navy,
                  height: 1.25,
                ),
          ),
          if (report.detailAddress != null) ...[
            const SizedBox(height: 4),
            Text(
              report.detailAddress!,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.acorn,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ],
          const SizedBox(height: 12),
          Text(
            '생성일 ${_formatDate(report.createdAt)}',
            style: const TextStyle(color: AppTheme.muted),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

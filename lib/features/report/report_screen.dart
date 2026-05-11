import 'dart:io';

import 'package:flutter/material.dart';

import '../../app.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/section_title.dart';
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
            const SizedBox(height: 22),
            const SectionTitle('원문 정보'),
            const SizedBox(height: 10),
            ...report.summaryCards.map((card) => _SummaryCardTile(card: card)),
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: AspectRatio(
          aspectRatio: 4 / 3,
          child: Image.file(
            File(imagePath),
            fit: BoxFit.cover,
          ),
        ),
      ),
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
                color: isSaved ? AppTheme.navy : const Color(0xFFB45309),
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
                    color: AppTheme.teal,
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

class _SummaryCardTile extends StatelessWidget {
  const _SummaryCardTile({required this.card});

  final SummaryCard card;

  @override
  Widget build(BuildContext context) {
    final isTodo = card.status == 'server_todo';
    return AppCard(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isTodo ? const Color(0xFFF8FAFC) : AppTheme.mint,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.line),
            ),
            child: Icon(
              isTodo ? Icons.cloud_sync_rounded : Icons.check_circle_rounded,
              color: isTodo ? AppTheme.muted : AppTheme.teal,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        card.title,
                        style: const TextStyle(
                          color: AppTheme.navy,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    StatusPill(
                      label: isTodo ? 'Server TODO' : 'Mock',
                      color: isTodo ? AppTheme.amber : AppTheme.teal,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  card.value,
                  style: TextStyle(
                    color: isTodo ? AppTheme.amber : AppTheme.teal,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  card.description,
                  style: const TextStyle(
                    color: AppTheme.muted,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../app.dart';
import '../core/theme/app_theme.dart';
import '../core/widgets/app_card.dart';
import '../core/widgets/empty_state.dart';
import '../core/widgets/section_title.dart';
import '../core/widgets/status_pill.dart';
import '../data/mock/mock_ocr_service.dart';
import '../data/models/research_report.dart';
import 'capture/capture_screen.dart';
import 'extraction/extraction_screen.dart';
import 'history/history_screen.dart';
import 'report/report_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const String routeName = '/';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<ResearchReport>> historiesFuture;
  bool hasLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!hasLoaded) {
      hasLoaded = true;
      historiesFuture = _loadHistories();
    }
  }

  Future<List<ResearchReport>> _loadHistories() {
    return RepositoryScope.of(context).findHistories();
  }

  void _refresh() {
    setState(() {
      historiesFuture = _loadHistories();
    });
  }

  Future<void> _openCapture() async {
    await Navigator.of(context).pushNamed(CaptureScreen.routeName);
    _refresh();
  }

  Future<void> _startSample() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const ExtractionScreen(imagePath: MockOcrSource.sample),
      ),
    );
    _refresh();
  }

  Future<void> _openHistory() async {
    await Navigator.of(context).pushNamed(HistoryScreen.routeName);
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('주소 분석 앱'),
        actions: [
          IconButton(
            tooltip: '이력',
            onPressed: _openHistory,
            icon: const Icon(Icons.history_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => _refresh(),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 32),
            children: [
              _HeroPanel(onStart: _openCapture, onSample: _startSample),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SectionTitle('최근 분석'),
                  TextButton.icon(
                    onPressed: _openHistory,
                    icon: const Icon(Icons.search_rounded, size: 18),
                    label: const Text('전체 보기'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              FutureBuilder<List<ResearchReport>>(
                future: historiesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 36),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final histories = snapshot.data ?? [];
                  if (histories.isEmpty) {
                    return EmptyState(
                      title: '저장된 분석이 없습니다',
                      message: '샘플 데이터로 먼저 앱 흐름을 확인할 수 있습니다.',
                      action: OutlinedButton.icon(
                        onPressed: _startSample,
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: const Text('샘플로 시작'),
                      ),
                    );
                  }

                  return Column(
                    children: histories.take(5).map((report) {
                      return _RecentReportTile(
                        report: report,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => ReportScreen(
                                report: report,
                                autosave: false,
                              ),
                            ),
                          );
                        },
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroPanel extends StatelessWidget {
  const _HeroPanel({
    required this.onStart,
    required this.onSample,
  });

  final VoidCallback onStart;
  final VoidCallback onSample;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              StatusPill(
                label: 'Flutter Local MVP',
                color: AppTheme.teal,
                icon: Icons.offline_bolt_rounded,
              ),
              Spacer(),
              Icon(Icons.apartment_rounded, color: AppTheme.navy),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            '캡쳐 이미지에서 주소를 찾아드려요',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppTheme.navy,
                  height: 1.22,
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 10),
          Text(
            '이미지를 선택하면 Mock OCR로 주소 후보를 추출하고 자료 카드를 로컬에 저장합니다.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.muted,
                  height: 1.5,
                ),
          ),
          const SizedBox(height: 18),
          const Divider(),
          const SizedBox(height: 14),
          const Row(
            children: [
              _Metric(label: 'Mock OCR', value: 'ON'),
              SizedBox(width: 12),
              _Metric(label: '저장소', value: 'Local'),
              SizedBox(width: 12),
              _Metric(label: '서버', value: 'TODO'),
            ],
          ),
          const SizedBox(height: 18),
          ElevatedButton.icon(
            onPressed: onStart,
            icon: const Icon(Icons.add_a_photo_rounded),
            label: const Text('새 분석 시작'),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: onSample,
            icon: const Icon(Icons.auto_awesome_rounded),
            label: const Text('샘플 데이터로 시작'),
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppTheme.navy,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppTheme.muted,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentReportTile extends StatelessWidget {
  const _RecentReportTile({
    required this.report,
    required this.onTap,
  });

  final ResearchReport report;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: ListTile(
        leading: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppTheme.mint,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.location_on_rounded, color: AppTheme.teal),
        ),
        title: Text(
          report.normalizedAddress,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        subtitle: Text(
          _formatDate(report.createdAt),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: AppTheme.muted),
        ),
        trailing: const Icon(Icons.chevron_right_rounded, color: AppTheme.muted),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

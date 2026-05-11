import 'package:flutter/material.dart';

import '../app.dart';
import '../core/theme/app_theme.dart';
import '../core/widgets/app_card.dart';
import '../core/widgets/empty_state.dart';
import '../core/widgets/section_title.dart';
import '../data/models/research_report.dart';
import '../data/models/text_folder.dart';
import '../data/ocr/mock_ocr_service.dart';
import 'capture/capture_screen.dart';
import 'extraction/extraction_screen.dart';
import 'history/history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const String routeName = '/';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<_HomeData> homeFuture;
  bool hasLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!hasLoaded) {
      hasLoaded = true;
      homeFuture = _loadHome();
    }
  }

  Future<_HomeData> _loadHome() async {
    final repository = RepositoryScope.of(context);
    final results = await Future.wait([
      repository.findFolders(),
      repository.findHistories(),
    ]);
    return _HomeData(
      folders: results[0] as List<TextFolder>,
      reports: results[1] as List<ResearchReport>,
    );
  }

  void _refresh() {
    setState(() {
      homeFuture = _loadHome();
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

  Future<void> _openFolder(TextFolder folder) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => HistoryScreen(folder: folder),
      ),
    );
    _refresh();
  }

  Future<void> _createFolder() async {
    final name = await _requestFolderName(title: '새 폴더');
    if (name == null || name.trim().isEmpty || !mounted) {
      return;
    }

    await RepositoryScope.of(context).createFolder(name);
    _refresh();
  }

  Future<void> _renameFolder(TextFolder folder) async {
    final name = await _requestFolderName(
      title: '폴더 이름 변경',
      initialValue: folder.name,
    );
    if (name == null || name.trim().isEmpty || !mounted) {
      return;
    }

    await RepositoryScope.of(context).renameFolder(folder, name);
    _refresh();
  }

  Future<void> _deleteFolder(TextFolder folder) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('폴더 삭제'),
        content: Text(
          '"${folder.name}" 폴더를 삭제할까요?\n저장된 텍스트는 기본 보관함으로 이동합니다.',
        ),
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

    if (confirmed == true && mounted) {
      await RepositoryScope.of(context).deleteFolder(folder.id);
      _refresh();
    }
  }

  Future<String?> _requestFolderName({
    required String title,
    String initialValue = '',
  }) async {
    final controller = TextEditingController(text: initialValue);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: '폴더 이름',
            hintText: '예: 맛집, 부동산, 여행',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('저장'),
          ),
        ],
      ),
    );
    controller.dispose();
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Place Note'),
        actions: [
          IconButton(
            tooltip: '새 폴더',
            onPressed: _createFolder,
            icon: const Icon(Icons.create_new_folder_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => _refresh(),
          child: FutureBuilder<_HomeData>(
            future: homeFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final data = snapshot.data ?? _HomeData.empty();
              return ListView(
                padding: const EdgeInsets.fromLTRB(18, 10, 18, 32),
                children: [
                  _HeroPanel(
                    totalFolders: data.folders.length,
                    totalReports: data.reports.length,
                    onCapture: _openCapture,
                    onSample: _startSample,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SectionTitle('폴더'),
                      TextButton.icon(
                        onPressed: _createFolder,
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: const Text('추가'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (data.folders.isEmpty)
                    EmptyState(
                      title: '폴더가 없습니다',
                      message: '폴더를 만들고 캡쳐 텍스트를 정리해보세요.',
                      action: OutlinedButton.icon(
                        onPressed: _createFolder,
                        icon: const Icon(Icons.create_new_folder_rounded),
                        label: const Text('폴더 만들기'),
                      ),
                    )
                  else
                    ...data.folders.map(
                      (folder) => _FolderTile(
                        folder: folder,
                        count: data.countFor(folder.id),
                        latest: data.latestFor(folder.id),
                        onOpen: () => _openFolder(folder),
                        onRename: folder.id == TextFolder.inboxId
                            ? null
                            : () => _renameFolder(folder),
                        onDelete: folder.id == TextFolder.inboxId
                            ? null
                            : () => _deleteFolder(folder),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _HomeData {
  const _HomeData({
    required this.folders,
    required this.reports,
  });

  factory _HomeData.empty() {
    return const _HomeData(folders: [], reports: []);
  }

  final List<TextFolder> folders;
  final List<ResearchReport> reports;

  int countFor(String folderId) {
    return reports.where((report) => report.folderId == folderId).length;
  }

  ResearchReport? latestFor(String folderId) {
    final items = reports.where((report) => report.folderId == folderId);
    return items.isEmpty ? null : items.first;
  }
}

class _HeroPanel extends StatelessWidget {
  const _HeroPanel({
    required this.totalFolders,
    required this.totalReports,
    required this.onCapture,
    required this.onSample,
  });

  final int totalFolders;
  final int totalReports;
  final VoidCallback onCapture;
  final VoidCallback onSample;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.folder_special_rounded, color: AppTheme.teal),
          const SizedBox(height: 16),
          Text(
            '캡쳐와 복사 텍스트를 폴더에 모아두세요',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppTheme.navy,
                  height: 1.22,
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 10),
          Text(
            '사진 속 글자를 OCR로 읽고, 필요한 문장을 골라 폴더별 노트로 저장합니다.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.muted,
                  height: 1.5,
                ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _Metric(label: '폴더', value: '$totalFolders'),
              const SizedBox(width: 12),
              _Metric(label: '저장 항목', value: '$totalReports'),
              const SizedBox(width: 12),
              const _Metric(label: '저장소', value: 'Local'),
            ],
          ),
          const SizedBox(height: 18),
          ElevatedButton.icon(
            onPressed: onCapture,
            icon: const Icon(Icons.add_photo_alternate_rounded),
            label: const Text('캡쳐 텍스트 저장'),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: onSample,
            icon: const Icon(Icons.auto_awesome_rounded),
            label: const Text('샘플로 흐름 보기'),
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

class _FolderTile extends StatelessWidget {
  const _FolderTile({
    required this.folder,
    required this.count,
    required this.latest,
    required this.onOpen,
    required this.onRename,
    required this.onDelete,
  });

  final TextFolder folder;
  final int count;
  final ResearchReport? latest;
  final VoidCallback onOpen;
  final VoidCallback? onRename;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      onTap: onOpen,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.mint,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.folder_rounded, color: AppTheme.teal),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  folder.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppTheme.navy,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  latest?.normalizedAddress ?? '아직 저장된 텍스트가 없습니다',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppTheme.muted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$count',
            style: const TextStyle(
              color: AppTheme.teal,
              fontWeight: FontWeight.w900,
            ),
          ),
          PopupMenuButton<String>(
            tooltip: '폴더 관리',
            onSelected: (value) {
              if (value == 'rename') {
                onRename?.call();
              } else if (value == 'delete') {
                onDelete?.call();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem<String>(
                value: 'rename',
                enabled: onRename != null,
                child: const Text('이름 변경'),
              ),
              PopupMenuItem<String>(
                value: 'delete',
                enabled: onDelete != null,
                child: const Text('삭제'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

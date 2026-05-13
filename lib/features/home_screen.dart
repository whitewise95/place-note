import 'package:flutter/material.dart';

import '../app.dart';
import '../core/theme/app_theme.dart';
import '../core/widgets/app_card.dart';
import '../core/widgets/dot_mark.dart';
import '../core/widgets/empty_state.dart';
import '../core/widgets/folder_name_dialog.dart';
import '../core/widgets/section_title.dart';
import '../data/models/research_report.dart';
import '../data/models/text_folder.dart';
import 'capture/capture_screen.dart';
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
    return showDialog<String>(
      context: context,
      builder: (context) => FolderNameDialog(
        title: title,
        initialValue: initialValue,
        confirmLabel: '저장',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            DotMark(size: 30),
            SizedBox(width: 10),
            Text('Place Note'),
          ],
        ),
        actions: [
          IconButton(
            tooltip: '새 폴더',
            onPressed: _createFolder,
            icon: const Icon(Icons.create_new_folder_rounded),
          ),
        ],
      ),
      floatingActionButton: _CaptureFloatingButton(onPressed: _openCapture),
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

class _CaptureFloatingButton extends StatefulWidget {
  const _CaptureFloatingButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  State<_CaptureFloatingButton> createState() => _CaptureFloatingButtonState();
}

class _CaptureFloatingButtonState extends State<_CaptureFloatingButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;
  late final Animation<double> floatOffset;
  late final Animation<double> shadowLift;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1900),
    )..repeat(reverse: true);
    final curve = CurvedAnimation(parent: controller, curve: Curves.easeInOut);
    floatOffset = Tween<double>(begin: 0, end: -7).animate(curve);
    shadowLift = Tween<double>(begin: 0, end: 1).animate(curve);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final lift = shadowLift.value;
        return Transform.translate(
          offset: Offset(0, floatOffset.value),
          child: Container(
            width: 74,
            height: 74,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.brown.withValues(alpha: 0.22 + lift * 0.04),
                  blurRadius: 28 + lift * 8,
                  offset: Offset(0, 18 + lift * 5),
                ),
                BoxShadow(
                  color: AppTheme.caramel.withValues(alpha: 0.14 + lift * 0.08),
                  blurRadius: 16 + lift * 8,
                  offset: Offset(0, 4 + lift * 2),
                ),
              ],
            ),
            child: child,
          ),
        );
      },
      child: FloatingActionButton.large(
        heroTag: 'captureTextFab',
        tooltip: '사진 속 글자 읽기',
        elevation: 0,
        highlightElevation: 0,
        backgroundColor: AppTheme.brown,
        foregroundColor: AppTheme.surface,
        shape: const CircleBorder(),
        onPressed: widget.onPressed,
        child: const DotMark(size: 36),
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
      padding: EdgeInsets.zero,
      onTap: onOpen,
      child: Stack(
        children: [
          Positioned(
            left: 14,
            top: 0,
            child: Container(
              width: 58,
              height: 10,
              decoration: const BoxDecoration(
                color: AppTheme.surfaceAlt,
                borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 16, 8, 14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceAlt,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.line),
                  ),
                  child:
                      const Icon(Icons.folder_rounded, color: AppTheme.acorn),
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
                          color: AppTheme.brown,
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
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceAlt,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '$count',
                    style: const TextStyle(
                      color: AppTheme.acorn,
                      fontWeight: FontWeight.w900,
                    ),
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
          ),
        ],
      ),
    );
  }
}

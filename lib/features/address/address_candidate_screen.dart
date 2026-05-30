import 'dart:io';

import 'package:flutter/material.dart';

import '../../app.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/folder_name_dialog.dart';
import '../../core/widgets/section_title.dart';
import '../../data/models/extraction_result.dart';
import '../../data/models/research_report.dart';
import '../../data/models/text_folder.dart';
import '../../data/repositories/address_candidate_extractor.dart';
import 'address_save_flow.dart';
import '../report/report_screen.dart';

class AddressCandidateScreen extends StatefulWidget {
  const AddressCandidateScreen({
    required this.result,
    this.returnToWebAfterSave = false,
    super.key,
  });

  final ExtractionResult result;
  final bool returnToWebAfterSave;

  @override
  State<AddressCandidateScreen> createState() => _AddressCandidateScreenState();
}

class _AddressCandidateScreenState extends State<AddressCandidateScreen> {
  late final TextEditingController manualController;
  late final List<String> ocrLines;
  late final List<String> ocrWords;
  final selectedOcrParts = <String>{};
  List<TextFolder> folders = [TextFolder.inbox()];
  String selectedFolderId = TextFolder.inboxId;
  bool isCreating = false;
  bool isLoadingFolders = true;
  bool showOcrWords = false;
  bool hasLoadedFolders = false;

  @override
  void initState() {
    super.initState();
    manualController = TextEditingController();
    ocrLines = _extractOcrLines(widget.result.ocrText);
    ocrWords = _extractOcrWords(widget.result.ocrText);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!hasLoadedFolders) {
      hasLoadedFolders = true;
      _loadFolders();
    }
  }

  @override
  void dispose() {
    manualController.dispose();
    super.dispose();
  }

  Future<void> _createReport() async {
    final candidate =
        AddressCandidateExtractor.fromManualInput(manualController.text);

    if (candidate.rawText.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('저장할 텍스트를 입력하거나 OCR 글자를 선택해주세요.')),
      );
      return;
    }

    setState(() => isCreating = true);
    final repository = RepositoryScope.of(context);
    late final ResearchReport report;
    try {
      report = await createAndSaveSelectedTextReport(
        repository: repository,
        candidate: candidate,
        imagePath: widget.result.imagePath,
        ocrText: widget.result.ocrText,
        folderId: selectedFolderId,
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() => isCreating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('저장에 실패했습니다. 잠시 뒤 다시 시도해주세요.')),
      );
      return;
    }

    if (!mounted) {
      return;
    }

    if (widget.returnToWebAfterSave) {
      Navigator.of(context).pop(report.id);
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => ReportScreen(report: report, autosave: false),
      ),
    );
  }

  Future<void> _loadFolders() async {
    final loaded = await RepositoryScope.of(context).findFolders();
    if (!mounted) {
      return;
    }

    setState(() {
      folders = loaded;
      selectedFolderId = loaded.any((folder) => folder.id == selectedFolderId)
          ? selectedFolderId
          : TextFolder.inboxId;
      isLoadingFolders = false;
    });
  }

  Future<void> _createFolder() async {
    final name = await showDialog<String>(
      context: context,
      builder: (context) => const FolderNameDialog(
        title: '새 폴더',
        confirmLabel: '생성',
      ),
    );

    if (name == null || name.trim().isEmpty || !mounted) {
      return;
    }

    final folder = await RepositoryScope.of(context).createFolder(name);
    if (!mounted) {
      return;
    }

    setState(() {
      folders = [...folders, folder];
      selectedFolderId = folder.id;
    });
  }

  void _toggleOcrPart(String part) {
    setState(() {
      if (!selectedOcrParts.add(part)) {
        selectedOcrParts.remove(part);
      }
      manualController.text = _selectedOcrText();
      manualController.selection = TextSelection.collapsed(
        offset: manualController.text.length,
      );
    });
  }

  void _clearOcrSelection() {
    setState(() {
      selectedOcrParts.clear();
      manualController.clear();
    });
  }

  void _openSourceViewer() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (context) {
        return _SourceViewerSheet(
          imagePath: widget.result.imagePath,
          ocrText: widget.result.ocrText,
        );
      },
    );
  }

  String _selectedOcrText() {
    final orderedParts = <String>[
      ...ocrLines.where(selectedOcrParts.contains),
      ...ocrWords.where(selectedOcrParts.contains),
    ];
    return orderedParts.join(' ').replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('텍스트 저장')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 32),
          children: [
            const SectionTitle('저장할 텍스트'),
            const SizedBox(height: 10),
            AppCard(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      '사진과 OCR 원문은 별도 화면에서 확인할 수 있습니다.',
                      style: TextStyle(
                        color: AppTheme.muted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _openSourceViewer,
                    icon: const Icon(Icons.visibility_rounded),
                    label: const Text('원문 보기'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _FolderPickerCard(
              folders: folders,
              selectedFolderId: selectedFolderId,
              isLoading: isLoadingFolders,
              onChanged: (value) => setState(() => selectedFolderId = value),
              onCreate: _createFolder,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: manualController,
              minLines: 1,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: '저장할 문장',
                hintText: '직접 입력하거나 아래 OCR 조각을 선택하세요',
              ),
            ),
            const SizedBox(height: 18),
            _OcrSelectionCard(
              lines: ocrLines,
              words: ocrWords,
              selectedParts: selectedOcrParts,
              showWords: showOcrWords,
              onModeChanged: (value) => setState(() => showOcrWords = value),
              onPartSelected: _toggleOcrPart,
              onClear: selectedOcrParts.isEmpty ? null : _clearOcrSelection,
            ),
            const SizedBox(height: 12),
            AppCard(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  const Icon(
                    Icons.touch_app_rounded,
                    color: AppTheme.acorn,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      selectedOcrParts.isEmpty
                          ? 'OCR 조각을 누르면 저장 문장에 조합됩니다.'
                          : '${selectedOcrParts.length}개 글자 조각 선택됨',
                      style: const TextStyle(
                        color: AppTheme.muted,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: isCreating ? null : _createReport,
              icon: isCreating
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.archive_rounded),
              label: Text(isCreating ? '주소 확인 중' : '폴더에 저장하기'),
            ),
          ],
        ),
      ),
    );
  }

  List<String> _extractOcrLines(String text) {
    final seen = <String>{};
    return text
        .split(RegExp(r'\r?\n'))
        .map(_cleanOcrPart)
        .where((part) => part.length >= 2)
        .where(seen.add)
        .toList();
  }

  List<String> _extractOcrWords(String text) {
    final seen = <String>{};
    return text
        .split(RegExp(r'[\s\n\r]+'))
        .map(_cleanOcrPart)
        .where((part) => part.length >= 2)
        .where((part) => !RegExp(r'^https?://|^www\.').hasMatch(part))
        .where(seen.add)
        .toList();
  }

  String _cleanOcrPart(String value) {
    return value
        .replaceAll(RegExp(r'^[^\w가-힣]+|[^\w가-힣\-]+$'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}

class _FolderPickerCard extends StatelessWidget {
  const _FolderPickerCard({
    required this.folders,
    required this.selectedFolderId,
    required this.isLoading,
    required this.onChanged,
    required this.onCreate,
  });

  final List<TextFolder> folders;
  final String selectedFolderId;
  final bool isLoading;
  final ValueChanged<String> onChanged;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  '저장 폴더',
                  style: TextStyle(
                    color: AppTheme.navy,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: onCreate,
                icon: const Icon(Icons.create_new_folder_rounded),
                label: const Text('새 폴더'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (isLoading)
            const LinearProgressIndicator()
          else
            DropdownButtonFormField<String>(
              initialValue: selectedFolderId,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.folder_rounded),
              ),
              items: folders
                  .map(
                    (folder) => DropdownMenuItem<String>(
                      value: folder.id,
                      child: Text(folder.name),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  onChanged(value);
                }
              },
            ),
        ],
      ),
    );
  }
}

class _SourceViewerSheet extends StatelessWidget {
  const _SourceViewerSheet({
    required this.imagePath,
    required this.ocrText,
  });

  final String? imagePath;
  final String ocrText;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: DefaultTabController(
        length: 2,
        child: SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.82,
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.line,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 10),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 18),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '원문 보기',
                        style: TextStyle(
                          color: AppTheme.ink,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const TabBar(
                tabs: [
                  Tab(icon: Icon(Icons.image_rounded), text: '사진'),
                  Tab(icon: Icon(Icons.text_snippet_rounded), text: 'OCR 글'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _ImagePreview(imagePath: imagePath),
                    _OcrTextPreview(ocrText: ocrText),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImagePreview extends StatelessWidget {
  const _ImagePreview({required this.imagePath});

  final String? imagePath;

  @override
  Widget build(BuildContext context) {
    final path = imagePath;
    if (path == null || path.isEmpty || !File(path).existsSync()) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            '첨부된 사진을 찾을 수 없습니다.',
            style: TextStyle(color: AppTheme.muted),
          ),
        ),
      );
    }

    return InteractiveViewer(
      minScale: 0.8,
      maxScale: 4,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Image.file(
            File(path),
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

class _OcrTextPreview extends StatelessWidget {
  const _OcrTextPreview({required this.ocrText});

  final String ocrText;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: SelectableText(
        ocrText.trim(),
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              height: 1.5,
              color: AppTheme.ink,
            ),
      ),
    );
  }
}

class _OcrSelectionCard extends StatelessWidget {
  const _OcrSelectionCard({
    required this.lines,
    required this.words,
    required this.selectedParts,
    required this.showWords,
    required this.onModeChanged,
    required this.onPartSelected,
    required this.onClear,
  });

  final List<String> lines;
  final List<String> words;
  final Set<String> selectedParts;
  final bool showWords;
  final ValueChanged<bool> onModeChanged;
  final ValueChanged<String> onPartSelected;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final parts = showWords ? words : lines;
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'OCR 글자 선택',
                  style: TextStyle(
                    color: AppTheme.navy,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              IconButton(
                tooltip: '선택 초기화',
                onPressed: onClear,
                icon: const Icon(Icons.refresh_rounded),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment<bool>(
                value: false,
                icon: Icon(Icons.subject_rounded),
                label: Text('줄'),
              ),
              ButtonSegment<bool>(
                value: true,
                icon: Icon(Icons.short_text_rounded),
                label: Text('단어'),
              ),
            ],
            selected: {showWords},
            onSelectionChanged: (values) => onModeChanged(values.first),
          ),
          const SizedBox(height: 12),
          if (parts.isEmpty)
            const Text(
              '선택할 OCR 텍스트가 없습니다.',
              style: TextStyle(color: AppTheme.muted),
            )
          else
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 240),
              child: Scrollbar(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(right: 8, bottom: 2),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: parts
                        .map(
                          (part) => FilterChip(
                            label: Text(part),
                            selected: selectedParts.contains(part),
                            onSelected: (_) => onPartSelected(part),
                            selectedColor: AppTheme.mint,
                            checkmarkColor: AppTheme.brown,
                            side: BorderSide(
                              color: selectedParts.contains(part)
                                  ? AppTheme.caramel.withValues(alpha: 0.42)
                                  : AppTheme.line,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../app.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/section_title.dart';
import '../../core/widgets/status_pill.dart';
import '../../data/models/address_candidate.dart';
import '../../data/models/extraction_result.dart';
import '../../data/repositories/address_candidate_extractor.dart';
import '../report/report_screen.dart';

class AddressCandidateScreen extends StatefulWidget {
  const AddressCandidateScreen({
    required this.result,
    super.key,
  });

  final ExtractionResult result;

  @override
  State<AddressCandidateScreen> createState() => _AddressCandidateScreenState();
}

class _AddressCandidateScreenState extends State<AddressCandidateScreen> {
  AddressCandidate? selected;
  late final TextEditingController manualController;
  late final List<String> ocrLines;
  late final List<String> ocrWords;
  final selectedOcrParts = <String>{};
  bool useManualInput = false;
  bool isCreating = false;
  bool showOcrWords = false;

  @override
  void initState() {
    super.initState();
    selected = widget.result.candidates.isEmpty
        ? null
        : widget.result.candidates.first;
    manualController = TextEditingController();
    ocrLines = _extractOcrLines(widget.result.ocrText);
    ocrWords = _extractOcrWords(widget.result.ocrText);
    useManualInput = widget.result.candidates.isEmpty;
  }

  @override
  void dispose() {
    manualController.dispose();
    super.dispose();
  }

  Future<void> _createReport() async {
    final candidate = useManualInput
        ? AddressCandidateExtractor.fromManualInput(manualController.text)
        : selected;

    if (candidate == null || candidate.rawText.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('분석할 주소를 입력하거나 후보를 선택해주세요.')),
      );
      return;
    }

    setState(() => isCreating = true);
    final repository = RepositoryScope.of(context);
    final report = await repository.createReport(
      candidate: candidate,
      imagePath: widget.result.imagePath,
      ocrText: widget.result.ocrText,
    );

    if (!mounted) {
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => ReportScreen(report: report),
      ),
    );
  }

  void _toggleOcrPart(String part) {
    setState(() {
      useManualInput = true;
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
      useManualInput = widget.result.candidates.isEmpty;
    });
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
      appBar: AppBar(title: const Text('주소 후보')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 32),
          children: [
            const SectionTitle('OCR 원문'),
            const SizedBox(height: 10),
            AppCard(
              child: Padding(
                padding: EdgeInsets.zero,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const StatusPill(
                      label: 'Mock OCR',
                      color: AppTheme.navy,
                      icon: Icons.document_scanner_rounded,
                    ),
                    const SizedBox(height: 12),
                    SelectableText(
                      widget.result.ocrText.trim(),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            height: 1.5,
                            color: AppTheme.ink,
                          ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 22),
            const SectionTitle('자동 후보'),
            const SizedBox(height: 10),
            if (widget.result.candidates.isEmpty)
              const AppCard(
                child: Padding(
                  padding: EdgeInsets.zero,
                  child: Text('자동 추출된 주소가 없습니다. 직접 입력으로 분석을 시작하세요.'),
                ),
              )
            else
              ...widget.result.candidates.map(_candidateTile),
            const SizedBox(height: 12),
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
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                title: const Text(
                  '직접 입력하기',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                subtitle: const Text(
                  '후보를 수정하거나 주소를 직접 입력합니다.',
                  style: TextStyle(color: AppTheme.muted),
                ),
                value: useManualInput,
                onChanged: (value) => setState(() => useManualInput = value),
              ),
            ),
            if (useManualInput) ...[
              const SizedBox(height: 8),
              TextField(
                controller: manualController,
                minLines: 1,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: '주소 입력',
                  hintText: '예: 서울 강남구 테헤란로 123 301호',
                ),
              ),
            ],
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: isCreating ? null : _createReport,
              icon: isCreating
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.analytics_rounded),
              label: const Text('이 주소로 분석하기'),
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

  Widget _candidateTile(AddressCandidate candidate) {
    final isSelected = selected?.id == candidate.id && !useManualInput;
    return AppCard(
      margin: const EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.zero,
      child: RadioListTile<AddressCandidate>(
        activeColor: AppTheme.teal,
        value: candidate,
        groupValue: selected,
        onChanged: (value) {
          setState(() {
            selected = value;
            useManualInput = false;
          });
        },
        title: Text(
          candidate.normalizedAddress,
          style: const TextStyle(
            color: AppTheme.navy,
            fontWeight: FontWeight.w900,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 7),
          child: Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _Badge(label: '추정 주소', active: isSelected),
              _Badge(label: '신뢰도 ${candidate.confidence}%', active: isSelected),
              if (candidate.detailAddress != null)
                _Badge(label: candidate.detailAddress!, active: isSelected),
            ],
          ),
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
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: parts
                  .map(
                    (part) => FilterChip(
                      label: Text(part),
                      selected: selectedParts.contains(part),
                      onSelected: (_) => onPartSelected(part),
                      selectedColor: AppTheme.mint,
                      checkmarkColor: AppTheme.teal,
                      side: BorderSide(
                        color: selectedParts.contains(part)
                            ? AppTheme.teal.withOpacity(0.25)
                            : AppTheme.line,
                      ),
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.label,
    required this.active,
  });

  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: active ? AppTheme.mint : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: active ? AppTheme.teal.withOpacity(0.16) : AppTheme.line,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: active ? AppTheme.teal : AppTheme.muted,
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

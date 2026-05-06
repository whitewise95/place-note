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
  bool useManualInput = false;
  bool isCreating = false;

  @override
  void initState() {
    super.initState();
    selected = widget.result.candidates.isEmpty ? null : widget.result.candidates.first;
    manualController = TextEditingController();
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
                    Text(
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

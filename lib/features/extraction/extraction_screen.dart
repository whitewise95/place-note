import 'package:flutter/material.dart';

import '../../app.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/status_pill.dart';
import '../../data/models/extraction_result.dart';
import '../../data/models/text_folder.dart';
import '../../data/ocr/mock_ocr_service.dart';
import '../address/address_candidate_screen.dart';
import '../address/address_save_flow.dart';
import '../report/report_screen.dart';

class ExtractionScreen extends StatefulWidget {
  const ExtractionScreen({
    required this.imagePath,
    this.returnToWebAfterSave = false,
    super.key,
  });

  final String? imagePath;
  final bool returnToWebAfterSave;

  @override
  State<ExtractionScreen> createState() => _ExtractionScreenState();
}

class _ExtractionScreenState extends State<ExtractionScreen> {
  bool hasStarted = false;
  bool isLoading = true;
  String? errorMessage;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!hasStarted) {
      hasStarted = true;
      _extract();
    }
  }

  Future<void> _extract() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final repository = RepositoryScope.of(context);
    try {
      final result = await repository.extractCandidates(widget.imagePath);
      if (!mounted) {
        return;
      }

      await Future<void>.delayed(const Duration(milliseconds: 350));
      if (!mounted) {
        return;
      }

      await _openNext(result);
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        isLoading = false;
        errorMessage = '$error';
      });
    }
  }

  void _startSample() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => ExtractionScreen(
          imagePath: MockOcrSource.sample,
          returnToWebAfterSave: widget.returnToWebAfterSave,
        ),
      ),
    );
  }

  Future<void> _openNext(ExtractionResult result) async {
    final canAutoSelect = widget.imagePath == MockOcrSource.sample &&
        result.candidates.length == 1 &&
        result.candidates.first.confidence >= 90;

    if (canAutoSelect) {
      final repository = RepositoryScope.of(context);
      final report = await createAndSaveSelectedTextReport(
        repository: repository,
        candidate: result.candidates.first,
        imagePath: result.imagePath,
        ocrText: result.ocrText,
        folderId: TextFolder.inboxId,
      );

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
      return;
    }

    if (widget.returnToWebAfterSave) {
      final reportId = await Navigator.of(context).push<String>(
        MaterialPageRoute<String>(
          builder: (_) => AddressCandidateScreen(
            result: result,
            returnToWebAfterSave: widget.returnToWebAfterSave,
          ),
        ),
      );
      if (mounted && reportId != null) {
        Navigator.of(context).pop(reportId);
      }
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => AddressCandidateScreen(result: result),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('텍스트 인식 중')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: isLoading
              ? _LoadingState()
              : _ErrorState(
                  message: errorMessage ?? '텍스트 인식에 실패했습니다.',
                  onRetry: _extract,
                  onSample: _startSample,
                ),
        ),
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(
          width: 72,
          height: 72,
          child: CircularProgressIndicator(strokeWidth: 7),
        ),
        const SizedBox(height: 28),
        Text(
          '이미지 속 텍스트를 읽는 중입니다',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
                color: AppTheme.navy,
              ),
        ),
        const SizedBox(height: 10),
        Text(
          'ML Kit OCR로 텍스트 조각을 꺼내고 있습니다.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.muted,
              ),
        ),
        const SizedBox(height: 18),
        const StatusPill(
          label: 'On-device OCR',
          color: AppTheme.sage,
          icon: Icons.document_scanner_rounded,
        ),
        const SizedBox(height: 28),
        const LinearProgressIndicator(),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.message,
    required this.onRetry,
    required this.onSample,
  });

  final String message;
  final VoidCallback onRetry;
  final VoidCallback onSample;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBEB),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.line),
          ),
          child: const Icon(Icons.error_outline_rounded, color: AppTheme.amber),
        ),
        const SizedBox(height: 20),
        Text(
          'OCR 실패',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppTheme.navy,
                fontWeight: FontWeight.w900,
              ),
        ),
        const SizedBox(height: 10),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppTheme.muted, height: 1.45),
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('다시 시도'),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: onSample,
          icon: const Icon(Icons.auto_awesome_rounded),
          label: const Text('샘플로 진행'),
        ),
      ],
    );
  }
}

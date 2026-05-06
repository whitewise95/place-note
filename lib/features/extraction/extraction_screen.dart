import 'package:flutter/material.dart';

import '../../app.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/status_pill.dart';
import '../../data/models/extraction_result.dart';
import '../address/address_candidate_screen.dart';
import '../report/report_screen.dart';

class ExtractionScreen extends StatefulWidget {
  const ExtractionScreen({
    required this.imagePath,
    super.key,
  });

  final String? imagePath;

  @override
  State<ExtractionScreen> createState() => _ExtractionScreenState();
}

class _ExtractionScreenState extends State<ExtractionScreen> {
  bool hasStarted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!hasStarted) {
      hasStarted = true;
      _extract();
    }
  }

  Future<void> _extract() async {
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
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('텍스트 인식 중 문제가 발생했습니다. 샘플 데이터로 다시 시도해주세요.')),
      );
      Navigator.of(context).pop();
    }
  }

  Future<void> _openNext(ExtractionResult result) async {
    if (result.candidates.length == 1 && result.candidates.first.confidence >= 90) {
      final repository = RepositoryScope.of(context);
      final report = await repository.createReport(
        candidate: result.candidates.first,
        imagePath: result.imagePath,
        ocrText: result.ocrText,
      );

      if (!mounted) {
        return;
      }

      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => ReportScreen(report: report),
        ),
      );
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                width: 72,
                height: 72,
                child: CircularProgressIndicator(strokeWidth: 7),
              ),
              const SizedBox(height: 28),
              Text(
                '주소 후보를 찾는 중입니다',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: AppTheme.navy,
                    ),
              ),
              const SizedBox(height: 10),
              Text(
                '현재 MVP는 MockOcrService를 사용합니다.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.muted,
                    ),
              ),
              const SizedBox(height: 18),
              const StatusPill(
                label: 'Local processing',
                color: AppTheme.teal,
                icon: Icons.offline_bolt_rounded,
              ),
              const SizedBox(height: 28),
              const LinearProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}

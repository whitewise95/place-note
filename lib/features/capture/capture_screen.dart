import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/section_title.dart';
import '../../core/widgets/status_pill.dart';
import '../../data/ocr/mock_ocr_service.dart';
import '../extraction/extraction_screen.dart';

class CaptureScreen extends StatefulWidget {
  const CaptureScreen({super.key});

  static const String routeName = '/capture';

  @override
  State<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen> {
  final ImagePicker picker = ImagePicker();
  String? imagePath;
  bool isPicking = false;

  Future<void> _pick(ImageSource source) async {
    setState(() => isPicking = true);
    try {
      final image = await picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1600,
      );

      if (!mounted) {
        return;
      }

      if (image != null) {
        setState(() => imagePath = image.path);
      }
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('이미지 접근 권한을 확인해주세요. 설정에서 권한을 허용하면 다시 시도할 수 있습니다.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => isPicking = false);
      }
    }
  }

  void _startWith(String? path) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => ExtractionScreen(imagePath: path),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('이미지 선택')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 32),
          children: [
            const SectionTitle('소스 가져오기'),
            const SizedBox(height: 10),
            AppCard(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AspectRatio(
                    aspectRatio: 4 / 3,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceAlt,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.line),
                      ),
                      child: imagePath == null
                          ? const _PreviewPlaceholder()
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                File(imagePath!),
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    const _PreviewPlaceholder(),
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      StatusPill(
                        label: imagePath == null ? '선택 대기' : '이미지 준비 완료',
                        color:
                            imagePath == null ? AppTheme.muted : AppTheme.sage,
                        icon: imagePath == null
                            ? Icons.image_search_rounded
                            : Icons.check_circle_rounded,
                      ),
                      const StatusPill(
                        label: '기기 저장',
                        color: AppTheme.acorn,
                        icon: Icons.memory_rounded,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              child: Column(
                children: [
                  _SourceButton(
                    onPressed:
                        isPicking ? null : () => _pick(ImageSource.gallery),
                    icon: Icons.photo_library_rounded,
                    title: '사진첩에서 선택',
                    subtitle: '저장해둔 화면 캡쳐를 불러옵니다.',
                  ),
                  const Divider(height: 1),
                  _SourceButton(
                    onPressed:
                        isPicking ? null : () => _pick(ImageSource.camera),
                    icon: Icons.photo_camera_rounded,
                    title: '카메라로 촬영',
                    subtitle: '문서나 화면을 바로 촬영합니다.',
                  ),
                  const Divider(height: 1),
                  _SourceButton(
                    onPressed: isPicking
                        ? null
                        : () => _startWith(MockOcrSource.sample),
                    icon: Icons.auto_awesome_rounded,
                    title: '샘플 데이터로 시작',
                    subtitle: '이미지 없이 MVP 흐름을 확인합니다.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            ElevatedButton.icon(
              onPressed: imagePath == null || isPicking
                  ? null
                  : () => _startWith(imagePath),
              icon: const Icon(Icons.text_snippet_rounded),
              label: const Text('텍스트 읽고 보관하기'),
            ),
            if (isPicking) ...[
              const SizedBox(height: 16),
              const LinearProgressIndicator(),
            ],
          ],
        ),
      ),
    );
  }
}

class _SourceButton extends StatelessWidget {
  const _SourceButton({
    required this.onPressed,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final VoidCallback? onPressed;
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppTheme.mint,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.line),
              ),
              child: Icon(icon, color: AppTheme.acorn),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppTheme.ink,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppTheme.muted, fontSize: 13),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppTheme.muted),
          ],
        ),
      ),
    );
  }
}

class _PreviewPlaceholder extends StatelessWidget {
  const _PreviewPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.image_search_rounded, size: 48, color: AppTheme.acorn),
          SizedBox(height: 10),
          Text(
            '이미지 미리보기',
            style: TextStyle(
              color: AppTheme.muted,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

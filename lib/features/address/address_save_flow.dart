import '../../data/models/address_candidate.dart';
import '../../data/models/research_report.dart';
import '../../data/repositories/address_analysis_repository.dart';

Future<ResearchReport> createAndSaveSelectedTextReport({
  required AddressAnalysisRepository repository,
  required AddressCandidate candidate,
  required String? imagePath,
  required String ocrText,
  required String folderId,
}) async {
  final resolvedCandidate = await repository.resolveAddress(candidate);
  final report = await repository.createReport(
    candidate: resolvedCandidate,
    imagePath: imagePath,
    ocrText: ocrText,
    folderId: folderId,
  );
  await repository.save(report);
  return report.copyWith(isSaved: true);
}

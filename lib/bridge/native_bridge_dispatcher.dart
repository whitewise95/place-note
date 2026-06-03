import '../core/storage/image_attachment_storage.dart';
import '../core/storage/report_storage.dart';
import '../data/models/research_report.dart';
import '../data/models/text_folder.dart';
import 'bridge_message.dart';

typedef LoadFolders = Future<List<TextFolder>> Function();
typedef LoadReports = Future<List<ResearchReport>> Function();
typedef LoadImageDataUrl = Future<String?> Function(String? imagePath);
typedef SaveReportFromWeb = Future<ResearchReport> Function({
  required String folderId,
  required String selectedText,
  required String normalizedAddress,
  String? detailAddress,
  double? latitude,
  double? longitude,
  String? province,
  String? district,
  String? locality,
  required String? imagePath,
  required String ocrText,
});

class NativeBridgeDispatcher {
  NativeBridgeDispatcher({
    required LoadFolders loadFolders,
    required LoadReports loadReports,
    required LoadImageDataUrl loadImageDataUrl,
    SaveReportFromWeb? saveReportFromWeb,
  })  : _loadFolders = loadFolders,
        _loadReports = loadReports,
        _loadImageDataUrl = loadImageDataUrl,
        _saveReportFromWeb = saveReportFromWeb;

  factory NativeBridgeDispatcher.local() {
    final storage = ReportStorage();
    final imageStorage = ImageAttachmentStorage();
    return NativeBridgeDispatcher(
      loadFolders: storage.loadFolders,
      loadReports: storage.loadReports,
      loadImageDataUrl: imageStorage.readAsDataUrl,
      saveReportFromWeb: ({
        required folderId,
        required selectedText,
        required normalizedAddress,
        detailAddress,
        latitude,
        longitude,
        province,
        district,
        locality,
        required imagePath,
        required ocrText,
      }) async {
        final storedImagePath = await imageStorage.persist(imagePath);
        final report = ResearchReport(
          id: 'report-${DateTime.now().microsecondsSinceEpoch}',
          rawAddress: selectedText,
          normalizedAddress: normalizedAddress,
          summaryCards: const [
            SummaryCard(
              title: '선택한 텍스트',
              value: '저장됨',
              description: 'React 저장 흐름에서 사용자가 고른 문장을 로컬 폴더에 저장했습니다.',
              status: 'local',
            ),
          ],
          status: 'local_web',
          createdAt: DateTime.now(),
          folderId: folderId,
          imagePath: storedImagePath,
          ocrText: ocrText,
          detailAddress: detailAddress,
          latitude: latitude,
          longitude: longitude,
          province: province,
          district: district,
          locality: locality,
          isSaved: true,
        );
        await storage.saveReport(report);
        return report.copyWith(isSaved: true);
      },
    );
  }

  final LoadFolders _loadFolders;
  final LoadReports _loadReports;
  final LoadImageDataUrl _loadImageDataUrl;
  final SaveReportFromWeb? _saveReportFromWeb;

  Future<Map<String, dynamic>> handle(String rawMessage) async {
    BridgeRequest request;
    try {
      request = BridgeRequest.parse(rawMessage);
    } catch (_) {
      return const BridgeResponse.error('', 'invalid_request').toJson();
    }

    switch (request.method) {
      case 'folders.list':
        final folders = await _loadFolders();
        return BridgeResponse.success(
          request.id,
          folders.map((folder) => folder.toJson()).toList(),
        ).toJson();
      case 'reports.list':
        return BridgeResponse.success(
          request.id,
          await _reportDtos(await _loadReports()),
        ).toJson();
      case 'reports.save':
        return _saveReport(request);
      default:
        return BridgeResponse.error(request.id, 'unsupported_method').toJson();
    }
  }

  Future<Map<String, dynamic>> _saveReport(BridgeRequest request) async {
    final saveReport = _saveReportFromWeb;
    if (saveReport == null) {
      return BridgeResponse.error(request.id, 'unsupported_method').toJson();
    }

    final folderId = _asString(request.params['folderId']);
    final selectedText = _asString(request.params['selectedText']);
    final normalizedAddress = _asString(request.params['normalizedAddress']);
    final ocrText = _asString(request.params['ocrText']);
    if (folderId == null ||
        selectedText == null ||
        normalizedAddress == null ||
        ocrText == null) {
      return BridgeResponse.error(request.id, 'invalid_params').toJson();
    }

    final report = await saveReport(
      folderId: folderId,
      selectedText: selectedText,
      normalizedAddress: normalizedAddress,
      detailAddress: _asString(request.params['detailAddress']),
      latitude: _asDouble(request.params['latitude']),
      longitude: _asDouble(request.params['longitude']),
      province: _asString(request.params['province']),
      district: _asString(request.params['district']),
      locality: _asString(request.params['locality']),
      imagePath: _asString(request.params['imagePath']),
      ocrText: ocrText,
    );
    return BridgeResponse.success(request.id, await _reportDto(report))
        .toJson();
  }

  Future<List<Map<String, dynamic>>> _reportDtos(
    List<ResearchReport> reports,
  ) async {
    final result = <Map<String, dynamic>>[];
    for (final report in reports) {
      result.add(await _reportDto(report));
    }
    return result;
  }

  Future<Map<String, dynamic>> _reportDto(ResearchReport report) async {
    final imageDataUrl = await _loadImageDataUrl(report.imagePath);
    return {
      'id': report.id,
      'folderId': report.folderId,
      'normalizedAddress': report.normalizedAddress,
      'rawAddress': report.rawAddress,
      'createdAt': report.createdAt.toIso8601String(),
      if (report.latitude != null) 'latitude': report.latitude,
      if (report.longitude != null) 'longitude': report.longitude,
      if (report.province != null) 'province': report.province,
      if (report.district != null) 'district': report.district,
      if (report.locality != null) 'locality': report.locality,
      if (imageDataUrl != null) 'imageDataUrl': imageDataUrl,
    };
  }

  String? _asString(Object? value) {
    if (value is! String || value.trim().isEmpty) {
      return null;
    }
    return value.trim();
  }

  double? _asDouble(Object? value) {
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }
}

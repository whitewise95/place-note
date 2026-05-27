import '../core/storage/image_attachment_storage.dart';
import '../core/storage/report_storage.dart';
import '../data/models/research_report.dart';
import '../data/models/text_folder.dart';
import 'bridge_message.dart';

typedef LoadFolders = Future<List<TextFolder>> Function();
typedef LoadReports = Future<List<ResearchReport>> Function();
typedef LoadImageDataUrl = Future<String?> Function(String? imagePath);

class NativeBridgeDispatcher {
  NativeBridgeDispatcher({
    required LoadFolders loadFolders,
    required LoadReports loadReports,
    required LoadImageDataUrl loadImageDataUrl,
  })  : _loadFolders = loadFolders,
        _loadReports = loadReports,
        _loadImageDataUrl = loadImageDataUrl;

  factory NativeBridgeDispatcher.local() {
    final storage = ReportStorage();
    final imageStorage = ImageAttachmentStorage();
    return NativeBridgeDispatcher(
      loadFolders: storage.loadFolders,
      loadReports: storage.loadReports,
      loadImageDataUrl: imageStorage.readAsDataUrl,
    );
  }

  final LoadFolders _loadFolders;
  final LoadReports _loadReports;
  final LoadImageDataUrl _loadImageDataUrl;

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
      default:
        return BridgeResponse.error(request.id, 'unsupported_method').toJson();
    }
  }

  Future<List<Map<String, dynamic>>> _reportDtos(
    List<ResearchReport> reports,
  ) async {
    final result = <Map<String, dynamic>>[];
    for (final report in reports) {
      final imageDataUrl = await _loadImageDataUrl(report.imagePath);
      result.add({
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
      });
    }
    return result;
  }
}

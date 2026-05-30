import 'dart:io';

import 'package:flutter/material.dart';

import '../../app.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/status_pill.dart';
import '../../data/models/research_report.dart';
import '../../data/models/text_folder.dart';
import '../../data/regions/address_region.dart';
import '../../data/regions/address_region_parser.dart';
import '../report/report_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({
    this.folder,
    super.key,
  });

  static const String routeName = '/history';

  final TextFolder? folder;

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final TextEditingController searchController = TextEditingController();
  List<ResearchReport> reports = [];
  String? selectedProvince;
  String? selectedDistrict;
  String? selectedLocality;
  bool isLoading = true;
  bool hasLoaded = false;

  @override
  void initState() {
    super.initState();
    searchController.addListener(() => setState(() {}));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!hasLoaded) {
      hasLoaded = true;
      _load();
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => isLoading = true);
    final loaded = await RepositoryScope.of(context).findHistories();
    if (!mounted) {
      return;
    }

    setState(() {
      reports = loaded;
      isLoading = false;
    });
  }

  Future<void> _delete(ResearchReport report) async {
    await RepositoryScope.of(context).delete(report.id);
    await _load();
  }

  List<ResearchReport> get filteredReports {
    final keyword = searchController.text.trim().toLowerCase();
    final scopedReports = _scopedReports;

    return scopedReports.where((report) {
      final region = _regionOf(report);
      final matchesKeyword = keyword.isEmpty ||
          report.normalizedAddress.toLowerCase().contains(keyword) ||
          report.rawAddress.toLowerCase().contains(keyword);
      final matchesProvince =
          selectedProvince == null || region.province == selectedProvince;
      final matchesDistrict =
          selectedDistrict == null || region.district == selectedDistrict;
      final matchesLocality =
          selectedLocality == null || region.locality == selectedLocality;

      return matchesKeyword &&
          matchesProvince &&
          matchesDistrict &&
          matchesLocality;
    }).toList();
  }

  List<ResearchReport> get _scopedReports {
    if (widget.folder == null) {
      return reports;
    }

    return reports
        .where((report) => report.folderId == widget.folder!.id)
        .toList();
  }

  List<String> get provinceOptions {
    return _regionOptions(
      _scopedReports,
      (region) => region.province,
    );
  }

  List<String> get districtOptions {
    return _regionOptions(
      _scopedReports.where((report) {
        final region = _regionOf(report);
        return selectedProvince == null || region.province == selectedProvince;
      }),
      (region) => region.district,
    );
  }

  List<String> get localityOptions {
    return _regionOptions(
      _scopedReports.where((report) {
        final region = _regionOf(report);
        final matchesProvince =
            selectedProvince == null || region.province == selectedProvince;
        final matchesDistrict =
            selectedDistrict == null || region.district == selectedDistrict;
        return matchesProvince && matchesDistrict;
      }),
      (region) => region.locality,
    );
  }

  AddressRegion _regionOf(ResearchReport report) {
    final structuredAddress = [
      report.province,
      report.district,
      report.locality,
    ].whereType<String>().where((value) => value.trim().isNotEmpty).join(' ');
    if (structuredAddress.isNotEmpty) {
      return AddressRegionParser.parse(structuredAddress);
    }
    return AddressRegionParser.parse(report.normalizedAddress);
  }

  List<String> _regionOptions(
    Iterable<ResearchReport> source,
    String? Function(AddressRegion region) selector,
  ) {
    final options = <String>{};
    for (final report in source) {
      final value = selector(_regionOf(report));
      if (value != null && value.trim().isNotEmpty) {
        options.add(value);
      }
    }

    return options.toList()..sort();
  }

  void _selectProvince(String? value) {
    setState(() {
      selectedProvince = value;
      selectedDistrict = null;
      selectedLocality = null;
    });
  }

  void _selectDistrict(String? value) {
    setState(() {
      selectedDistrict = value;
      selectedLocality = null;
    });
  }

  void _selectLocality(String? value) {
    setState(() {
      selectedLocality = value;
    });
  }

  void _clearRegionFilters() {
    setState(() {
      selectedProvince = null;
      selectedDistrict = null;
      selectedLocality = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final filtered = filteredReports;

    return Scaffold(
      appBar: AppBar(title: Text(widget.folder?.name ?? '전체 텍스트')),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 12),
              child: TextField(
                controller: searchController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search_rounded),
                  hintText: '저장한 텍스트 검색',
                ),
              ),
            ),
            if (!isLoading && _scopedReports.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
                child: _RegionFilterPanel(
                  provinceOptions: provinceOptions,
                  districtOptions: districtOptions,
                  localityOptions: localityOptions,
                  selectedProvince: selectedProvince,
                  selectedDistrict: selectedDistrict,
                  selectedLocality: selectedLocality,
                  onProvinceSelected: _selectProvince,
                  onDistrictSelected: _selectDistrict,
                  onLocalitySelected: _selectLocality,
                  onClear: _clearRegionFilters,
                ),
              ),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filtered.isEmpty
                      ? const EmptyState(
                          title: '검색 결과가 없습니다',
                          message: '저장된 텍스트가 있으면 다시 찾을 수 있습니다.',
                        )
                      : RefreshIndicator(
                          onRefresh: _load,
                          child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(18, 0, 18, 28),
                            itemCount: filtered.length,
                            itemBuilder: (context, index) {
                              final report = filtered[index];
                              return _HistoryTile(
                                report: report,
                                onOpen: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) => ReportScreen(
                                        report: report,
                                        autosave: false,
                                      ),
                                    ),
                                  );
                                },
                                onDelete: () => _delete(report),
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RegionFilterPanel extends StatelessWidget {
  const _RegionFilterPanel({
    required this.provinceOptions,
    required this.districtOptions,
    required this.localityOptions,
    required this.selectedProvince,
    required this.selectedDistrict,
    required this.selectedLocality,
    required this.onProvinceSelected,
    required this.onDistrictSelected,
    required this.onLocalitySelected,
    required this.onClear,
  });

  final List<String> provinceOptions;
  final List<String> districtOptions;
  final List<String> localityOptions;
  final String? selectedProvince;
  final String? selectedDistrict;
  final String? selectedLocality;
  final ValueChanged<String?> onProvinceSelected;
  final ValueChanged<String?> onDistrictSelected;
  final ValueChanged<String?> onLocalitySelected;
  final VoidCallback onClear;

  bool get hasSelection =>
      selectedProvince != null ||
      selectedDistrict != null ||
      selectedLocality != null;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.tune_rounded, color: AppTheme.acorn),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  '지역 필터',
                  style: TextStyle(
                    color: AppTheme.ink,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              TextButton(
                onPressed: hasSelection ? onClear : null,
                child: const Text('초기화'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _RegionFilterRow(
            label: '시/도',
            options: provinceOptions,
            selectedValue: selectedProvince,
            onSelected: onProvinceSelected,
          ),
          if (districtOptions.isNotEmpty) ...[
            const SizedBox(height: 8),
            _RegionFilterRow(
              label: '시/군/구',
              options: districtOptions,
              selectedValue: selectedDistrict,
              onSelected: onDistrictSelected,
            ),
          ],
          if (localityOptions.isNotEmpty) ...[
            const SizedBox(height: 8),
            _RegionFilterRow(
              label: '동/도로명',
              options: localityOptions,
              selectedValue: selectedLocality,
              onSelected: onLocalitySelected,
            ),
          ],
        ],
      ),
    );
  }
}

class _RegionFilterRow extends StatelessWidget {
  const _RegionFilterRow({
    required this.label,
    required this.options,
    required this.selectedValue,
    required this.onSelected,
  });

  final String label;
  final List<String> options;
  final String? selectedValue;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.muted,
            fontSize: 12,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 6),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _RegionChip(
                label: '전체',
                selected: selectedValue == null,
                onSelected: () => onSelected(null),
              ),
              ...options.map(
                (option) => _RegionChip(
                  label: option,
                  selected: selectedValue == option,
                  onSelected: () => onSelected(option),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RegionChip extends StatelessWidget {
  const _RegionChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onSelected(),
        showCheckmark: false,
        labelStyle: TextStyle(
          color: selected ? AppTheme.brown : AppTheme.muted,
          fontWeight: FontWeight.w900,
        ),
        backgroundColor: AppTheme.surface,
        selectedColor: const Color(0xFFFFE2B8),
        side: BorderSide(
          color: selected ? AppTheme.caramel : AppTheme.line,
        ),
      ),
    );
  }
}

class _HistoryTile extends StatefulWidget {
  const _HistoryTile({
    required this.report,
    required this.onOpen,
    required this.onDelete,
  });

  final ResearchReport report;
  final VoidCallback onOpen;
  final VoidCallback onDelete;

  @override
  State<_HistoryTile> createState() => _HistoryTileState();
}

class _HistoryTileState extends State<_HistoryTile> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: AnimatedScale(
        scale: isHovered ? 1.01 : 1,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOut,
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: isHovered ? AppTheme.surfaceAlt : AppTheme.elevatedSurface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isHovered ? AppTheme.caramel : AppTheme.line,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.brown.withValues(alpha: isHovered ? 0.16 : 0.1),
                blurRadius: isHovered ? 24 : 16,
                offset: Offset(0, isHovered ? 12 : 8),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: widget.onOpen,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _HistoryThumb(report: widget.report),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.report.normalizedAddress,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppTheme.navy,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: [
                              StatusPill(
                                label: _formatDate(widget.report.createdAt),
                                color: AppTheme.muted,
                                icon: Icons.schedule_rounded,
                              ),
                              const StatusPill(
                                label: 'Local',
                                color: AppTheme.sage,
                                icon: Icons.storage_rounded,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    _HoverActions(
                      isHovered: isHovered,
                      onOpen: widget.onOpen,
                      onDelete: () => _confirmDelete(context),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('텍스트 삭제'),
        content: const Text('이 저장 항목을 삭제할까요?'),
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

    if (confirmed == true) {
      widget.onDelete();
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class _HoverActions extends StatelessWidget {
  const _HoverActions({
    required this.isHovered,
    required this.onOpen,
    required this.onDelete,
  });

  final bool isHovered;
  final VoidCallback onOpen;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: isHovered ? 1 : 0.72,
      duration: const Duration(milliseconds: 140),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        padding: EdgeInsets.all(isHovered ? 4 : 0),
        decoration: BoxDecoration(
          color: isHovered ? AppTheme.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isHovered ? AppTheme.line : Colors.transparent,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 140),
              height: isHovered ? 40 : 0,
              child: ClipRect(
                child: AnimatedOpacity(
                  opacity: isHovered ? 1 : 0,
                  duration: const Duration(milliseconds: 100),
                  child: IconButton(
                    tooltip: '열기',
                    onPressed: onOpen,
                    icon: const Icon(Icons.open_in_new_rounded),
                    color: AppTheme.acorn,
                  ),
                ),
              ),
            ),
            IconButton(
              tooltip: '삭제',
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline_rounded),
              color: isHovered ? AppTheme.caramel : AppTheme.muted,
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryThumb extends StatelessWidget {
  const _HistoryThumb({required this.report});

  final ResearchReport report;

  @override
  Widget build(BuildContext context) {
    final path = report.imagePath;
    final hasImage = path != null && File(path).existsSync();

    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: AppTheme.surfaceAlt,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: hasImage
          ? Image.file(
              File(path),
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.text_snippet_rounded,
                color: AppTheme.acorn,
              ),
            )
          : const Icon(Icons.text_snippet_rounded, color: AppTheme.acorn),
    );
  }
}

import 'package:flutter/material.dart';
import '../struct/studyDocument.dart';
import '../struct/documentLocation.dart';
import '../database/study_document_dao.dart';

/// Trang bản đồ/vị trí vật lý của tài liệu
class LocationMapPage extends StatefulWidget {
  const LocationMapPage({super.key});

  @override
  State<LocationMapPage> createState() => _LocationMapPageState();
}

class _LocationMapPageState extends State<LocationMapPage> {
  final DocumentDao _dao = DocumentDao();
  String? _selectedLocationName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Bản đồ Tài liệu',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        'Vị trí vật lý nơi lưu trữ tài liệu',
                        style: TextStyle(
                          fontSize: 13,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7D8DF),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.location_on_rounded, color: Color(0xFFD81B60), size: 16),
                        SizedBox(width: 4),
                        Text('Khuôn viên FPT HCM', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFFD81B60))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Campus Map Visualization
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _CampusMapWidget(
                selectedLocation: _selectedLocationName,
                onLocationTap: (name) => setState(() => _selectedLocationName = name == _selectedLocationName ? null : name),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          // Location Legend
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _buildLegend(theme),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          // Documents at selected location
          StreamBuilder<List<StudyDocument>>(
            stream: _dao.watchAll(),
            initialData: _dao.getAll(),
            builder: (context, snapshot) {
              final allDocs = snapshot.data ?? [];
              final docsWithLocation = _selectedLocationName == null
                  ? allDocs.where((d) => d.location != null).toList()
                  : allDocs.where((d) => d.location?.locationName == _selectedLocationName).toList();

              return SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedLocationName == null
                            ? 'Tất cả tài liệu có vị trí (${docsWithLocation.length})'
                            : 'Tại "$_selectedLocationName" (${docsWithLocation.length})',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      if (docsWithLocation.isEmpty)
                        _buildEmptyLocation(theme)
                      else
                        ...docsWithLocation.map((doc) => _DocumentLocationCard(document: doc)),
                    ],
                  ),
                ),
              );
            },
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  Widget _buildLegend(ThemeData theme) {
    final locations = SampleLocations.presets;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Các địa điểm', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: locations.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (ctx, i) {
              final loc = locations[i];
              final isSelected = _selectedLocationName == loc.locationName;
              return InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => setState(() => _selectedLocationName = isSelected ? null : loc.locationName),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFD81B60) : theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? const Color(0xFFD81B60) : Colors.grey.shade300,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _locationIcon(loc.locationName),
                        size: 14,
                        color: isSelected ? Colors.white : const Color(0xFFD81B60),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        loc.locationName,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  IconData _locationIcon(String name) {
    if (name.contains('Thư viện')) return Icons.local_library_rounded;
    if (name.contains('Lab') || name.contains('Phòng học')) return Icons.computer_rounded;
    if (name.contains('Ký túc')) return Icons.home_rounded;
    if (name.contains('Cafe')) return Icons.local_cafe_rounded;
    if (name.contains('Seminar')) return Icons.groups_rounded;
    return Icons.location_on_rounded;
  }

  Widget _buildEmptyLocation(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(Icons.location_off_rounded, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            'Chưa có tài liệu nào tại vị trí này',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            'Thêm tài liệu và gán vị trí khi tạo/chỉnh sửa tài liệu',
            style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Widget giả lập bản đồ khuôn viên trường
class _CampusMapWidget extends StatelessWidget {
  final String? selectedLocation;
  final void Function(String) onLocationTap;

  const _CampusMapWidget({this.selectedLocation, required this.onLocationTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 240,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1B5E20), Color(0xFF2E7D32), Color(0xFF388E3C)],
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 16, offset: const Offset(0, 4)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Roads
            CustomPaint(
              size: const Size(double.infinity, 240),
              painter: _CampusRoadPainter(),
            ),
            // Buildings
            _MapPin(left: 0.15, top: 0.2, label: 'Thư viện', icon: Icons.local_library_rounded, isSelected: selectedLocation?.contains('Thư viện') ?? false, onTap: () => onLocationTap('Thư viện Trường ĐH FPT TP.HCM')),
            _MapPin(left: 0.5, top: 0.15, label: 'Lab 301', icon: Icons.computer_rounded, isSelected: selectedLocation?.contains('SE Lab') ?? false, onTap: () => onLocationTap('Phòng học SE Lab 301')),
            _MapPin(left: 0.78, top: 0.3, label: 'Ký túc xá', icon: Icons.home_rounded, isSelected: selectedLocation?.contains('Ký túc') ?? false, onTap: () => onLocationTap('Ký túc xá Block A')),
            _MapPin(left: 0.3, top: 0.55, label: 'Lab 201', icon: Icons.computer_rounded, isSelected: selectedLocation?.contains('Computer Lab') ?? false, onTap: () => onLocationTap('Phòng Computer Lab 201')),
            _MapPin(left: 0.63, top: 0.6, label: 'Seminar', icon: Icons.groups_rounded, isSelected: selectedLocation?.contains('Seminar') ?? false, onTap: () => onLocationTap('Phòng Seminar SB-101')),
            _MapPin(left: 0.82, top: 0.75, label: 'Cafe', icon: Icons.local_cafe_rounded, isSelected: selectedLocation?.contains('Cafe') ?? false, onTap: () => onLocationTap('Quán Cafe Study Zone')),
            // Map label
            const Positioned(
              bottom: 8,
              left: 12,
              child: Text('© Khuôn viên FPT University HCM', style: TextStyle(color: Colors.white54, fontSize: 10)),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapPin extends StatelessWidget {
  final double left;
  final double top;
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _MapPin({
    required this.left,
    required this.top,
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left * MediaQuery.of(context).size.width * 0.85,
      top: top * 220,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedScale(
          scale: isSelected ? 1.15 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFD81B60) : Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 2))],
                ),
                child: Icon(icon, size: 16, color: isSelected ? Colors.white : const Color(0xFFD81B60)),
              ),
              Container(
                margin: const EdgeInsets.only(top: 2),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFD81B60) : Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  label,
                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : Colors.black87),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CampusRoadPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.15)
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Horizontal main road
    canvas.drawLine(Offset(0, size.height * 0.5), Offset(size.width, size.height * 0.5), paint);
    // Vertical road
    canvas.drawLine(Offset(size.width * 0.4, 0), Offset(size.width * 0.4, size.height), paint);
    // Diagonal path
    canvas.drawLine(Offset(size.width * 0.6, size.height * 0.3), Offset(size.width * 0.85, size.height * 0.7), paint);
  }

  @override
  bool shouldRepaint(_) => false;
}

class _DocumentLocationCard extends StatelessWidget {
  final StudyDocument document;
  const _DocumentLocationCard({required this.document});

  @override
  Widget build(BuildContext context) {
    final loc = document.location!;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF7D8DF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.location_on_rounded, color: Color(0xFFD81B60), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(document.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 3),
                Text(loc.displayLabel, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                if (loc.address.isNotEmpty)
                  Text(loc.address, style: TextStyle(fontSize: 11, color: Colors.grey.shade400), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${loc.latitude.toStringAsFixed(4)},\n${loc.longitude.toStringAsFixed(4)}',
              style: const TextStyle(fontSize: 9, fontFamily: 'monospace', color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget chọn vị trí để embed trong AddEditDocumentPage
class LocationPickerWidget extends StatefulWidget {
  final DocumentLocation? initialLocation;
  final ValueChanged<DocumentLocation?> onLocationChanged;

  const LocationPickerWidget({
    super.key,
    this.initialLocation,
    required this.onLocationChanged,
  });

  @override
  State<LocationPickerWidget> createState() => _LocationPickerWidgetState();
}

class _LocationPickerWidgetState extends State<LocationPickerWidget> {
  DocumentLocation? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialLocation;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.location_on_rounded, color: Color(0xFFD81B60), size: 18),
            const SizedBox(width: 6),
            const Text('Vị trí vật lý', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const Spacer(),
            if (_selected != null)
              TextButton.icon(
                onPressed: () {
                  setState(() => _selected = null);
                  widget.onLocationChanged(null);
                },
                icon: const Icon(Icons.clear_rounded, size: 14),
                label: const Text('Xóa vị trí', style: TextStyle(fontSize: 12)),
                style: TextButton.styleFrom(foregroundColor: Colors.grey),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (_selected != null)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF7D8DF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFD81B60).withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Color(0xFFD81B60), size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _selected!.displayLabel,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFFD81B60)),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 8),
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: SampleLocations.presets.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (ctx, i) {
              final loc = SampleLocations.presets[i];
              final isSel = _selected?.locationName == loc.locationName;
              return InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  setState(() => _selected = isSel ? null : loc);
                  widget.onLocationChanged(isSel ? null : loc);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSel ? const Color(0xFFF7D8DF) : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: isSel ? const Color(0xFFD81B60) : Colors.grey.shade300),
                  ),
                  child: Text(
                    loc.locationName,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                      color: isSel ? const Color(0xFFD81B60) : Colors.grey.shade700,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

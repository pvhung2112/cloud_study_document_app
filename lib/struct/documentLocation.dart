/// Model đại diện cho vị trí vật lý nơi tài liệu được lưu trữ
class DocumentLocation {
  final double latitude;
  final double longitude;
  final String address;
  final String locationName;
  final String? room;
  final String? shelf;

  const DocumentLocation({
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.locationName,
    this.room,
    this.shelf,
  });

  String get displayLabel {
    final parts = <String>[locationName];
    if (room != null && room!.isNotEmpty) parts.add('Phòng $room');
    if (shelf != null && shelf!.isNotEmpty) parts.add('Kệ $shelf');
    return parts.join(' · ');
  }

  Map<String, dynamic> toMap() => {
        'latitude': latitude,
        'longitude': longitude,
        'address': address,
        'location_name': locationName,
        'room': room,
        'shelf': shelf,
      };

  factory DocumentLocation.fromMap(Map<String, dynamic> map) {
    return DocumentLocation(
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      address: map['address'] as String? ?? '',
      locationName: map['location_name'] as String? ?? '',
      room: map['room'] as String?,
      shelf: map['shelf'] as String?,
    );
  }

  DocumentLocation copyWith({
    double? latitude,
    double? longitude,
    String? address,
    String? locationName,
    String? room,
    String? shelf,
  }) {
    return DocumentLocation(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      locationName: locationName ?? this.locationName,
      room: room ?? this.room,
      shelf: shelf ?? this.shelf,
    );
  }

  @override
  String toString() => 'DocumentLocation($locationName @ $latitude,$longitude)';
}

/// Danh sách vị trí mẫu (thư viện, phòng học, ký túc xá, ...)
class SampleLocations {
  static const List<DocumentLocation> presets = [
    DocumentLocation(
      latitude: 10.8700,
      longitude: 106.8030,
      address: 'Lô 6, Đường số 6, KĐT Vạn Phúc, Thủ Đức, TP.HCM',
      locationName: 'Thư viện Trường ĐH FPT TP.HCM',
      room: 'Reading Hall A',
      shelf: 'D-12',
    ),
    DocumentLocation(
      latitude: 10.8695,
      longitude: 106.8025,
      address: 'Lô 6, Đường số 6, KĐT Vạn Phúc, Thủ Đức, TP.HCM',
      locationName: 'Phòng học SE Lab 301',
      room: '301',
      shelf: null,
    ),
    DocumentLocation(
      latitude: 10.8710,
      longitude: 106.8040,
      address: 'Lô 6, Đường số 6, KĐT Vạn Phúc, Thủ Đức, TP.HCM',
      locationName: 'Ký túc xá Block A',
      room: 'A-205',
      shelf: null,
    ),
    DocumentLocation(
      latitude: 10.8680,
      longitude: 106.8020,
      address: 'Lô 6, Đường số 6, KĐT Vạn Phúc, Thủ Đức, TP.HCM',
      locationName: 'Phòng Computer Lab 201',
      room: '201',
      shelf: null,
    ),
    DocumentLocation(
      latitude: 10.8720,
      longitude: 106.8050,
      address: 'Lô 6, Đường số 6, KĐT Vạn Phúc, Thủ Đức, TP.HCM',
      locationName: 'Phòng Seminar SB-101',
      room: 'SB-101',
      shelf: 'Kệ đầu phòng',
    ),
    DocumentLocation(
      latitude: 10.8668,
      longitude: 106.8015,
      address: 'KĐT Vạn Phúc, Thủ Đức, TP.HCM',
      locationName: 'Quán Cafe Study Zone',
      room: null,
      shelf: null,
    ),
  ];
}

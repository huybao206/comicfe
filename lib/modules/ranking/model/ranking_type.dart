class RankingType {
  final String typeCode;
  final String name;
  final String? description;
  final bool isActive;
  final int sortOrder;

  const RankingType({
    required this.typeCode,
    required this.name,
    this.description,
    required this.isActive,
    required this.sortOrder,
  });

  factory RankingType.fromMap(Map<String, dynamic> map) {
    final code = (map['typeCode'] ??
        map['type_code'] ??
        map['code'] ??
        map['type'] ??
        '')
        .toString();

    final label = (map['name'] ??
        map['label'] ??
        map['title'] ??
        map['typeName'] ??
        map['type_name'] ??
        code)
        .toString();

    return RankingType(
      typeCode: code,
      name: label,
      description: (map['description'] ?? map['desc'])?.toString(),
      isActive: _toBool(map['isActive'] ?? map['is_active'] ?? true),
      sortOrder: _toInt(map['sortOrder'] ?? map['sort_order']),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static bool _toBool(dynamic value) {
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is num) return value.toInt() == 1;

    final text = value?.toString().toLowerCase().trim();
    return text == 'true' || text == '1' || text == 'yes';
  }
}
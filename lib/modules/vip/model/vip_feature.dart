class VipFeature {
  final int id;
  final String featureCode;
  final String featureName;
  final String? description;
  final int requiredVipLevel;
  final bool isActive;

  VipFeature({
    required this.id,
    required this.featureCode,
    required this.featureName,
    this.description,
    required this.requiredVipLevel,
    required this.isActive,
  });

  factory VipFeature.fromMap(Map<String, dynamic> map) {
    int toInt(dynamic value) => int.tryParse('$value') ?? 0;

    return VipFeature(
      id: toInt(map['id']),
      featureCode: (map['feature_code'] ?? '').toString(),
      featureName: (map['feature_name'] ?? '').toString(),
      description: map['description']?.toString(),
      requiredVipLevel: toInt(
        map['required_vip_level'] ?? map['requiredVipLevel'],
      ),
      isActive: '${map['is_active']}' == '1' || map['is_active'] == true,
    );
  }
}
class AfkConfig {
  final int id;
  final String configKey;
  final String? configValue;
  final String? valueType;
  final String? description;
  final dynamic parsedValue;
  final bool isActive;

  AfkConfig({
    required this.id,
    required this.configKey,
    required this.configValue,
    required this.valueType,
    required this.description,
    required this.parsedValue,
    required this.isActive,
  });

  factory AfkConfig.fromMap(Map<String, dynamic> map) {
    return AfkConfig(
      id: (map['id'] as num?)?.toInt() ?? 0,
      configKey: (map['config_key'] ?? '').toString(),
      configValue: map['config_value']?.toString(),
      valueType: map['value_type']?.toString(),
      description: map['description']?.toString(),
      parsedValue: map['parsed_value'],
      isActive: map['is_active'] == true,
    );
  }
}
class AfkConfig {
  final int id;
  final String configKey;
  final String? configValue;
  final String? valueType;
  final String? description;
  final dynamic parsedValue;
  final bool isActive;

  const AfkConfig({
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
      id: _toInt(map['id']),
      configKey: (map['config_key'] ?? '').toString(),
      configValue: map['config_value']?.toString(),
      valueType: map['value_type']?.toString(),
      description: map['description']?.toString(),
      parsedValue: map['parsed_value'],
      isActive: _toBool(map['is_active'] ?? true),
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

    final text = value?.toString().trim().toLowerCase();

    return text == null ||
        text.isEmpty ||
        text == 'true' ||
        text == '1' ||
        text == 'yes' ||
        text == 'active';
  }
}
class RankingType {
  final String typeCode;
  final String name;
  final String? description;

  RankingType({
    required this.typeCode,
    required this.name,
    this.description,
  });

  factory RankingType.fromMap(Map<String, dynamic> map) {
    return RankingType(
      typeCode: (map['typeCode'] ??
          map['type_code'] ??
          map['code'] ??
          '')
          .toString(),
      name: (map['displayName'] ??
          map['typeName'] ??
          map['name'] ??
          map['title'] ??
          '')
          .toString(),
      description: map['description']?.toString(),
    );
  }
}
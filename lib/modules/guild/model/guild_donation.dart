class GuildDonation {
  final int id;
  final String donorName;
  final int contributionPoints;
  final String? createdAt;

  GuildDonation({
    required this.id,
    required this.donorName,
    required this.contributionPoints,
    this.createdAt,
  });

  factory GuildDonation.fromMap(Map<String, dynamic> map) {
    final donorName = map['display_name'] ??
        map['username'] ??
        map['donor_name'] ??
        map['name'] ??
        'Đồng đạo';

    return GuildDonation(
      id: int.tryParse('${map['id'] ?? 0}') ?? 0,
      donorName: donorName.toString(),
      contributionPoints:
      int.tryParse('${map['contribution_points'] ?? map['points'] ?? 0}') ??
          0,
      createdAt: map['created_at']?.toString(),
    );
  }
}
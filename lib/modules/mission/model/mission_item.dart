class MissionItem {
  final int id;
  final int missionId;
  final String title;
  final String description;
  final String missionType;
  final String targetType;
  final int targetValue;
  final int currentProgress;
  final int rewardGold;
  final int rewardExp;
  final int? rewardItemId;
  final int rewardItemQuantity;
  final String status;
  final bool isClaimed;

  const MissionItem({
    required this.id,
    required this.missionId,
    required this.title,
    required this.description,
    required this.missionType,
    required this.targetType,
    required this.targetValue,
    required this.currentProgress,
    required this.rewardGold,
    required this.rewardExp,
    required this.rewardItemId,
    required this.rewardItemQuantity,
    required this.status,
    required this.isClaimed,
  });

  factory MissionItem.fromJson(Map<String, dynamic> json) {
    final nestedMission = json['mission'];
    final missionMap = nestedMission is Map
        ? Map<String, dynamic>.from(nestedMission)
        : <String, dynamic>{};

    dynamic pick(String snake, String camel, [String? fallback]) {
      return json[snake] ??
          json[camel] ??
          (fallback == null ? null : json[fallback]) ??
          missionMap[snake] ??
          missionMap[camel] ??
          (fallback == null ? null : missionMap[fallback]);
    }

    final missionId = _toInt(
      pick('mission_id', 'missionId') ?? json['id'] ?? missionMap['id'],
    );

    final statusText = (pick('status', 'status') ??
        pick('claim_status', 'claimStatus') ??
        '')
        .toString();

    final claimed = _toBool(
      pick('is_claimed', 'isClaimed') ??
          pick('claimed', 'claimed') ??
          pick('reward_claimed', 'rewardClaimed'),
    ) ||
        statusText.toLowerCase() == 'claimed';

    return MissionItem(
      id: _toInt(json['user_mission_id'] ?? json['userMissionId'] ?? json['id']),
      missionId: missionId,
      title: (pick('title', 'title') ??
          pick('mission_title', 'missionTitle') ??
          pick('name', 'name') ??
          'Nhiệm vụ')
          .toString(),
      description: (pick('description', 'description') ??
          pick('mission_description', 'missionDescription') ??
          '')
          .toString(),
      missionType:
      (pick('mission_type', 'missionType', 'type') ?? 'daily').toString(),
      targetType:
      (pick('target_type', 'targetType', 'target') ?? '').toString(),
      targetValue: _toInt(pick('target_value', 'targetValue') ?? 1),
      currentProgress:
      _toInt(pick('current_progress', 'currentProgress') ?? 0),
      rewardGold: _toInt(pick('reward_gold', 'rewardGold') ?? 0),
      rewardExp: _toInt(pick('reward_exp', 'rewardExp') ?? 0),
      rewardItemId: _nullableInt(pick('reward_item_id', 'rewardItemId')),
      rewardItemQuantity:
      _toInt(pick('reward_item_quantity', 'rewardItemQuantity') ?? 0),
      status: statusText.isEmpty ? (claimed ? 'claimed' : 'active') : statusText,
      isClaimed: claimed,
    );
  }

  double get progressRatio {
    if (targetValue <= 0) return 0;
    final ratio = currentProgress / targetValue;
    if (ratio < 0) return 0;
    if (ratio > 1) return 1;
    return ratio;
  }

  bool get isCompleted => currentProgress >= targetValue;
  bool get canClaim => isCompleted && !isClaimed;

  String get typeLabel {
    switch (missionType.toLowerCase()) {
      case 'daily':
        return 'Hằng ngày';
      case 'weekly':
        return 'Hằng tuần';
      case 'event':
        return 'Sự kiện';
      case 'story':
        return 'Cốt truyện';
      default:
        return missionType.isEmpty ? 'Nhiệm vụ' : missionType;
    }
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  static int? _nullableInt(dynamic value) {
    if (value == null) return null;
    final parsed = _toInt(value);
    return parsed <= 0 ? null : parsed;
  }

  static bool _toBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    final text = value?.toString().toLowerCase().trim() ?? '';
    return text == 'true' || text == '1' || text == 'yes';
  }
}

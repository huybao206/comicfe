import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/widgets/app_top_toast.dart';
import '../model/mission_item.dart';
import '../provider/mission_provider.dart';

class MissionScreen extends StatefulWidget {
  const MissionScreen({
    super.key,
    this.showBackButton = true,
  });

  final bool showBackButton;

  @override
  State<MissionScreen> createState() => _MissionScreenState();
}

class _MissionScreenState extends State<MissionScreen> {
  static const _filters = <_MissionFilter>[
    _MissionFilter('all', 'Tất cả'),
    _MissionFilter('daily', 'Ngày'),
    _MissionFilter('weekly', 'Tuần'),
    _MissionFilter('event', 'Sự kiện'),
    _MissionFilter('story', 'Cốt truyện'),
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      context.read<MissionProvider>().loadMissions();
    });
  }

  void _goBack() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _claim(MissionItem mission) async {
    final ok = await context
        .read<MissionProvider>()
        .claimMissionReward(mission.missionId);

    if (!mounted) return;

    AppTopToast.show(
      context,
      ok
          ? 'Đã nhận thưởng nhiệm vụ: ${mission.title}'
          : context.read<MissionProvider>().errorMessage ??
          'Không nhận được thưởng nhiệm vụ',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070B15),
      body: SafeArea(
        child: Consumer<MissionProvider>(
          builder: (context, provider, _) {
            return RefreshIndicator(
              color: const Color(0xFFE0AA2E),
              backgroundColor: const Color(0xFF10192B),
              onRefresh: () => provider.loadMissions(),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                      child: _MissionHeroHeader(
                        showBackButton: widget.showBackButton,
                        onBack: _goBack,
                        completed: provider.missions
                            .where((item) => item.isCompleted)
                            .length,
                        claimable: provider.missions
                            .where((item) => item.canClaim)
                            .length,
                        total: provider.missions.length,
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 46,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          final filter = _filters[index];
                          final selected = provider.selectedType == filter.value;
                          return ChoiceChip(
                            selected: selected,
                            label: Text(filter.label),
                            selectedColor: const Color(0xFFE0AA2E),
                            backgroundColor: const Color(0xFF10192B),
                            labelStyle: TextStyle(
                              color: selected
                                  ? const Color(0xFF201400)
                                  : const Color(0xFFE8D29B),
                              fontWeight: FontWeight.w800,
                            ),
                            side: BorderSide(
                              color: selected
                                  ? const Color(0xFFE0AA2E)
                                  : const Color(0xFF263B68),
                            ),
                            onSelected: (_) => provider.setType(filter.value),
                          );
                        },
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemCount: _filters.length,
                      ),
                    ),
                  ),
                  if (provider.isLoading)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFE0AA2E),
                        ),
                      ),
                    )
                  else if (provider.errorMessage != null)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            provider.errorMessage!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Color(0xFFFFB4B4)),
                          ),
                        ),
                      ),
                    )
                  else if (provider.filteredMissions.isEmpty)
                      const SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Text(
                            'Chưa có nhiệm vụ',
                            style: TextStyle(color: Color(0xFFE8D29B)),
                          ),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                        sliver: SliverList.separated(
                          itemBuilder: (context, index) {
                            final mission = provider.filteredMissions[index];
                            return _MissionCard(
                              mission: mission,
                              onClaim: mission.canClaim
                                  ? () => _claim(mission)
                                  : null,
                            );
                          },
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemCount: provider.filteredMissions.length,
                        ),
                      ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _MissionHeroHeader extends StatelessWidget {
  const _MissionHeroHeader({
    required this.showBackButton,
    required this.onBack,
    required this.completed,
    required this.claimable,
    required this.total,
  });

  final bool showBackButton;
  final VoidCallback onBack;
  final int completed;
  final int claimable;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF1D2744), Color(0xFF0D1426)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: const Color(0xFF9C721C)),
      ),
      child: Row(
        children: [
          if (showBackButton) ...[
            InkWell(
              onTap: onBack,
              borderRadius: BorderRadius.circular(999),
              child: Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFF10192B),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: const Color(0xFF2A4778)),
                ),
                child: const Icon(
                  Icons.arrow_back_rounded,
                  color: Color(0xFFF4D37A),
                  size: 22,
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFE0AA2E),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.assignment_turned_in_rounded,
              color: Color(0xFF201400),
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Nhiệm vụ tu luyện',
                  style: TextStyle(
                    color: Color(0xFFF7E7B7),
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Hoàn thành nhiệm vụ để nhận vàng, EXP và vật phẩm.',
                  style: TextStyle(
                    color: Color(0xFFB8C2D9),
                    fontSize: 12.5,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _HeaderChip(
                      icon: Icons.list_alt_rounded,
                      text: '$total nhiệm vụ',
                    ),
                    _HeaderChip(
                      icon: Icons.done_all_rounded,
                      text: '$completed hoàn thành',
                    ),
                    _HeaderChip(
                      icon: Icons.card_giftcard_rounded,
                      text: '$claimable có thưởng',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderChip extends StatelessWidget {
  const _HeaderChip({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xAA10192B),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFF2A4778)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: const Color(0xFFE0AA2E)),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(
              color: Color(0xFFF3D896),
              fontWeight: FontWeight.w800,
              fontSize: 11.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _MissionCard extends StatelessWidget {
  const _MissionCard({
    required this.mission,
    required this.onClaim,
  });

  final MissionItem mission;
  final VoidCallback? onClaim;

  @override
  Widget build(BuildContext context) {
    final progressTarget = mission.targetValue <= 0 ? 1 : mission.targetValue;
    final progressText = '${mission.currentProgress}/$progressTarget';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF10192B),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: mission.canClaim
              ? const Color(0xFFE0AA2E)
              : const Color(0xFF2A4778),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const _MissionIcon(),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mission.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFFF7E7B7),
                        fontSize: 15.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      mission.description.trim().isEmpty
                          ? mission.targetType
                          : mission.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFFB8C2D9),
                        height: 1.3,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _MissionBadge(label: mission.typeLabel),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Text(
                'Tiến độ',
                style: TextStyle(
                  color: Color(0xFFB8C2D9),
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              Text(
                progressText,
                style: const TextStyle(
                  color: Color(0xFFF3D896),
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 7,
              value: mission.progressRatio,
              backgroundColor: const Color(0xFF22304E),
              valueColor:
              const AlwaysStoppedAnimation<Color>(Color(0xFF86A8FF)),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (mission.rewardGold > 0)
                      _RewardChip(
                        icon: Icons.monetization_on_rounded,
                        text: '${mission.rewardGold} vàng',
                      ),
                    if (mission.rewardExp > 0)
                      _RewardChip(
                        icon: Icons.auto_awesome_rounded,
                        text: '${mission.rewardExp} EXP',
                      ),
                    if (mission.rewardItemId != null)
                      _RewardChip(
                        icon: Icons.inventory_2_rounded,
                        text: 'Vật phẩm x${mission.rewardItemQuantity}',
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: onClaim,
                icon: Icon(
                  mission.isClaimed
                      ? Icons.verified_rounded
                      : Icons.card_giftcard_rounded,
                  size: 17,
                ),
                label: Text(
                  mission.isClaimed
                      ? 'Đã nhận'
                      : mission.canClaim
                      ? 'Nhận'
                      : 'Chưa xong',
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: mission.canClaim
                      ? const Color(0xFFE0AA2E)
                      : const Color(0xFF22304E),
                  foregroundColor: mission.canClaim
                      ? const Color(0xFF201400)
                      : const Color(0xFF9BA9C9),
                  disabledBackgroundColor: const Color(0xFF22304E),
                  disabledForegroundColor: const Color(0xFF9BA9C9),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MissionIcon extends StatelessWidget {
  const _MissionIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: const Color(0xFF283F7A),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Icon(
        Icons.menu_book_rounded,
        color: Color(0xFFE8D29B),
      ),
    );
  }
}

class _MissionBadge extends StatelessWidget {
  const _MissionBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF1D2C52),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFF3B5EA5)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFFBFD0FF),
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _RewardChip extends StatelessWidget {
  const _RewardChip({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF17223A),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFF2A4778)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFFE0AA2E)),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              color: Color(0xFFF0DCA3),
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _MissionFilter {
  const _MissionFilter(this.value, this.label);

  final String value;
  final String label;
}

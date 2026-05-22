import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/network/api_client.dart';
import '../../../core/widgets/app_top_toast.dart';
import '../model/cultivation_models.dart';
import '../service/cultivation_service.dart';

class CultivationScreen extends StatefulWidget {
  const CultivationScreen({super.key});

  @override
  State<CultivationScreen> createState() => _CultivationScreenState();
}

class _CultivationScreenState extends State<CultivationScreen> {
  late final CultivationService _service;
  bool _loading = true;
  bool _breaking = false;
  String? _error;
  CultivationStateData? _data;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _service = CultivationService(apiClient: context.read<ApiClient>());
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final data = await _service.getMyCultivation();
      if (!mounted) return;
      setState(() { _data = data; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = e.toString().replaceFirst('Exception: ', ''); });
    } finally {
      if (mounted) setState(() { _loading = false; });
    }
  }

  Future<void> _attempt(bool insurance) async {
    setState(() { _breaking = true; });
    try {
      final result = await _service.attemptBreakthrough(useInsurance: insurance);
      if (!mounted) return;
      final ok = result['success'] == true;
      AppTopToast.show(
        context,
        ok ? 'Đột phá thành công, cảnh giới đã tăng!' : 'Đột phá thất bại, lần sau tỉ lệ sẽ tăng thêm.',
      );
      await _load();
    } catch (e) {
      if (!mounted) return;
      AppTopToast.show(context, e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() { _breaking = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070B14),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFFE3B341)))
            : _error != null
            ? Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFFFFB4B4)))))
            : RefreshIndicator(
          onRefresh: _load,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _Hero(data: _data!),
              const SizedBox(height: 14),
              _BreakthroughPanel(data: _data!, breaking: _breaking, onAttempt: _attempt),
              const SizedBox(height: 14),
              _LevelRoadmap(levels: _data!.levels, currentLevel: _data!.levelNumber),
            ],
          ),
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.data});
  final CultivationStateData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(colors: [Color(0xFF241407), Color(0xFF102446)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        border: Border.all(color: const Color(0xFFC28A2C)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 58, height: 58, decoration: BoxDecoration(color: const Color(0xFFE0AA2E), borderRadius: BorderRadius.circular(18)), child: const Icon(Icons.auto_awesome_rounded, color: Color(0xFF221404), size: 32)),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(data.realmName.isEmpty ? 'Cảnh giới' : data.realmName, style: const TextStyle(color: Color(0xFFFFE8A8), fontSize: 23, fontWeight: FontWeight.w900)),
            const SizedBox(height: 4),
            Text('Level ${data.levelNumber} • Tầng ${data.stageNumber} • ${data.stageName}', style: const TextStyle(color: Color(0xFFD8C08B), fontWeight: FontWeight.w700)),
          ])),
        ]),
        const SizedBox(height: 18),
        Row(children: [
          _Stat(label: 'EXP', value: '${data.currentExp}/${data.expRequired}'),
          const SizedBox(width: 10),
          _Stat(label: 'Lực chiến', value: '${data.combatPower}'),
          const SizedBox(width: 10),
          _Stat(label: 'AFK', value: '${data.afkMultiplier.toStringAsFixed(3)}x'),
        ]),
        const SizedBox(height: 14),
        ClipRRect(borderRadius: BorderRadius.circular(999), child: LinearProgressIndicator(minHeight: 10, value: data.progressRatio, backgroundColor: const Color(0xFF322315), valueColor: const AlwaysStoppedAnimation(Color(0xFFE3B341)))),
      ]),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Expanded(child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFF10192B), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF283B61))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(color: Color(0xFF98A8C8), fontSize: 11, fontWeight: FontWeight.w700)), const SizedBox(height: 5), Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFFFFE8A8), fontWeight: FontWeight.w900))])));
}

class _BreakthroughPanel extends StatelessWidget {
  const _BreakthroughPanel({required this.data, required this.breaking, required this.onAttempt});
  final CultivationStateData data;
  final bool breaking;
  final Future<void> Function(bool) onAttempt;

  @override
  Widget build(BuildContext context) {
    final rule = data.currentRule;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF10192B), borderRadius: BorderRadius.circular(22), border: Border.all(color: const Color(0xFF293A5E))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Đột phá cảnh giới', style: TextStyle(color: Color(0xFFFFE8A8), fontWeight: FontWeight.w900, fontSize: 16)),
        const SizedBox(height: 8),
        if (rule == null)
          const Text('Chưa tới mốc đột phá. Hãy tích lũy EXP để lên tầng.', style: TextStyle(color: Color(0xFFB8C2D9)))
        else ...[
          Text('${rule.fromRealmName} → ${rule.toRealmName}', style: const TextStyle(color: Color(0xFFD8C08B), fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text('Vật phẩm: ${rule.requiredItemName} x${rule.requiredItemQuantity}', style: const TextStyle(color: Color(0xFFB8C2D9))),
          Text('Bảo hiểm: ${rule.insuranceItemName} x${rule.insuranceItemQuantity}', style: const TextStyle(color: Color(0xFFB8C2D9))),
          Text('Tỉ lệ hiện tại: ${rule.currentSuccessRatePercent.toStringAsFixed(0)}% • Fail +${(rule.failBonusPerFail * 100).toStringAsFixed(0)}%', style: const TextStyle(color: Color(0xFF82E0AA), fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: FilledButton(onPressed: breaking ? null : () => onAttempt(false), child: Text(breaking ? 'Đang thử...' : 'Đột phá'))),
            const SizedBox(width: 10),
            Expanded(child: OutlinedButton(onPressed: breaking ? null : () => onAttempt(true), child: const Text('Dùng bảo hiểm'))),
          ]),
        ],
      ]),
    );
  }
}

class _LevelRoadmap extends StatelessWidget {
  const _LevelRoadmap({required this.levels, required this.currentLevel});
  final List<CultivationLevel> levels;
  final int currentLevel;
  @override
  Widget build(BuildContext context) {
    final nearby = levels.where((l) => (l.levelNumber - currentLevel).abs() <= 5 || l.isBreakthroughLevel).take(60).toList();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF10192B), borderRadius: BorderRadius.circular(22), border: Border.all(color: const Color(0xFF293A5E))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Lộ trình cảnh giới', style: TextStyle(color: Color(0xFFFFE8A8), fontWeight: FontWeight.w900, fontSize: 16)),
        const SizedBox(height: 10),
        ...nearby.map((level) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: level.levelNumber == currentLevel ? const Color(0xFF2A1E0B) : const Color(0xFF0B1222), borderRadius: BorderRadius.circular(14), border: Border.all(color: level.isBreakthroughLevel ? const Color(0xFFE0AA2E) : const Color(0xFF22304E))),
          child: Row(children: [
            Expanded(child: Text('Lv.${level.levelNumber} • ${level.realmName} tầng ${level.stageNumber}', style: const TextStyle(color: Color(0xFFF1D996), fontWeight: FontWeight.w800))),
            Text('${level.expRequired} EXP', style: const TextStyle(color: Color(0xFF9BA9C9), fontSize: 12)),
          ]),
        )),
      ]),
    );
  }
}

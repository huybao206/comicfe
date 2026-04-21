import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model/vip_feature.dart';
import '../model/vip_level.dart';
import '../provider/vip_provider.dart';

class VipScreen extends StatefulWidget {
  const VipScreen({super.key});

  @override
  State<VipScreen> createState() => _VipScreenState();
}

class _VipScreenState extends State<VipScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<VipProvider>().loadAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<VipProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('VIP'),
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<VipProvider>().loadAll(),
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            const Text(
              'Hệ thống VIP',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),

            if (provider.myVip != null)
              Card(
                color: Colors.amber.shade50,
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.workspace_premium_outlined),
                  ),
                  title: Text('VIP hiện tại: ${provider.myVip!.vipLevelName}'),
                  subtitle: Text(
                    'Level ${provider.myVip!.vipLevelNumber} • '
                        'Topup: ${provider.myVip!.cumulativeTopupAmount}',
                  ),
                ),
              ),

            const SizedBox(height: 12),

            if (provider.isLoading && provider.levels.isEmpty && provider.features.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 80),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (provider.errorMessage != null &&
                provider.levels.isEmpty &&
                provider.features.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 80),
                child: Center(child: Text(provider.errorMessage!)),
              )
            else ...[
                const Text(
                  'Danh sách VIP level',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                ...provider.levels.map((level) => _levelCard(level)),

                const SizedBox(height: 18),

                const Text(
                  'Quyền lợi VIP',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                ...provider.features.map((feature) => _featureCard(feature)),
              ],
          ],
        ),
      ),
    );
  }

  Widget _levelCard(VipLevel level) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.amber.shade100,
          child: Text('${level.levelNumber}'),
        ),
        title: Text(level.levelName),
        subtitle: Text(
          'Yêu cầu tích nạp: ${level.requiredCumulativeTopup}',
        ),
        trailing: level.isActive
            ? const Icon(Icons.check_circle, color: Colors.green)
            : const Icon(Icons.cancel_outlined),
      ),
    );
  }

  Widget _featureCard(VipFeature feature) {
    return Card(
      child: ListTile(
        leading: const CircleAvatar(
          child: Icon(Icons.stars_outlined),
        ),
        title: Text(feature.featureName),
        subtitle: Text(
          '${feature.description ?? "Không có mô tả"}\n'
              'Mở ở VIP ${feature.requiredVipLevel}',
        ),
        isThreeLine: true,
        trailing: feature.isActive
            ? const Icon(Icons.check_circle, color: Colors.green)
            : const Icon(Icons.cancel_outlined),
      ),
    );
  }
}
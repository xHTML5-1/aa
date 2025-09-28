import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'di/providers.dart';
import 'features/site_management/domain/entities/expense.dart';
import 'features/site_management/domain/entities/period.dart';
import 'features/site_management/domain/entities/invoice.dart';
import 'features/site_management/domain/entities/site.dart';
import 'features/site_management/presentation/controllers/site_controller.dart';
import 'features/site_management/presentation/state/site_state.dart';

class SiteApp extends ConsumerStatefulWidget {
  const SiteApp({super.key});

  @override
  ConsumerState<SiteApp> createState() => _SiteAppState();
}

class _SiteAppState extends ConsumerState<SiteApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationServiceProvider).initialize();
      ref.read(siteControllerProvider.notifier).loadSite('demo-site');
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      useMaterial3: true,
    );
    return MaterialApp(
      title: 'Site & Aidat Yönetimi',
      theme: theme,
      home: const SiteDashboardPage(),
    );
  }
}

class SiteDashboardPage extends ConsumerWidget {
  const SiteDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(siteControllerProvider);
    final controller = ref.read(siteControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(state.site?.name ?? 'Site & Aidat Yönetimi'),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                final siteId = state.site?.id ?? 'demo-site';
                await controller.loadSite(siteId);
              },
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (state.errorMessage != null)
                    Card(
                      color: Colors.red.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          state.errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ),
                  if (state.site != null)
                    _RolesSection(roles: state.site!.roles),
                  const SizedBox(height: 16),
                  _PeriodList(
                    periods: state.periods,
                    onRun: (period) async {
                      final siteId = state.site?.id ?? 'demo-site';
                      await controller.runPeriod(siteId, period);
                    },
                    onPublish: (period) async {
                      final siteId = state.site?.id ?? 'demo-site';
                      await controller.publishPeriod(siteId, period.id);
                    },
                  ),
                  const SizedBox(height: 16),
                  _InvoiceList(
                    invoices: state.invoices,
                    onCollect: (invoice) async {
                      final siteId = state.site?.id ?? 'demo-site';
                      await controller.collectPayment(
                        siteId,
                        invoice.id,
                        'iyzico',
                      );
                    },
                    onMarkPaid: (invoice) async {
                      final siteId = state.site?.id ?? 'demo-site';
                      await controller.markInvoicePaid(siteId, invoice.id);
                    },
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final site = state.site ??
              Site(id: 'demo-site', name: 'Demo Site', units: const [], roles: const []);
          final newPeriod = Period(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            name: 'Yeni Dönem',
            siteId: site.id,
            expenses: const [
              ExpenseItem(
                id: 'exp-1',
                name: 'Genel Temizlik',
                amount: 15000,
                distributionType: ExpenseDistributionType.squareMeter,
              ),
            ],
            status: PeriodStatus.draft,
          );
          controller.runPeriod(site.id, newPeriod);
        },
        child: const Icon(Icons.play_circle_outline),
      ),
    );
  }
}

class _RolesSection extends StatelessWidget {
  const _RolesSection({required this.roles});

  final List<String> roles;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Roller',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: roles
                  .map((role) => Chip(
                        label: Text(role.replaceAll('_', ' ')),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _PeriodList extends StatelessWidget {
  const _PeriodList({
    required this.periods,
    required this.onRun,
    required this.onPublish,
  });

  final List<Period> periods;
  final ValueChanged<Period> onRun;
  final ValueChanged<Period> onPublish;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Dönemler',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        if (periods.isEmpty)
          const Text('Henüz dönem bulunmuyor'),
        ...periods.map((period) => Card(
              child: ListTile(
                title: Text(period.name),
                subtitle: Text('Durum: ${period.status.name}'),
                trailing: Wrap(
                  spacing: 8,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.calculate_outlined),
                      onPressed: () => onRun(period),
                    ),
                    IconButton(
                      icon: const Icon(Icons.publish_outlined),
                      onPressed: () => onPublish(period),
                    ),
                  ],
                ),
              ),
            )),
      ],
    );
  }
}

class _InvoiceList extends StatelessWidget {
  const _InvoiceList({
    required this.invoices,
    required this.onCollect,
    required this.onMarkPaid,
  });

  final List<Invoice> invoices;
  final ValueChanged<Invoice> onCollect;
  final ValueChanged<Invoice> onMarkPaid;

  @override
  Widget build(BuildContext context) {
    if (invoices.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Faturalar',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        ...invoices.map((invoice) => Card(
              child: ListTile(
                title: Text('${invoice.tenantName} - ${invoice.total.toStringAsFixed(2)} ₺'),
                subtitle: Text('Durum: ${invoice.paymentStatus}'),
                trailing: Wrap(
                  spacing: 8,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.payment),
                      onPressed: () => onCollect(invoice),
                    ),
                    IconButton(
                      icon: const Icon(Icons.check_circle_outline),
                      onPressed: () => onMarkPaid(invoice),
                    ),
                  ],
                ),
              ),
            )),
      ],
    );
  }
}

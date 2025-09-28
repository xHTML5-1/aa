import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:site_aidat_management/features/site_management/domain/entities/expense.dart';
import 'package:site_aidat_management/features/site_management/domain/entities/invoice.dart';
import 'package:site_aidat_management/features/site_management/domain/entities/period.dart';
import 'package:site_aidat_management/features/site_management/domain/repositories/site_repository.dart';
import 'package:site_aidat_management/features/site_management/domain/usecases/run_period.dart';

class _MockSiteRepository extends Mock implements SiteRepository {}

void main() {
  group('RunPeriod', () {
    late _MockSiteRepository repository;
    late RunPeriod useCase;

    setUp(() {
      repository = _MockSiteRepository();
      useCase = RunPeriod(repository);
    });

    test('should call repository with correct parameters', () async {
      final period = Period(
        id: 'period-1',
        name: 'Ocak 2024',
        siteId: 'demo-site',
        expenses: const [
          ExpenseItem(
            id: 'exp-1',
            name: 'Güvenlik',
            amount: 1000,
            distributionType: ExpenseDistributionType.fixed,
          ),
        ],
        status: PeriodStatus.draft,
      );
      final invoices = [
        Invoice(
          id: 'inv-1',
          periodId: 'period-1',
          periodName: 'Ocak 2024',
          unitId: 'unit-1',
          tenantId: 'tenant-1',
          tenantName: 'Sakin 1',
          items: const [
            InvoiceItem(description: 'Güvenlik', amount: 500),
          ],
          total: 500,
        ),
      ];

      when(() => repository.runPeriod('demo-site', period))
          .thenAnswer((_) async => invoices);

      final result = await useCase(const RunPeriodParams(
        siteId: 'demo-site',
        period: period,
      ));

      expect(result.isRight(), isTrue);
      expect(result.getOrElse(() => []), equals(invoices));
      verify(() => repository.runPeriod('demo-site', period)).called(1);
    });
  });
}

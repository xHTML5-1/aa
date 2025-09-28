import '../../domain/entities/period.dart';
import 'expense_model.dart';

class PeriodModel extends Period {
  PeriodModel({
    required super.id,
    required super.name,
    required super.siteId,
    required List<ExpenseItem> super.expenses,
    required super.status,
    super.generatedInvoices = const <String>[],
    super.createdAt,
  });

  factory PeriodModel.fromJson(Map<String, dynamic> json) {
    return PeriodModel(
      id: json['id'] as String,
      name: json['name'] as String,
      siteId: json['site_id'] as String,
      expenses: (json['expenses'] as List)
          .map((dynamic item) => ExpenseModel.fromJson(
                Map<String, dynamic>.from(item as Map),
              ))
          .toList(),
      status: PeriodStatus.values.firstWhere(
        (element) => element.name == (json['status'] as String),
        orElse: () => PeriodStatus.draft,
      ),
      generatedInvoices: json['generated_invoices'] == null
          ? const <String>[]
          : List<String>.from(json['generated_invoices'] as List),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'name': name,
        'site_id': siteId,
        'expenses': expenses
            .map((item) => item is ExpenseModel
                ? item.toJson()
                : ExpenseModel(
                    id: item.id,
                    name: item.name,
                    amount: item.amount,
                    distributionType: item.distributionType,
                    meterReadings: item.meterReadings,
                  ).toJson())
            .toList(),
        'status': status.name,
        'generated_invoices': generatedInvoices,
        'created_at': createdAt?.toIso8601String(),
      };
}

import '../../domain/entities/invoice.dart';

class InvoiceModel extends Invoice {
  const InvoiceModel({
    required super.id,
    required super.periodId,
    required super.periodName,
    required super.unitId,
    required super.tenantId,
    required super.tenantName,
    required List<InvoiceItem> super.items,
    required super.total,
    super.paymentStatus,
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    return InvoiceModel(
      id: json['id'] as String,
      periodId: json['period_id'] as String,
      periodName: json['period_name'] as String,
      unitId: json['unit_id'] as String,
      tenantId: json['tenant_id'] as String,
      tenantName: json['tenant_name'] as String,
      items: (json['items'] as List)
          .map(
            (dynamic item) => InvoiceItem(
              description: (item as Map)['description'] as String,
              amount: ((item)['amount'] as num).toDouble(),
            ),
          )
          .toList(),
      total: (json['total'] as num).toDouble(),
      paymentStatus: json['payment_status'] as String,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'period_id': periodId,
        'period_name': periodName,
        'unit_id': unitId,
        'tenant_id': tenantId,
        'tenant_name': tenantName,
        'items': items
            .map((item) => <String, dynamic>{
                  'description': item.description,
                  'amount': item.amount,
                })
            .toList(),
        'total': total,
        'payment_status': paymentStatus,
      };
}

class InvoiceItem {
  const InvoiceItem({
    required this.description,
    required this.amount,
  });

  final String description;
  final double amount;
}

class Invoice {
  const Invoice({
    required this.id,
    required this.periodId,
    required this.periodName,
    required this.unitId,
    required this.tenantId,
    required this.tenantName,
    required this.items,
    required this.total,
    this.paymentStatus = 'unpaid',
  });

  final String id;
  final String periodId;
  final String periodName;
  final String unitId;
  final String tenantId;
  final String tenantName;
  final List<InvoiceItem> items;
  final double total;
  final String paymentStatus;

  Invoice copyWith({String? paymentStatus}) => Invoice(
        id: id,
        periodId: periodId,
        periodName: periodName,
        unitId: unitId,
        tenantId: tenantId,
        tenantName: tenantName,
        items: items,
        total: total,
        paymentStatus: paymentStatus ?? this.paymentStatus,
      );
}

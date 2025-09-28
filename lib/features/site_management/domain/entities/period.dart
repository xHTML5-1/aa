import 'expense.dart';

enum PeriodStatus { draft, processing, published }

class Period {
  const Period({
    required this.id,
    required this.name,
    required this.siteId,
    required this.expenses,
    required this.status,
    this.generatedInvoices = const <String>[],
    this.createdAt,
  });

  final String id;
  final String name;
  final String siteId;
  final List<ExpenseItem> expenses;
  final PeriodStatus status;
  final List<String> generatedInvoices;
  final DateTime? createdAt;

  Period copyWith({
    PeriodStatus? status,
    List<String>? generatedInvoices,
  }) {
    return Period(
      id: id,
      name: name,
      siteId: siteId,
      expenses: expenses,
      status: status ?? this.status,
      generatedInvoices: generatedInvoices ?? this.generatedInvoices,
      createdAt: createdAt,
    );
  }
}

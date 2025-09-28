enum ExpenseDistributionType {
  landShare,
  squareMeter,
  fixed,
  meter,
}

class ExpenseItem {
  const ExpenseItem({
    required this.id,
    required this.name,
    required this.amount,
    required this.distributionType,
    this.meterReadings = const <String, double>{},
  });

  final String id;
  final String name;
  final double amount;
  final ExpenseDistributionType distributionType;
  final Map<String, double> meterReadings;
}

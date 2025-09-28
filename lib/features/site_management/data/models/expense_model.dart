import '../../domain/entities/expense.dart';

class ExpenseModel extends ExpenseItem {
  const ExpenseModel({
    required super.id,
    required super.name,
    required super.amount,
    required super.distributionType,
    super.meterReadings = const <String, double>{},
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id'] as String,
      name: json['name'] as String,
      amount: (json['amount'] as num).toDouble(),
      distributionType: ExpenseDistributionType.values
          .firstWhere(
            (type) => type.name == (json['distribution_type'] as String),
          ),
      meterReadings: json['meter_readings'] == null
          ? const <String, double>{}
          : Map<String, double>.from(
              (json['meter_readings'] as Map).map(
                (key, value) => MapEntry(key as String, (value as num).toDouble()),
              ),
            ),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'name': name,
        'amount': amount,
        'distribution_type': distributionType.name,
        'meter_readings': meterReadings,
      };
}

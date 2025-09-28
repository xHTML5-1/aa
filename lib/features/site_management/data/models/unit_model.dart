import '../../domain/entities/unit.dart';

class UnitModel extends Unit {
  const UnitModel({
    required super.id,
    required super.block,
    required super.floor,
    required super.number,
    required super.squareMeter,
    required super.landShare,
    required super.tenantId,
  });

  factory UnitModel.fromJson(Map<String, dynamic> json) {
    return UnitModel(
      id: json['id'] as String,
      block: json['block'] as String,
      floor: json['floor'] as int,
      number: json['number'] as String,
      squareMeter: (json['square_meter'] as num).toDouble(),
      landShare: (json['land_share'] as num).toDouble(),
      tenantId: json['tenant_id'] as String,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'block': block,
        'floor': floor,
        'number': number,
        'square_meter': squareMeter,
        'land_share': landShare,
        'tenant_id': tenantId,
      };
}

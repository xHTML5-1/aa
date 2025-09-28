import '../../domain/entities/site.dart';
import 'unit_model.dart';

class SiteModel extends Site {
  const SiteModel({
    required super.id,
    required super.name,
    required List<UnitModel> super.units,
    required super.roles,
  });

  factory SiteModel.fromJson(Map<String, dynamic> json) {
    return SiteModel(
      id: json['id'] as String,
      name: json['name'] as String,
      units: (json['units'] as List)
          .map((dynamic item) => UnitModel.fromJson(
                Map<String, dynamic>.from(item as Map),
              ))
          .toList(),
      roles: List<String>.from(json['roles'] as List),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'name': name,
        'units': units.map((unit) => (unit as UnitModel).toJson()).toList(),
        'roles': roles,
      };
}

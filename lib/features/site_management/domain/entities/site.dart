import 'unit.dart';

class Site {
  const Site({
    required this.id,
    required this.name,
    required this.units,
    required this.roles,
  });

  final String id;
  final String name;
  final List<Unit> units;
  final List<String> roles;
}

class Unit {
  const Unit({
    required this.id,
    required this.block,
    required this.floor,
    required this.number,
    required this.squareMeter,
    required this.landShare,
    required this.tenantId,
  });

  final String id;
  final String block;
  final int floor;
  final String number;
  final double squareMeter;
  final double landShare;
  final String tenantId;
}

import 'package:floor/floor.dart';

@entity
class MaterialRequisition {
  @primaryKey
  final String id;
  final String projectName;
  final String requestedBy;
  final String department;
  final String materialDescription;
  final double quantity;
  final String unit;
  final String purpose;
  final DateTime requestDate;
  final DateTime? requiredDate;
  final DateTime createdAt;

  MaterialRequisition({
    required this.id,
    required this.projectName,
    required this.requestedBy,
    required this.department,
    required this.materialDescription,
    required this.quantity,
    required this.unit,
    required this.purpose,
    required this.requestDate,
    this.requiredDate,
    required this.createdAt,
  });

  // Copy with method for updating
  MaterialRequisition copyWith({
    String? id,
    String? projectName,
    String? requestedBy,
    String? department,
    String? materialDescription,
    double? quantity,
    String? unit,
    String? purpose,
    DateTime? requestDate,
    DateTime? requiredDate,
    DateTime? createdAt,
  }) {
    return MaterialRequisition(
      id: id ?? this.id,
      projectName: projectName ?? this.projectName,
      requestedBy: requestedBy ?? this.requestedBy,
      department: department ?? this.department,
      materialDescription: materialDescription ?? this.materialDescription,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      purpose: purpose ?? this.purpose,
      requestDate: requestDate ?? this.requestDate,
      requiredDate: requiredDate ?? this.requiredDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
import 'dart:convert';
import 'dtr_model.dart';
import 'pole_model.dart';

/// DTR model specifically for Google Sheets integration
/// This model includes all the fields needed for the Google Sheets integration
/// and provides JSON serialization methods
class DTRSheet {
  final String dtrCode;
  final String dtrName;
  final String createdAt;
  final String createdBy;
  final Map<String, dynamic> meta;
  final List<PoleSheet> poles;

  DTRSheet({
    required this.dtrCode,
    required this.dtrName,
    required this.createdAt,
    required this.createdBy,
    required this.meta,
    required this.poles,
  });

  /// Create a DTRSheet from a DTR and its poles
  factory DTRSheet.fromDTR(DTR dtr, List<Pole> poles, String userId) {
    return DTRSheet(
      dtrCode: dtr.dtrCode,
      dtrName: dtr.village, // Using village as the DTR name
      createdAt: DateTime.now().toIso8601String(),
      createdBy: userId,
      meta: {
        'capacity': dtr.capacity,
        'village': dtr.village,
        'location': dtr.location,
        'landMarks': dtr.landMarks,
        'ccc': dtr.ccc,
        'feeder': dtr.feeder,
        'substation': dtr.substation,
        'drgNo': dtr.drgNo,
        'docDate': dtr.docDate,
        'jmcNo': dtr.jmcNo,
        'gp': dtr.gp,
        'censusCode': dtr.censusCode,
        'block': dtr.block,
        'division': dtr.division,
        'user': dtr.user,
      },
      poles: poles.map((pole) => PoleSheet.fromPole(pole)).toList(),
    );
  }

  /// Convert DTRSheet to JSON map
  Map<String, dynamic> toJson() {
    return {
      'dtrCode': dtrCode,
      'dtrName': dtrName,
      'createdAt': createdAt,
      'createdBy': createdBy,
      'meta': meta,
      'poles': poles.map((pole) => pole.toJson()).toList(),
    };
  }

  /// Create DTRSheet from JSON map
  factory DTRSheet.fromJson(Map<String, dynamic> json) {
    return DTRSheet(
      dtrCode: json['dtrCode'] as String,
      dtrName: json['dtrName'] as String,
      createdAt: json['createdAt'] as String,
      createdBy: json['createdBy'] as String,
      meta: Map<String, dynamic>.from(json['meta'] as Map),
      poles: (json['poles'] as List)
          .map((pole) => PoleSheet.fromJson(Map<String, dynamic>.from(pole)))
          .toList(),
    );
  }

  /// Convert DTRSheet to JSON string
  String toJsonString() {
    return jsonEncode(toJson());
  }

  /// Create DTRSheet from JSON string
  factory DTRSheet.fromJsonString(String jsonString) {
    return DTRSheet.fromJson(jsonDecode(jsonString));
  }
}

/// Pole model specifically for Google Sheets integration
class PoleSheet {
  final String poleNo;
  final String poleType;
  final double routeLength;
  final int newPccPoleCount;
  final int quantity;
  final String remarks;
  // Add other pole fields as needed

  PoleSheet({
    required this.poleNo,
    required this.poleType,
    required this.routeLength,
    required this.newPccPoleCount,
    required this.quantity,
    required this.remarks,
  });

  /// Create a PoleSheet from a Pole
  factory PoleSheet.fromPole(Pole pole) {
    return PoleSheet(
      poleNo: pole.poleNo,
      poleType: pole.typeOfPole,
      routeLength: pole.routhLength,
      newPccPoleCount: pole.newPole,
      quantity: 1, // You might want to calculate this differently
      remarks: pole.remarks,
    );
  }

  /// Convert PoleSheet to JSON map
  Map<String, dynamic> toJson() {
    return {
      'poleNo': poleNo,
      'poleType': poleType,
      'routeLength': routeLength,
      'newPccPoleCount': newPccPoleCount,
      'quantity': quantity,
      'remarks': remarks,
    };
  }

  /// Create PoleSheet from JSON map
  factory PoleSheet.fromJson(Map<String, dynamic> json) {
    return PoleSheet(
      poleNo: json['poleNo'] as String,
      poleType: json['poleType'] as String,
      routeLength: (json['routeLength'] as num).toDouble(),
      newPccPoleCount: json['newPccPoleCount'] as int,
      quantity: json['quantity'] as int,
      remarks: json['remarks'] as String,
    );
  }
}
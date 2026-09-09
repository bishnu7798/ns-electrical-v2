class DTR {
  final String id;
  final String dtrCode;
  final String capacity;
  final String village;
  final String location;
  final String landMarks;
  final String ccc;
  final String feeder;
  final String _substation; // Changed from feederCapacity
  final String drgNo;
  final String docDate;
  final String jmcNo;
  final String gp;
  final String censusCode;
  final String block; // Added Block field
  final String division; // Added Division field
  final String user; // Added User field
  final List<String> connectedPoles;

  // Getter for substation
  String get substation => _substation;

  DTR({
    required this.id,
    required this.dtrCode,
    required this.capacity,
    required this.village,
    required this.location,
    required this.landMarks,
    required this.ccc,
    required this.feeder,
    required String substation, // Changed from feederCapacity
    required this.drgNo,
    required this.docDate,
    required this.jmcNo,
    required this.gp,
    required this.censusCode,
    required this.block, // Added Block field
    required this.division, // Added Division field
    required this.user, // Added User field
    required this.connectedPoles,
  }) : _substation = substation;

  // Convert DTR to Map for storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'dtrCode': dtrCode,
      'capacity': capacity,
      'village': village,
      'location': location,
      'landMarks': landMarks,
      'ccc': ccc,
      'feeder': feeder,
      'substation': _substation, // Changed from feederCapacity
      'drgNo': drgNo,
      'docDate': docDate,
      'jmcNo': jmcNo,
      'gp': gp,
      'censusCode': censusCode,
      'block': block, // Added Block field
      'division': division, // Added Division field
      'user': user, // Added User field
      'connectedPoles': connectedPoles,
    };
  }

  // Create DTR from Map
  factory DTR.fromMap(Map<String, dynamic> map) {
    return DTR(
      id: map['id']?.toString() ?? '',
      dtrCode: map['dtrCode']?.toString() ?? '',
      capacity: map['capacity']?.toString() ?? '',
      village: map['village']?.toString() ?? '',
      location: map['location']?.toString() ?? '',
      landMarks: map['landMarks']?.toString() ?? '',
      ccc: map['ccc']?.toString() ?? '',
      feeder: map['feeder']?.toString() ?? '',
      substation: map['substation']?.toString() ?? '', // Changed from feederCapacity
      drgNo: map['drgNo']?.toString() ?? '',
      docDate: map['docDate']?.toString() ?? '',
      jmcNo: map['jmcNo']?.toString() ?? '',
      gp: map['gp']?.toString() ?? '',
      censusCode: map['censusCode']?.toString() ?? '',
      block: map['block']?.toString() ?? '', // Added Block field
      division: map['division']?.toString() ?? '', // Added Division field
      user: map['user']?.toString() ?? '', // Added User field
      connectedPoles: List<String>.from(map['connectedPoles'] ?? []),
    );
  }
}
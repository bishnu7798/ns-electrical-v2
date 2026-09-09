class Pole {
  final String id;
  final int slNo;
  final String typeOfPole;
  final String gpsNo;
  final String poleNo;
  final double routhLength;
  final int newPole;
  final int staySet;
  final int stayClampType1;
  final int stayClampType2;
  final int giEarthSpike;
  final int suspension;
  final int deadEnd;
  final int distributionJunctionBox;
  final int eyeHook;
  final int ltPoleClampType1;
  final int ltPoleClampType2;
  final int ipcForDB50To70;
  final int ipcFor16SQMM;
  final int ipcForAbcToAbc50To70SQMM;
  final int straightThroughJoint70SQMM;
  final int straightThroughJoint16SQMM;
  final int straightThroughJoint50SQMM;
  final int serviceConnection1ph;
  final int serviceConnection3ph;
  final String remarks;
  final String dtrId;
  
  // Dismantle Inventory fields
  final int ltBracket1Ph;
  final int ltBracket3Ph;
  final int backClamp;
  final int dIronClamp;
  final int shackleInsulator;
  final int ciReel;
  final int shackleStrap;
  final int boxBracket;
  final int lc;
  final int exStay;
  
  // Wire specification and configuration fields
  final String wireType;
  final String wireConfiguration;

  Pole({
    required this.id,
    required this.slNo,
    required this.typeOfPole,
    required this.gpsNo,
    required this.poleNo,
    required this.routhLength,
    required this.newPole,
    required this.staySet,
    required this.stayClampType1,
    required this.stayClampType2,
    required this.giEarthSpike,
    required this.suspension,
    required this.deadEnd,
    required this.distributionJunctionBox,
    required this.eyeHook,
    required this.ltPoleClampType1,
    required this.ltPoleClampType2,
    required this.ipcForDB50To70,
    required this.ipcFor16SQMM,
    required this.ipcForAbcToAbc50To70SQMM,
    required this.straightThroughJoint70SQMM,
    required this.straightThroughJoint16SQMM,
    required this.straightThroughJoint50SQMM,
    required this.serviceConnection1ph,
    required this.serviceConnection3ph,
    required this.remarks,
    required this.dtrId,
    
    // Dismantle Inventory fields
    required this.ltBracket1Ph,
    required this.ltBracket3Ph,
    required this.backClamp,
    required this.dIronClamp,
    required this.shackleInsulator,
    required this.ciReel,
    required this.shackleStrap,
    required this.boxBracket,
    required this.lc,
    required this.exStay,
    // Wire specification and configuration fields
    required this.wireType,
    required this.wireConfiguration,
  });

  // Convert Pole to Map for storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'slNo': slNo,
      'typeOfPole': typeOfPole,
      'gpsNo': gpsNo,
      'poleNo': poleNo,
      'routhLength': routhLength,
      'newPole': newPole,
      'staySet': staySet,
      'stayClampType1': stayClampType1,
      'stayClampType2': stayClampType2,
      'giEarthSpike': giEarthSpike,
      'suspension': suspension,
      'deadEnd': deadEnd,
      'distributionJunctionBox': distributionJunctionBox,
      'eyeHook': eyeHook,
      'ltPoleClampType1': ltPoleClampType1,
      'ltPoleClampType2': ltPoleClampType2,
      'ipcForDB50To70': ipcForDB50To70,
      'ipcFor16SQMM': ipcFor16SQMM,
      'ipcForAbcToAbc50To70SQMM': ipcForAbcToAbc50To70SQMM,
      'straightThroughJoint70SQMM': straightThroughJoint70SQMM,
      'straightThroughJoint16SQMM': straightThroughJoint16SQMM,
      'straightThroughJoint50SQMM': straightThroughJoint50SQMM,
      'serviceConnection1ph': serviceConnection1ph,
      'serviceConnection3ph': serviceConnection3ph,
      'remarks': remarks,
      'dtrId': dtrId,
      // Dismantle Inventory fields
      'ltBracket1Ph': ltBracket1Ph,
      'ltBracket3Ph': ltBracket3Ph,
      'backClamp': backClamp,
      'dIronClamp': dIronClamp,
      'shackleInsulator': shackleInsulator,
      'ciReel': ciReel,
      'shackleStrap': shackleStrap,
      'boxBracket': boxBracket,
      'lc': lc,
      'exStay': exStay,
      // Wire specification and configuration fields
      'wireType': wireType,
      'wireConfiguration': wireConfiguration,
    };
  }

  // Create Pole from Map
  factory Pole.fromMap(Map<String, dynamic> map) {
    return Pole(
      id: map['id']?.toString() ?? '',
      slNo: map['slNo'] is int ? map['slNo'] : int.tryParse(map['slNo'].toString()) ?? 0,
      typeOfPole: map['typeOfPole']?.toString() ?? '',
      gpsNo: map['gpsNo']?.toString() ?? '',
      poleNo: map['poleNo']?.toString() ?? '',
      routhLength: map['routhLength'] is double 
          ? map['routhLength'] 
          : double.tryParse(map['routhLength'].toString()) ?? 0.0,
      newPole: map['newPole'] is int ? map['newPole'] : int.tryParse(map['newPole'].toString()) ?? 0,
      staySet: map['staySet'] is int ? map['staySet'] : int.tryParse(map['staySet'].toString()) ?? 0,
      stayClampType1: map['stayClampType1'] is int ? map['stayClampType1'] : int.tryParse(map['stayClampType1'].toString()) ?? 0,
      stayClampType2: map['stayClampType2'] is int ? map['stayClampType2'] : int.tryParse(map['stayClampType2'].toString()) ?? 0,
      giEarthSpike: map['giEarthSpike'] is int ? map['giEarthSpike'] : int.tryParse(map['giEarthSpike'].toString()) ?? 0,
      suspension: map['suspension'] is int ? map['suspension'] : int.tryParse(map['suspension'].toString()) ?? 0,
      deadEnd: map['deadEnd'] is int ? map['deadEnd'] : int.tryParse(map['deadEnd'].toString()) ?? 0,
      distributionJunctionBox: map['distributionJunctionBox'] is int ? map['distributionJunctionBox'] : int.tryParse(map['distributionJunctionBox'].toString()) ?? 0,
      eyeHook: map['eyeHook'] is int ? map['eyeHook'] : int.tryParse(map['eyeHook'].toString()) ?? 0,
      ltPoleClampType1: map['ltPoleClampType1'] is int ? map['ltPoleClampType1'] : int.tryParse(map['ltPoleClampType1'].toString()) ?? 0,
      ltPoleClampType2: map['ltPoleClampType2'] is int ? map['ltPoleClampType2'] : int.tryParse(map['ltPoleClampType2'].toString()) ?? 0,
      ipcForDB50To70: map['ipcForDB50To70'] is int ? map['ipcForDB50To70'] : int.tryParse(map['ipcForDB50To70'].toString()) ?? 0,
      ipcFor16SQMM: map['ipcFor16SQMM'] is int ? map['ipcFor16SQMM'] : int.tryParse(map['ipcFor16SQMM'].toString()) ?? 0,
      ipcForAbcToAbc50To70SQMM: map['ipcForAbcToAbc50To70SQMM'] is int ? map['ipcForAbcToAbc50To70SQMM'] : int.tryParse(map['ipcForAbcToAbc50To70SQMM'].toString()) ?? 0,
      straightThroughJoint70SQMM: map['straightThroughJoint70SQMM'] is int ? map['straightThroughJoint70SQMM'] : int.tryParse(map['straightThroughJoint70SQMM'].toString()) ?? 0,
      straightThroughJoint16SQMM: map['straightThroughJoint16SQMM'] is int ? map['straightThroughJoint16SQMM'] : int.tryParse(map['straightThroughJoint16SQMM'].toString()) ?? 0,
      straightThroughJoint50SQMM: map['straightThroughJoint50SQMM'] is int ? map['straightThroughJoint50SQMM'] : int.tryParse(map['straightThroughJoint50SQMM'].toString()) ?? 0,
      serviceConnection1ph: map['serviceConnection1ph'] is int ? map['serviceConnection1ph'] : int.tryParse(map['serviceConnection1ph'].toString()) ?? 0,
      serviceConnection3ph: map['serviceConnection3ph'] is int ? map['serviceConnection3ph'] : int.tryParse(map['serviceConnection3ph'].toString()) ?? 0,
      remarks: map['remarks']?.toString() ?? '',
      dtrId: map['dtrId']?.toString() ?? '',
      // Dismantle Inventory fields
      ltBracket1Ph: map['ltBracket1Ph'] is int ? map['ltBracket1Ph'] : int.tryParse(map['ltBracket1Ph'].toString()) ?? 0,
      ltBracket3Ph: map['ltBracket3Ph'] is int ? map['ltBracket3Ph'] : int.tryParse(map['ltBracket3Ph'].toString()) ?? 0,
      backClamp: map['backClamp'] is int ? map['backClamp'] : int.tryParse(map['backClamp'].toString()) ?? 0,
      dIronClamp: map['dIronClamp'] is int ? map['dIronClamp'] : int.tryParse(map['dIronClamp'].toString()) ?? 0,
      shackleInsulator: map['shackleInsulator'] is int ? map['shackleInsulator'] : int.tryParse(map['shackleInsulator'].toString()) ?? 0,
      ciReel: map['ciReel'] is int ? map['ciReel'] : int.tryParse(map['ciReel'].toString()) ?? 0,
      shackleStrap: map['shackleStrap'] is int ? map['shackleStrap'] : int.tryParse(map['shackleStrap'].toString()) ?? 0,
      boxBracket: map['boxBracket'] is int ? map['boxBracket'] : int.tryParse(map['boxBracket'].toString()) ?? 0,
      lc: map['lc'] is int ? map['lc'] : int.tryParse(map['lc'].toString()) ?? 0,
      exStay: map['exStay'] is int ? map['exStay'] : int.tryParse(map['exStay'].toString()) ?? 0,
      // Wire specification and configuration fields
      wireType: map['wireType']?.toString() ?? '',
      wireConfiguration: map['wireConfiguration']?.toString() ?? '',
    );
  }
}
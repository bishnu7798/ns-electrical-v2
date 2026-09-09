import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/models/dtr_model.dart';
import '../../core/models/pole_model.dart';
import '../../core/services/pole_service.dart';
import '../../shared/utils/responsive_utils.dart';

class AddPoleScreenNew extends StatefulWidget {
  const AddPoleScreenNew({super.key, required this.dtr, this.poleToEdit});

  final DTR dtr;
  final Pole? poleToEdit;

  @override
  State<AddPoleScreenNew> createState() => _AddPoleScreenNewState();
}

class _AddPoleScreenNewState extends State<AddPoleScreenNew> {
  final _backClampController = TextEditingController();
  final _boxBracketController = TextEditingController();
  final _ciReelController = TextEditingController();
  final _dIronClampController = TextEditingController();
  final _deadEndController = TextEditingController();
  final _deadEndFocusNode = FocusNode();
  final _distributionJunctionBoxController = TextEditingController();
  final _distributionJunctionBoxFocusNode = FocusNode();
  final _exStayController = TextEditingController();
   int _exStayOption = 0;
  final _eyeHookController = TextEditingController();
  final _eyeHookFocusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();
  final _giEarthSpikeController = TextEditingController();
  final _giEarthSpikeFocusNode = FocusNode();
  final _gpsNoController = TextEditingController();
  // Focus nodes for smart navigation
  final _gpsNoFocusNode = FocusNode();

  final _ipcFor16SQMMController = TextEditingController();
  final _ipcFor16SQMMFocusNode = FocusNode();
  final _ipcForAbcToAbc50To70SQMMController = TextEditingController();
  final _ipcForAbcToAbc50To70SQMMFocusNode = FocusNode();
  final _ipcForDB50To70Controller = TextEditingController();
  final _ipcForDB50To70FocusNode = FocusNode();
  bool _isAddNewButtonEnabled = false;
  // Switch state for dismantle inventory
  bool _isDismantle = false;

  bool _isPoleNoReadOnly = true;
  // Button state
  bool _isSaveButtonEnabled = false;

  final _lcController = TextEditingController();
  // Dismantle Inventory controllers
  final _ltBracket1PhController = TextEditingController();

  final _ltBracket3PhController = TextEditingController();
  final _ltPoleClampType1Controller = TextEditingController();
  final _ltPoleClampType1FocusNode = FocusNode();
  final _ltPoleClampType2Controller = TextEditingController();
  final _ltPoleClampType2FocusNode = FocusNode();
  final _newPoleController = TextEditingController();
  final _newPoleFocusNode = FocusNode();
  final _poleNoController = TextEditingController();
  final _poleNoFocusNode = FocusNode();
  final _poleService = PoleService();
  final _remarksController = TextEditingController();
  final _routhLengthController = TextEditingController();
  final _routhLengthFocusNode = FocusNode();
  // Scroll controller for smooth scrolling
  final ScrollController _scrollController = ScrollController();

  // Wire configuration selection
  String _selectedWireConfiguration = '';

  // Wire specification selection
  String _selectedWireType = '';

  final _serviceConnection1phController = TextEditingController();
  final _serviceConnection1phFocusNode = FocusNode();
  final _serviceConnection3phController = TextEditingController();
  final _serviceConnection3phFocusNode = FocusNode();
  final _shackleInsulatorController = TextEditingController();
  final _shackleStrapController = TextEditingController();
  // Add this new state variable to control GPS field visibility
  bool _showGpsField = false;

  // Add this new state variable to control Straight Through Joint visibility
  // Changed default to false to hide for all poles
  bool _showStraightThroughJoint = false;

  // Form controllers
  final _slNoController = TextEditingController();

  final _stayClampType1Controller = TextEditingController();
  final _stayClampType1FocusNode = FocusNode();
  // Flag to track if Stay Clamp Type 1 was manually edited
  bool _stayClampType1ManuallyEdited = false;

  final _stayClampType2Controller = TextEditingController();
  final _stayClampType2FocusNode = FocusNode();
  // Accessories controllers
  final _staySetController = TextEditingController();

  final _staySetFocusNode = FocusNode();
  final _straightThroughJoint16SQMMController = TextEditingController();
  final _straightThroughJoint16SQMMFocusNode = FocusNode();
  final _straightThroughJoint50SQMMController = TextEditingController();
  final _straightThroughJoint50SQMMFocusNode = FocusNode();
  final _straightThroughJoint70SQMMController = TextEditingController();
  final _straightThroughJoint70SQMMFocusNode = FocusNode();
  final _suspensionController = TextEditingController();
  final _suspensionFocusNode = FocusNode();
  // Form values with default values
  String _typeOfPole = '';

  final _typeOfPoleController = TextEditingController();

  @override
  void dispose() {
    _slNoController.dispose();
    _typeOfPoleController.dispose();
    _gpsNoController.dispose();
    _poleNoController.dispose();
    _routhLengthController.dispose();
    _newPoleController.dispose();
    _remarksController.dispose();

    _staySetController.dispose();
    _stayClampType1Controller.dispose();
    _stayClampType2Controller.dispose();
    _giEarthSpikeController.dispose();
    _suspensionController.dispose();
    _deadEndController.dispose();
    _distributionJunctionBoxController.dispose();
    _eyeHookController.dispose();
    _ltPoleClampType1Controller.dispose();
    _ltPoleClampType2Controller.dispose();
    _ipcForDB50To70Controller.dispose();
    _ipcFor16SQMMController.dispose();
    _ipcForAbcToAbc50To70SQMMController.dispose();
    _straightThroughJoint70SQMMController.dispose();
    _straightThroughJoint16SQMMController.dispose();
    _straightThroughJoint50SQMMController.dispose();
    _serviceConnection1phController.dispose();
    _serviceConnection3phController.dispose();

    _ltBracket1PhController.dispose();
    _ltBracket3PhController.dispose();
    _backClampController.dispose();
    _dIronClampController.dispose();
    _shackleInsulatorController.dispose();
    _ciReelController.dispose();
    _shackleStrapController.dispose();
    _boxBracketController.dispose();
    _lcController.dispose();
    _exStayController.dispose();
    
    _suspensionController.removeListener(_calculateEyeHookValue);
    _deadEndController.removeListener(_calculateEyeHookValue);
    _distributionJunctionBoxController.removeListener(_calculateIpcForDB50To70Value);
    _staySetController.removeListener(_updateStayClampType1Value);
    _stayClampType1Controller.removeListener(_onStayClampType1Changed);
    _exStayController.removeListener(_updateRemarksBasedOnConditions);
    _serviceConnection1phController.removeListener(_autoFillDistributionJunctionBox);
    _serviceConnection3phController.removeListener(_autoFillDistributionJunctionBox);
    
    // Remove controller listeners
    _routhLengthController.removeListener(_checkButtonStates);
    _newPoleController.removeListener(_checkButtonStates);
    _staySetController.removeListener(_checkButtonStates);
    _stayClampType1Controller.removeListener(_checkButtonStates);
    _stayClampType2Controller.removeListener(_checkButtonStates);
    _giEarthSpikeController.removeListener(_checkButtonStates);
    _suspensionController.removeListener(_checkButtonStates);
    _deadEndController.removeListener(_checkButtonStates);
    _distributionJunctionBoxController.removeListener(_checkButtonStates);
    _eyeHookController.removeListener(_checkButtonStates);
    _ltPoleClampType1Controller.removeListener(_checkButtonStates);
    _ltPoleClampType2Controller.removeListener(_checkButtonStates);
    _ipcForDB50To70Controller.removeListener(_checkButtonStates);
    _ipcFor16SQMMController.removeListener(_checkButtonStates);
    _ipcForAbcToAbc50To70SQMMController.removeListener(_checkButtonStates);
    _straightThroughJoint70SQMMController.removeListener(_checkButtonStates);
    _straightThroughJoint16SQMMController.removeListener(_checkButtonStates);
    _straightThroughJoint50SQMMController.removeListener(_checkButtonStates);
    _serviceConnection1phController.removeListener(_checkButtonStates);
    _serviceConnection3phController.removeListener(_checkButtonStates);
    
    // Dispose focus nodes
    _gpsNoFocusNode.dispose();
    _poleNoFocusNode.dispose();
    _routhLengthFocusNode.dispose();
    _newPoleFocusNode.dispose();
    _staySetFocusNode.dispose();
    _stayClampType1FocusNode.dispose();
    _stayClampType2FocusNode.dispose();
    _giEarthSpikeFocusNode.dispose();
    _suspensionFocusNode.dispose();
    _deadEndFocusNode.dispose();
    _distributionJunctionBoxFocusNode.dispose();
    _eyeHookFocusNode.dispose();
    _ltPoleClampType1FocusNode.dispose();
    _ltPoleClampType2FocusNode.dispose();
    _ipcForDB50To70FocusNode.dispose();
    _ipcFor16SQMMFocusNode.dispose();
    _ipcForAbcToAbc50To70SQMMFocusNode.dispose();
    _straightThroughJoint70SQMMFocusNode.dispose();
    _straightThroughJoint16SQMMFocusNode.dispose();
    _straightThroughJoint50SQMMFocusNode.dispose();
    _serviceConnection1phFocusNode.dispose();
    _serviceConnection3phFocusNode.dispose();
    
    // Dispose scroll controller
    _scrollController.dispose();

    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    
    // Check if we're editing an existing pole
    if (widget.poleToEdit != null) {
      _populateFormWithPoleData(widget.poleToEdit!);
    } else {
      _loadNextSerialNumber();
    }
    
    // Add listeners to auto-calculate values
    _suspensionController.addListener(_calculateEyeHookValue);
    _deadEndController.addListener(_calculateEyeHookValue);
    _distributionJunctionBoxController.addListener(_calculateIpcForDB50To70Value);
    _staySetController.addListener(_updateStayClampType1Value);
    _stayClampType1Controller.addListener(_onStayClampType1Changed);
    
    // Add listeners for Remarks auto-fill
    _exStayController.addListener(_updateExStayBasedOnConditions);
    
    // Add listener for Distribution Junction Box auto-fill logic
    _serviceConnection1phController.addListener(_autoFillDistributionJunctionBox);
    _serviceConnection3phController.addListener(_autoFillDistributionJunctionBox);
    
    // Add listeners to check button states
    _addControllerListeners();
    
    // Focus on the first field after a short delay to ensure the UI is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _gpsNoFocusNode.requestFocus();
    });
    
    // Note: _isDismantle and _typeOfPole changes are handled in their respective setState calls
  }

  void _addControllerListeners() {
    // Add listeners to all controllers to check button states
    _routhLengthController.addListener(_checkButtonStates);
    _newPoleController.addListener(_checkButtonStates);
    _staySetController.addListener(_checkButtonStates);
    _stayClampType1Controller.addListener(_checkButtonStates);
    _stayClampType2Controller.addListener(_checkButtonStates);
    _giEarthSpikeController.addListener(_checkButtonStates);
    _suspensionController.addListener(_checkButtonStates);
    _deadEndController.addListener(_checkButtonStates);
    _distributionJunctionBoxController.addListener(_checkButtonStates);
    _eyeHookController.addListener(_checkButtonStates);
    _ltPoleClampType1Controller.addListener(_checkButtonStates);
    _ltPoleClampType2Controller.addListener(_checkButtonStates);
    _ipcForDB50To70Controller.addListener(_checkButtonStates);
    _ipcFor16SQMMController.addListener(_checkButtonStates);
    _ipcForAbcToAbc50To70SQMMController.addListener(_checkButtonStates);
    _straightThroughJoint70SQMMController.addListener(_checkButtonStates);
    _straightThroughJoint16SQMMController.addListener(_checkButtonStates);
    _straightThroughJoint50SQMMController.addListener(_checkButtonStates);
    _serviceConnection1phController.addListener(_checkButtonStates);
    _serviceConnection3phController.addListener(_checkButtonStates);
    
  }

  void _checkButtonStates() {
    // Check if all mandatory fields are filled
    final isMandatoryFieldsFilled = _areMandatoryFieldsFilled();
    
    if (_isSaveButtonEnabled != isMandatoryFieldsFilled || 
        _isAddNewButtonEnabled != isMandatoryFieldsFilled) {
      setState(() {
        _isSaveButtonEnabled = isMandatoryFieldsFilled;
        _isAddNewButtonEnabled = isMandatoryFieldsFilled;
      });
    }
  }

  bool _areMandatoryFieldsFilled() {
    // Check if pole type is selected and all mandatory fields have values
    return _typeOfPole.isNotEmpty &&
        _routhLengthController.text.isNotEmpty &&
        _newPoleController.text.isNotEmpty &&
        _staySetController.text.isNotEmpty &&
        _stayClampType1Controller.text.isNotEmpty &&
        _stayClampType2Controller.text.isNotEmpty &&
        _giEarthSpikeController.text.isNotEmpty &&
        _suspensionController.text.isNotEmpty &&
        _deadEndController.text.isNotEmpty &&
        _distributionJunctionBoxController.text.isNotEmpty &&
        _eyeHookController.text.isNotEmpty &&
        _ltPoleClampType1Controller.text.isNotEmpty &&
        _ltPoleClampType2Controller.text.isNotEmpty &&
        _ipcForDB50To70Controller.text.isNotEmpty &&
        _ipcFor16SQMMController.text.isNotEmpty &&
        _ipcForAbcToAbc50To70SQMMController.text.isNotEmpty &&
        // Note: Straight through joint fields are optional and shouldn't block button activation
        _serviceConnection1phController.text.isNotEmpty &&
        _serviceConnection3phController.text.isNotEmpty 
        //&&
        ;
        // Wire Specification is required
       // _selectedWireType.isNotEmpty &&
        // Wire Configuration is required
     //   _selectedWireConfiguration.isNotEmpty;

  }

  Future<void> _loadNextSerialNumber() async {
    try {
      final poles = await _poleService.getPolesForDTR(widget.dtr.id);
      final nextSerialNumber = poles.length + 1;
      setState(() {
        _slNoController.text = nextSerialNumber.toString();
        // Initialize Ex-STAY controller with default value of "0"
        _exStayController.text = '0';
        // Set default Ex-STAY option to "No Ex Stay" (0)
        _exStayOption = 0;
        // Initialize Straight Through Joint controllers to default value '0'
        _straightThroughJoint70SQMMController.text = '0';
        _straightThroughJoint16SQMMController.text = '0';
        _straightThroughJoint50SQMMController.text = '0';
      });
    } catch (e) {
      setState(() {
        _slNoController.text = '1';
        // Initialize Ex-STAY controller with default value of "0"
        _exStayController.text = '0';
        // Set default Ex-STAY option to "No Ex Stay" (0)
        _exStayOption = 0;
        // Initialize Straight Through Joint controllers to default value '0'
        _straightThroughJoint70SQMMController.text = '0';
        _straightThroughJoint16SQMMController.text = '0';
        _straightThroughJoint50SQMMController.text = '0';
      });
    }
  }

  void _generatePoleNumber(List<Pole> existingPoles) {
    if (_typeOfPole.isEmpty) {
      _poleNoController.clear();
      setState(() {
        _isPoleNoReadOnly = true;
      });
      return;
    }
    
    final filteredPoles = existingPoles
        .where((pole) => pole.typeOfPole == _typeOfPole)
        .toList();
    
    filteredPoles.sort((a, b) {
      final RegExp numericRegExp = RegExp(r'(\d+)');
      final matchA = numericRegExp.firstMatch(a.poleNo);
      final matchB = numericRegExp.firstMatch(b.poleNo);
      
      if (matchA != null && matchB != null) {
        final numA = int.tryParse(matchA.group(1) ?? '0') ?? 0;
        final numB = int.tryParse(matchB.group(1) ?? '0') ?? 0;
        return numA.compareTo(numB);
      }
      return 0;
    });
    
    if (_typeOfPole == 'New pole') {
      final nextNumber = _getNextPoleNumber(filteredPoles, 'P');
      _poleNoController.text = 'P$nextNumber';
      setState(() {
        _isPoleNoReadOnly = true;
      });
    } else if (_typeOfPole == 'Ex Pole') {
      final nextNumber = _getNextPoleNumber(filteredPoles, 'E');
      _poleNoController.text = 'E$nextNumber';
      setState(() {
        _isPoleNoReadOnly = false;
      });
    } else {
      setState(() {
        _isPoleNoReadOnly = false;
      });
      if (_poleNoController.text.isEmpty) {
        final nextNumber = _getNextPoleNumber(filteredPoles, 'O');
        _poleNoController.text = 'O$nextNumber';
      }
    }
  }

  int _getNextPoleNumber(List<Pole> poles, String prefix) {
    if (poles.isEmpty) {
      return 1;
    }
    
    final RegExp numericRegExp = RegExp(r'(\d+)');
    int maxNumber = 0;
    
    for (final pole in poles) {
      if (pole.poleNo.startsWith(prefix)) {
        final match = numericRegExp.firstMatch(pole.poleNo);
        if (match != null) {
          final number = int.tryParse(match.group(1) ?? '0') ?? 0;
          if (number > maxNumber) {
            maxNumber = number;
          }
        }
      }
    }
    
    return maxNumber + 1;
  }

  void _populateFormWithPoleData(Pole pole) {
    _slNoController.text = pole.slNo.toString();
    _typeOfPoleController.text = pole.typeOfPole;
    _typeOfPole = pole.typeOfPole;
    _gpsNoController.text = pole.gpsNo;
    _poleNoController.text = pole.poleNo;
    _routhLengthController.text = pole.routhLength.toString();
    _newPoleController.text = pole.newPole.toString();
    _staySetController.text = pole.staySet.toString();
    // Set stayClampType1 to match staySet (they should be the same)
    _stayClampType1Controller.text = pole.stayClampType1.toString();
    _stayClampType2Controller.text = pole.stayClampType2.toString();
    _giEarthSpikeController.text = pole.giEarthSpike.toString();
    _suspensionController.text = pole.suspension.toString();
    _deadEndController.text = pole.deadEnd.toString();
    _distributionJunctionBoxController.text = pole.distributionJunctionBox.toString();
    _eyeHookController.text = pole.eyeHook.toString();
    _ltPoleClampType1Controller.text = pole.ltPoleClampType1.toString();
    _ltPoleClampType2Controller.text = pole.ltPoleClampType2.toString();
    _ipcForDB50To70Controller.text = pole.ipcForDB50To70.toString();
    _ipcFor16SQMMController.text = pole.ipcFor16SQMM.toString();
    _ipcForAbcToAbc50To70SQMMController.text = pole.ipcForAbcToAbc50To70SQMM.toString();
    
    // Populate Straight Through Joint values but keep fields hidden by default
    _straightThroughJoint70SQMMController.text = pole.straightThroughJoint70SQMM.toString();
    _straightThroughJoint16SQMMController.text = pole.straightThroughJoint16SQMM.toString();
    _straightThroughJoint50SQMMController.text = pole.straightThroughJoint50SQMM.toString();
    
    // Keep the fields hidden by default for all poles
    _showStraightThroughJoint = false;
    
    _serviceConnection1phController.text = pole.serviceConnection1ph.toString();
    _serviceConnection3phController.text = pole.serviceConnection3ph.toString();
    _remarksController.text = pole.remarks;
    
    // Populate LT BRACKET text fields
    _ltBracket1PhController.text = pole.ltBracket1Ph.toString();
    _ltBracket3PhController.text = pole.ltBracket3Ph.toString();
    
    // Set wire type based on existing data (you may need to adjust this based on your data model)
    _selectedWireType = pole.wireType;
    _selectedWireConfiguration = pole.wireConfiguration;
    
    _backClampController.text = pole.backClamp.toString();
    _dIronClampController.text = pole.dIronClamp.toString();
    _shackleInsulatorController.text = pole.shackleInsulator.toString();
    _ciReelController.text = pole.ciReel.toString();
    _shackleStrapController.text = pole.shackleStrap.toString();
    _boxBracketController.text = pole.boxBracket.toString();
    _lcController.text = pole.lc.toString();
    _exStayController.text = pole.exStay.toString();
    
    // Set the Ex-STAY option based on the value
    // 0 = No Ex-stay (default), 1 = 1 Ex stay, 2 = Add value (custom)
    if (pole.exStay == 0) {
      _exStayOption = 0;
    } else if (pole.exStay == 1) {
      _exStayOption = 1;
    } else {
      _exStayOption = 2; // Custom value
    }
    
    setState(() {
      _isPoleNoReadOnly = (pole.typeOfPole == 'New pole' || pole.typeOfPole == 'Ex Pole');
      _isDismantle = (pole.ltBracket1Ph == 0 && pole.ltBracket3Ph == 0 && 
                     pole.backClamp == 0 && pole.dIronClamp == 0 && 
                     pole.shackleInsulator == 0 && pole.ciReel == 0 && 
                     pole.shackleStrap == 0 && pole.boxBracket == 0 && 
                     pole.lc == 0 && pole.exStay == 0);
      // Check if Stay Clamp Type 1 was manually edited (different from Stay Set)
      _stayClampType1ManuallyEdited = (pole.stayClampType1 != pole.staySet);
    });
    
    // Check button states after populating all data
    _checkButtonStates();
  }

  void _calculateEyeHookValue() {
    final suspension = int.tryParse(_suspensionController.text) ?? 0;
    final deadEnd = int.tryParse(_deadEndController.text) ?? 0;
    final eyeHook = suspension + deadEnd;
    _eyeHookController.text = eyeHook.toString();
    _ltPoleClampType1Controller.text = eyeHook.toString();
  }

  void _calculateIpcForDB50To70Value() {
    final distributionJunctionBox = int.tryParse(_distributionJunctionBoxController.text) ?? 0;
    final ipcForDB50To70 = distributionJunctionBox * 4;
    _ipcForDB50To70Controller.text = ipcForDB50To70.toString();
  }

  void _updateStayClampType1Value() {
    final staySetValue = _staySetController.text;
    
    // Apply auto-fill rules based on stay set value
    if (staySetValue.isNotEmpty) {
      final staySetInt = int.tryParse(staySetValue) ?? 0;
      
      switch (staySetInt) {
        case 1:
          _stayClampType1Controller.text = '1';
          _stayClampType2Controller.text = '0';
          break;
        case 2:
          _stayClampType1Controller.text = '1';
          _stayClampType2Controller.text = '1';
          break;
        case 3:
          _stayClampType1Controller.text = '2';
          _stayClampType2Controller.text = '1';
          break;
        case 4:
          _stayClampType1Controller.text = '2';
          _stayClampType2Controller.text = '2';
          break;
        default:
          
          if (staySetInt > 4) {
            _stayClampType1Controller.text = staySetValue;
            _stayClampType2Controller.text = '0';
          } else {
            // For invalid values (0 or negative), clear both fields
            _stayClampType1Controller.clear();
            _stayClampType2Controller.clear();
          }
          break;
      }
    }
    // Reset both fields if Stay Set is cleared
    else {
      _stayClampType1Controller.clear();
      _stayClampType2Controller.clear();
    }
  }

  void _onStayClampType1Changed() {
    // Check if the current value differs from what would be auto-filled
    final staySetValue = _staySetController.text;
    final stayClampType1Value = _stayClampType1Controller.text;
    
    // If the values are different, mark as manually edited
    if (staySetValue != stayClampType1Value) {
      _stayClampType1ManuallyEdited = true;
    } 
    // If they're the same and Stay Set is not empty, it might be because:
    // 1. The user changed Stay Set to match Stay Clamp Type 1
    // 2. Auto-fill just happened
    // We'll keep the flag as is in this case
    else if (staySetValue.isEmpty) {
      // If Stay Set is empty, reset the manual edit flag
      _stayClampType1ManuallyEdited = false;
    }toString();
  }

  void _updateNewPoleField(String poleType) {
    if (poleType == 'New pole') {
      _newPoleController.text = '1';
      _giEarthSpikeController.text = '1';
    } else {
      _newPoleController.text = '0';
      _giEarthSpikeController.text = '0';
    }
  }

  void _setDismantleInventoryToZero() {
    _ltBracket1PhController.text = '0';
    _ltBracket3PhController.text = '0';
    _backClampController.text = '0';
    _dIronClampController.text = '0';
    _shackleInsulatorController.text = '0';
    _ciReelController.text = '0';
    _shackleStrapController.text = '0';
    _boxBracketController.text = '0';
    _lcController.text = '0';
    _exStayController.text = '0';
  }

  void _updateRemarksBasedOnConditions() {
    // If "Type of Pole" is selected as "NEW POLE", do not fill anything (ignore previous logic)
    if (_typeOfPole == 'New pole') {
      return;
    }
    
    // If "No Dismantle" is checked, auto-fill Remarks = "NO DISMANTLE"
    if (_isDismantle) {
      _remarksController.text = 'NO DISMANTLE';
      return;
    }
    
    // If "Ex Stay Qty" is filled, auto-fill Remarks = "EX STAY [qty]"
    final exStayValue = _exStayController.text.trim();
    if (exStayValue.isNotEmpty && exStayValue != '0') {
      _remarksController.text = 'EX STAY $exStayValue';
      return;
    }
    
    // If none of the conditions are met, clear the remarks field
    _remarksController.clear(); // Clear the remarks field when no conditions apply
  }

  void _updateExStayBasedOnConditions() {
    // This method handles updating remarks when Ex Stay value changes
    // If No Dismantle is checked, we should prioritize that over Ex Stay
    if (_isDismantle) {
      _remarksController.text = 'NO DISMANTLE';
    } else {
      // Otherwise, update based on Ex Stay value
      final exStayValue = _exStayController.text.trim();
      if (exStayValue.isNotEmpty && exStayValue != '0') {
        _remarksController.text = 'EX STAY $exStayValue';
      } else {
        // If no Ex Stay value and No Dismantle is not checked, clear remarks
        _updateRemarksBasedOnConditions();
      }
    }
  }

  void _autoFillDistributionJunctionBox() {
    // Get current values
    final distributionJunctionBoxValue = _distributionJunctionBoxController.text.trim();
    final serviceConnection1phValue = _serviceConnection1phController.text.trim();
    final serviceConnection3phValue = _serviceConnection3phController.text.trim();
    
    // Check if distribution junction box is empty or 0
    final isDistributionJunctionBoxEmptyOrZero = 
        distributionJunctionBoxValue.isEmpty || distributionJunctionBoxValue == '0';
    
    // Check if either service connection field has a value greater than 0
    final hasServiceConnectionValue = 
        (int.tryParse(serviceConnection1phValue) ?? 0) > 0 ||
        (int.tryParse(serviceConnection3phValue) ?? 0) > 0;
    
    // If distribution junction box is empty/zero and service connections have values
    if (isDistributionJunctionBoxEmptyOrZero && hasServiceConnectionValue) {
      _distributionJunctionBoxController.text = '1';
      // Also update the IPC value since it depends on distribution junction box
      _calculateIpcForDB50To70Value();
    }
  }

  Future<void> _savePole() async {
    // Validate that Type of Pole is selected
    if (_typeOfPole.isEmpty) {
      // Scroll to top smoothly
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
      
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select Type of Pole'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }
    
    if (_formKey.currentState!.validate()) {
      if (_typeOfPole.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select a pole type')),
          );
        }
        return;
      }
      
      try {
        final pole = Pole(
          id: widget.poleToEdit?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
          slNo: int.tryParse(_slNoController.text) ?? 0,
          typeOfPole: _typeOfPole,
          gpsNo: _gpsNoController.text,
          poleNo: _poleNoController.text,
          routhLength: double.tryParse(_routhLengthController.text) ?? 0.0,
          newPole: int.tryParse(_newPoleController.text) ?? 0,
          staySet: int.tryParse(_staySetController.text) ?? 0,
          stayClampType1: int.tryParse(_stayClampType1Controller.text) ?? 0,
          stayClampType2: int.tryParse(_stayClampType2Controller.text) ?? 0,
          giEarthSpike: int.tryParse(_giEarthSpikeController.text) ?? 0,
          suspension: int.tryParse(_suspensionController.text) ?? 0,
          deadEnd: int.tryParse(_deadEndController.text) ?? 0,
          distributionJunctionBox: int.tryParse(_distributionJunctionBoxController.text) ?? 0,
          eyeHook: int.tryParse(_eyeHookController.text) ?? 0,
          ltPoleClampType1: int.tryParse(_ltPoleClampType1Controller.text) ?? 0,
          ltPoleClampType2: int.tryParse(_ltPoleClampType2Controller.text) ?? 0,
          ipcForDB50To70: int.tryParse(_ipcForDB50To70Controller.text) ?? 0,
          ipcFor16SQMM: int.tryParse(_ipcFor16SQMMController.text) ?? 0,
          ipcForAbcToAbc50To70SQMM: int.tryParse(_ipcForAbcToAbc50To70SQMMController.text) ?? 0,
          // Set Straight Through Joint values to 0 if checkbox is not checked
          straightThroughJoint70SQMM: _showStraightThroughJoint ? (int.tryParse(_straightThroughJoint70SQMMController.text) ?? 0) : 0,
          straightThroughJoint16SQMM: _showStraightThroughJoint ? (int.tryParse(_straightThroughJoint16SQMMController.text) ?? 0) : 0,
          straightThroughJoint50SQMM: _showStraightThroughJoint ? (int.tryParse(_straightThroughJoint50SQMMController.text) ?? 0) : 0,
          serviceConnection1ph: int.tryParse(_serviceConnection1phController.text) ?? 0,
          serviceConnection3ph: int.tryParse(_serviceConnection3phController.text) ?? 0,
          remarks: _remarksController.text,
          dtrId: widget.dtr.id,
          ltBracket1Ph: _isDismantle ? 0 : (int.tryParse(_ltBracket1PhController.text) ?? 0),
          ltBracket3Ph: _isDismantle ? 0 : (int.tryParse(_ltBracket3PhController.text) ?? 0),
          backClamp: _isDismantle ? 0 : (int.tryParse(_backClampController.text) ?? 0),
          dIronClamp: _isDismantle ? 0 : (int.tryParse(_dIronClampController.text) ?? 0),
          shackleInsulator: _isDismantle ? 0 : (int.tryParse(_shackleInsulatorController.text) ?? 0),
          ciReel: _isDismantle ? 0 : (int.tryParse(_ciReelController.text) ?? 0),
          shackleStrap: _isDismantle ? 0 : (int.tryParse(_shackleStrapController.text) ?? 0),
          boxBracket: _isDismantle ? 0 : (int.tryParse(_boxBracketController.text) ?? 0),
          lc: _isDismantle ? 0 : (int.tryParse(_lcController.text) ?? 0),
          exStay: _isDismantle ? 0 : (int.tryParse(_exStayController.text) ?? 0),
          // Wire specification and configuration
          wireType: _selectedWireType,
          wireConfiguration: _selectedWireConfiguration,
        );

        if (widget.poleToEdit != null) {
          await _poleService.updatePole(pole);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Pole updated successfully')),
            );
          }
        } else {
          await _poleService.savePole(pole);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Pole added successfully')),
            );
          }
        }

        Navigator.pop(context, true);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error saving pole: $e')),
          );
        }
      }
    }
  }

  Future<void> _confirmDeletePole() async {
    if (widget.poleToEdit == null) return;
    
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Pole'),
          content: const Text('Are you sure you want to delete this pole?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
    
    if (confirm == true) {
      await _deletePole();
    }
  }

  Future<void> _deletePole() async {
    if (widget.poleToEdit == null) return;
    
    try {
      await _poleService.deletePole(widget.poleToEdit!.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pole deleted successfully')),
        );
        Navigator.pop(context, true); // Return true to indicate successful deletion
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting pole: $e')),
        );
      }
    }
  }

  Future<void> _saveAndAddNewPole() async {
    // Validate that Type of Pole is selected
    if (_typeOfPole.isEmpty) {
      // Scroll to top smoothly
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
      
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select Type of Pole'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }
    
    if (_formKey.currentState!.validate()) {
      if (_typeOfPole.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select a pole type')),
          );
        }
        return;
      }
      
      try {
        final pole = Pole(
          id: widget.poleToEdit?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
          slNo: int.tryParse(_slNoController.text) ?? 0,
          typeOfPole: _typeOfPole,
          gpsNo: _gpsNoController.text,
          poleNo: _poleNoController.text,
          routhLength: double.tryParse(_routhLengthController.text) ?? 0.0,
          newPole: int.tryParse(_newPoleController.text) ?? 0,
          staySet: int.tryParse(_staySetController.text) ?? 0,
          stayClampType1: int.tryParse(_stayClampType1Controller.text) ?? 0,
          stayClampType2: int.tryParse(_stayClampType2Controller.text) ?? 0,
          giEarthSpike: int.tryParse(_giEarthSpikeController.text) ?? 0,
          suspension: int.tryParse(_suspensionController.text) ?? 0,
          deadEnd: int.tryParse(_deadEndController.text) ?? 0,
          distributionJunctionBox: int.tryParse(_distributionJunctionBoxController.text) ?? 0,
          eyeHook: int.tryParse(_eyeHookController.text) ?? 0,
          ltPoleClampType1: int.tryParse(_ltPoleClampType1Controller.text) ?? 0,
          ltPoleClampType2: int.tryParse(_ltPoleClampType2Controller.text) ?? 0,
          ipcForDB50To70: int.tryParse(_ipcForDB50To70Controller.text) ?? 0,
          ipcFor16SQMM: int.tryParse(_ipcFor16SQMMController.text) ?? 0,
          ipcForAbcToAbc50To70SQMM: int.tryParse(_ipcForAbcToAbc50To70SQMMController.text) ?? 0,
          // Set Straight Through Joint values to 0 if checkbox is not checked
          straightThroughJoint70SQMM: _showStraightThroughJoint ? (int.tryParse(_straightThroughJoint70SQMMController.text) ?? 0) : 0,
          straightThroughJoint16SQMM: _showStraightThroughJoint ? (int.tryParse(_straightThroughJoint16SQMMController.text) ?? 0) : 0,
          straightThroughJoint50SQMM: _showStraightThroughJoint ? (int.tryParse(_straightThroughJoint50SQMMController.text) ?? 0) : 0,
          serviceConnection1ph: int.tryParse(_serviceConnection1phController.text) ?? 0,
          serviceConnection3ph: int.tryParse(_serviceConnection3phController.text) ?? 0,
          remarks: _remarksController.text,
          dtrId: widget.dtr.id,
          ltBracket1Ph: _isDismantle ? 0 : (int.tryParse(_ltBracket1PhController.text) ?? 0),
          ltBracket3Ph: _isDismantle ? 0 : (int.tryParse(_ltBracket3PhController.text) ?? 0),
          backClamp: _isDismantle ? 0 : (int.tryParse(_backClampController.text) ?? 0),
          dIronClamp: _isDismantle ? 0 : (int.tryParse(_dIronClampController.text) ?? 0),
          shackleInsulator: _isDismantle ? 0 : (int.tryParse(_shackleInsulatorController.text) ?? 0),
          ciReel: _isDismantle ? 0 : (int.tryParse(_ciReelController.text) ?? 0),
          shackleStrap: _isDismantle ? 0 : (int.tryParse(_shackleStrapController.text) ?? 0),
          boxBracket: _isDismantle ? 0 : (int.tryParse(_boxBracketController.text) ?? 0),
          lc: _isDismantle ? 0 : (int.tryParse(_lcController.text) ?? 0),
          exStay: _isDismantle ? 0 : (int.tryParse(_exStayController.text) ?? 0),
          // Wire specification and configuration
          wireType: _selectedWireType,
          wireConfiguration: _selectedWireConfiguration,
        
        );

        if (widget.poleToEdit != null) {
          await _poleService.updatePole(pole);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Pole updated successfully')),
            );
          }
        } else {
          await _poleService.savePole(pole);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Pole added successfully')),
            );
          }
        }

        if (widget.poleToEdit == null) {
          _resetForm();
          // Scroll to top after resetting the form
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              0.0,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          }
        } else {
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error saving pole: $e')),
          );
        }
      }
    }
  }

  void _resetForm() {
    _gpsNoController.clear();
    _routhLengthController.clear();
    _newPoleController.clear();
    _remarksController.clear();

    _staySetController.clear();
    _stayClampType1Controller.clear();
    _stayClampType2Controller.clear();
    _giEarthSpikeController.clear();
    _suspensionController.clear();
    _deadEndController.clear();
    _distributionJunctionBoxController.clear();
    _eyeHookController.clear();
    _ltPoleClampType1Controller.clear();
    _ltPoleClampType2Controller.clear();
    _ipcForDB50To70Controller.clear();
    _ipcFor16SQMMController.clear();
    _ipcForAbcToAbc50To70SQMMController.clear();
    // Initialize Straight Through Joint controllers to default value '0'
    _straightThroughJoint70SQMMController.text = '0';
    _straightThroughJoint16SQMMController.text = '0';
    _straightThroughJoint50SQMMController.text = '0';
    _serviceConnection1phController.clear();
    _serviceConnection3phController.clear();

    // Reset LT BRACKET text fields
    _ltBracket1PhController.clear();
    _ltBracket3PhController.clear();
    
    // Reset wire selections
    setState(() {
      _selectedWireType = '';
      _selectedWireConfiguration = '';
      _showStraightThroughJoint = false; // Ensure Straight Through Joint is hidden on reset
    });
    
    _backClampController.clear();
    _dIronClampController.clear();
    _shackleInsulatorController.clear();
    _ciReelController.clear();
    _shackleStrapController.clear();
    _boxBracketController.clear();
    _lcController.clear();
    _exStayController.clear();
    

    setState(() {
      _typeOfPole = '';
      _typeOfPoleController.text = _typeOfPole;
      _isPoleNoReadOnly = true;
      _poleNoController.clear();
      _isDismantle = false;
      // Reset the manual edit flag
      _stayClampType1ManuallyEdited = false;
      // Reset button states
      _isSaveButtonEnabled = false;
      _isAddNewButtonEnabled = false;
    });
    
    // Reset Ex-STAY option to default (0)
    setState(() {
      _exStayOption = 0;
    });
    _exStayController.text = '0';

    _loadNextSerialNumber();
    
    // Focus on the first field
    _gpsNoFocusNode.requestFocus();
    
    // Scroll to top after resetting the form
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    int maxLines = 1,
    bool readOnly = false,
    List<TextInputFormatter>? inputFormatters,
    FocusNode? focusNode,
    VoidCallback? onFieldSubmitted, // Add this parameter
    bool isMandatory = true, // Add this parameter to identify mandatory fields
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      readOnly: readOnly,
      inputFormatters: inputFormatters,
      focusNode: focusNode, // Add focus node
      onFieldSubmitted: (value) {
        // Auto-fill mandatory empty fields with "0"
        if (isMandatory && value.isEmpty) {
          controller.text = '0';
        }
        
        // Call custom onFieldSubmitted if provided
        onFieldSubmitted?.call();
      },
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 16,
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildReadOnlyText({required String label, required String value}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value.isNotEmpty ? value : 'Auto-generated',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExStayOptionButton({
    required int value,
    required String label,
    required String description,
  }) {
    final isSelected = _exStayOption == value;
    
    return SizedBox(
      height: 55, // Reduced height to prevent overflow
      child: Card(
        color: isSelected 
            ? Theme.of(context).primaryColor.withOpacity(0.1)
            : null,
        child: InkWell(
          onTap: () {
            setState(() {
              _exStayOption = value;
              if (value == 0) {
                _exStayController.text = '0';
              } else if (value == 1) {
                _exStayController.text = '1';
              } else {
                _exStayController.clear();
              }
            });
          },
          child: Container(
            padding: const EdgeInsets.all(6), // Reduced padding
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 12, // Further reduced font size
                  ),
                ),
                const SizedBox(height: 1), // Minimal spacing
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10, // Smaller description text
                    color: Colors.grey[600],
                    fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeOfPoleCheckboxes() {
    final List<String> poleTypes = ['New pole', 'Ex Pole', 'Others'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Type of Pole',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        if (_typeOfPole.isEmpty)
          const Text(
            'Please select a pole type',
            style: TextStyle(
              fontSize: 14,
              color: Colors.red,
              fontStyle: FontStyle.italic,
            ),
          ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ...poleTypes
                .map(
                  (type) => Expanded(
                    child: SizedBox(
                      height: 55, // Reduced height to prevent overflow
                      child: Card(
                        color: _typeOfPole == type
                            ? Theme.of(context).primaryColor.withOpacity(0.1)
                            : null,
                        child: InkWell(
                          onTap: () async {
                            setState(() {
                              _typeOfPole = type;
                              _typeOfPoleController.text = type;
                              _updateNewPoleField(type);
                              
                              // Enable buttons when pole type is selected
                              _isSaveButtonEnabled = _areMandatoryFieldsFilled();
                              _isAddNewButtonEnabled = _areMandatoryFieldsFilled();
                              
                              // Automatically check NO DISMANTLE checkbox when 'New pole' is selected
                              // And uncheck it when switching to other pole types
                              if (_typeOfPole == 'New pole') {
                                _isDismantle = true;
                                _setDismantleInventoryToZero();
                              } else {
                                _isDismantle = false;
                              }
                              
                              // Update remarks based on conditions
                              _updateRemarksBasedOnConditions();
                            });
                            
                            try {
                              final poles = await _poleService.getPolesForDTR(widget.dtr.id);
                              _generatePoleNumber(poles);
                            } catch (e) {
                              _generatePoleNumber([]);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(6), // Reduced padding
                            child: Center(
                              child: Text(
                                type,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: _typeOfPole == type
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  fontSize: 13,  // Reduced font size
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ],
        ),
        // Add checkbox to control GPS field visibility
        Row(
          children: [
            Checkbox(
              value: _showGpsField,
              onChanged: (value) {
                setState(() {
                  _showGpsField = value ?? false;
                });
              },
            ),
            const Expanded(
              child: Text(
                'Add GPS Number',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWireSpecificationCheckboxes() {
    final List<String> wireTypes = [
      'ACSR 50 sqmm',
      'ACSR 30 sqmm',
      'AAC 50 sqmm',
      'AAC 25 sqmm',
      'ACSR 20 sqmm',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Wire Specification',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Select Wire Type (Only one can be selected):',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Column(
          children: wireTypes
              .map(
                (type) => RadioListTile<String>(
                  title: Text(type),
                  value: type,
                  groupValue: _selectedWireType,
                  onChanged: (value) {
                    setState(() {
                      _selectedWireType = value ?? '';
                    });
                  },
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildWireConfigurationCheckboxes() {
    final List<String> wireConfigurations = [
      '2 wire',
      '3 wire',
      '4 wire',
      '5 wire',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Wire Configuration',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Select Wire Configuration (Only one can be selected):',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: wireConfigurations.map((config) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Checkbox(
                  value: _selectedWireConfiguration == config,
                  onChanged: (value) {
                    setState(() {
                      // If checkbox is checked, set the value; if unchecked, clear it
                      _selectedWireConfiguration = value == true ? config : '';
                      
                      // Automatically fill LT_BRACKET fields based on wire configuration
                      if (_selectedWireConfiguration == '2 wire') {
                        // For 2 wire, set LT_BRACKET_1PH to 1
                        _ltBracket1PhController.text = '1';
                        _ltBracket3PhController.text = '0';
                      } else if (_selectedWireConfiguration == '3 wire' || 
                                 _selectedWireConfiguration == '4 wire' || 
                                 _selectedWireConfiguration == '5 wire') {
                        // For 3, 4, or 5 wire, set LT_BRACKET_3PH to 1
                        _ltBracket1PhController.text = '0';
                        _ltBracket3PhController.text = '1';
                      } else {
                        // If no configuration selected, clear both fields
                        _ltBracket1PhController.clear();
                        _ltBracket3PhController.clear();
                      }
                      
                      // Automatically fill BACK CLAMP with 4 when any wire configuration is selected
                      if (_selectedWireConfiguration == '2 wire' || 
                          _selectedWireConfiguration == '3 wire' || 
                          _selectedWireConfiguration == '4 wire' || 
                          _selectedWireConfiguration == '5 wire') {
                        _backClampController.text = '4';
                      } else {
                        // If no configuration selected, clear BACK CLAMP
                        _backClampController.clear();
                      }
                      
                      // Automatically fill D IRON CLAMP & SHACKLE INSULATOR based on wire configuration
                      if (_selectedWireConfiguration == '2 wire') {
                        // For 2 wire, set both to 2
                        _dIronClampController.text = '2';
                        _shackleInsulatorController.text = '2';
                      } else if (_selectedWireConfiguration == '3 wire') {
                        // For 3 wire, set both to 3
                        _dIronClampController.text = '3';
                        _shackleInsulatorController.text = '3';
                      } else if (_selectedWireConfiguration == '4 wire') {
                        // For 4 wire, set both to 4
                        _dIronClampController.text = '4';
                        _shackleInsulatorController.text = '4';
                      } else if (_selectedWireConfiguration == '5 wire') {
                        // For 5 wire, set both to 5
                        _dIronClampController.text = '5';
                        _shackleInsulatorController.text = '5';
                      } else {
                        // If no configuration selected, clear both fields
                        _dIronClampController.clear();
                        _shackleInsulatorController.clear();
                      }
                    });
                  },
                ),
                Flexible(
                  child: Text(config),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.poleToEdit != null ? 'Edit Pole' : 'Add New Pole'),
        centerTitle: true,
        elevation: 2,
        actions: widget.poleToEdit != null
            ? [
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: _confirmDeletePole,
                  tooltip: 'Delete Pole',
                ),
              ]
            : null,
      ),
      body: SingleChildScrollView(
        controller: _scrollController, // Add scroll controller
        child: ResponsiveContainer(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Basic Information Section
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: ResponsiveUtils.getResponsiveCardPadding(context),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Basic Information',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildReadOnlyText(
                          label: 'Sl No',
                          value: _slNoController.text,
                        ),
                        SizedBox(height: ResponsiveUtils.getFieldSpacing(context)),
                        _buildTypeOfPoleCheckboxes(),
                        SizedBox(height: ResponsiveUtils.getFieldSpacing(context)),
                        // Conditionally show GPS No field based on checkbox
                        if (_showGpsField) ...[
                          _buildTextField(
                            controller: _gpsNoController,
                            label: 'GPS No (Optional)',
                            maxLines: 1,
                            keyboardType: TextInputType.number,
                            focusNode: _gpsNoFocusNode,
                            onFieldSubmitted: () {
                              // GPS No is optional, so we don't auto-fill it
                              // Move focus to next field
                              _poleNoFocusNode.requestFocus();
                            },
                            isMandatory: false, // GPS No is optional
                          ),
                          const SizedBox(height: 16),
                        ],
                        _buildTextField(
                          controller: _poleNoController,
                          label: 'Pole No',
                          maxLines: 1,
                          readOnly: _isPoleNoReadOnly,
                          focusNode: _poleNoFocusNode,
                          onFieldSubmitted: () {
                            // Pole No is mandatory, but it's usually auto-generated
                            // Move focus to next field
                            _routhLengthFocusNode.requestFocus();
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _routhLengthController,
                          label: 'Route Length (mtr)',
                          maxLines: 1,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*')),
                          ],
                          focusNode: _routhLengthFocusNode,
                          onFieldSubmitted: () {
                            // Auto-fill if empty and move to next field
                            if (_routhLengthController.text.isEmpty) {
                              _routhLengthController.text = '0';
                            }
                            _newPoleFocusNode.requestFocus();
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _newPoleController,
                          label: 'New Pole 8mtr PCC',
                          maxLines: 1,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          focusNode: _newPoleFocusNode,
                          onFieldSubmitted: () {
                            // Auto-fill if empty and move to next field
                            if (_newPoleController.text.isEmpty) {
                              _newPoleController.text = '0';
                            }
                            _staySetFocusNode.requestFocus();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context)),

                // Accessories Section
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: ResponsiveUtils.getResponsiveCardPadding(context),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Accessories',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _staySetController,
                          label: 'Stay Set',
                          maxLines: 1,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          focusNode: _staySetFocusNode,
                          onFieldSubmitted: () {
                            // Auto-fill if empty and move to next field
                            if (_staySetController.text.isEmpty) {
                              _staySetController.text = '0';
                            }
                            _stayClampType1FocusNode.requestFocus();
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _stayClampType1Controller,
                          label: 'Stay Clamp Type 1',
                          maxLines: 1,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          focusNode: _stayClampType1FocusNode,
                          onFieldSubmitted: () {
                            // Auto-fill if empty and move to next field
                            if (_stayClampType1Controller.text.isEmpty) {
                              _stayClampType1Controller.text = '0';
                            }
                            _stayClampType2FocusNode.requestFocus();
                          },

                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _stayClampType2Controller,
                          label: 'Stay Clamp Type 2',
                          maxLines: 1,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          focusNode: _stayClampType2FocusNode,
                          onFieldSubmitted: () {
                            // Auto-fill if empty and move to next field
                            if (_stayClampType2Controller.text.isEmpty) {
                              _stayClampType2Controller.text = '0';
                            }
                            _giEarthSpikeFocusNode.requestFocus();
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _giEarthSpikeController,
                          label: 'GI Earth Spike',
                          maxLines: 1,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          focusNode: _giEarthSpikeFocusNode,
                          onFieldSubmitted: () {
                            // Auto-fill if empty and move to next field
                            if (_giEarthSpikeController.text.isEmpty) {
                              _giEarthSpikeController.text = '0';
                            }
                            _suspensionFocusNode.requestFocus();
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _suspensionController,
                          label: 'Suspension',
                          maxLines: 1,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          focusNode: _suspensionFocusNode,
                          onFieldSubmitted: () {
                            // Auto-fill if empty and move to next field
                            if (_suspensionController.text.isEmpty) {
                              _suspensionController.text = '0';
                            }
                            _deadEndFocusNode.requestFocus();
                          },
                        ),
                     /*   const SizedBox(height: 16),
                        _buildTextField(
                          controller: _lcController,
                          label: 'L.C',
                          keyboardType: TextInputType.number,
                          maxLines: 1,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                        ),*/
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _deadEndController,
                          label: 'Dead End',
                          maxLines: 1,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          focusNode: _deadEndFocusNode,
                          onFieldSubmitted: () {
                            // Auto-fill if empty and move to next field
                            if (_deadEndController.text.isEmpty) {
                              _deadEndController.text = '0';
                            }
                            _distributionJunctionBoxFocusNode.requestFocus();
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _distributionJunctionBoxController,
                          label: 'Distribution Junction Box',
                          maxLines: 1,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          focusNode: _distributionJunctionBoxFocusNode,
                          onFieldSubmitted: () {
                            // Auto-fill if empty and move to next field
                            if (_distributionJunctionBoxController.text.isEmpty) {
                              _distributionJunctionBoxController.text = '0';
                            }
                            _eyeHookFocusNode.requestFocus();
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _eyeHookController,
                          label: 'Eye Hook',
                          maxLines: 1,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          focusNode: _eyeHookFocusNode,
                          onFieldSubmitted: () {
                            // Auto-fill if empty and move to next field
                            if (_eyeHookController.text.isEmpty) {
                              _eyeHookController.text = '0';
                            }
                            _ltPoleClampType1FocusNode.requestFocus();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // LT Pole Clamps Section
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: ResponsiveUtils.getResponsiveCardPadding(context),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'LT Pole Clamps',
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _ltPoleClampType1Controller,
                          label: 'Type 1',
                          maxLines: 1,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          focusNode: _ltPoleClampType1FocusNode,
                          onFieldSubmitted: () {
                            // Auto-fill if empty and move to next field
                            if (_ltPoleClampType1Controller.text.isEmpty) {
                              _ltPoleClampType1Controller.text = '0';
                            }
                            _ltPoleClampType2FocusNode.requestFocus();
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _ltPoleClampType2Controller,
                          label: 'Type 2',
                          maxLines: 1,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          focusNode: _ltPoleClampType2FocusNode,
                          onFieldSubmitted: () {
                            // Auto-fill if empty and move to next field
                            if (_ltPoleClampType2Controller.text.isEmpty) {
                              _ltPoleClampType2Controller.text = '0';
                            }
                            _ipcForDB50To70FocusNode.requestFocus();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // IPC Section
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: ResponsiveUtils.getResponsiveCardPadding(context),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'IPC',
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _ipcForDB50To70Controller,
                          label: 'DB 50 To 70',
                          maxLines: 1,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          focusNode: _ipcForDB50To70FocusNode,
                          onFieldSubmitted: () {
                            // Auto-fill if empty and move to next field
                            if (_ipcForDB50To70Controller.text.isEmpty) {
                              _ipcForDB50To70Controller.text = '0';
                            }
                            _ipcFor16SQMMFocusNode.requestFocus();
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _ipcFor16SQMMController,
                          label: '16 SQMM',
                          maxLines: 1,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          focusNode: _ipcFor16SQMMFocusNode,
                          onFieldSubmitted: () {
                            // Auto-fill if empty and move to next field
                            if (_ipcFor16SQMMController.text.isEmpty) {
                              _ipcFor16SQMMController.text = '0';
                            }
                            _ipcForAbcToAbc50To70SQMMFocusNode.requestFocus();
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _ipcForAbcToAbc50To70SQMMController,
                          label: 'ABC To ABC 50 To 70 SQMM',
                          maxLines: 1,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          focusNode: _ipcForAbcToAbc50To70SQMMFocusNode,
                          onFieldSubmitted: () {
                            // Auto-fill if empty and move to next field
                            if (_ipcForAbcToAbc50To70SQMMController.text.isEmpty) {
                              _ipcForAbcToAbc50To70SQMMController.text = '0';
                            }
                            // If Straight Through Joint is visible, focus on it, otherwise jump to Service Connection
                            if (_showStraightThroughJoint) {
                              _straightThroughJoint70SQMMFocusNode.requestFocus();
                            } else {
                              _serviceConnection1phFocusNode.requestFocus();
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context)),

                // Straight Through Joint Section
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: ResponsiveUtils.getResponsiveCardPadding(context),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Straight Through Joint',
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Checkbox to control Straight Through Joint visibility
                        Row(
                          children: [
                            Checkbox(
                              value: _showStraightThroughJoint,
                              onChanged: (bool? value) {
                                setState(() {
                                  _showStraightThroughJoint = value ?? false;
                                  // When unchecked, clear the fields and set to 0
                                  if (!_showStraightThroughJoint) {
                                    _straightThroughJoint70SQMMController.text = '0';
                                    _straightThroughJoint16SQMMController.text = '0';
                                    _straightThroughJoint50SQMMController.text = '0';
                                  }
                                });
                              },
                            ),
                            const Expanded(
                              child: Text(
                                'Add Straight Through Joint Details',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Only show Straight Through Joint fields when checkbox is checked
                        if (_showStraightThroughJoint) ...[
                          _buildTextField(
                            controller: _straightThroughJoint70SQMMController,
                            label: '70 SQMM',
                            maxLines: 1,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            focusNode: _straightThroughJoint70SQMMFocusNode,
                            onFieldSubmitted: () {
                              // Auto-fill if empty and move to next field
                              if (_straightThroughJoint70SQMMController.text.isEmpty) {
                                _straightThroughJoint70SQMMController.text = '0';
                              }
                              _straightThroughJoint16SQMMFocusNode.requestFocus();
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _straightThroughJoint16SQMMController,
                            label: '16 SQMM',
                            maxLines: 1,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            focusNode: _straightThroughJoint16SQMMFocusNode,
                            onFieldSubmitted: () {
                              // Auto-fill if empty and move to next field
                              if (_straightThroughJoint16SQMMController.text.isEmpty) {
                                _straightThroughJoint16SQMMController.text = '0';
                              }
                              _straightThroughJoint50SQMMFocusNode.requestFocus();
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _straightThroughJoint50SQMMController,
                            label: '50 SQMM',
                            maxLines: 1,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            focusNode: _straightThroughJoint50SQMMFocusNode,
                            onFieldSubmitted: () {
                              // Auto-fill if empty and move to next field
                              if (_straightThroughJoint50SQMMController.text.isEmpty) {
                                _straightThroughJoint50SQMMController.text = '0';
                              }
                              _serviceConnection1phFocusNode.requestFocus();
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context)),

                // Service Connection Section
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: ResponsiveUtils.getResponsiveCardPadding(context),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Service Connection',
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _serviceConnection1phController,
                          label: '1 Phase',
                          maxLines: 1,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          focusNode: _serviceConnection1phFocusNode,
                          onFieldSubmitted: () {
                            // Auto-fill if empty and move to next field
                            if (_serviceConnection1phController.text.isEmpty) {
                              _serviceConnection1phController.text = '0';
                            }
                            _serviceConnection3phFocusNode.requestFocus();
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _serviceConnection3phController,
                          label: '3 Phase',
                          maxLines: 1,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          focusNode: _serviceConnection3phFocusNode,
                          onFieldSubmitted: () {
                            // Auto-fill if empty and move to next field
                            if (_serviceConnection3phController.text.isEmpty) {
                              _serviceConnection3phController.text = '0';
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context)),

                // Ex-STAY Section
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: ResponsiveUtils.getResponsiveCardPadding(context),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Ex-STAY',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Ex-STAY options with Type of Pole style
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: _buildExStayOptionButton(
                                value: 0,
                                label: 'No Ex Stay',
                                description: '0 value',
                              ),
                            ),
                            Expanded(
                              child: _buildExStayOptionButton(
                                value: 1,
                                label: '1 Ex Stay',
                                description: 'Value: 1',
                              ),
                            ),
                            Expanded(
                              child: _buildExStayOptionButton(
                                value: 2,
                                label: 'Enter Value',
                                description: 'Custom input',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Show text field when "Enter Value" is selected
                        if (_exStayOption == 2)
                          _buildTextField(
                            controller: _exStayController,
                            label: 'Ex-STAY Value',
                            keyboardType: TextInputType.number,
                            maxLines: 1,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                          )
                        // Show readonly display for other options
                        else
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              children: [
                                const Text(
                                  'Ex-STAY Value: ',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  _exStayOption == 0 ? '0 (No Ex Stay)' : '1 (1 Ex Stay)',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context)),

                // Wire Specification Section
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: ResponsiveUtils.getResponsiveCardPadding(context),
                    child: _buildWireSpecificationCheckboxes(),
                  ),
                ),
                SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context)),
                
                // Wire Configuration Section
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: ResponsiveUtils.getResponsiveCardPadding(context),
                    child: _buildWireConfigurationCheckboxes(),
                  ),
                ),
                SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context)),

                // LT BRACKET Section (changed to text fields)
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: ResponsiveUtils.getResponsiveCardPadding(context),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Dismantle inventory' ,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // NO DISMANTLE Checkbox
                        Row(
                          children: [
                            Checkbox(
                              value: _isDismantle,
                              onChanged: (bool? value) {
                                setState(() {
                                  _isDismantle = value ?? false;
                                  // When checked, set all dismantle inventory fields to 0
                                  if (_isDismantle) {
                                    _setDismantleInventoryToZero();
                                  }
                                  // Update remarks based on conditions
                                  _updateRemarksBasedOnConditions();
                                });
                              },
                            ),
                            const Expanded(
                              child: Text(
                                'NO DISMANTLE',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Only show dismantle inventory fields when NOT checked (NO DISMANTLE = false)
                        if (!_isDismantle)
                          Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildTextField(
                                      controller: _ltBracket1PhController,
                                      label: 'LT BRACKET 1 PH',
                                      maxLines: 1,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _buildTextField(
                                      controller: _ltBracket3PhController,
                                      label: 'LT BRACKET 3 PH',
                                      maxLines: 1,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _backClampController,
                                label: 'Back Clamp',
                                maxLines: 1,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _dIronClampController,
                                label: 'D IRON CLAMP',
                                maxLines: 1,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _shackleInsulatorController,
                                label: 'SHACKLE INSULATOR',
                                maxLines: 1,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _ciReelController,
                                label: 'CI REEL',
                                maxLines: 1,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _shackleStrapController,
                                label: 'SHACKLE STRAP',
                                maxLines: 1,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _boxBracketController,
                                label: 'BOX BRACKET',
                                keyboardType: TextInputType.number,
                                maxLines: 1,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _lcController,
                                label: 'L.C',
                                keyboardType: TextInputType.number,
                                maxLines: 1,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context)),

                // Remarks Section
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: ResponsiveUtils.getResponsiveCardPadding(context),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Remarks',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _remarksController,
                          label: 'Remarks',
                          maxLines: 3,
                          keyboardType: TextInputType.multiline,
                          
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context)),

                // Save Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isSaveButtonEnabled ? _savePole : null, // Use the enabled state
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          widget.poleToEdit != null ? 'Update Pole' : 'Save Pole',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isAddNewButtonEnabled ? _saveAndAddNewPole : null, // Use the enabled state
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          backgroundColor: Theme.of(context).colorScheme.secondary,
                        ),
                        child: const Text(
                          'Add New Pole',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

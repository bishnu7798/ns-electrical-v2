import 'dart:io';
import 'package:flutter/material.dart';
// import 'package:provider/provider.dart'; // Added import for provider

import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/models/dtr_model.dart';
import '../../core/models/pole_model.dart';
import '../../core/services/pole_service.dart';
import '../../core/services/dtr_service.dart';

import '../../shared/constants/app_constants.dart';

class PoleScheduleScreen extends StatefulWidget {
  const PoleScheduleScreen({super.key, required this.dtr});

  final DTR dtr;

  @override
  State<PoleScheduleScreen> createState() => _PoleScheduleScreenState();
}

class _PoleScheduleScreenState extends State<PoleScheduleScreen> {
  late DTR _currentDtr;
  final _dtrService = DTRService();
  bool _isLoading = true;
  final _poleService = PoleService();
  List<Pole> _poles = [];
  // Add ScrollController for smooth scrolling to top
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController
        .dispose(); // Dispose the controller to prevent memory leaks
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _currentDtr = widget.dtr;
    _loadPoles();
  }

  Future<void> _loadPoles() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Fetch actual poles for this DTR
      final poles = await _poleService.getPolesForDTR(widget.dtr.id);

      setState(() {
        _poles = poles;
        _isLoading = false;
      });

      // Scroll to top when loading is complete
      _scrollToTop();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading poles: $e')));
      }
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.list_alt_outlined,
            size: 64,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(height: 16),
          const Text(
            'No poles found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'No poles have been added to this DTR yet.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          FloatingActionButton.extended(
            onPressed: () async {
              final result = await Navigator.pushNamed(
                context,
                AppConstants.addPoleRoute,
                arguments: {'dtr': widget.dtr},
              );

              // If a pole was added, refresh the list
              if (result != null && result as bool) {
                _loadPoles();
              }

              // Scroll to top smoothly after the action
              _scrollToTop();
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Pole'),
            heroTag: 'empty_state_add_pole_fab',
          ),
        ],
      ),
    );
  }

  Widget _buildPoleScheduleForm() {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // DTR Header Information
            _buildDtrHeader(),
            const SizedBox(height: 24),

            // Spreadsheet-like table
            _buildSpreadsheetTable(),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildDtrHeader() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Simple header
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'DTR Information',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: _editDTR,
                  tooltip: 'Edit DTR Information',
                ),
              ],
            ),
            const SizedBox(height: 20),

            // DTR Code as main title
            Text(
              _currentDtr.dtrCode.isEmpty ? 'Unknown DTR' : _currentDtr.dtrCode,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // Organized information in sections
            _buildInfoRow('Capacity', '${_currentDtr.capacity} kVA'),
            const SizedBox(height: 12),
            _buildInfoRow('Village', _currentDtr.village),
            const SizedBox(height: 12),
            _buildInfoRow('Location', _currentDtr.location),
            const SizedBox(height: 12),
            _buildInfoRow('Land Marks', _currentDtr.landMarks),
            const SizedBox(height: 12),
            _buildInfoRow('CCC', _currentDtr.ccc),
            const SizedBox(height: 12),
            _buildInfoRow('Feeder', _currentDtr.feeder),
            const SizedBox(height: 12),
            _buildInfoRow('Substation',
                _currentDtr.substation), // Changed from Feeder Capacity
            const SizedBox(height: 12),
            _buildInfoRow('DRG No', _currentDtr.drgNo),
            const SizedBox(height: 12),
            _buildInfoRow('D.O.C Date', _currentDtr.docDate),
            const SizedBox(height: 12),
            _buildInfoRow('JMC No', _currentDtr.jmcNo),
            const SizedBox(height: 12),
            _buildInfoRow('GP', _currentDtr.gp),
            const SizedBox(height: 12),
            _buildInfoRow('Census Code', _currentDtr.censusCode),
            const SizedBox(height: 12),
            _buildInfoRow('Block', _currentDtr.block),
            const SizedBox(height: 12),
            _buildInfoRow('Division', _currentDtr.division),
            const SizedBox(height: 12),
            _buildInfoRow('User', _currentDtr.user), // Added User field
          ],
        ),
      ),
    );
  }

  // Simple info row with label, value, and icon
  Widget _buildInfoRow(String label, String value) {
    // Map labels to appropriate icons
    IconData getIconForLabel(String label) {
      switch (label) {
        case 'Capacity':
          return Icons.bolt;
        case 'Village':
          return Icons.location_city;
        case 'Location':
          return Icons.place;
        case 'Land Marks':
          return Icons.landslide;
        case 'CCC':
          return Icons.account_balance;
        case 'Feeder':
          return Icons.flash_on;
        case 'Substation':
          return Icons.electrical_services;
        case 'DRG No':
          return Icons.document_scanner;
        case 'D.O.C Date':
          return Icons.calendar_today;
        case 'JMC No':
          return Icons.confirmation_number;
        case 'GP':
          return Icons.group;
        case 'Census Code':
          return Icons.tag;
        case 'Block':
          return Icons.account_tree;
        case 'Division':
          return Icons.location_city;
        case 'User':
          return Icons.person;
        default:
          return Icons.info;
      }
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          getIconForLabel(label),
          size: 20,
          color: Theme.of(context).primaryColor,
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value.isNotEmpty && value != 'N/A' ? value : 'N/A',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSpreadsheetTable() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.table_chart,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 10),
                Text(
                  'Pole Schedule',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: _editPoleSchedule,
                  tooltip: 'Edit Pole Schedule',
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Improved scrollable container with better performance
            LayoutBuilder(
              builder: (context, constraints) {
                return ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: constraints.maxHeight * 0.6, // Responsive height
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Table(
                        border: TableBorder.all(
                          color: Colors.grey.shade300,
                          width: 1,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        columnWidths: const {
                          0: FixedColumnWidth(60), // SL NO
                          1: FixedColumnWidth(100), // Pole No.
                          2: FixedColumnWidth(150), // Route Length
                          3: FixedColumnWidth(120), // New PCC Pole
                          4: FixedColumnWidth(100), // LT Stay set
                          5: FixedColumnWidth(120), // LT Stay clamp (Type-I)
                          6: FixedColumnWidth(120), // LT Stay clamp (Type-II)
                          7: FixedColumnWidth(150), // GI Earth Spike
                          8: FixedColumnWidth(100), // Suspension
                          9: FixedColumnWidth(100), // Dead End
                          10: FixedColumnWidth(
                              150), // Distribution Junction Box
                          11: FixedColumnWidth(80), // Eye hook
                          12: FixedColumnWidth(120), // LT pole clamp (Type-I)
                          13: FixedColumnWidth(120), // LT pole clamp (Type-II)
                          14: FixedColumnWidth(
                              150), // IPC (ABC) to DB charging set 50-70 sq.mm
                          15: FixedColumnWidth(120), // IPC (ABC) for 16 sq.mm
                          16: FixedColumnWidth(
                              150), // IPC ABC TEE joint for 70 sq.mm
                          17: FixedColumnWidth(
                            150,
                          ), // Straight through joint (ABC) 70 sq.mm power cable
                          18: FixedColumnWidth(
                            150,
                          ), // Straight through joint (ABC) 16 sq.mm power cable
                          19: FixedColumnWidth(
                            150,
                          ), // Straight through joint (ABC) 50 sq.mm neutral wire
                          20: FixedColumnWidth(120), // Service Connection (1Ph)
                          21: FixedColumnWidth(120), // Service Connection (3Ph)
                          22: FixedColumnWidth(150), // Remarks
                          23: FixedColumnWidth(100), // GPS No
                        },
                        children: [
                          // Table Header Row
                          TableRow(
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .primaryColor
                                  .withOpacity(0.1),
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(8),
                              ),
                            ),
                            children: [
                              _buildTableHeaderCell('SL NO'),
                              _buildTableHeaderCell('Pole No.'),
                              _buildTableHeaderCell(
                                'Route Length AB XLPE Cable 3C X 70 SQ.MM + 1C X 16 SQ.MM',
                              ),
                              _buildTableHeaderCell(
                                  'New PCC Pole 8 mtr. long (WL-200 kg)'),
                              _buildTableHeaderCell('LT Stay set'),
                              _buildTableHeaderCell('LT Stay clamp (Type-I)'),
                              _buildTableHeaderCell('LT Stay clamp (Type-II)'),
                              _buildTableHeaderCell(
                                'GI Earth Spike 20mm dia 185mm solid rod with 5mm GI wire',
                              ),
                              _buildTableHeaderCell('Suspension'),
                              _buildTableHeaderCell('Dead End'),
                              _buildTableHeaderCell(
                                  'Distribution Junction Box'),
                              _buildTableHeaderCell('Eye hook'),
                              _buildTableHeaderCell('LT pole clamp (Type-I)'),
                              _buildTableHeaderCell('LT pole clamp (Type-II)'),
                              _buildTableHeaderCell(
                                  'IPC (ABC) to DB charging set 50-70 sq.mm'),
                              _buildTableHeaderCell('IPC (ABC) for 16 sq.mm'),
                              _buildTableHeaderCell(
                                  'IPC ABC TEE joint for 70 sq.mm'),
                              _buildTableHeaderCell(
                                'Straight through joint (ABC) 70 sq.mm power cable',
                              ),
                              _buildTableHeaderCell(
                                'Straight through joint (ABC) 16 sq.mm power cable',
                              ),
                              _buildTableHeaderCell(
                                'Straight through joint (ABC) 50 sq.mm neutral wire',
                              ),
                              _buildTableHeaderCell('Service Connection (1Ph)'),
                              _buildTableHeaderCell('Service Connection (3Ph)'),
                              _buildTableHeaderCell('Remarks'),
                              _buildTableHeaderCell('GPS No'),
                            ],
                          ),

                          // Units Row (newly added row for SL No, Pole No, and Route Length)
                          TableRow(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                            ),
                            children: [
                              _buildTableUnitCell(
                                  'Unit'), // Updated to use Unit column
                              _buildTableUnitCell(
                                  'No'), // Updated to use Pole No. column
                              _buildTableUnitCell(
                                  'Mtr.'), // Updated to use Route Length column
                              _buildTableUnitCell(
                                  'Nos.'), // Updated to use New PCC Pole column
                              _buildTableUnitCell(
                                  'Set.'), // Updated to use LT Stay set column
                              _buildTableUnitCell(
                                'Pair.',
                              ), // Updated to use LT Stay clamp (Type-I) column
                              _buildTableUnitCell(
                                'Pair.',
                              ), // Updated to use LT Stay clamp (Type-II) column
                              _buildTableUnitCell(
                                'Nos.',
                              ), // Updated to use GI Earth Spike column
                              _buildTableUnitCell(
                                  'Nos.'), // Updated to use Suspension column
                              _buildTableUnitCell(
                                  'Nos.'), // Updated to use Dead End column
                              _buildTableUnitCell(
                                'Nos.',
                              ), // Updated to use Distribution Junction Box column
                              _buildTableUnitCell(
                                  'Nos.'), // Updated to use Eye hook column
                              _buildTableUnitCell(
                                'Pair.',
                              ), // Updated to use LT pole clamp (Type-I) column
                              _buildTableUnitCell(
                                'Pair.',
                              ), // Updated to use LT pole clamp (Type-II) column
                              _buildTableUnitCell(
                                'Nos.',
                              ), // Updated to use IPC (ABC) to DB charging set 50-70 sq.mm column
                              _buildTableUnitCell(
                                'Nos.',
                              ), // Updated to use IPC (ABC) for 16 sq.mm column
                              _buildTableUnitCell(
                                'Nos.',
                              ), // Updated to use IPC ABC TEE joint for 70 sq.mm column
                              _buildTableUnitCell(
                                'Nos.',
                              ), // Updated to use Straight through joint (ABC) 70 sq.mm power cable column
                              _buildTableUnitCell(
                                'Nos.',
                              ), // Updated to use Straight through joint (ABC) 16 sq.mm power cable column
                              _buildTableUnitCell(
                                'Nos.',
                              ), // Updated to use Straight through joint (ABC) 50 sq.mm neutral wire column
                              _buildTableUnitCell(
                                'Nos.',
                              ), // Updated to use Service Connection (1Ph) column
                              _buildTableUnitCell(
                                'Nos.',
                              ), // Updated to use Service Connection (3Ph) column
                              _buildTableUnitCell(
                                  ''), // Updated to use Remarks column
                              _buildTableUnitCell(
                                  'No'), // Updated to use GPS No column
                            ],
                          ),

                          // Data Rows
                          ...List.generate(_poles.length, (index) {
                            final pole = _poles[index];
                            return TableRow(
                              children: [
                                _buildTableCell(
                                  (pole.slNo).toString(),
                                ),
                                _buildTableCell(pole.poleNo),
                                _buildTableCell(
                                  pole.routhLength.toStringAsFixed(2),
                                ),
                                _buildTableCell(
                                    (pole.newPole == 1 ? '1' : '0')),
                                _buildTableCell(pole.staySet.toString()),
                                _buildTableCell(pole.stayClampType1.toString()),
                                _buildTableCell(pole.stayClampType2.toString()),
                                _buildTableCell(pole.giEarthSpike.toString()),
                                _buildTableCell(pole.suspension.toString()),
                                _buildTableCell(pole.deadEnd.toString()),
                                _buildTableCell(
                                  pole.distributionJunctionBox.toString(),
                                ),
                                _buildTableCell(pole.eyeHook.toString()),
                                _buildTableCell(
                                    pole.ltPoleClampType1.toString()),
                                _buildTableCell(
                                    pole.ltPoleClampType2.toString()),
                                _buildTableCell(pole.ipcForDB50To70.toString()),
                                _buildTableCell(pole.ipcFor16SQMM.toString()),
                                _buildTableCell(
                                  pole.ipcForAbcToAbc50To70SQMM.toString(),
                                ),
                                _buildTableCell(
                                  pole.straightThroughJoint70SQMM.toString(),
                                ),
                                _buildTableCell(
                                  pole.straightThroughJoint16SQMM.toString(),
                                ),
                                _buildTableCell(
                                  pole.straightThroughJoint50SQMM.toString(),
                                ),
                                _buildTableCell(
                                  pole.serviceConnection1ph.toString(),
                                ),
                                _buildTableCell(
                                  pole.serviceConnection3ph.toString(),
                                ),
                                _buildTableCell(pole.remarks),
                                _buildTableCell(pole.gpsNo),
                              ],
                            );
                          }),

                          // Total Row
                          TableRow(
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .primaryColor
                                  .withOpacity(0.2),
                              border: Border.all(
                                color: Colors.black,
                                width: 2,
                              ),
                            ),
                            children: [
                              _buildTableTotalCell('Total'),
                              _buildTableTotalCell(''),
                              _buildTableTotalCell(
                                _calculateTotalRouteLength().toStringAsFixed(2),
                              ),
                              _buildTableTotalCell(
                                  _calculateTotalNewPoles().toString()),
                              _buildTableTotalCell(
                                  _calculateTotalStaySet().toString()),
                              _buildTableTotalCell(
                                _calculateTotalStayClampType1().toString(),
                              ),
                              _buildTableTotalCell(
                                _calculateTotalStayClampType2().toString(),
                              ),
                              _buildTableTotalCell(
                                _calculateTotalGiEarthSpike().toString(),
                              ),
                              _buildTableTotalCell(
                                  _calculateTotalSuspension().toString()),
                              _buildTableTotalCell(
                                  _calculateTotalDeadEnd().toString()),
                              _buildTableTotalCell(
                                _calculateTotalDistributionJunctionBox()
                                    .toString(),
                              ),
                              _buildTableTotalCell(
                                  _calculateTotalEyeHook().toString()),
                              _buildTableTotalCell(
                                _calculateTotalLtPoleClampType1().toString(),
                              ),
                              _buildTableTotalCell(
                                _calculateTotalLtPoleClampType2().toString(),
                              ),
                              _buildTableTotalCell(
                                _calculateTotalIpcForDB50To70().toString(),
                              ),
                              _buildTableTotalCell(
                                _calculateTotalIpcFor16SQMM().toString(),
                              ),
                              _buildTableTotalCell(
                                _calculateTotalIpcForAbcToAbc50To70SQMM()
                                    .toString(),
                              ),
                              _buildTableTotalCell(
                                _calculateTotalStraightThroughJoint70SQMM()
                                    .toString(),
                              ),
                              _buildTableTotalCell(
                                _calculateTotalStraightThroughJoint16SQMM()
                                    .toString(),
                              ),
                              _buildTableTotalCell(
                                _calculateTotalStraightThroughJoint50SQMM()
                                    .toString(),
                              ),
                              _buildTableTotalCell(
                                _calculateTotalServiceConnection1ph()
                                    .toString(),
                              ),
                              _buildTableTotalCell(
                                _calculateTotalServiceConnection3ph()
                                    .toString(),
                              ),
                              _buildTableTotalCell(''),
                              _buildTableTotalCell(''),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Calculation methods for totals
  double _calculateTotalRouteLength() {
    return _poles.fold(0.0, (sum, pole) => sum + pole.routhLength);
  }

  int _calculateTotalNewPoles() {
    return _poles.fold(0, (sum, pole) => sum + ((pole.newPole == 1) ? 1 : 0));
  }

  int _calculateTotalStaySet() {
    return _poles.fold(0, (sum, pole) => sum + pole.staySet);
  }

  int _calculateTotalStayClampType1() {
    return _poles.fold(0, (sum, pole) => sum + pole.stayClampType1);
  }

  int _calculateTotalStayClampType2() {
    return _poles.fold(0, (sum, pole) => sum + pole.stayClampType2);
  }

  int _calculateTotalGiEarthSpike() {
    return _poles.fold(0, (sum, pole) => sum + pole.giEarthSpike);
  }

  int _calculateTotalSuspension() {
    return _poles.fold(0, (sum, pole) => sum + pole.suspension);
  }

  int _calculateTotalDeadEnd() {
    return _poles.fold(0, (sum, pole) => sum + pole.deadEnd);
  }

  int _calculateTotalDistributionJunctionBox() {
    return _poles.fold(
      0,
      (sum, pole) => sum + pole.distributionJunctionBox,
    );
  }

  int _calculateTotalEyeHook() {
    return _poles.fold(0, (sum, pole) => sum + pole.eyeHook);
  }

  int _calculateTotalLtPoleClampType1() {
    return _poles.fold(0, (sum, pole) => sum + pole.ltPoleClampType1);
  }

  int _calculateTotalLtPoleClampType2() {
    return _poles.fold(0, (sum, pole) => sum + pole.ltPoleClampType2);
  }

  int _calculateTotalIpcForDB50To70() {
    return _poles.fold(0, (sum, pole) => sum + pole.ipcForDB50To70);
  }

  int _calculateTotalIpcFor16SQMM() {
    return _poles.fold(0, (sum, pole) => sum + pole.ipcFor16SQMM);
  }

  int _calculateTotalIpcForAbcToAbc50To70SQMM() {
    return _poles.fold(
      0,
      (sum, pole) => sum + pole.ipcForAbcToAbc50To70SQMM,
    );
  }

  int _calculateTotalStraightThroughJoint70SQMM() {
    return _poles.fold(
      0,
      (sum, pole) => sum + pole.straightThroughJoint70SQMM,
    );
  }

  int _calculateTotalStraightThroughJoint16SQMM() {
    return _poles.fold(
      0,
      (sum, pole) => sum + pole.straightThroughJoint16SQMM,
    );
  }

  int _calculateTotalStraightThroughJoint50SQMM() {
    return _poles.fold(
      0,
      (sum, pole) => sum + pole.straightThroughJoint50SQMM,
    );
  }

  int _calculateTotalServiceConnection1ph() {
    return _poles.fold(
      0,
      (sum, pole) => sum + pole.serviceConnection1ph,
    );
  }

  int _calculateTotalServiceConnection3ph() {
    return _poles.fold(
      0,
      (sum, pole) => sum + pole.serviceConnection3ph,
    );
  }

  Widget _buildTableHeaderCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTableCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: const TextStyle(fontSize: 10),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTableTotalCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Future<void> _exportToCsv() async {
    try {
      // No permission check needed - directly export CSV data
      // Create CSV data for DTR with improved structure
      List<List<dynamic>> dtrData = [
        // Title row
        ['DTR Code :', _currentDtr.dtrCode, ' POLE SCHEDULE'],
        [],
        // Report generation date
        ['Report Generated:', DateTime.now().toString()],
        [
          'Report Generated by ',
          _currentDtr.user,
          "Using Ns Eletrical Mobile App"
        ],
        [],
        [],

        // DTR Information Section
        ['DTR INFORMATION'],
        [],
        [],
        ['DTR Code', _currentDtr.dtrCode],
        ['Capacity', '${_currentDtr.capacity} KVA'],
        ['Village', _currentDtr.village],
        ['Location', _currentDtr.location],
        ['Land Marks', _currentDtr.landMarks],
        ['CCC', _currentDtr.ccc],
        ['Feeder', _currentDtr.feeder],
        ['Substation', _currentDtr.substation],
        ['DRG No', _currentDtr.drgNo],
        ['DOC Date', _currentDtr.docDate],
        ['JMC No', _currentDtr.jmcNo],
        ['GP', _currentDtr.gp],
        ['Census Code', _currentDtr.censusCode],
        ['Block', _currentDtr.block],
        ['Division', _currentDtr.division],
        ['User', _currentDtr.user],
        [],

        // First Table: Pole Schedule
        ['POLE SCHEDULE'],
        [],
        [
          'SL NO',
          'Pole No.',
          'Route Length (Mtr.)',
          'New PCC Pole',
          'LT Stay set',
          'LT Stay clamp (Type-I)',
          'LT Stay clamp (Type-II)',
          'GI Earth Spike',
          'Suspension',
          'Dead End',
          'Distribution Junction Box',
          'Eye hook',
          'LT pole clamp (Type-I)',
          'LT pole clamp (Type-II)',
          'IPC (ABC) to DB charging set 50-70 sq.mm',
          'IPC (ABC) for 16 sq.mm',
          'IPC ABC TEE joint for 70 sq.mm',
          'Straight through joint (ABC) 70 sq.mm power cable',
          'Straight through joint (ABC) 16 sq.mm power cable',
          'Straight through joint (ABC) 50 sq.mm neutral wire',
          'Service Connection (1Ph)',
          'Service Connection (3Ph)',
          'Remarks',
          'GPS No'
        ],
        [
          'Unit',
          'No',
          'Mtr.',
          'Nos.',
          'Set.',
          'Pair.',
          'Pair.',
          'Nos.',
          'Nos.',
          'Nos.',
          'Nos.',
          'Nos.',
          'Pair.',
          'Pair.',
          'Nos.',
          'Nos.',
          'Nos.',
          'Nos.',
          'Nos.',
          'Nos.',
          'Nos.',
          'Nos.',
          '',
          'No',
        ],

        // rows for poles
        ..._poles.map(
          (pole) => [
            pole.slNo,
            pole.poleNo,
            pole.routhLength.toStringAsFixed(2),
            pole.newPole == 1 ? '1' : '0',
            pole.staySet,
            pole.stayClampType1,
            pole.stayClampType2,
            pole.giEarthSpike,
            pole.suspension,
            pole.deadEnd,
            pole.distributionJunctionBox,
            pole.eyeHook,
            pole.ltPoleClampType1,
            pole.ltPoleClampType2,
            pole.ipcForDB50To70,
            pole.ipcFor16SQMM,
            pole.ipcForAbcToAbc50To70SQMM,
            pole.straightThroughJoint70SQMM,
            pole.straightThroughJoint16SQMM,
            pole.straightThroughJoint50SQMM,
            pole.serviceConnection1ph,
            pole.serviceConnection3ph,
            pole.remarks,
            pole.gpsNo,
          ],
        ),
        [], // Empty row for separation
        [
          'TOTAL',
          '',
          _calculateTotalRouteLength().toStringAsFixed(2),
          _calculateTotalNewPoles().toString(),
          _calculateTotalStaySet().toString(),
          _calculateTotalStayClampType1().toString(),
          _calculateTotalStayClampType2().toString(),
          _calculateTotalGiEarthSpike().toString(),
          _calculateTotalSuspension().toString(),
          _calculateTotalDeadEnd().toString(),
          _calculateTotalDistributionJunctionBox().toString(),
          _calculateTotalEyeHook().toString(),
          _calculateTotalLtPoleClampType1().toString(),
          _calculateTotalLtPoleClampType2().toString(),
          _calculateTotalIpcForDB50To70().toString(),
          _calculateTotalIpcFor16SQMM().toString(),
          _calculateTotalIpcForAbcToAbc50To70SQMM().toString(),
          _calculateTotalStraightThroughJoint70SQMM().toString(),
          _calculateTotalStraightThroughJoint16SQMM().toString(),
          _calculateTotalStraightThroughJoint50SQMM().toString(),
          _calculateTotalServiceConnection1ph().toString(),
          _calculateTotalServiceConnection3ph().toString(),
          '',
          '',
        ],
        [], // Empty row for separation

        // Second Table: Dismantle Inventory
        ['DISMANTLE INVENTORY'],
        [],
        [
          'S.No.',
          'POLE NO',
          'LT BRACKET 1 PH',
          'LT BRACKET 3 PH',
          'Back Clamp',
          'D IRON CLAMP',
          'SHACKLE INSULATOR',
          'CI REEL',
          'SHACKLE STRAP',
          'BOX BRACKET',
          'L.C',
          'Ex-STAY',
          'ACSR 50 sqmm 2-wire',
          'ACSR 50 sqmm 3-wire',
          'ACSR 50 sqmm 4-wire',
          'ACSR 50 sqmm 5-wire',
          'ACSR 30 sqmm 2-wire',
          'ACSR 30 sqmm 3-wire',
          'ACSR 30 sqmm 4-wire',
          'ACSR 30 sqmm 5-wire',
          'AAC 50 sqmm 2-wire',
          'AAC 50 sqmm 3-wire',
          'AAC 50 sqmm 4-wire',
          'AAC 50 sqmm 5-wire',
          'AAC 25 sqmm 2-wire',
          'AAC 25 sqmm 3-wire',
          'AAC 25 sqmm 4-wire',
          'AAC 25 sqmm 5-wire',
          'ACSR 20 sqmm 2-wire',
          'ACSR 20 sqmm 3-wire',
          'ACSR 20 sqmm 4-wire',
          'ACSR 20 sqmm 5-wire',
          'REMARKS',
        ],
        // Data rows for each pole in dismantle inventory
        ...List.generate(_poles.length, (index) {
          final pole = _poles[index];

          // Calculate the route length value based on wire configuration
          String getRouteLengthForWire(String wireType, String wireConfig) {
            // Only show route length if this wire type and configuration match what was selected
            if (pole.wireType == wireType &&
                pole.wireConfiguration == wireConfig) {
              return pole.routhLength.toStringAsFixed(2);
            }
            return '';
          }

          return [
            index + 1, // S.No.
            pole.poleNo, // POLE NO
            pole.ltBracket1Ph, // LT BRACKET 1 PH
            pole.ltBracket3Ph, // LT BRACKET 3 PH
            pole.backClamp, // Back Clamp
            pole.dIronClamp, // D IRON CLAMP
            pole.shackleInsulator, // SHACKLE INSULATOR
            pole.ciReel, // CI REEL
            pole.shackleStrap, // SHACKLE STRAP
            pole.boxBracket, // BOX BRACKET
            pole.lc, // L.C
            pole.exStay, // Ex-STAY
            // ACSR 50 sqmm wires
            getRouteLengthForWire('ACSR 50 sqmm', '2 wire'),
            getRouteLengthForWire('ACSR 50 sqmm', '3 wire'),
            getRouteLengthForWire('ACSR 50 sqmm', '4 wire'),
            getRouteLengthForWire('ACSR 50 sqmm', '5 wire'),
            // ACSR 30 sqmm wires
            getRouteLengthForWire('ACSR 30 sqmm', '2 wire'),
            getRouteLengthForWire('ACSR 30 sqmm', '3 wire'),
            getRouteLengthForWire('ACSR 30 sqmm', '4 wire'),
            getRouteLengthForWire('ACSR 30 sqmm', '5 wire'),
            // AAC 50 sqmm wires
            getRouteLengthForWire('AAC 50 sqmm', '2 wire'),
            getRouteLengthForWire('AAC 50 sqmm', '3 wire'),
            getRouteLengthForWire('AAC 50 sqmm', '4 wire'),
            getRouteLengthForWire('AAC 50 sqmm', '5 wire'),
            // AAC 25 sqmm wires
            getRouteLengthForWire('AAC 25 sqmm', '2 wire'),
            getRouteLengthForWire('AAC 25 sqmm', '3 wire'),
            getRouteLengthForWire('AAC 25 sqmm', '4 wire'),
            getRouteLengthForWire('AAC 25 sqmm', '5 wire'),
            // ACSR 20 sqmm wires
            getRouteLengthForWire('ACSR 20 sqmm', '2 wire'),
            getRouteLengthForWire('ACSR 20 sqmm', '3 wire'),
            getRouteLengthForWire('ACSR 20 sqmm', '4 wire'),
            getRouteLengthForWire('ACSR 20 sqmm', '5 wire'),
            pole.remarks, // REMARKS
          ];
        }),
        [], // Empty row for separation
        [
          'TOTAL',
          '',
          _calculateTotalLtBracket1Ph().toString(),
          _calculateTotalLtBracket3Ph().toString(),
          _calculateTotalBackClamp().toString(),
          _calculateTotalDIronClamp().toString(),
          _calculateTotalShackleInsulator().toString(),
          _calculateTotalCiReel().toString(),
          _calculateTotalShackleStrap().toString(),
          _calculateTotalBoxBracket().toString(),
          _calculateTotalLc().toString(),
          _calculateTotalExStay().toString(),
          _calculateTotalRouteLengthForWire('ACSR 50 sqmm', '2 wire')
              .toStringAsFixed(2),
          _calculateTotalRouteLengthForWire('ACSR 50 sqmm', '3 wire')
              .toStringAsFixed(2),
          _calculateTotalRouteLengthForWire('ACSR 50 sqmm', '4 wire')
              .toStringAsFixed(2),
          _calculateTotalRouteLengthForWire('ACSR 50 sqmm', '5 wire')
              .toStringAsFixed(2),
          _calculateTotalRouteLengthForWire('ACSR 30 sqmm', '2 wire')
              .toStringAsFixed(2),
          _calculateTotalRouteLengthForWire('ACSR 30 sqmm', '3 wire')
              .toStringAsFixed(2),
          _calculateTotalRouteLengthForWire('ACSR 30 sqmm', '4 wire')
              .toStringAsFixed(2),
          _calculateTotalRouteLengthForWire('ACSR 30 sqmm', '5 wire')
              .toStringAsFixed(2),
          _calculateTotalRouteLengthForWire('AAC 50 sqmm', '2 wire')
              .toStringAsFixed(2),
          _calculateTotalRouteLengthForWire('AAC 50 sqmm', '3 wire')
              .toStringAsFixed(2),
          _calculateTotalRouteLengthForWire('AAC 50 sqmm', '4 wire')
              .toStringAsFixed(2),
          _calculateTotalRouteLengthForWire('AAC 50 sqmm', '5 wire')
              .toStringAsFixed(2),
          _calculateTotalRouteLengthForWire('AAC 25 sqmm', '2 wire')
              .toStringAsFixed(2),
          _calculateTotalRouteLengthForWire('AAC 25 sqmm', '3 wire')
              .toStringAsFixed(2),
          _calculateTotalRouteLengthForWire('AAC 25 sqmm', '4 wire')
              .toStringAsFixed(2),
          _calculateTotalRouteLengthForWire('AAC 25 sqmm', '5 wire')
              .toStringAsFixed(2),
          _calculateTotalRouteLengthForWire('ACSR 20 sqmm', '2 wire')
              .toStringAsFixed(2),
          _calculateTotalRouteLengthForWire('ACSR 20 sqmm', '3 wire')
              .toStringAsFixed(2),
          _calculateTotalRouteLengthForWire('ACSR 20 sqmm', '4 wire')
              .toStringAsFixed(2),
          _calculateTotalRouteLengthForWire('ACSR 20 sqmm', '5 wire')
              .toStringAsFixed(2),
          '',
        ],
        [], // Empty row for separation
        [
          'ACTUAL',
          '',
          _calculateTotalLtBracket1Ph().toString(),
          _calculateTotalLtBracket3Ph().toString(),
          (_calculateTotalBackClamp() - (_calculateTotalExStay() * 2))
              .toString(),
          (_calculateTotalDIronClamp() -
                  _calculateTotalDistributionJunctionBox())
              .toString(),
          (_calculateTotalShackleInsulator() -
                  _calculateTotalDistributionJunctionBox())
              .toString(),
          _calculateTotalCiReel().toString(),
          _calculateTotalShackleStrap().toString(),
          _calculateTotalBoxBracket().toString(),
          _calculateTotalLc().toString(),
          '',
          _calculateTotalRouteLengthForWire('ACSR 50 sqmm', '2 wire')
              .toStringAsFixed(2),
          _calculateTotalRouteLengthForWire('ACSR 50 sqmm', '3 wire')
              .toStringAsFixed(2),
          _calculateTotalRouteLengthForWire('ACSR 50 sqmm', '4 wire')
              .toStringAsFixed(2),
          _calculateTotalRouteLengthForWire('ACSR 50 sqmm', '5 wire')
              .toStringAsFixed(2),
          _calculateTotalRouteLengthForWire('ACSR 30 sqmm', '2 wire')
              .toStringAsFixed(2),
          _calculateTotalRouteLengthForWire('ACSR 30 sqmm', '3 wire')
              .toStringAsFixed(2),
          _calculateTotalRouteLengthForWire('ACSR 30 sqmm', '4 wire')
              .toStringAsFixed(2),
          _calculateTotalRouteLengthForWire('ACSR 30 sqmm', '5 wire')
              .toStringAsFixed(2),
          _calculateTotalRouteLengthForWire('AAC 50 sqmm', '2 wire')
              .toStringAsFixed(2),
          _calculateTotalRouteLengthForWire('AAC 50 sqmm', '3 wire')
              .toStringAsFixed(2),
          _calculateTotalRouteLengthForWire('AAC 50 sqmm', '4 wire')
              .toStringAsFixed(2),
          _calculateTotalRouteLengthForWire('AAC 50 sqmm', '5 wire')
              .toStringAsFixed(2),
          _calculateTotalRouteLengthForWire('AAC 25 sqmm', '2 wire')
              .toStringAsFixed(2),
          _calculateTotalRouteLengthForWire('AAC 25 sqmm', '3 wire')
              .toStringAsFixed(2),
          _calculateTotalRouteLengthForWire('AAC 25 sqmm', '4 wire')
              .toStringAsFixed(2),
          _calculateTotalRouteLengthForWire('AAC 25 sqmm', '5 wire')
              .toStringAsFixed(2),
          _calculateTotalRouteLengthForWire('ACSR 20 sqmm', '2 wire')
              .toStringAsFixed(2),
          _calculateTotalRouteLengthForWire('ACSR 20 sqmm', '3 wire')
              .toStringAsFixed(2),
          _calculateTotalRouteLengthForWire('ACSR 20 sqmm', '4 wire')
              .toStringAsFixed(2),
          _calculateTotalRouteLengthForWire('ACSR 20 sqmm', '5 wire')
              .toStringAsFixed(2),
          '',
        ],
      ];

      // Convert to CSV
      String csv = const ListToCsvConverter().convert(dtrData);

      // Create a temporary file and share it as a CSV file
      final directory = await getTemporaryDirectory();

      // Create a filename with DTR information
      String dtrCode =
          _currentDtr.dtrCode.isNotEmpty ? _currentDtr.dtrCode : 'NOT FOUND';
      String village =
          _currentDtr.village.isNotEmpty ? _currentDtr.village : '';
      String location =
          _currentDtr.location.isNotEmpty ? _currentDtr.location : '';
      String landmarks =
          _currentDtr.landMarks.isNotEmpty ? _currentDtr.landMarks : ' ';

      // Sanitize filenames by replacing invalid characters
      dtrCode = dtrCode.replaceAll(RegExp(r'[<>:"/\|?*]'), '_');
      village = village.replaceAll(RegExp(r'[<>:"/\|?*]'), '_');
      location = location.replaceAll(RegExp(r'[<>:"/\|?*]'), '_');
      landmarks = landmarks.replaceAll(RegExp(r'[<>:"/\|?*]'), '_');

      // Create filename in the format: village location landmarks (dtr_code)
      final fileName = '$village $location $landmarks ($dtrCode).csv';
      final path = '${directory.path}/$fileName';

      // Write CSV to file
      final file = File(path);
      await file.writeAsString(csv);

      // Share the file
      await Share.shareXFiles([
        XFile(path),
      ],
          text:
              'DTR and Pole Data for ${_currentDtr.dtrCode.isNotEmpty ? _currentDtr.dtrCode : ''}');

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('CSV file exported successfully')),
        );
      }
    } catch (e, stackTrace) {
      print('Error exporting to CSV: $e');
      print('Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(
            content: Text('Error exporting to CSV. Please try again.')));
      }
    }
  }

  Future<void> _addNewPole() async {
    final result = await Navigator.pushNamed(
      context,
      AppConstants.addPoleRoute,
      arguments: {'dtr': widget.dtr},
    );

    // If a pole was added, refresh the list
    if (result != null && result as bool) {
      _loadPoles();
    }

    // Scroll to top smoothly after the action
    _scrollToTop();
  }

  // Method to scroll to top smoothly
  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0.0, // Scroll to top
        duration:
            const Duration(milliseconds: 500), // Smooth animation duration
        curve: Curves.easeInOut, // Smooth curve
      );
    }
  }

  Widget _buildTableUnitCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Colors.black54,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  // Method to handle pole schedule editing
  Future<void> _editPoleSchedule() async {
    // Show a dialog with options to edit individual poles or add new ones
    if (mounted) {
      await showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (BuildContext context) {
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  height: 4,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Header
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Pole Schedule Options',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // Options
                ListTile(
                  leading: const Icon(Icons.add, color: Colors.green),
                  title: const Text('Add New Pole'),
                  onTap: () {
                    Navigator.pop(context);
                    _addNewPole();
                  },
                ),

                ListTile(
                  leading: const Icon(Icons.edit, color: Colors.blue),
                  title: const Text('Edit Individual Poles'),
                  onTap: () {
                    Navigator.pop(context);
                    _showPoleSelectionDialog();
                  },
                ),

                ListTile(
                  leading: const Icon(Icons.edit_square, color: Colors.orange),
                  title: const Text('Edit All Poles'),
                  onTap: () {
                    Navigator.pop(context);
                    _editAllPoles();
                  },
                ),

                const Divider(height: 1),

                ListTile(
                  title: const Text('Cancel'),
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          );
        },
      );
    }
  }

  // Method to show pole selection dialog for editing
  Future<void> _showPoleSelectionDialog() async {
    if (mounted) {
      await showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        // Add constraints to prevent overflow
        constraints: const BoxConstraints(
          maxHeight: 400, // Limit height to prevent overflow
        ),
        builder: (BuildContext context) {
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  height: 4,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Header
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Select Pole to Edit',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // List of poles
                Expanded(
                  // Use Expanded instead of SizedBox for better flexibility
                  child: ListView.builder(
                    itemCount: _poles.length,
                    itemBuilder: (context, index) {
                      final pole = _poles[index];
                      return ListTile(
                        title: Text('Pole ${pole.poleNo}'),
                        subtitle: Text('SL No: ${pole.slNo}'),
                        onTap: () {
                          Navigator.pop(context);
                          _editPole(pole);
                        },
                      );
                    },
                  ),
                ),

                const Divider(height: 1),

                ListTile(
                  title: const Text('Cancel'),
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          );
        },
      );
    }
  }

  // Method to edit a specific pole
  Future<void> _editPole(Pole pole) async {
    // Navigate to the add pole screen with the pole to edit
    final result = await Navigator.pushNamed(
      context,
      AppConstants.addPoleRoute,
      arguments: {'dtr': widget.dtr, 'poleToEdit': pole},
    );

    // If a pole was updated, refresh the list
    if (result != null && result as bool) {
      _loadPoles();
    }

    // Scroll to top smoothly after the action
    _scrollToTop();
  }

  // Method to edit all poles at once
  Future<void> _editAllPoles() async {
    // Show a dialog with options to edit all poles
    if (mounted) {
      await showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        // Add constraints to prevent overflow
        constraints: const BoxConstraints(
          maxHeight: 300, // Limit height to prevent overflow
        ),
        builder: (BuildContext context) {
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  height: 4,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Header
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Edit All Poles',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // Message
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'This feature allows you to edit all poles in sequence. You will be taken through each pole one by one.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Edit All Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context); // Close the bottom sheet

                      // Start editing all poles sequentially
                      _startEditingAllPoles();
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      // Make button responsive with flexible sizing
                      minimumSize: const Size(double.infinity, 50),
                      // Reduce padding for better fit
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Edit All', // Further shortened text
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Cancel Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      // Make button responsive with flexible sizing
                      minimumSize: const Size(double.infinity, 50),
                      // Reduce padding for better fit
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          );
        },
      );
    }
  }

  // Method to start editing all poles in sequence
  Future<void> _startEditingAllPoles() async {
    if (_poles.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('OK')),
        );
      }
      return;
    }

    // Start editing from the first pole
    _editPoleAtIndex(0);
  }

  // Method to edit a pole at specific index and move to next
  Future<void> _editPoleAtIndex(int index) async {
    if (index >= _poles.length) {
      // All poles have been edited
      if (mounted) {
        if (_poles.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('OK')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('All poles have been updated')),
          );
        }
        _loadPoles(); // Refresh the list
      }
      return;
    }

    // Edit the current pole
    final pole = _poles[index];
    final result = await Navigator.pushNamed(
      context,
      AppConstants.addPoleRoute,
      arguments: {
        'dtr': widget.dtr,
        'poleToEdit': pole,
      },
    );

    // Handle navigation results
    if (result != null && result as bool) {
      // Regular save, continue to the next pole
      _loadPoles(); // Refresh the list
      _editPoleAtIndex(index + 1);
    }
  }

  // Add this method to handle DTR editing
  Future<void> _editDTR() async {
    // Navigate to DTR edit screen
    final result = await Navigator.pushNamed(
      context,
      AppConstants.dtrRoute,
      arguments: _currentDtr, // Pass the current DTR for editing
    );

    // If DTR was updated, refresh the DTR data
    if (result != null && result as bool) {
      // Reload the DTR data to get updated information
      await _refreshDtrData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('DTR updated successfully')),
        );
      }
    }
  }

  // Add this method to refresh DTR data
  Future<void> _refreshDtrData() async {
    try {
      // Fetch the updated DTR from the service
      final updatedDtr = await _dtrService.getDTRById(_currentDtr.id);
      if (updatedDtr != null && mounted) {
        // Update the current DTR state
        setState(() {
          _currentDtr = updatedDtr;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error refreshing DTR data: $e')),
        );
      }
    }
  }

  // Add this new method for the dismantle inventory table
  Widget _buildDismantleInventoryTable() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.inventory,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 10),
                Text(
                  'Dismantle Inventory',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Improved scrollable container with better performance
            LayoutBuilder(
              builder: (context, constraints) {
                return ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: constraints.maxHeight * 0.6, // Responsive height
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Table(
                        border: TableBorder.all(
                          color: Colors.black,
                          width: 0.5,
                        ),
                        columnWidths: const {
                          0: FixedColumnWidth(60), // S.No.
                          1: FixedColumnWidth(80), // POLE NO
                          2: FixedColumnWidth(60), // LT BRACKET 1 PH
                          3: FixedColumnWidth(60), // LT BRACKET 3 PH
                          4: FixedColumnWidth(80), // Back Clamp
                          5: FixedColumnWidth(100), // D IRON CLAMP
                          6: FixedColumnWidth(120), // SHACKLE INSULATOR
                          7: FixedColumnWidth(70), // CI REEL
                          8: FixedColumnWidth(100), // SHACKLE STRAP
                          9: FixedColumnWidth(90), // BOX BRACKET
                          10: FixedColumnWidth(50), // L.C
                          11: FixedColumnWidth(70), // Ex-STAY
                          12: FixedColumnWidth(60), // ACSR 50 sqmm 2-wire
                          13: FixedColumnWidth(60), // ACSR 50 sqmm 3-wire
                          14: FixedColumnWidth(60), // ACSR 50 sqmm 4-wire
                          15: FixedColumnWidth(60), // ACSR 50 sqmm 5-wire
                          16: FixedColumnWidth(60), // ACSR 30 sqmm 2-wire
                          17: FixedColumnWidth(60), // ACSR 30 sqmm 3-wire
                          18: FixedColumnWidth(60), // ACSR 30 sqmm 4-wire
                          19: FixedColumnWidth(60), // ACSR 30 sqmm 5-wire
                          20: FixedColumnWidth(60), // AAC 50 sqmm 2-wire
                          21: FixedColumnWidth(60), // AAC 50 sqmm 3-wire
                          22: FixedColumnWidth(60), // AAC 50 sqmm 4-wire
                          23: FixedColumnWidth(60), // AAC 50 sqmm 5-wire
                          24: FixedColumnWidth(60), // AAC 25 sqmm 2-wire
                          25: FixedColumnWidth(60), // AAC 25 sqmm 3-wire
                          26: FixedColumnWidth(60), // AAC 25 sqmm 4-wire
                          27: FixedColumnWidth(60), // AAC 25 sqmm 5-wire
                          28: FixedColumnWidth(60), // ACSR 20 sqmm 2-wire
                          29: FixedColumnWidth(60), // ACSR 20 sqmm 3-wire
                          30: FixedColumnWidth(60), // ACSR 20 sqmm 4-wire
                          31: FixedColumnWidth(60), // ACSR 20 sqmm 5-wire
                          32: FixedColumnWidth(100), // REMARKS
                        },
                        children: [
                          // First header row with group labels
                          TableRow(
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .primaryColor
                                  .withOpacity(0.1),
                            ),
                            children: [
                              _buildTableHeaderCell('S.No.'),
                              _buildTableHeaderCell('POLE NO'),
                              _buildTableHeaderCell('LT BRACKET'),
                              _buildTableHeaderCell('LT BRACKET'),
                              _buildTableHeaderCell('Back Clamp'),
                              _buildTableHeaderCell('D IRON CLAMP'),
                              _buildTableHeaderCell('SHACKLE INSULATOR'),
                              _buildTableHeaderCell('CI REEL'),
                              _buildTableHeaderCell('SHACKLE STRAP'),
                              _buildTableHeaderCell('BOX BRACKET'),
                              _buildTableHeaderCell('L.C'),
                              _buildTableHeaderCell('Ex-STAY'),
                              _buildTableHeaderCell('ACSR 50 sqmm'),
                              _buildTableHeaderCell('ACSR 50 sqmm'),
                              _buildTableHeaderCell('ACSR 50 sqmm'),
                              _buildTableHeaderCell('ACSR 50 sqmm'),
                              _buildTableHeaderCell('ACSR 30 sqmm'),
                              _buildTableHeaderCell('ACSR 30 sqmm'),
                              _buildTableHeaderCell('ACSR 30 sqmm'),
                              _buildTableHeaderCell('ACSR 30 sqmm'),
                              _buildTableHeaderCell('AAC 50 sqmm'),
                              _buildTableHeaderCell('AAC 50 sqmm'),
                              _buildTableHeaderCell('AAC 50 sqmm'),
                              _buildTableHeaderCell('AAC 50 sqmm'),
                              _buildTableHeaderCell('AAC 25 sqmm'),
                              _buildTableHeaderCell('AAC 25 sqmm'),
                              _buildTableHeaderCell('AAC 25 sqmm'),
                              _buildTableHeaderCell('AAC 25 sqmm'),
                              _buildTableHeaderCell('ACSR 20 sqmm'),
                              _buildTableHeaderCell('ACSR 20 sqmm'),
                              _buildTableHeaderCell('ACSR 20 sqmm'),
                              _buildTableHeaderCell('ACSR 20 sqmm'),
                              _buildTableHeaderCell('REMARKS'),
                            ],
                          ),
                          // Second header row with subheaders
                          TableRow(
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .primaryColor
                                  .withOpacity(0.1),
                            ),
                            children: [
                              _buildTableHeaderCell(''),
                              _buildTableHeaderCell(''),
                              _buildTableHeaderCell('1 PH'),
                              _buildTableHeaderCell('3 PH'),
                              _buildTableHeaderCell(''),
                              _buildTableHeaderCell(''),
                              _buildTableHeaderCell(''),
                              _buildTableHeaderCell(''),
                              _buildTableHeaderCell(''),
                              _buildTableHeaderCell(''),
                              _buildTableHeaderCell(''),
                              _buildTableHeaderCell(''),
                              _buildTableHeaderCell('2-wire'),
                              _buildTableHeaderCell('3-wire'),
                              _buildTableHeaderCell('4-wire'),
                              _buildTableHeaderCell('5-wire'),
                              _buildTableHeaderCell('2-wire'),
                              _buildTableHeaderCell('3-wire'),
                              _buildTableHeaderCell('4-wire'),
                              _buildTableHeaderCell('5-wire'),
                              _buildTableHeaderCell('2-wire'),
                              _buildTableHeaderCell('3-wire'),
                              _buildTableHeaderCell('4-wire'),
                              _buildTableHeaderCell('5-wire'),
                              _buildTableHeaderCell('2-wire'),
                              _buildTableHeaderCell('3-wire'),
                              _buildTableHeaderCell('4-wire'),
                              _buildTableHeaderCell('5-wire'),
                              _buildTableHeaderCell('2-wire'),
                              _buildTableHeaderCell('3-wire'),
                              _buildTableHeaderCell('4-wire'),
                              _buildTableHeaderCell('5-wire'),
                              _buildTableHeaderCell(''),
                            ],
                          ),
                          // Data rows for each pole
                          ...List.generate(_poles.length, (index) {
                            final pole = _poles[index];

                            // Calculate the route length value based on wire configuration
                            String getRouteLengthForWire(
                                String wireType, String wireConfig) {
                              // Only show route length if this wire type and configuration match what was selected
                              if (pole.wireType == wireType &&
                                  pole.wireConfiguration == wireConfig) {
                                return pole.routhLength.toStringAsFixed(2);
                              }
                              return '';
                            }

                            return TableRow(
                              children: [
                                _buildTableCell('${index + 1}'), // S.No.
                                _buildTableCell(pole.poleNo), // POLE NO
                                _buildTableCell(pole.ltBracket1Ph
                                    .toString()), // LT BRACKET 1 PH
                                _buildTableCell(pole.ltBracket3Ph
                                    .toString()), // LT BRACKET 3 PH
                                _buildTableCell(
                                    pole.backClamp.toString()), // Back Clamp
                                _buildTableCell(
                                    pole.dIronClamp.toString()), // D IRON CLAMP
                                _buildTableCell(pole.shackleInsulator
                                    .toString()), // SHACKLE INSULATOR
                                _buildTableCell(
                                    pole.ciReel.toString()), // CI REEL
                                _buildTableCell(pole.shackleStrap
                                    .toString()), // SHACKLE STRAP
                                _buildTableCell(
                                    pole.boxBracket.toString()), // BOX BRACKET
                                _buildTableCell(pole.lc.toString()), // L.C
                                _buildTableCell(
                                    pole.exStay.toString()), // Ex-STAY
                                // ACSR 50 sqmm wires
                                _buildTableCell(getRouteLengthForWire(
                                    'ACSR 50 sqmm', '2 wire')),
                                _buildTableCell(getRouteLengthForWire(
                                    'ACSR 50 sqmm', '3 wire')),
                                _buildTableCell(getRouteLengthForWire(
                                    'ACSR 50 sqmm', '4 wire')),
                                _buildTableCell(getRouteLengthForWire(
                                    'ACSR 50 sqmm', '5 wire')),
                                // ACSR 30 sqmm wires
                                _buildTableCell(getRouteLengthForWire(
                                    'ACSR 30 sqmm', '2 wire')),
                                _buildTableCell(getRouteLengthForWire(
                                    'ACSR 30 sqmm', '3 wire')),
                                _buildTableCell(getRouteLengthForWire(
                                    'ACSR 30 sqmm', '4 wire')),
                                _buildTableCell(getRouteLengthForWire(
                                    'ACSR 30 sqmm', '5 wire')),
                                // AAC 50 sqmm wires
                                _buildTableCell(getRouteLengthForWire(
                                    'AAC 50 sqmm', '2 wire')),
                                _buildTableCell(getRouteLengthForWire(
                                    'AAC 50 sqmm', '3 wire')),
                                _buildTableCell(getRouteLengthForWire(
                                    'AAC 50 sqmm', '4 wire')),
                                _buildTableCell(getRouteLengthForWire(
                                    'AAC 50 sqmm', '5 wire')),
                                // AAC 25 sqmm wires
                                _buildTableCell(getRouteLengthForWire(
                                    'AAC 25 sqmm', '2 wire')),
                                _buildTableCell(getRouteLengthForWire(
                                    'AAC 25 sqmm', '3 wire')),
                                _buildTableCell(getRouteLengthForWire(
                                    'AAC 25 sqmm', '4 wire')),
                                _buildTableCell(getRouteLengthForWire(
                                    'AAC 25 sqmm', '5 wire')),
                                // ACSR 20 sqmm wires
                                _buildTableCell(getRouteLengthForWire(
                                    'ACSR 20 sqmm', '2 wire')),
                                _buildTableCell(getRouteLengthForWire(
                                    'ACSR 20 sqmm', '3 wire')),
                                _buildTableCell(getRouteLengthForWire(
                                    'ACSR 20 sqmm', '4 wire')),
                                _buildTableCell(getRouteLengthForWire(
                                    'ACSR 20 sqmm', '5 wire')),
                                _buildTableCell(pole.remarks), // REMARKS
                              ],
                            );
                          }),
                          // Total Row
                          TableRow(
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .primaryColor
                                  .withOpacity(0.2),
                              border: Border.all(
                                color: Colors.black,
                                width: 2,
                              ),
                            ),
                            children: [
                              _buildTableTotalCell('Total'),
                              _buildTableTotalCell(''),
                              _buildTableTotalCell(
                                  _calculateTotalLtBracket1Ph().toString()),
                              _buildTableTotalCell(
                                  _calculateTotalLtBracket3Ph().toString()),
                              _buildTableTotalCell(
                                  _calculateTotalBackClamp().toString()),
                              _buildTableTotalCell(
                                  _calculateTotalDIronClamp().toString()),
                              _buildTableTotalCell(
                                  _calculateTotalShackleInsulator().toString()),
                              _buildTableTotalCell(
                                  _calculateTotalCiReel().toString()),
                              _buildTableTotalCell(
                                  _calculateTotalShackleStrap().toString()),
                              _buildTableTotalCell(
                                  _calculateTotalBoxBracket().toString()),
                              _buildTableTotalCell(
                                  _calculateTotalLc().toString()),
                              _buildTableTotalCell(
                                  _calculateTotalExStay().toString()),
                              _buildTableTotalCell(
                                  _calculateTotalRouteLengthForWire(
                                          'ACSR 50 sqmm', '2 wire')
                                      .toStringAsFixed(2)),
                              _buildTableTotalCell(
                                  _calculateTotalRouteLengthForWire(
                                          'ACSR 50 sqmm', '3 wire')
                                      .toStringAsFixed(2)),
                              _buildTableTotalCell(
                                  _calculateTotalRouteLengthForWire(
                                          'ACSR 50 sqmm', '4 wire')
                                      .toStringAsFixed(2)),
                              _buildTableTotalCell(
                                  _calculateTotalRouteLengthForWire(
                                          'ACSR 50 sqmm', '5 wire')
                                      .toStringAsFixed(2)),
                              _buildTableTotalCell(
                                  _calculateTotalRouteLengthForWire(
                                          'ACSR 30 sqmm', '2 wire')
                                      .toStringAsFixed(2)),
                              _buildTableTotalCell(
                                  _calculateTotalRouteLengthForWire(
                                          'ACSR 30 sqmm', '3 wire')
                                      .toStringAsFixed(2)),
                              _buildTableTotalCell(
                                  _calculateTotalRouteLengthForWire(
                                          'ACSR 30 sqmm', '4 wire')
                                      .toStringAsFixed(2)),
                              _buildTableTotalCell(
                                  _calculateTotalRouteLengthForWire(
                                          'ACSR 30 sqmm', '5 wire')
                                      .toStringAsFixed(2)),
                              _buildTableTotalCell(
                                  _calculateTotalRouteLengthForWire(
                                          'AAC 50 sqmm', '2 wire')
                                      .toStringAsFixed(2)),
                              _buildTableTotalCell(
                                  _calculateTotalRouteLengthForWire(
                                          'AAC 50 sqmm', '3 wire')
                                      .toStringAsFixed(2)),
                              _buildTableTotalCell(
                                  _calculateTotalRouteLengthForWire(
                                          'AAC 50 sqmm', '4 wire')
                                      .toStringAsFixed(2)),
                              _buildTableTotalCell(
                                  _calculateTotalRouteLengthForWire(
                                          'AAC 50 sqmm', '5 wire')
                                      .toStringAsFixed(2)),
                              _buildTableTotalCell(
                                  _calculateTotalRouteLengthForWire(
                                          'AAC 25 sqmm', '2 wire')
                                      .toStringAsFixed(2)),
                              _buildTableTotalCell(
                                  _calculateTotalRouteLengthForWire(
                                          'AAC 25 sqmm', '3 wire')
                                      .toStringAsFixed(2)),
                              _buildTableTotalCell(
                                  _calculateTotalRouteLengthForWire(
                                          'AAC 25 sqmm', '4 wire')
                                      .toStringAsFixed(2)),
                              _buildTableTotalCell(
                                  _calculateTotalRouteLengthForWire(
                                          'AAC 25 sqmm', '5 wire')
                                      .toStringAsFixed(2)),
                              _buildTableTotalCell(
                                  _calculateTotalRouteLengthForWire(
                                          'ACSR 20 sqmm', '2 wire')
                                      .toStringAsFixed(2)),
                              _buildTableTotalCell(
                                  _calculateTotalRouteLengthForWire(
                                          'ACSR 20 sqmm', '3 wire')
                                      .toStringAsFixed(2)),
                              _buildTableTotalCell(
                                  _calculateTotalRouteLengthForWire(
                                          'ACSR 20 sqmm', '4 wire')
                                      .toStringAsFixed(2)),
                              _buildTableTotalCell(
                                  _calculateTotalRouteLengthForWire(
                                          'ACSR 20 sqmm', '5 wire')
                                      .toStringAsFixed(2)),
                              _buildTableTotalCell(''),
                            ],
                          ),
                          // ACTUAL Row
                          TableRow(
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .primaryColor
                                  .withOpacity(0.3),
                              border: const Border(
                                top: BorderSide(
                                  color: Colors.black,
                                  width: 1,
                                ),
                              ),
                            ),
                            children: [
                              _buildTableTotalCell('ACTUAL'),
                              _buildTableTotalCell(''),
                              _buildTableTotalCell(
                                  _calculateTotalLtBracket1Ph().toString()),
                              _buildTableTotalCell(
                                  _calculateTotalLtBracket3Ph().toString()),
                              _buildTableTotalCell((_calculateTotalBackClamp() -
                                      (_calculateTotalExStay() * 2))
                                  .toString()),
                              _buildTableTotalCell((_calculateTotalDIronClamp() -
                                      _calculateTotalDistributionJunctionBox())
                                  .toString()),
                              _buildTableTotalCell(
                                  (_calculateTotalShackleInsulator() -
                                          _calculateTotalDistributionJunctionBox())
                                      .toString()),
                              _buildTableTotalCell(
                                  _calculateTotalCiReel().toString()),
                              _buildTableTotalCell(
                                  _calculateTotalShackleStrap().toString()),
                              _buildTableTotalCell(
                                  _calculateTotalBoxBracket().toString()),
                              _buildTableTotalCell(
                                  _calculateTotalLc().toString()),
                              _buildTableTotalCell(''),
                              _buildTableTotalCell(
                                  _calculateTotalRouteLengthForWire(
                                          'ACSR 50 sqmm', '2 wire')
                                      .toStringAsFixed(2)),
                              _buildTableTotalCell(
                                  _calculateTotalRouteLengthForWire(
                                          'ACSR 50 sqmm', '3 wire')
                                      .toStringAsFixed(2)),
                              _buildTableTotalCell(
                                  _calculateTotalRouteLengthForWire(
                                          'ACSR 50 sqmm', '4 wire')
                                      .toStringAsFixed(2)),
                              _buildTableTotalCell(
                                  _calculateTotalRouteLengthForWire(
                                          'ACSR 50 sqmm', '5 wire')
                                      .toStringAsFixed(2)),
                              _buildTableTotalCell(
                                  _calculateTotalRouteLengthForWire(
                                          'ACSR 30 sqmm', '2 wire')
                                      .toStringAsFixed(2)),
                              _buildTableTotalCell(
                                  _calculateTotalRouteLengthForWire(
                                          'ACSR 30 sqmm', '3 wire')
                                      .toStringAsFixed(2)),
                              _buildTableTotalCell(
                                  _calculateTotalRouteLengthForWire(
                                          'ACSR 30 sqmm', '4 wire')
                                      .toStringAsFixed(2)),
                              _buildTableTotalCell(
                                  _calculateTotalRouteLengthForWire(
                                          'ACSR 30 sqmm', '5 wire')
                                      .toStringAsFixed(2)),
                              _buildTableTotalCell(
                                  _calculateTotalRouteLengthForWire(
                                          'AAC 50 sqmm', '2 wire')
                                      .toStringAsFixed(2)),
                              _buildTableTotalCell(
                                  _calculateTotalRouteLengthForWire(
                                          'AAC 50 sqmm', '3 wire')
                                      .toStringAsFixed(2)),
                              _buildTableTotalCell(
                                  _calculateTotalRouteLengthForWire(
                                          'AAC 50 sqmm', '4 wire')
                                      .toStringAsFixed(2)),
                              _buildTableTotalCell(
                                  _calculateTotalRouteLengthForWire(
                                          'AAC 50 sqmm', '5 wire')
                                      .toStringAsFixed(2)),
                              _buildTableTotalCell(
                                  _calculateTotalRouteLengthForWire(
                                          'AAC 25 sqmm', '2 wire')
                                      .toStringAsFixed(2)),
                              _buildTableTotalCell(
                                  _calculateTotalRouteLengthForWire(
                                          'AAC 25 sqmm', '3 wire')
                                      .toStringAsFixed(2)),
                              _buildTableTotalCell(
                                  _calculateTotalRouteLengthForWire(
                                          'AAC 25 sqmm', '4 wire')
                                      .toStringAsFixed(2)),
                              _buildTableTotalCell(
                                  _calculateTotalRouteLengthForWire(
                                          'AAC 25 sqmm', '5 wire')
                                      .toStringAsFixed(2)),
                              _buildTableTotalCell(
                                  _calculateTotalRouteLengthForWire(
                                          'ACSR 20 sqmm', '2 wire')
                                      .toStringAsFixed(2)),
                              _buildTableTotalCell(
                                  _calculateTotalRouteLengthForWire(
                                          'ACSR 20 sqmm', '3 wire')
                                      .toStringAsFixed(2)),
                              _buildTableTotalCell(
                                  _calculateTotalRouteLengthForWire(
                                          'ACSR 20 sqmm', '4 wire')
                                      .toStringAsFixed(2)),
                              _buildTableTotalCell(
                                  _calculateTotalRouteLengthForWire(
                                          'ACSR 20 sqmm', '5 wire')
                                      .toStringAsFixed(2)),
                              _buildTableTotalCell(''),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Calculation methods for dismantle inventory totals
  int _calculateTotalLtBracket1Ph() {
    return _poles.fold(0, (sum, pole) => sum + pole.ltBracket1Ph);
  }

  int _calculateTotalLtBracket3Ph() {
    return _poles.fold(0, (sum, pole) => sum + pole.ltBracket3Ph);
  }

  int _calculateTotalBackClamp() {
    return _poles.fold(0, (sum, pole) => sum + pole.backClamp);
  }

  int _calculateTotalDIronClamp() {
    return _poles.fold(0, (sum, pole) => sum + pole.dIronClamp);
  }

  int _calculateTotalShackleInsulator() {
    return _poles.fold(0, (sum, pole) => sum + pole.shackleInsulator);
  }

  int _calculateTotalCiReel() {
    return _poles.fold(0, (sum, pole) => sum + pole.ciReel);
  }

  int _calculateTotalShackleStrap() {
    return _poles.fold(0, (sum, pole) => sum + pole.shackleStrap);
  }

  int _calculateTotalBoxBracket() {
    return _poles.fold(0, (sum, pole) => sum + pole.boxBracket);
  }

  int _calculateTotalLc() {
    return _poles.fold(0, (sum, pole) => sum + pole.lc);
  }

  int _calculateTotalExStay() {
    return _poles.fold(0, (sum, pole) => sum + pole.exStay);
  }

  // Calculate total route length for specific wire type and configuration
  double _calculateTotalRouteLengthForWire(String wireType, String wireConfig) {
    return _poles
        .where((pole) =>
            pole.wireType == wireType && pole.wireConfiguration == wireConfig)
        .fold(0.0, (sum, pole) => sum + pole.routhLength);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${_currentDtr.village} (${_currentDtr.dtrCode}) Pole Schedule',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        elevation: 2,
        actions: [
          IconButton(
            onPressed: () {
              _loadPoles();
              // Scroll to top when refreshing
              _scrollToTop();
            },
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
          IconButton(
            onPressed: _exportToCsv,
            icon: const Icon(Icons.share),
            tooltip: 'Export',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _poles.isEmpty
              ? _buildEmptyState()
              : SingleChildScrollView(
                  controller: _scrollController, // Add the controller here
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPoleScheduleForm(),
                      _buildDismantleInventoryTable(), // Add the new dismantle inventory table
                      const SizedBox(
                          height:
                              80), // Add bottom padding to prevent content from being hidden by navigation buttons
                    ],
                  ),
                ),
      floatingActionButton: FloatingActionButton(
          onPressed: _addNewPole,
          tooltip: 'Add Pole',
          heroTag: 'main_add_pole_fab',
          child: const Icon(Icons.add)),
      // Edit functionality is now available through icons in the headers
    );
  }
}

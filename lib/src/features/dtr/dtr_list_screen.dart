import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';

import '../../core/models/dtr_model.dart';
import '../../core/models/pole_model.dart';
import '../../core/services/dtr_service.dart';
import '../../core/services/pole_service.dart';
import '../../core/services/auth_service.dart';

// Modern color palette
class DTRListColors {
  static const primaryGradient = [Color(0xFF667eea), Color(0xFF764ba2)];
  static const secondaryGradient = [Color(0xFFf093fb), Color(0xFFf5576c)];
  static const successGradient = [Color(0xFF4facfe), Color(0xFF00f2fe)];
  static const warningGradient = [Color(0xFFfa709a), Color(0xFFfee140)];
  static const infoGradient = [Color(0xFF30cfd0), Color(0xFF330867)];
  
  static Color getCardColor(bool isDarkMode) => 
      isDarkMode ? const Color(0xFF1E1E2E) : Colors.white;
  
  static Color getBackgroundColor(bool isDarkMode) => 
      isDarkMode ? const Color(0xFF0F0F1A) : const Color(0xFFF8FAFF);
  
  static Color getTextColor(bool isDarkMode) => 
      isDarkMode ? Colors.white : const Color(0xFF1A1A2E);
  
  static Color getSubtextColor(bool isDarkMode) => 
      isDarkMode ? const Color(0xFF8B8B9E) : const Color(0xFF6B7280);
}

class DTRListScreen extends StatefulWidget {
  const DTRListScreen({super.key});

  @override
  State<DTRListScreen> createState() => _DTRListScreenState();
}

class _DTRListScreenState extends State<DTRListScreen> {
  final DTRService _dtrService = DTRService();
  final PoleService _poleService = PoleService();
  
  List<DTR> _dtrs = [];
  Map<String, List<Pole>> _dtrPoles = {};
  Map<String, DTRMaterialsSummary> _materialsSummary = {};
  bool _isLoading = true;
  String _searchQuery = '';
  List<DTR> _filteredDTRs = [];

  @override
  void initState() {
    super.initState();
    _loadDTRs();
  }

  Future<void> _loadDTRs() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get current user
      final authService = Provider.of<AuthService>(context, listen: false);
      final currentUser = authService.userEmail;

      // Get all DTRs
      final allDTRs = await _dtrService.getAllDTRs();
      
      // Filter DTRs by current user
      final userDTRs = allDTRs.where((dtr) => 
        dtr.user.isEmpty || dtr.user == currentUser
      ).toList();

      // Load poles and calculate materials for each DTR
      final Map<String, List<Pole>> polesMap = {};
      final Map<String, DTRMaterialsSummary> summaryMap = {};

      for (final dtr in userDTRs) {
        final poles = await _poleService.getPolesForDTR(dtr.id);
        polesMap[dtr.id] = poles;
        summaryMap[dtr.id] = _calculateMaterialsSummary(poles);
      }

      setState(() {
        _dtrs = userDTRs;
        _filteredDTRs = userDTRs;
        _dtrPoles = polesMap;
        _materialsSummary = summaryMap;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading DTRs: $e')),
        );
      }
    }
  }

  DTRMaterialsSummary _calculateMaterialsSummary(List<Pole> poles) {
    int totalMaterials = 0;
    int totalDismantle = 0;

    for (final pole in poles) {
      // Sum all construction materials
      totalMaterials += pole.newPole +
          pole.staySet +
          pole.stayClampType1 +
          pole.stayClampType2 +
          pole.giEarthSpike +
          pole.suspension +
          pole.deadEnd +
          pole.distributionJunctionBox +
          pole.eyeHook +
          pole.ltPoleClampType1 +
          pole.ltPoleClampType2 +
          pole.ipcForDB50To70 +
          pole.ipcFor16SQMM +
          pole.ipcForAbcToAbc50To70SQMM +
          pole.straightThroughJoint70SQMM +
          pole.straightThroughJoint16SQMM +
          pole.straightThroughJoint50SQMM +
          pole.serviceConnection1ph +
          pole.serviceConnection3ph;

      // Sum all dismantle inventory
      totalDismantle += pole.ltBracket1Ph +
          pole.ltBracket3Ph +
          pole.backClamp +
          pole.dIronClamp +
          pole.shackleInsulator +
          pole.ciReel +
          pole.shackleStrap +
          pole.boxBracket +
          pole.lc +
          pole.exStay;
    }

    return DTRMaterialsSummary(
      totalMaterials: totalMaterials,
      totalDismantle: totalDismantle,
      poleCount: poles.length,
    );
  }

  void _filterDTRs(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredDTRs = _dtrs;
      } else {
        _filteredDTRs = _dtrs.where((dtr) {
          return dtr.dtrCode.toLowerCase().contains(query.toLowerCase()) ||
              dtr.village.toLowerCase().contains(query.toLowerCase()) ||
              dtr.location.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: DTRListColors.getBackgroundColor(isDarkMode),
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(context, isDarkMode, colorScheme),
      body: _isLoading
          ? _buildLoadingWidget(isDarkMode)
          : _buildBody(context, isDarkMode, colorScheme),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isDarkMode, ColorScheme colorScheme) {
    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: DTRListColors.primaryGradient,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white.withValues(alpha: 0.1),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Reports & Analytics',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 20,
              letterSpacing: -0.5,
            ),
          ),
          Text(
            '${_dtrs.length} Transformers',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.refresh_rounded, color: Colors.white, size: 20),
          ),
          onPressed: _loadDTRs,
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildLoadingWidget(bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: DTRListColors.primaryGradient[0],
          ),
          const SizedBox(height: 16),
          Text(
            'Loading DTRs...',
            style: TextStyle(
              color: DTRListColors.getSubtextColor(isDarkMode),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, bool isDarkMode, ColorScheme colorScheme) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Top spacing for app bar
        SliverToBoxAdapter(
          child: SizedBox(height: isDarkMode ? 100 : 110),
        ),

        // Search Bar
        SliverToBoxAdapter(
          child: FadeInDown(
            duration: const Duration(milliseconds: 600),
            child: _buildSearchBar(context, isDarkMode, colorScheme),
          ),
        ),

        SliverToBoxAdapter(
          child: SizedBox(height: isDarkMode ? 20 : 24),
        ),

        // Summary Cards
        SliverToBoxAdapter(
          child: FadeInUp(
            delay: const Duration(milliseconds: 200),
            duration: const Duration(milliseconds: 600),
            child: _buildSummaryCards(context, isDarkMode, colorScheme),
          ),
        ),

        SliverToBoxAdapter(
          child: SizedBox(height: isDarkMode ? 24 : 28),
        ),

        // DTR Table Header
        SliverToBoxAdapter(
          child: FadeInUp(
            delay: const Duration(milliseconds: 300),
            duration: const Duration(milliseconds: 600),
            child: _buildTableHeader(context, isDarkMode, colorScheme),
          ),
        ),

        SliverToBoxAdapter(
          child: SizedBox(height: isDarkMode ? 16 : 20),
        ),

        // DTR Data Table
        _filteredDTRs.isEmpty
            ? SliverToBoxAdapter(
                child: FadeInUp(
                  delay: const Duration(milliseconds: 400),
                  duration: const Duration(milliseconds: 600),
                  child: _buildEmptyWidget(context, isDarkMode),
                ),
              )
            : SliverToBoxAdapter(
                child: FadeInUp(
                  delay: const Duration(milliseconds: 400),
                  duration: const Duration(milliseconds: 600),
                  child: _buildDTRDataTable(context, isDarkMode, colorScheme),
                ),
              ),

        // Bottom spacing
        SliverToBoxAdapter(
          child: SizedBox(height: isDarkMode ? 40 : 50),
        ),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context, bool isDarkMode, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkMode
                ? [const Color(0xFF252538), const Color(0xFF1E1E2E)]
                : [Colors.white, const Color(0xFFF0F4FF)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: DTRListColors.primaryGradient[0].withValues(alpha: isDarkMode ? 0.2 : 0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
              spreadRadius: -4,
            ),
          ],
          border: Border.all(
            color: isDarkMode 
                ? Colors.white.withValues(alpha: 0.05) 
                : Colors.white.withValues(alpha: 0.8),
            width: 1,
          ),
        ),
        child: TextField(
          onChanged: _filterDTRs,
          style: TextStyle(
            color: DTRListColors.getTextColor(isDarkMode),
            fontSize: 16,
          ),
          decoration: InputDecoration(
            hintText: 'Search by DTR code, village...',
            hintStyle: TextStyle(
              color: DTRListColors.getSubtextColor(isDarkMode),
              fontSize: 15,
            ),
            prefixIcon: Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: DTRListColors.primaryGradient,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.search_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCards(BuildContext context, bool isDarkMode, ColorScheme colorScheme) {
    // Calculate totals
    final totalDTRs = _dtrs.length;
    final totalPoles = _dtrPoles.values.fold<int>(0, (sum, poles) => sum + poles.length);
    final totalMaterials = _materialsSummary.values.fold<int>(
      0, 
      (sum, summary) => sum + summary.totalMaterials,
    );
    final totalDismantle = _materialsSummary.values.fold<int>(
      0,
      (sum, summary) => sum + summary.totalDismantle,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'DTRs',
                  totalDTRs.toString(),
                  Icons.electrical_services_rounded,
                  DTRListColors.primaryGradient,
                  isDarkMode,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  'Poles',
                  totalPoles.toString(),
                  Icons.format_list_numbered_rounded,
                  DTRListColors.successGradient,
                  isDarkMode,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Materials',
                  totalMaterials.toString(),
                  Icons.inventory_2_rounded,
                  DTRListColors.secondaryGradient,
                  isDarkMode,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  'Dismantle',
                  totalDismantle.toString(),
                  Icons.recycling_rounded,
                  DTRListColors.warningGradient,
                  isDarkMode,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    String label,
    String value,
    IconData icon,
    List<Color> gradient,
    bool isDarkMode,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDarkMode
              ? [const Color(0xFF252538), const Color(0xFF1E1E2E)]
              : [Colors.white, const Color(0xFFF8FAFF)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradient[0].withValues(alpha: isDarkMode ? 0.2 : 0.15),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: isDarkMode 
              ? Colors.white.withValues(alpha: 0.05) 
              : Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: gradient),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: gradient[0].withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: DTRListColors.getTextColor(isDarkMode),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: DTRListColors.getSubtextColor(isDarkMode),
            ),
          ),
        ],
      ),
    );
  }

  // Table column definitions
  final List<Map<String, dynamic>> _tableColumns = [
    {'key': 'dtrCode', 'label': 'DTR Code', 'width': 100.0},
    {'key': 'village', 'label': 'Village', 'width': 120.0},
    {'key': 'routeLength', 'label': 'Route Length (Mtr)', 'width': 120.0},
    {'key': 'newPole', 'label': 'New PCC Pole', 'width': 90.0},
    {'key': 'staySet', 'label': 'LT Stay set', 'width': 90.0},
    {'key': 'stayClampType1', 'label': 'LT Stay clamp (Type-I)', 'width': 130.0},
    {'key': 'stayClampType2', 'label': 'LT Stay clamp (Type-II)', 'width': 140.0},
    {'key': 'giEarthSpike', 'label': 'GI Earth Spike', 'width': 100.0},
    {'key': 'suspension', 'label': 'Suspension', 'width': 90.0},
    {'key': 'deadEnd', 'label': 'Dead End', 'width': 80.0},
    {'key': 'distributionJunctionBox', 'label': 'Distribution Junction Box', 'width': 150.0},
    {'key': 'eyeHook', 'label': 'Eye hook', 'width': 80.0},
    {'key': 'ltPoleClampType1', 'label': 'LT pole clamp (Type-I)', 'width': 140.0},
    {'key': 'ltPoleClampType2', 'label': 'LT pole clamp (Type-II)', 'width': 150.0},
    {'key': 'ipcForDB50To70', 'label': 'IPC (ABC) to DB 50-70', 'width': 150.0},
    {'key': 'ipcFor16SQMM', 'label': 'IPC (ABC) for 16', 'width': 130.0},
    {'key': 'ipcForAbcToAbc50To70SQMM', 'label': 'IPC ABC TEE 70', 'width': 130.0},
    {'key': 'straightThroughJoint70SQMM', 'label': 'STJ 70 sq.mm', 'width': 110.0},
    {'key': 'straightThroughJoint16SQMM', 'label': 'STJ 16 sq.mm', 'width': 110.0},
    {'key': 'straightThroughJoint50SQMM', 'label': 'STJ 50 sq.mm', 'width': 110.0},
    {'key': 'serviceConnection1ph', 'label': 'Service Conn (1Ph)', 'width': 130.0},
    {'key': 'serviceConnection3ph', 'label': 'Service Conn (3Ph)', 'width': 130.0},
    {'key': 'ltBracket1Ph', 'label': 'LT BRACKET 1 PH', 'width': 120.0},
    {'key': 'ltBracket3Ph', 'label': 'LT BRACKET 3 PH', 'width': 120.0},
    {'key': 'backClamp', 'label': 'Back Clamp', 'width': 100.0},
    {'key': 'dIronClamp', 'label': 'D IRON CLAMP', 'width': 110.0},
    {'key': 'shackleInsulator', 'label': 'SHACKLE INSULATOR', 'width': 140.0},
    {'key': 'ciReel', 'label': 'CI REEL', 'width': 80.0},
    {'key': 'shackleStrap', 'label': 'SHACKLE STRAP', 'width': 120.0},
    {'key': 'boxBracket', 'label': 'BOX BRACKET', 'width': 110.0},
    {'key': 'lc', 'label': 'L.C', 'width': 60.0},
    {'key': 'exStay', 'label': 'Ex-STAY', 'width': 80.0},
    // Wire types with length columns from pole_schedule_screen.dart 995-1014
    {'key': 'acsr50_2', 'label': 'ACSR 50 2-wire (Mtr)', 'width': 140.0},
    {'key': 'acsr50_3', 'label': 'ACSR 50 3-wire (Mtr)', 'width': 140.0},
    {'key': 'acsr50_4', 'label': 'ACSR 50 4-wire (Mtr)', 'width': 140.0},
    {'key': 'acsr50_5', 'label': 'ACSR 50 5-wire (Mtr)', 'width': 140.0},
    {'key': 'acsr30_2', 'label': 'ACSR 30 2-wire (Mtr)', 'width': 140.0},
    {'key': 'acsr30_3', 'label': 'ACSR 30 3-wire (Mtr)', 'width': 140.0},
    {'key': 'acsr30_4', 'label': 'ACSR 30 4-wire (Mtr)', 'width': 140.0},
    {'key': 'acsr30_5', 'label': 'ACSR 30 5-wire (Mtr)', 'width': 140.0},
    {'key': 'aac50_2', 'label': 'AAC 50 2-wire (Mtr)', 'width': 140.0},
    {'key': 'aac50_3', 'label': 'AAC 50 3-wire (Mtr)', 'width': 140.0},
    {'key': 'aac50_4', 'label': 'AAC 50 4-wire (Mtr)', 'width': 140.0},
    {'key': 'aac50_5', 'label': 'AAC 50 5-wire (Mtr)', 'width': 140.0},
    {'key': 'aac25_2', 'label': 'AAC 25 2-wire (Mtr)', 'width': 140.0},
    {'key': 'aac25_3', 'label': 'AAC 25 3-wire (Mtr)', 'width': 140.0},
    {'key': 'aac25_4', 'label': 'AAC 25 4-wire (Mtr)', 'width': 140.0},
    {'key': 'aac25_5', 'label': 'AAC 25 5-wire (Mtr)', 'width': 140.0},
    {'key': 'acsr20_2', 'label': 'ACSR 20 2-wire (Mtr)', 'width': 140.0},
    {'key': 'acsr20_3', 'label': 'ACSR 20 3-wire (Mtr)', 'width': 140.0},
    {'key': 'acsr20_4', 'label': 'ACSR 20 4-wire (Mtr)', 'width': 140.0},
    {'key': 'acsr20_5', 'label': 'ACSR 20 5-wire (Mtr)', 'width': 140.0},
  ];

  Widget _buildTableHeader(BuildContext context, bool isDarkMode, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: DTRListColors.infoGradient,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: DTRListColors.infoGradient[0].withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.table_chart_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'DTR Materials Table',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: DTRListColors.getTextColor(isDarkMode),
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: DTRListColors.primaryGradient,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${_filteredDTRs.length} DTRs',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDTRDataTable(BuildContext context, bool isDarkMode, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkMode
                ? [const Color(0xFF252538), const Color(0xFF1E1E2E)]
                : [Colors.white, const Color(0xFFF8FAFF)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: DTRListColors.primaryGradient[0].withValues(alpha: isDarkMode ? 0.15 : 0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(
            color: isDarkMode 
                ? Colors.white.withValues(alpha: 0.05) 
                : Colors.grey[200]!,
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(
                  DTRListColors.primaryGradient[0].withValues(alpha: 0.1),
                ),
                dataRowColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return DTRListColors.primaryGradient[0].withValues(alpha: 0.05);
                  }
                  return null;
                }),
                border: TableBorder(
                  horizontalInside: BorderSide(
                    color: isDarkMode 
                        ? Colors.white.withValues(alpha: 0.05) 
                        : Colors.grey[200]!,
                  ),
                  verticalInside: BorderSide(
                    color: isDarkMode 
                        ? Colors.white.withValues(alpha: 0.05) 
                        : Colors.grey[200]!,
                  ),
                ),
                columnSpacing: 16,
                horizontalMargin: 16,
                columns: _tableColumns.map((col) {
                  return DataColumn(
                    label: Container(
                      width: col['width'] as double,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        col['label'] as String,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: DTRListColors.getTextColor(isDarkMode),
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                  );
                }).toList(),
                rows: _filteredDTRs.map((dtr) {
                  final poles = _dtrPoles[dtr.id] ?? [];
                  final actuals = _calculatePoleActuals(poles);
                  
                  return DataRow(
                    cells: _tableColumns.map((col) {
                      final key = col['key'] as String;
                      String value = '';
                      
                      switch (key) {
                        case 'dtrCode':
                          value = dtr.dtrCode;
                          break;
                        case 'village':
                          value = dtr.village;
                          break;
                        case 'routeLength':
                          value = _calculateTotalRouteLength(poles).toStringAsFixed(2);
                          break;
                        case 'newPole':
                          value = actuals['newPole']?.toString() ?? '0';
                          break;
                        case 'staySet':
                          value = actuals['staySet']?.toString() ?? '0';
                          break;
                        case 'stayClampType1':
                          value = actuals['stayClampType1']?.toString() ?? '0';
                          break;
                        case 'stayClampType2':
                          value = actuals['stayClampType2']?.toString() ?? '0';
                          break;
                        case 'giEarthSpike':
                          value = actuals['giEarthSpike']?.toString() ?? '0';
                          break;
                        case 'suspension':
                          value = actuals['suspension']?.toString() ?? '0';
                          break;
                        case 'deadEnd':
                          value = actuals['deadEnd']?.toString() ?? '0';
                          break;
                        case 'distributionJunctionBox':
                          value = actuals['distributionJunctionBox']?.toString() ?? '0';
                          break;
                        case 'eyeHook':
                          value = actuals['eyeHook']?.toString() ?? '0';
                          break;
                        case 'ltPoleClampType1':
                          value = actuals['ltPoleClampType1']?.toString() ?? '0';
                          break;
                        case 'ltPoleClampType2':
                          value = actuals['ltPoleClampType2']?.toString() ?? '0';
                          break;
                        case 'ipcForDB50To70':
                          value = actuals['ipcForDB50To70']?.toString() ?? '0';
                          break;
                        case 'ipcFor16SQMM':
                          value = actuals['ipcFor16SQMM']?.toString() ?? '0';
                          break;
                        case 'ipcForAbcToAbc50To70SQMM':
                          value = actuals['ipcForAbcToAbc50To70SQMM']?.toString() ?? '0';
                          break;
                        case 'straightThroughJoint70SQMM':
                          value = actuals['straightThroughJoint70SQMM']?.toString() ?? '0';
                          break;
                        case 'straightThroughJoint16SQMM':
                          value = actuals['straightThroughJoint16SQMM']?.toString() ?? '0';
                          break;
                        case 'straightThroughJoint50SQMM':
                          value = actuals['straightThroughJoint50SQMM']?.toString() ?? '0';
                          break;
                        case 'serviceConnection1ph':
                          value = actuals['serviceConnection1ph']?.toString() ?? '0';
                          break;
                        case 'serviceConnection3ph':
                          value = actuals['serviceConnection3ph']?.toString() ?? '0';
                          break;
                        case 'ltBracket1Ph':
                          value = actuals['ltBracket1Ph']?.toString() ?? '0';
                          break;
                        case 'ltBracket3Ph':
                          value = actuals['ltBracket3Ph']?.toString() ?? '0';
                          break;
                        case 'backClamp':
                          value = actuals['backClamp']?.toString() ?? '0';
                          break;
                        case 'dIronClamp':
                          value = actuals['dIronClamp']?.toString() ?? '0';
                          break;
                        case 'shackleInsulator':
                          value = actuals['shackleInsulator']?.toString() ?? '0';
                          break;
                        case 'ciReel':
                          value = actuals['ciReel']?.toString() ?? '0';
                          break;
                        case 'shackleStrap':
                          value = actuals['shackleStrap']?.toString() ?? '0';
                          break;
                        case 'boxBracket':
                          value = actuals['boxBracket']?.toString() ?? '0';
                          break;
                        case 'lc':
                          value = actuals['lc']?.toString() ?? '0';
                          break;
                        case 'exStay':
                          value = actuals['exStay']?.toString() ?? '0';
                          break;
                        // Wire types - calculate total route length for matching wire configuration
                        default:
                          if (key.startsWith('acsr') || key.startsWith('aac')) {
                            value = _calculateWireRouteLength(poles, key).toStringAsFixed(2);
                          } else {
                            value = '0';
                          }
                      }
                      
                      return DataCell(
                        Container(
                          width: col['width'] as double,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: key == 'dtrCode' || key == 'village'
                            ? Text(
                                value,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: DTRListColors.getTextColor(isDarkMode),
                                ),
                                overflow: TextOverflow.ellipsis,
                              )
                            : Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: value != '0' 
                                      ? DTRListColors.successGradient[0].withValues(alpha: 0.1)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  value,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: value != '0' ? FontWeight.w700 : FontWeight.w500,
                                    color: value != '0' 
                                        ? DTRListColors.successGradient[0]
                                        : DTRListColors.getSubtextColor(isDarkMode),
                                  ),
                                ),
                              ),
                        ),
                      );
                    }).toList(),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Map<String, int> _calculatePoleActuals(List<Pole> poles) {
    // First calculate totals
    final totals = <String, int>{
      'newPole': 0,
      'staySet': 0,
      'stayClampType1': 0,
      'stayClampType2': 0,
      'giEarthSpike': 0,
      'suspension': 0,
      'deadEnd': 0,
      'distributionJunctionBox': 0,
      'eyeHook': 0,
      'ltPoleClampType1': 0,
      'ltPoleClampType2': 0,
      'ipcForDB50To70': 0,
      'ipcFor16SQMM': 0,
      'ipcForAbcToAbc50To70SQMM': 0,
      'straightThroughJoint70SQMM': 0,
      'straightThroughJoint16SQMM': 0,
      'straightThroughJoint50SQMM': 0,
      'serviceConnection1ph': 0,
      'serviceConnection3ph': 0,
      'ltBracket1Ph': 0,
      'ltBracket3Ph': 0,
      'backClamp': 0,
      'dIronClamp': 0,
      'shackleInsulator': 0,
      'ciReel': 0,
      'shackleStrap': 0,
      'boxBracket': 0,
      'lc': 0,
      'exStay': 0,
    };

    for (final pole in poles) {
      totals['newPole'] = totals['newPole']! + pole.newPole;
      totals['staySet'] = totals['staySet']! + pole.staySet;
      totals['stayClampType1'] = totals['stayClampType1']! + pole.stayClampType1;
      totals['stayClampType2'] = totals['stayClampType2']! + pole.stayClampType2;
      totals['giEarthSpike'] = totals['giEarthSpike']! + pole.giEarthSpike;
      totals['suspension'] = totals['suspension']! + pole.suspension;
      totals['deadEnd'] = totals['deadEnd']! + pole.deadEnd;
      totals['distributionJunctionBox'] = totals['distributionJunctionBox']! + pole.distributionJunctionBox;
      totals['eyeHook'] = totals['eyeHook']! + pole.eyeHook;
      totals['ltPoleClampType1'] = totals['ltPoleClampType1']! + pole.ltPoleClampType1;
      totals['ltPoleClampType2'] = totals['ltPoleClampType2']! + pole.ltPoleClampType2;
      totals['ipcForDB50To70'] = totals['ipcForDB50To70']! + pole.ipcForDB50To70;
      totals['ipcFor16SQMM'] = totals['ipcFor16SQMM']! + pole.ipcFor16SQMM;
      totals['ipcForAbcToAbc50To70SQMM'] = totals['ipcForAbcToAbc50To70SQMM']! + pole.ipcForAbcToAbc50To70SQMM;
      totals['straightThroughJoint70SQMM'] = totals['straightThroughJoint70SQMM']! + pole.straightThroughJoint70SQMM;
      totals['straightThroughJoint16SQMM'] = totals['straightThroughJoint16SQMM']! + pole.straightThroughJoint16SQMM;
      totals['straightThroughJoint50SQMM'] = totals['straightThroughJoint50SQMM']! + pole.straightThroughJoint50SQMM;
      totals['serviceConnection1ph'] = totals['serviceConnection1ph']! + pole.serviceConnection1ph;
      totals['serviceConnection3ph'] = totals['serviceConnection3ph']! + pole.serviceConnection3ph;
      totals['ltBracket1Ph'] = totals['ltBracket1Ph']! + pole.ltBracket1Ph;
      totals['ltBracket3Ph'] = totals['ltBracket3Ph']! + pole.ltBracket3Ph;
      totals['backClamp'] = totals['backClamp']! + pole.backClamp;
      totals['dIronClamp'] = totals['dIronClamp']! + pole.dIronClamp;
      totals['shackleInsulator'] = totals['shackleInsulator']! + pole.shackleInsulator;
      totals['ciReel'] = totals['ciReel']! + pole.ciReel;
      totals['shackleStrap'] = totals['shackleStrap']! + pole.shackleStrap;
      totals['boxBracket'] = totals['boxBracket']! + pole.boxBracket;
      totals['lc'] = totals['lc']! + pole.lc;
      totals['exStay'] = totals['exStay']! + pole.exStay;
    }

    // Now calculate ACTUAL values based on pole_schedule_screen.dart logic
    final actuals = <String, int>{};
    
    // These fields remain the same (actual = total)
    actuals['newPole'] = totals['newPole']!;
    actuals['staySet'] = totals['staySet']!;
    actuals['stayClampType1'] = totals['stayClampType1']!;
    actuals['stayClampType2'] = totals['stayClampType2']!;
    actuals['giEarthSpike'] = totals['giEarthSpike']!;
    actuals['suspension'] = totals['suspension']!;
    actuals['deadEnd'] = totals['deadEnd']!;
    actuals['distributionJunctionBox'] = totals['distributionJunctionBox']!;
    actuals['eyeHook'] = totals['eyeHook']!;
    actuals['ltPoleClampType1'] = totals['ltPoleClampType1']!;
    actuals['ltPoleClampType2'] = totals['ltPoleClampType2']!;
    actuals['ipcForDB50To70'] = totals['ipcForDB50To70']!;
    actuals['ipcFor16SQMM'] = totals['ipcFor16SQMM']!;
    actuals['ipcForAbcToAbc50To70SQMM'] = totals['ipcForAbcToAbc50To70SQMM']!;
    actuals['straightThroughJoint70SQMM'] = totals['straightThroughJoint70SQMM']!;
    actuals['straightThroughJoint16SQMM'] = totals['straightThroughJoint16SQMM']!;
    actuals['straightThroughJoint50SQMM'] = totals['straightThroughJoint50SQMM']!;
    actuals['serviceConnection1ph'] = totals['serviceConnection1ph']!;
    actuals['serviceConnection3ph'] = totals['serviceConnection3ph']!;
    actuals['ltBracket1Ph'] = totals['ltBracket1Ph']!;
    actuals['ltBracket3Ph'] = totals['ltBracket3Ph']!;
    actuals['ciReel'] = totals['ciReel']!;
    actuals['shackleStrap'] = totals['shackleStrap']!;
    actuals['boxBracket'] = totals['boxBracket']!;
    actuals['lc'] = totals['lc']!;
    actuals['exStay'] = totals['exStay']!;
    
    // These fields have calculated ACTUAL values
    // ACTUAL Back Clamp = Total Back Clamp - (Total Ex-Stay * 2)
    actuals['backClamp'] = totals['backClamp']! - (totals['exStay']! * 2);
    
    // ACTUAL D Iron Clamp = Total D Iron Clamp - Total Distribution Junction Box
    actuals['dIronClamp'] = totals['dIronClamp']! - totals['distributionJunctionBox']!;
    
    // ACTUAL Shackle Insulator = Total Shackle Insulator - Total Distribution Junction Box
    actuals['shackleInsulator'] = totals['shackleInsulator']! - totals['distributionJunctionBox']!;

    return actuals;
  }

  double _calculateTotalRouteLength(List<Pole> poles) {
    double totalLength = 0.0;
    for (final pole in poles) {
      // Use routhLength field from Pole model
      totalLength += pole.routhLength;
    }
    return totalLength;
  }

  double _calculateWireRouteLength(List<Pole> poles, String wireKey) {
    // Parse wire key to get type and configuration
    // Format: acsr50_2, aac25_3, etc.
    String? wireType;
    String? wireConfig;
    
    // Extract the wire count (e.g., "2" from "acsr50_2")
    final wireCount = wireKey.substring(wireKey.lastIndexOf('_') + 1);
    
    if (wireKey.startsWith('acsr50')) {
      wireType = 'ACSR 50 sqmm';
    } else if (wireKey.startsWith('acsr30')) {
      wireType = 'ACSR 30 sqmm';
    } else if (wireKey.startsWith('acsr20')) {
      wireType = 'ACSR 20 sqmm';
    } else if (wireKey.startsWith('aac50')) {
      wireType = 'AAC 50 sqmm';
    } else if (wireKey.startsWith('aac25')) {
      wireType = 'AAC 25 sqmm';
    }
    
    // Wire configuration is stored as "2 wire", "3 wire", etc.
    wireConfig = '$wireCount wire';
    
    if (wireType == null) return 0.0;
    
    // Sum route lengths for poles with matching wire type and configuration
    double totalLength = 0.0;
    for (final pole in poles) {
      // Check if both wire type and wire configuration match exactly
      if (pole.wireType == wireType && pole.wireConfiguration == wireConfig) {
        // Use routhLength field from Pole model
        totalLength += pole.routhLength;
      }
    }
    
    return totalLength;
  }

  Widget _buildDTRCard(
    BuildContext context,
    DTR dtr,
    DTRMaterialsSummary? summary,
    List<Pole> poles,
    bool isDarkMode,
    ColorScheme colorScheme,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkMode
                ? [const Color(0xFF252538), const Color(0xFF1E1E2E)]
                : [Colors.white, const Color(0xFFF8FAFF)],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: DTRListColors.primaryGradient[0].withValues(alpha: isDarkMode ? 0.15 : 0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
              spreadRadius: -4,
            ),
          ],
          border: Border.all(
            color: isDarkMode 
                ? Colors.white.withValues(alpha: 0.05) 
                : Colors.grey[200]!,
            width: 1,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _showDTRDetails(context, dtr, summary, poles),
            borderRadius: BorderRadius.circular(24),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row
                  Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: DTRListColors.primaryGradient,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: DTRListColors.primaryGradient[0].withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.electrical_services_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              dtr.dtrCode,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: DTRListColors.getTextColor(isDarkMode),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on_rounded,
                                  size: 14,
                                  color: DTRListColors.getSubtextColor(isDarkMode),
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    dtr.village.isNotEmpty ? dtr.village : 'No village',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: DTRListColors.getSubtextColor(isDarkMode),
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: DTRListColors.primaryGradient[0].withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.format_list_numbered_rounded,
                              size: 14,
                              color: DTRListColors.primaryGradient[0],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${poles.length}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: DTRListColors.primaryGradient[0],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Materials Row
                  Row(
                    children: [
                      Expanded(
                        child: _buildMaterialItem(
                          'Total Materials',
                          summary?.totalMaterials.toString() ?? '0',
                          Icons.inventory_2_rounded,
                          DTRListColors.successGradient,
                          isDarkMode,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildMaterialItem(
                          'Dismantle',
                          summary?.totalDismantle.toString() ?? '0',
                          Icons.recycling_rounded,
                          DTRListColors.warningGradient,
                          isDarkMode,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Footer Info
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.location_city_rounded,
                            size: 14,
                            color: DTRListColors.getSubtextColor(isDarkMode),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            dtr.location.isNotEmpty ? dtr.location : 'No location',
                            style: TextStyle(
                              fontSize: 12,
                              color: DTRListColors.getSubtextColor(isDarkMode),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            'View Details',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: DTRListColors.primaryGradient[0],
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 12,
                            color: DTRListColors.primaryGradient[0],
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMaterialItem(
    String label,
    String value,
    IconData icon,
    List<Color> gradient,
    bool isDarkMode,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            gradient[0].withValues(alpha: 0.1),
            gradient[1].withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: gradient[0].withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: gradient),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: DTRListColors.getTextColor(isDarkMode),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: DTRListColors.getSubtextColor(isDarkMode),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget(BuildContext context, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  DTRListColors.primaryGradient[0].withValues(alpha: 0.2),
                  DTRListColors.primaryGradient[1].withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Icon(
              Icons.electrical_services_outlined,
              size: 60,
              color: DTRListColors.primaryGradient[0].withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No DTRs Found',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: DTRListColors.getTextColor(isDarkMode),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isEmpty
                ? 'You haven\'t created any DTRs yet'
                : 'No DTRs match your search',
            style: TextStyle(
              fontSize: 14,
              color: DTRListColors.getSubtextColor(isDarkMode),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showDTRDetails(
    BuildContext context,
    DTR dtr,
    DTRMaterialsSummary? summary,
    List<Pole> poles,
  ) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    // Calculate detailed material totals
    final materialTotals = _calculateDetailedMaterialTotals(poles);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: DTRListColors.getBackgroundColor(isDarkMode),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: Column(
              children: [
                // Handle
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: DTRListColors.getSubtextColor(isDarkMode).withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                
                // Header
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: DTRListColors.primaryGradient,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(16)),
                        ),
                        child: const Icon(
                          Icons.electrical_services_rounded,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              dtr.dtrCode,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: DTRListColors.getTextColor(isDarkMode),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              dtr.village,
                              style: TextStyle(
                                fontSize: 14,
                                color: DTRListColors.getSubtextColor(isDarkMode),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),

                // Content
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      // Summary Cards Row
                      _buildDetailSummaryCards(materialTotals, isDarkMode),

                      const SizedBox(height: 24),

                      // Construction Materials Table
                      _buildMaterialsTable(
                        'Construction Materials',
                        Icons.construction_rounded,
                        DTRListColors.successGradient,
                        isDarkMode,
                        materialTotals.constructionMaterials,
                      ),

                      const SizedBox(height: 20),

                      // Dismantle Inventory Table
                      _buildMaterialsTable(
                        'Dismantle Inventory',
                        Icons.recycling_rounded,
                        DTRListColors.warningGradient,
                        isDarkMode,
                        materialTotals.dismantleMaterials,
                      ),

                      const SizedBox(height: 20),

                      // Location Info
                      _buildDetailSection(
                        'Location Information',
                        Icons.location_on_rounded,
                        DTRListColors.infoGradient,
                        isDarkMode,
                        [
                          _buildDetailRow('Village', dtr.village),
                          _buildDetailRow('Location', dtr.location),
                          _buildDetailRow('Land Marks', dtr.landMarks),
                          _buildDetailRow('Block', dtr.block),
                          _buildDetailRow('Division', dtr.division),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Technical Info
                      _buildDetailSection(
                        'Technical Details',
                        Icons.electrical_services_rounded,
                        DTRListColors.secondaryGradient,
                        isDarkMode,
                        [
                          _buildDetailRow('Capacity', '${dtr.capacity} kVA'),
                          _buildDetailRow('Feeder', dtr.feeder),
                          _buildDetailRow('Substation', dtr.substation),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Documentation
                      _buildDetailSection(
                        'Documentation',
                        Icons.description_rounded,
                        DTRListColors.primaryGradient,
                        isDarkMode,
                        [
                          _buildDetailRow('DRG No', dtr.drgNo),
                          _buildDetailRow('DOC Date', dtr.docDate),
                          _buildDetailRow('JMC No', dtr.jmcNo),
                          _buildDetailRow('Census Code', dtr.censusCode),
                        ],
                      ),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  DetailedMaterialTotals _calculateDetailedMaterialTotals(List<Pole> poles) {
    // Construction Materials (lines 869-889 from pole_schedule_screen)
    final constructionMaterials = <String, int>{
      'New PCC Pole': 0,
      'LT Stay set': 0,
      'LT Stay clamp (Type-I)': 0,
      'LT Stay clamp (Type-II)': 0,
      'GI Earth Spike': 0,
      'Suspension': 0,
      'Dead End': 0,
      'Distribution Junction Box': 0,
      'Eye hook': 0,
      'LT pole clamp (Type-I)': 0,
      'LT pole clamp (Type-II)': 0,
      'IPC (ABC) to DB charging set 50-70 sq.mm': 0,
      'IPC (ABC) for 16 sq.mm': 0,
      'IPC ABC TEE joint for 70 sq.mm': 0,
      'Straight through joint (ABC) 70 sq.mm power cable': 0,
      'Straight through joint (ABC) 16 sq.mm power cable': 0,
      'Straight through joint (ABC) 50 sq.mm neutral wire': 0,
      'Service Connection (1Ph)': 0,
      'Service Connection (3Ph)': 0,
    };

    // Dismantle Inventory (lines 985-1014 from pole_schedule_screen)
    final dismantleMaterials = <String, int>{
      'LT BRACKET 1 PH': 0,
      'LT BRACKET 3 PH': 0,
      'Back Clamp': 0,
      'D IRON CLAMP': 0,
      'SHACKLE INSULATOR': 0,
      'CI REEL': 0,
      'SHACKLE STRAP': 0,
      'BOX BRACKET': 0,
      'L.C': 0,
      'Ex-STAY': 0,
    };

    for (final pole in poles) {
      // Construction materials
      constructionMaterials['New PCC Pole'] = constructionMaterials['New PCC Pole']! + pole.newPole;
      constructionMaterials['LT Stay set'] = constructionMaterials['LT Stay set']! + pole.staySet;
      constructionMaterials['LT Stay clamp (Type-I)'] = constructionMaterials['LT Stay clamp (Type-I)']! + pole.stayClampType1;
      constructionMaterials['LT Stay clamp (Type-II)'] = constructionMaterials['LT Stay clamp (Type-II)']! + pole.stayClampType2;
      constructionMaterials['GI Earth Spike'] = constructionMaterials['GI Earth Spike']! + pole.giEarthSpike;
      constructionMaterials['Suspension'] = constructionMaterials['Suspension']! + pole.suspension;
      constructionMaterials['Dead End'] = constructionMaterials['Dead End']! + pole.deadEnd;
      constructionMaterials['Distribution Junction Box'] = constructionMaterials['Distribution Junction Box']! + pole.distributionJunctionBox;
      constructionMaterials['Eye hook'] = constructionMaterials['Eye hook']! + pole.eyeHook;
      constructionMaterials['LT pole clamp (Type-I)'] = constructionMaterials['LT pole clamp (Type-I)']! + pole.ltPoleClampType1;
      constructionMaterials['LT pole clamp (Type-II)'] = constructionMaterials['LT pole clamp (Type-II)']! + pole.ltPoleClampType2;
      constructionMaterials['IPC (ABC) to DB charging set 50-70 sq.mm'] = constructionMaterials['IPC (ABC) to DB charging set 50-70 sq.mm']! + pole.ipcForDB50To70;
      constructionMaterials['IPC (ABC) for 16 sq.mm'] = constructionMaterials['IPC (ABC) for 16 sq.mm']! + pole.ipcFor16SQMM;
      constructionMaterials['IPC ABC TEE joint for 70 sq.mm'] = constructionMaterials['IPC ABC TEE joint for 70 sq.mm']! + pole.ipcForAbcToAbc50To70SQMM;
      constructionMaterials['Straight through joint (ABC) 70 sq.mm power cable'] = constructionMaterials['Straight through joint (ABC) 70 sq.mm power cable']! + pole.straightThroughJoint70SQMM;
      constructionMaterials['Straight through joint (ABC) 16 sq.mm power cable'] = constructionMaterials['Straight through joint (ABC) 16 sq.mm power cable']! + pole.straightThroughJoint16SQMM;
      constructionMaterials['Straight through joint (ABC) 50 sq.mm neutral wire'] = constructionMaterials['Straight through joint (ABC) 50 sq.mm neutral wire']! + pole.straightThroughJoint50SQMM;
      constructionMaterials['Service Connection (1Ph)'] = constructionMaterials['Service Connection (1Ph)']! + pole.serviceConnection1ph;
      constructionMaterials['Service Connection (3Ph)'] = constructionMaterials['Service Connection (3Ph)']! + pole.serviceConnection3ph;

      // Dismantle materials
      dismantleMaterials['LT BRACKET 1 PH'] = dismantleMaterials['LT BRACKET 1 PH']! + pole.ltBracket1Ph;
      dismantleMaterials['LT BRACKET 3 PH'] = dismantleMaterials['LT BRACKET 3 PH']! + pole.ltBracket3Ph;
      dismantleMaterials['Back Clamp'] = dismantleMaterials['Back Clamp']! + pole.backClamp;
      dismantleMaterials['D IRON CLAMP'] = dismantleMaterials['D IRON CLAMP']! + pole.dIronClamp;
      dismantleMaterials['SHACKLE INSULATOR'] = dismantleMaterials['SHACKLE INSULATOR']! + pole.shackleInsulator;
      dismantleMaterials['CI REEL'] = dismantleMaterials['CI REEL']! + pole.ciReel;
      dismantleMaterials['SHACKLE STRAP'] = dismantleMaterials['SHACKLE STRAP']! + pole.shackleStrap;
      dismantleMaterials['BOX BRACKET'] = dismantleMaterials['BOX BRACKET']! + pole.boxBracket;
      dismantleMaterials['L.C'] = dismantleMaterials['L.C']! + pole.lc;
      dismantleMaterials['Ex-STAY'] = dismantleMaterials['Ex-STAY']! + pole.exStay;
    }

    // Filter out zero values and sort by value descending
    final filteredConstruction = Map<String, int>.fromEntries(
      constructionMaterials.entries.where((e) => e.value > 0).toList()
        ..sort((a, b) => b.value.compareTo(a.value)),
    );

    final filteredDismantle = Map<String, int>.fromEntries(
      dismantleMaterials.entries.where((e) => e.value > 0).toList()
        ..sort((a, b) => b.value.compareTo(a.value)),
    );

    return DetailedMaterialTotals(
      constructionMaterials: filteredConstruction,
      dismantleMaterials: filteredDismantle,
      totalConstruction: constructionMaterials.values.fold(0, (a, b) => a + b),
      totalDismantle: dismantleMaterials.values.fold(0, (a, b) => a + b),
    );
  }

  Widget _buildDetailSummaryCards(DetailedMaterialTotals totals, bool isDarkMode) {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            'Construction',
            totals.totalConstruction.toString(),
            Icons.construction_rounded,
            DTRListColors.successGradient,
            isDarkMode,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            'Dismantle',
            totals.totalDismantle.toString(),
            Icons.recycling_rounded,
            DTRListColors.warningGradient,
            isDarkMode,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            'Total Items',
            (totals.totalConstruction + totals.totalDismantle).toString(),
            Icons.inventory_2_rounded,
            DTRListColors.primaryGradient,
            isDarkMode,
          ),
        ),
      ],
    );
  }

  Widget _buildMaterialsTable(
    String title,
    IconData icon,
    List<Color> gradient,
    bool isDarkMode,
    Map<String, int> materials,
  ) {
    if (materials.isEmpty) {
      return _buildDetailSection(
        title,
        icon,
        gradient,
        isDarkMode,
        [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'No $title data available',
                style: TextStyle(
                  color: DTRListColors.getSubtextColor(isDarkMode),
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      );
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDarkMode
              ? [const Color(0xFF252538), const Color(0xFF1E1E2E)]
              : [Colors.white, const Color(0xFFF8FAFF)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradient[0].withValues(alpha: isDarkMode ? 0.15 : 0.1),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: isDarkMode 
              ? Colors.white.withValues(alpha: 0.05) 
              : Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  gradient[0].withValues(alpha: 0.15),
                  gradient[1].withValues(alpha: 0.05),
                ],
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              border: Border(
                bottom: BorderSide(
                  color: isDarkMode 
                      ? Colors.white.withValues(alpha: 0.05) 
                      : Colors.grey[200]!,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: gradient),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: gradient[0].withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: DTRListColors.getTextColor(isDarkMode),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${materials.length} items',
                        style: TextStyle(
                          fontSize: 12,
                          color: DTRListColors.getSubtextColor(isDarkMode),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: gradient),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    materials.values.fold(0, (a, b) => a + b).toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: gradient[0].withValues(alpha: 0.05),
              border: Border(
                bottom: BorderSide(
                  color: isDarkMode 
                      ? Colors.white.withValues(alpha: 0.05) 
                      : Colors.grey[200]!,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'Material Name',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: DTRListColors.getTextColor(isDarkMode),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'Qty',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: DTRListColors.getTextColor(isDarkMode),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Table Rows
          ...materials.entries.map((entry) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isDarkMode 
                        ? Colors.white.withValues(alpha: 0.03) 
                        : Colors.grey[100]!,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      entry.key,
                      style: TextStyle(
                        fontSize: 13,
                        color: DTRListColors.getTextColor(isDarkMode),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: gradient[0].withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        entry.value.toString(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: gradient[0],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildDetailSection(
    String title,
    IconData icon,
    List<Color> gradient,
    bool isDarkMode,
    List<Widget> children,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDarkMode
              ? [const Color(0xFF252538), const Color(0xFF1E1E2E)]
              : [Colors.white, const Color(0xFFF8FAFF)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradient[0].withValues(alpha: isDarkMode ? 0.15 : 0.1),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: isDarkMode 
              ? Colors.white.withValues(alpha: 0.05) 
              : Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  gradient[0].withValues(alpha: 0.1),
                  gradient[1].withValues(alpha: 0.05),
                ],
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              border: Border(
                bottom: BorderSide(
                  color: isDarkMode 
                      ? Colors.white.withValues(alpha: 0.05) 
                      : Colors.grey[200]!,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: gradient),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: DTRListColors.getTextColor(isDarkMode),
                  ),
                ),
              ],
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: DTRListColors.getSubtextColor(isDarkMode),
            ),
          ),
          Text(
            value.isNotEmpty ? value : '-',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: DTRListColors.getTextColor(isDarkMode),
            ),
          ),
        ],
      ),
    );
  }
}

class DTRMaterialsSummary {
  final int totalMaterials;
  final int totalDismantle;
  final int poleCount;

  DTRMaterialsSummary({
    required this.totalMaterials,
    required this.totalDismantle,
    required this.poleCount,
  });
}

class DetailedMaterialTotals {
  final Map<String, int> constructionMaterials;
  final Map<String, int> dismantleMaterials;
  final int totalConstruction;
  final int totalDismantle;

  DetailedMaterialTotals({
    required this.constructionMaterials,
    required this.dismantleMaterials,
    required this.totalConstruction,
    required this.totalDismantle,
  });
}

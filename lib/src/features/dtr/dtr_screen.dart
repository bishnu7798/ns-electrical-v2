import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:animate_do/animate_do.dart';

import '../../core/models/dtr_model.dart';
import '../../core/services/dtr_service.dart';
import '../../shared/widgets/custom_animations.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/dtr_api_service.dart';
import '../../core/services/offline_dtr_service.dart';
import '../../core/services/dtr_sync_service.dart';

// Modern color palette
class DTRColors {
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

class DTRScreen extends StatefulWidget {
  const DTRScreen({super.key, this.dtr});

  final DTR? dtr; // Make DTR optional for editing

  @override
  State<DTRScreen> createState() => _DTRScreenState();
}

class _DTRScreenState extends State<DTRScreen> {
  // Search and filter state
  final List<DTR> _allDTRs = [];

  late String _block;
  late TextEditingController _blockController;
  late FocusNode _blockFocusNode;
  late String _capacity;
  late TextEditingController _capacityController;
  late FocusNode _capacityFocusNode;
  late String _ccc;
  late TextEditingController _cccController;
  late FocusNode _cccFocusNode;
  late String _censusCode;
  late TextEditingController _censusCodeController;
  late FocusNode _censusCodeFocusNode;
  final List<String> _connectedPoles = [];
  late String _division;
  late TextEditingController _divisionController;
  late FocusNode _divisionFocusNode;
  late String _docDate;
  late TextEditingController _docDateController;
  late FocusNode _docDateFocusNode;
  late String _drgNo;
  late TextEditingController _drgNoController;
  late FocusNode _drgNoFocusNode;
  // DTR fields
  late String _dtrCode;

  // Add TextEditingController for all fields
  late TextEditingController _dtrCodeController;

  // Add FocusNode for each text field to enable jumping
  late FocusNode _dtrCodeFocusNode;

  final _dtrService = DTRService();
  List<String> _favoriteDTRs = [];
  late String _feeder;
  late TextEditingController _feederController;
  late FocusNode _feederFocusNode;
  final List<DTR> _filteredDTRs = [];
  final _formKey = GlobalKey<FormState>();
  late String _gp;
  late TextEditingController _gpController;
  late FocusNode _gpFocusNode;
  bool _isLoading = false; // For showing loading indicator
  final bool _isSearching = false; 
  late String _jmcNo;
  late TextEditingController _jmcNoController;
  late FocusNode _jmcNoFocusNode;
  late String _landMarks;
  late TextEditingController _landMarksController;
  late FocusNode _landMarksFocusNode;
  late String _location;
  late TextEditingController _locationController;
  late FocusNode _locationFocusNode;
  // Variable to track previous block value for smarter auto-fill
  String _previousBlockValue = '';

  // Recent DTRs
  List<String> _recentDTRCodes = [];

  List<String> _searchHistory = [];
  bool _showSuccessAnimation = false; // Added for success animation
  late String _substation; // Changed from _feederCapacity
  late TextEditingController _substationController;
  late FocusNode _substationFocusNode;
  late String _village;
  late TextEditingController _villageController;
  late FocusNode _villageFocusNode;

  @override
  void dispose() {
    // Remove listener when disposing
    _blockController.removeListener(_onBlockChanged);
    
    // Dispose all FocusNodes when the widget is disposed
    _dtrCodeFocusNode.dispose();
    _capacityFocusNode.dispose();
    _divisionFocusNode.dispose();
    _blockFocusNode.dispose();
    _cccFocusNode.dispose();
    _gpFocusNode.dispose();
    _villageFocusNode.dispose();
    _locationFocusNode.dispose();
    _landMarksFocusNode.dispose();
    _drgNoFocusNode.dispose();
    _censusCodeFocusNode.dispose();
    _docDateFocusNode.dispose();
    _jmcNoFocusNode.dispose();
    _feederFocusNode.dispose();
    _substationFocusNode.dispose();
    
    // Dispose all controllers when the widget is disposed
    _dtrCodeController.dispose();
    _capacityController.dispose();
    _villageController.dispose();
    _locationController.dispose();
    _landMarksController.dispose();
    _cccController.dispose();
    _feederController.dispose();
    _substationController.dispose();
    _drgNoController.dispose();
    _docDateController.dispose();
    _jmcNoController.dispose();
    _gpController.dispose();
    _censusCodeController.dispose();
    _blockController.dispose();
    _divisionController.dispose();
    
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    
    // Initialize FocusNodes
    _dtrCodeFocusNode = FocusNode();
    _capacityFocusNode = FocusNode();
    _divisionFocusNode = FocusNode();
    _blockFocusNode = FocusNode();
    _cccFocusNode = FocusNode();
    _gpFocusNode = FocusNode();
    _villageFocusNode = FocusNode();
    _locationFocusNode = FocusNode();
    _landMarksFocusNode = FocusNode();
    _drgNoFocusNode = FocusNode();
    _censusCodeFocusNode = FocusNode();
    _docDateFocusNode = FocusNode();
    _jmcNoFocusNode = FocusNode();
    _feederFocusNode = FocusNode();
    _substationFocusNode = FocusNode();
    
    // Check if we're editing an existing DTR
    if (widget.dtr != null) {
      // Initialize with existing DTR values
      _dtrCode = widget.dtr!.dtrCode;
      _capacity = widget.dtr!.capacity;
      _village = widget.dtr!.village;
      _location = widget.dtr!.location;
      _landMarks = widget.dtr!.landMarks;
      _ccc = widget.dtr!.ccc;
      _feeder = widget.dtr!.feeder;
      _substation = widget.dtr!.substation; // Changed from feederCapacity
      _drgNo = widget.dtr!.drgNo;
      _docDate = widget.dtr!.docDate;
      _jmcNo = widget.dtr!.jmcNo;
      _gp = widget.dtr!.gp;
      _censusCode = widget.dtr!.censusCode;
      _block = widget.dtr!.block;
      _division = widget.dtr!.division;
    } else {
      // Initialize with default values for new DTR
      _dtrCode = '';
      _capacity = '';
      _village = '';
      _location = '';
      _landMarks = '';
      _ccc = '';
      _feeder = '';
      _substation = ''; // Changed from _feederCapacity
      _drgNo = '';
      _docDate = '';
      _jmcNo = '';
      _gp = '';
      _censusCode = '';
      _block = '';
      _division = 'RAIGANJ'; // Set default value
    }
    
    // Initialize the controllers with the values
    _dtrCodeController = TextEditingController(text: _dtrCode);
    _capacityController = TextEditingController(text: _capacity);
    _villageController = TextEditingController(text: _village);
    _locationController = TextEditingController(text: _location);
    _landMarksController = TextEditingController(text: _landMarks);
    _cccController = TextEditingController(text: _ccc);
    _feederController = TextEditingController(text: _feeder);
    _substationController = TextEditingController(text: _substation);
    _drgNoController = TextEditingController(text: _drgNo);
    _docDateController = TextEditingController(text: _docDate);
    _jmcNoController = TextEditingController(text: _jmcNo);
    _gpController = TextEditingController(text: _gp);
    _censusCodeController = TextEditingController(text: _censusCode);
    _blockController = TextEditingController(text: _block);
    _divisionController = TextEditingController(text: _division);
    
    // Load recent DTR codes and search data
    _loadRecentDTRs();
    _loadFavoriteDTRs();
    _loadSearchHistory();
    
    // Add listener to block controller to auto-fill CCC
    _blockController.addListener(_onBlockChanged);
  }

  // Load recent DTR codes from shared preferences
  Future<void> _loadRecentDTRs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final recentDTRs = prefs.getStringList('recent_dtr_codes') ?? [];
      setState(() {
        _recentDTRCodes = recentDTRs.take(10).toList(); // Limit to 10 recent DTRs
      });
    } catch (e) {
      // Handle error silently
      setState(() {
        _recentDTRCodes = [];
      });
    }
  }

  // Save DTR code to recent list
  Future<void> _saveRecentDTR(String dtrCode) async {
    if (dtrCode.isEmpty) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final recentDTRs = prefs.getStringList('recent_dtr_codes') ?? [];
      
      // Remove if already exists to avoid duplicates
      recentDTRs.remove(dtrCode);
      
      // Add to the beginning of the list
      recentDTRs.insert(0, dtrCode);
      
      // Keep only the last 10 entries
      if (recentDTRs.length > 10) {
        recentDTRs.removeRange(10, recentDTRs.length);
      }
      
      await prefs.setStringList('recent_dtr_codes', recentDTRs);
      
      // Update the state
      setState(() {
        _recentDTRCodes = recentDTRs;
      });
    } catch (e) {
      // Handle error silently
    }
  }

  // Clear recent DTRs list
  Future<void> _clearRecentDTRs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('recent_dtr_codes');
      setState(() {
        _recentDTRCodes = [];
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Recent DTRs cleared')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to clear recent DTRs')),
      );
    }
  }

  // Load favorite DTRs from shared preferences
  Future<void> _loadFavoriteDTRs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoriteDTRs = prefs.getStringList('favorite_dtr_codes') ?? [];
      setState(() {
        _favoriteDTRs = favoriteDTRs;
      });
    } catch (e) {
      setState(() {
        _favoriteDTRs = [];
      });
    }
  }

  // Load search history from shared preferences
  Future<void> _loadSearchHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final searchHistory = prefs.getStringList('dtr_search_history') ?? [];
      setState(() {
        _searchHistory = searchHistory.take(10).toList(); // Limit to 10 recent searches
      });
    } catch (e) {
      setState(() {
        _searchHistory = [];
      });
    }
  }

  // Toggle favorite DTR
  Future<void> _toggleFavorite(String dtrCode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> favorites = prefs.getStringList('favorite_dtr_codes') ?? [];
      
      if (favorites.contains(dtrCode)) {
        favorites.remove(dtrCode);
      } else {
        favorites.add(dtrCode);
      }
      
      await prefs.setStringList('favorite_dtr_codes', favorites);
      setState(() {
        _favoriteDTRs = favorites;
      });
    } catch (e) {
      // Handle error silently
    }
  }

  // Add search term to history
  Future<void> _addToSearchHistory(String searchTerm) async {
    if (searchTerm.isEmpty) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> history = prefs.getStringList('dtr_search_history') ?? [];
      
      // Remove if already exists to avoid duplicates
      history.remove(searchTerm);
      
      // Add to the beginning of the list
      history.insert(0, searchTerm);
      
      // Keep only the last 10 entries
      if (history.length > 10) {
        history.removeRange(10, history.length);
      }
      
      await prefs.setStringList('dtr_search_history', history);
      setState(() {
        _searchHistory = history;
      });
    } catch (e) {
      // Handle error silently
    }
  }

  // Clear search history
  Future<void> _clearSearchHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('dtr_search_history');
      setState(() {
        _searchHistory = [];
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Search history cleared')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to clear search history')),
      );
    }
  }

  // Function to check DTR data from local storage only
  Future<void> _checkDTRCode(String dtrCode) async {
    if (dtrCode.isEmpty) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // First, try to find DTR in local storage
      final localDTRs = await _dtrService.getAllDTRs();
      final existingDTR = localDTRs.firstWhere(
        (dtr) => dtr.dtrCode.toLowerCase().trim() == dtrCode.toLowerCase().trim(),
        orElse: () => DTR(
          id: '',
          dtrCode: '',
          capacity: '',
          village: '',
          location: '',
          landMarks: '',
          ccc: '',
          feeder: '',
          substation: '',
          drgNo: '',
          docDate: '',
          jmcNo: '',
          gp: '',
          censusCode: '',
          block: '',
          division: '',
          user: '',
          connectedPoles: [],
        ),
      );
      
      // If found in local storage and not editing, populate fields
      if (existingDTR.id.isNotEmpty && widget.dtr == null) {
        // Populate fields with data from existing DTR by updating controllers
        setState(() {
          _blockController.text = existingDTR.block;
          // Format capacity to remove unnecessary decimal places
          _capacityController.text = _formatCapacity(existingDTR.capacity);
          _villageController.text = existingDTR.village;
          _cccController.text = existingDTR.ccc;
          _gpController.text = existingDTR.gp;
          _locationController.text = existingDTR.location;
          _drgNoController.text = existingDTR.drgNo;
          _feederController.text = existingDTR.feeder;
          _substationController.text = existingDTR.substation;
          _landMarksController.text = existingDTR.landMarks;
          _docDateController.text = existingDTR.docDate;
          _jmcNoController.text = existingDTR.jmcNo;
          _censusCodeController.text = existingDTR.censusCode;
          _divisionController.text = existingDTR.division;
          
          // Update state variables as well
          _block = existingDTR.block;
          _capacity = _formatCapacity(existingDTR.capacity);
          _village = existingDTR.village;
          _ccc = existingDTR.ccc;
          _gp = existingDTR.gp;
          _location = existingDTR.location;
          _drgNo = existingDTR.drgNo;
          _feeder = existingDTR.feeder;
          _substation = existingDTR.substation;
          _landMarks = existingDTR.landMarks;
          _docDate = existingDTR.docDate;
          _jmcNo = existingDTR.jmcNo;
          _censusCode = existingDTR.censusCode;
          _division = existingDTR.division;
        });
        
        // Show a snackbar to indicate success
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('DTR found locally 😊')),
        );
      } else {
        // If not found in local storage, check if API is configured and try to fetch from API
        if (!DTRAPIService.isConfigured()) {
          // API is not configured, show appropriate message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('API not configured. Please contact admin to set up Google Sheets integration 😓')),
          );
          // Clear all fields except DTR code
          setState(() {
            _blockController.text = '';
            _capacityController.text = '';
            _villageController.text = '';
            _cccController.text = '';
            _gpController.text = '';
            _locationController.text = '';
            _drgNoController.text = '';
            _feederController.text = '';
            _substationController.text = '';
            _landMarksController.text = '';
            _docDateController.text = '';
            _jmcNoController.text = '';
            _censusCodeController.text = '';
            _divisionController.text = 'RAIGANJ'; // Changed from 'Raiganj' to 'RAIGANJ'
            
            // Update state variables as well
            _block = '';
            _capacity = '';
            _village = '';
            _ccc = '';
            _gp = '';
            _location = '';
            _drgNo = '';
            _feeder = '';
            _substation = '';
            _landMarks = '';
            _docDate = '';
            _jmcNo = '';
            _censusCode = '';
            _division = 'RAIGANJ';
          });
        } else {
          // First try to fetch from API
          Map<String, dynamic>? apiDTRData = await DTRAPIService.fetchDTRData(dtrCode);
          
          if (apiDTRData != null) {
            // Populate fields with data from API
            setState(() {
              _blockController.text = apiDTRData['block']?.toString() ?? '';
              // Format capacity to remove unnecessary decimal places
              _capacityController.text = _formatCapacity(apiDTRData['capacity']?.toString() ?? '');
              _villageController.text = apiDTRData['village']?.toString() ?? '';
              _cccController.text = apiDTRData['ccc']?.toString() ?? '';
              _gpController.text = apiDTRData['gp']?.toString() ?? '';
              _locationController.text = apiDTRData['location']?.toString() ?? '';
              _drgNoController.text = apiDTRData['drgNo']?.toString() ?? '';
              _feederController.text = apiDTRData['feeder']?.toString() ?? '';
              _substationController.text = apiDTRData['substation']?.toString() ?? '';
              _landMarksController.text = apiDTRData['landMarks']?.toString() ?? '';
              _docDateController.text = apiDTRData['docDate']?.toString() ?? '';
              _jmcNoController.text = apiDTRData['jmcNo']?.toString() ?? '';
              _censusCodeController.text = apiDTRData['censusCode']?.toString() ?? '';
              _divisionController.text = apiDTRData['division']?.toString() ?? '';
              
              // Update state variables as well
              _block = apiDTRData['block']?.toString() ?? '';
              _capacity = _formatCapacity(apiDTRData['capacity']?.toString() ?? '');
              _village = apiDTRData['village']?.toString() ?? '';
              _ccc = apiDTRData['ccc']?.toString() ?? '';
              _gp = apiDTRData['gp']?.toString() ?? '';
              _location = apiDTRData['location']?.toString() ?? '';
              _drgNo = apiDTRData['drgNo']?.toString() ?? '';
              _feeder = apiDTRData['feeder']?.toString() ?? '';
              _substation = apiDTRData['substation']?.toString() ?? '';
              _landMarks = apiDTRData['landMarks']?.toString() ?? '';
              _docDate = apiDTRData['docDate']?.toString() ?? '';
              _jmcNo = apiDTRData['jmcNo']?.toString() ?? '';
              _censusCode = apiDTRData['censusCode']?.toString() ?? '';
              _division = apiDTRData['division']?.toString() ?? '';
            });
            
            // Show a snackbar to indicate success
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('DTR found via API 😊')),
            );
          } else {
            // If API failed, try offline data
            final offlineDTRData = await OfflineDTRService.findDTRByCodeOffline(dtrCode);
            
            if (offlineDTRData != null) {
              // Populate fields with data from offline storage
              setState(() {
                _blockController.text = offlineDTRData['block']?.toString() ?? '';
                // Format capacity to remove unnecessary decimal places
                _capacityController.text = _formatCapacity(offlineDTRData['capacity']?.toString() ?? '');
                _villageController.text = offlineDTRData['village']?.toString() ?? '';
                _cccController.text = offlineDTRData['ccc']?.toString() ?? '';
                _gpController.text = offlineDTRData['gp']?.toString() ?? '';
                _locationController.text = offlineDTRData['location']?.toString() ?? '';
                _drgNoController.text = offlineDTRData['drgNo']?.toString() ?? '';
                _feederController.text = offlineDTRData['feeder']?.toString() ?? '';
                _substationController.text = offlineDTRData['substation']?.toString() ?? '';
                _landMarksController.text = offlineDTRData['landMarks']?.toString() ?? '';
                _docDateController.text = offlineDTRData['docDate']?.toString() ?? '';
                _jmcNoController.text = offlineDTRData['jmcNo']?.toString() ?? '';
                _censusCodeController.text = offlineDTRData['censusCode']?.toString() ?? '';
                _divisionController.text = offlineDTRData['division']?.toString() ?? '';
                
                // Update state variables as well
                _block = offlineDTRData['block']?.toString() ?? '';
                _capacity = _formatCapacity(offlineDTRData['capacity']?.toString() ?? '');
                _village = offlineDTRData['village']?.toString() ?? '';
                _ccc = offlineDTRData['ccc']?.toString() ?? '';
                _gp = offlineDTRData['gp']?.toString() ?? '';
                _location = offlineDTRData['location']?.toString() ?? '';
                _drgNo = offlineDTRData['drgNo']?.toString() ?? '';
                _feeder = offlineDTRData['feeder']?.toString() ?? '';
                _substation = offlineDTRData['substation']?.toString() ?? '';
                _landMarks = offlineDTRData['landMarks']?.toString() ?? '';
                _docDate = offlineDTRData['docDate']?.toString() ?? '';
                _jmcNo = offlineDTRData['jmcNo']?.toString() ?? '';
                _censusCode = offlineDTRData['censusCode']?.toString() ?? '';
                _division = offlineDTRData['division']?.toString() ?? '';
              });
              
              // Show a snackbar to indicate success
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('DTR found via offline data 😊')),
              );
            } else {
              // Clear all fields except DTR code
              setState(() {
                _blockController.text = '';
                _capacityController.text = '';
                _villageController.text = '';
                _cccController.text = '';
                _gpController.text = '';
                _locationController.text = '';
                _drgNoController.text = '';
                _feederController.text = '';
                _substationController.text = '';
                _landMarksController.text = '';
                _docDateController.text = '';
                _jmcNoController.text = '';
                _censusCodeController.text = '';
                _divisionController.text = 'RAIGANJ'; // Changed from 'Raiganj' to 'RAIGANJ'
                
                // Update state variables as well
                _block = '';
                _capacity = '';
                _village = '';
                _ccc = '';
                _gp = '';
                _location = '';
                _drgNo = '';
                _feeder = '';
                _substation = '';
                _landMarks = '';
                _docDate = '';
                _jmcNo = '';
                _censusCode = '';
                _division = 'RAIGANJ';
              });
              
              // Show a snackbar to indicate no data found
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('DTR code not found 😓')),
              );
            }
          }
        }
      }
    } catch (e) {
      print('Error in _checkDTRCode: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error checking DTR code: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Helper method to check if API is properly configured
  bool _isApiConfigured() {
    return DTRAPIService.isConfigured();
  }

  // Modern Glassmorphism App Bar
  PreferredSizeWidget _buildModernAppBar(BuildContext context, bool isDarkMode, ColorScheme colorScheme) {
    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: DTRColors.primaryGradient,
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
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          Hero(
            tag: 'dtr_logo',
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.25),
                    Colors.white.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(13),
                child: Image.asset(
                  'assets/images/NSLOGO1.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Icon(
                        Icons.electrical_services_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.dtr != null ? 'Edit DTR' : 'New DTR',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.dtr != null ? 'Update existing record' : 'Create new record',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        if (widget.dtr != null)
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.2),
                    Colors.white.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.amber,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Editing',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  // Modern Hero Header with Glassmorphism
  Widget _buildModernHeader(BuildContext context, bool isDarkMode, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkMode
                ? [const Color(0xFF252538), const Color(0xFF1E1E2E)]
                : [Colors.white, const Color(0xFFF0F4FF)],
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: DTRColors.primaryGradient[0].withValues(alpha: isDarkMode ? 0.2 : 0.15),
              blurRadius: 30,
              offset: const Offset(0, 12),
              spreadRadius: -5,
            ),
          ],
          border: Border.all(
            color: isDarkMode 
                ? Colors.white.withValues(alpha: 0.05) 
                : Colors.white.withValues(alpha: 0.8),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: DTRColors.primaryGradient,
                ),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: DTRColors.primaryGradient[0].withValues(alpha: 0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                    spreadRadius: -2,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Image.asset(
                  'assets/images/dtr.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Icon(
                        Icons.electrical_services_rounded,
                        color: Colors.white,
                        size: 36,
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 22),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: DTRColors.successGradient,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'DTR Management',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.dtr != null ? 'Edit Transformer' : 'New Transformer',
                    style: TextStyle(
                      color: DTRColors.getTextColor(isDarkMode),
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.dtr != null
                        ? 'Update the transformer details'
                        : 'Enter transformer information',
                    style: TextStyle(
                      color: DTRColors.getSubtextColor(isDarkMode),
                      fontSize: 14,
                      height: 1.4,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Recent DTRs Section with Modern Chips
  Widget _buildRecentDTRsSection(BuildContext context, bool isDarkMode, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: DTRColors.secondaryGradient,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: DTRColors.secondaryGradient[0].withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.history_rounded,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Recent DTRs',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: DTRColors.getTextColor(isDarkMode),
                    ),
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: _clearRecentDTRs,
                icon: Icon(Icons.clear_all_rounded, size: 18, color: colorScheme.error),
                label: Text(
                  'Clear',
                  style: TextStyle(
                    color: colorScheme.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
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
                  color: Colors.black.withValues(alpha: isDarkMode ? 0.3 : 0.06),
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
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _recentDTRCodes.map((dtrCode) {
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      _dtrCodeController.text = dtrCode;
                      _checkDTRCode(dtrCode);
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: DTRColors.primaryGradient,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: DTRColors.primaryGradient[0].withValues(alpha: 0.35),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.electrical_services_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            dtrCode,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // Primary Info Section (DTR Code, Capacity, Division, Block, CCC, GP)
  Widget _buildPrimaryInfoSection(BuildContext context, bool isDarkMode, ColorScheme colorScheme) {
    return _buildModernFormSection(
        context,
        title: 'Primary Information',
        icon: Icons.info_outline,
        color: colorScheme.primary,
        isDarkMode: isDarkMode,
        children: [
          // DTR Code with Sync Button
          Row(
            children: [
              Expanded(
                flex: 3,
                child: _buildModernTextField(
                  label: 'DTR Code',
                  hint: 'Enter DTR code',
                  controller: _dtrCodeController,
                  focusNode: _dtrCodeFocusNode,
                  icon: Icons.qr_code,
                  isDarkMode: isDarkMode,
                  colorScheme: colorScheme,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (value) {
                    if (value.isNotEmpty) {
                      _addToSearchHistory(value);
                      _checkDTRCode(value);
                    }
                    FocusScope.of(context).requestFocus(_capacityFocusNode);
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 1,
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.orange, Colors.deepOrange],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => DTRSyncService.syncAllDTRData(context),
                      borderRadius: BorderRadius.circular(14),
                      child: const Center(
                        child: Icon(Icons.sync, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Capacity
          _buildModernTextField(
            label: 'Capacity (kVA)',
            hint: 'e.g., 100',
            controller: _capacityController,
            focusNode: _capacityFocusNode,
            icon: Icons.bolt,
            isDarkMode: isDarkMode,
            colorScheme: colorScheme,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_divisionFocusNode),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Required';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          // Division & Block Row
          Row(
            children: [
              Expanded(
                child: _buildModernTextField(
                  label: 'Division',
                  hint: 'e.g., RAIGANJ',
                  controller: _divisionController,
                  focusNode: _divisionFocusNode,
                  icon: Icons.location_city,
                  isDarkMode: isDarkMode,
                  colorScheme: colorScheme,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_blockFocusNode),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildModernTextField(
                  label: 'Block',
                  hint: 'e.g., BLOCK 1',
                  controller: _blockController,
                  focusNode: _blockFocusNode,
                  icon: Icons.account_tree,
                  isDarkMode: isDarkMode,
                  colorScheme: colorScheme,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_cccFocusNode),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // CCC & GP Row
          Row(
            children: [
              Expanded(
                child: _buildModernTextField(
                  label: 'CCC',
                  hint: 'CCC Number',
                  controller: _cccController,
                  focusNode: _cccFocusNode,
                  icon: Icons.account_balance,
                  isDarkMode: isDarkMode,
                  colorScheme: colorScheme,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_gpFocusNode),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildModernTextField(
                  label: 'GP',
                  hint: 'GP Name',
                  controller: _gpController,
                  focusNode: _gpFocusNode,
                  icon: Icons.group,
                  isDarkMode: isDarkMode,
                  colorScheme: colorScheme,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_villageFocusNode),
                ),
              ),
            ],
          ),
        ],
      );
  }

  // Location Section (Village, Location, Land Marks)
  Widget _buildLocationSection(BuildContext context, bool isDarkMode, ColorScheme colorScheme) {
    return _buildModernFormSection(
        context,
        title: 'Location Details',
        icon: Icons.place_outlined,
        color: Colors.green,
        isDarkMode: isDarkMode,
        children: [
          // Village
          _buildModernTextField(
            label: 'Village',
            hint: 'Enter village name',
            controller: _villageController,
            focusNode: _villageFocusNode,
            icon: Icons.location_city,
            isDarkMode: isDarkMode,
            colorScheme: colorScheme,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_locationFocusNode),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Required';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          // Location
          _buildModernTextField(
            label: 'Location',
            hint: 'Specific location details',
            controller: _locationController,
            focusNode: _locationFocusNode,
            icon: Icons.map,
            isDarkMode: isDarkMode,
            colorScheme: colorScheme,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_landMarksFocusNode),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Required';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          // Land Marks
          _buildModernTextField(
            label: 'Land Marks',
            hint: 'Nearby landmarks for identification',
            controller: _landMarksController,
            focusNode: _landMarksFocusNode,
            icon: Icons.landscape,
            isDarkMode: isDarkMode,
            colorScheme: colorScheme,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_drgNoFocusNode),
          ),
        ],
      );
  }

  // Documentation Section (DRG No, Census Code, DOC Date, JMC No)
  Widget _buildDocumentationSection(BuildContext context, bool isDarkMode, ColorScheme colorScheme) {
    return _buildModernFormSection(
        context,
        title: 'Documentation',
        icon: Icons.description_outlined,
        color: Colors.orange,
        isDarkMode: isDarkMode,
        children: [
          // DRG No & Census Code Row
          Row(
            children: [
              Expanded(
                child: _buildModernTextField(
                  label: 'DRG No',
                  hint: 'RNJ00',
                  controller: _drgNoController,
                  focusNode: _drgNoFocusNode,
                  icon: Icons.document_scanner,
                  isDarkMode: isDarkMode,
                  colorScheme: colorScheme,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_censusCodeFocusNode),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildModernTextField(
                  label: 'Census Code',
                  hint: 'Code',
                  controller: _censusCodeController,
                  focusNode: _censusCodeFocusNode,
                  icon: Icons.tag,
                  isDarkMode: isDarkMode,
                  colorScheme: colorScheme,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_docDateFocusNode),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // DOC Date & JMC No Row
          Row(
            children: [
              Expanded(
                child: _buildModernTextField(
                  label: 'D.O.C Date',
                  hint: 'DD-MM-YYYY',
                  controller: _docDateController,
                  focusNode: _docDateFocusNode,
                  icon: Icons.calendar_today,
                  isDarkMode: isDarkMode,
                  colorScheme: colorScheme,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_jmcNoFocusNode),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_month),
                    onPressed: () => _selectDate(context),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildModernTextField(
                  label: 'JMC No',
                  hint: 'JMC Number',
                  controller: _jmcNoController,
                  focusNode: _jmcNoFocusNode,
                  icon: Icons.confirmation_number,
                  isDarkMode: isDarkMode,
                  colorScheme: colorScheme,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_feederFocusNode),
                ),
              ),
            ],
          ),
        ],
      );
  }

  // Technical Section (Feeder, Substation)
  Widget _buildTechnicalSection(BuildContext context, bool isDarkMode, ColorScheme colorScheme) {
    return _buildModernFormSection(
      context,
      title: 'Technical Details',
      icon: Icons.electrical_services,
      color: Colors.purple,
      isDarkMode: isDarkMode,
      children: [
        // Feeder
        _buildModernTextField(
          label: 'Feeder',
          hint: 'Enter feeder name',
          controller: _feederController,
          focusNode: _feederFocusNode,
          icon: Icons.electric_bolt,
          isDarkMode: isDarkMode,
          colorScheme: colorScheme,
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_substationFocusNode),
        ),
        const SizedBox(height: 16),
        
        // Substation
        _buildModernTextField(
          label: 'Substation',
          hint: 'Enter substation name',
          controller: _substationController,
          focusNode: _substationFocusNode,
          icon: Icons.power,
          isDarkMode: isDarkMode,
          colorScheme: colorScheme,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _saveDTR(),
        ),
      ],
    );
  }

  // Modern Form Section Container with Enhanced Styling
  Widget _buildModernFormSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required bool isDarkMode,
    required List<Widget> children,
  }) {
    return Container(
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
            color: color.withValues(alpha: isDarkMode ? 0.15 : 0.1),
            blurRadius: 24,
            offset: const Offset(0, 10),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header with Gradient
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withValues(alpha: 0.12),
                  color.withValues(alpha: 0.03),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              border: Border(
                bottom: BorderSide(
                  color: isDarkMode 
                      ? Colors.white.withValues(alpha: 0.05) 
                      : Colors.grey[200]!,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color, color.withValues(alpha: 0.8)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: DTRColors.getTextColor(isDarkMode),
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Required fields marked with *',
                        style: TextStyle(
                          fontSize: 11,
                          color: DTRColors.getSubtextColor(isDarkMode),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Section Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  // Modern Text Field with Enhanced Design
  Widget _buildModernTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required FocusNode focusNode,
    required IconData icon,
    required bool isDarkMode,
    required ColorScheme colorScheme,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction textInputAction = TextInputAction.next,
    void Function(String)? onFieldSubmitted,
    String? Function(String?)? validator,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 14, color: colorScheme.primary),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: DTRColors.getTextColor(isDarkMode),
              ),
            ),
            if (validator != null)
              Text(
                ' *',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.error,
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          textCapitalization: TextCapitalization.characters,
          style: TextStyle(
            color: DTRColors.getTextColor(isDarkMode),
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: DTRColors.getSubtextColor(isDarkMode).withValues(alpha: 0.6),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            filled: true,
            fillColor: isDarkMode ? const Color(0xFF1A1A2E) : const Color(0xFFF8FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: isDarkMode 
                    ? Colors.white.withValues(alpha: 0.08) 
                    : Colors.grey[300]!,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: isDarkMode 
                    ? Colors.white.withValues(alpha: 0.08) 
                    : Colors.grey[300]!,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: colorScheme.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: colorScheme.error,
                width: 1.5,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: colorScheme.error,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            suffixIcon: suffixIcon != null
                ? Container(
                    margin: const EdgeInsets.all(8),
                    child: IconTheme(
                      data: IconThemeData(
                        color: isDarkMode 
                            ? Colors.grey[500] 
                            : Colors.grey[600],
                        size: 22,
                      ),
                      child: suffixIcon,
                    ),
                  )
                : null,
          ),
          validator: validator,
          onFieldSubmitted: onFieldSubmitted,
        ),
      ],
    );
  }

  // Modern Save Button with Enhanced Design
  Widget _buildModernSaveButton(BuildContext context, bool isDarkMode, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: DTRColors.successGradient,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: DTRColors.successGradient[0].withValues(alpha: isDarkMode ? 0.3 : 0.5),
              blurRadius: 20,
              offset: const Offset(0, 10),
              spreadRadius: -2,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _isLoading ? null : _saveDTR,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 22),
              child: Center(
                child: _isLoading
                    ? const SizedBox(
                        width: 26,
                        height: 26,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              widget.dtr != null ? Icons.save_rounded : Icons.add_circle_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            widget.dtr != null ? 'Update DTR Record' : 'Create DTR Record',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _saveDTR() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      // Make sure to get the latest values from the controllers
      _dtrCode = _dtrCodeController.text;
      _capacity = _capacityController.text;
      _village = _villageController.text;
      _location = _locationController.text;
      _landMarks = _landMarksController.text;
      _ccc = _cccController.text;
      _feeder = _feederController.text;
      _substation = _substationController.text;
      _drgNo = _drgNoController.text;
      _docDate = _docDateController.text;
      _jmcNo = _jmcNoController.text;
      _gp = _gpController.text;
      _censusCode = _censusCodeController.text;
      _block = _blockController.text;
      _division = _divisionController.text;
      
      // Get the current user email from the auth service
      final authService = Provider.of<AuthService>(context, listen: false);
      final currentUser = authService.userEmail;
      
      // Create or update DTR object
      final dtr = DTR(
        id: widget.dtr?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        dtrCode: _dtrCode,
        capacity: _capacity,
        village: _village,
        location: _location,
        landMarks: _landMarks,
        ccc: _ccc,
        feeder: _feeder,
        substation: _substation, 
        drgNo: _drgNo,
        docDate: _docDate,
        jmcNo: _jmcNo,
        gp: _gp,
        censusCode: _censusCode,
        block: _block,
        division: _division,
        user: currentUser, // Added User field
        connectedPoles: widget.dtr?.connectedPoles ?? _connectedPoles,
      );
      
      // Save DTR to service
      await _dtrService.saveDTR(dtr);
      
      // Save to recent DTRs list
      await _saveRecentDTR(_dtrCode);
      
      // Show enhanced success animation
      setState(() {
        _showSuccessAnimation = true;
      });
      
      // Keep the snackbar as a fallback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.dtr != null ? 'updated successfully! 👍' : 'created successfully! 😊')),
      );
    }
  }

  // Helper method to format capacity value
  String _formatCapacity(String capacity) {
    if (capacity.isEmpty) return capacity;
    
    try {
      // Try to parse as double
      final doubleValue = double.parse(capacity);
      
      // If it's a whole number, return as integer string
      if (doubleValue == doubleValue.toInt()) {
        return doubleValue.toInt().toString();
      }
      
      // Otherwise, return the original value
      return capacity;
    } catch (e) {
      // If parsing fails, return the original value
      return capacity;
    }
  }

  // Method to select date and format it as dd.MM.yyyy
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    
    if (picked != null) {
      // Format the date as dd.MM.yyyy
      final formattedDate = DateFormat('dd-MM-yyyy').format(picked);
      setState(() {
        _docDateController.text = formattedDate;
        _docDate = formattedDate;
      });
    }
  }

  // Function to handle block field changes and auto-fill CCC
  void _onBlockChanged() {
    // Auto-fill CCC with Block value, but allow manual editing
    if (!_cccController.text.isNotEmpty || _cccController.text == _previousBlockValue) {
      // Only auto-fill if CCC is empty or was previously auto-filled with block value
      setState(() {
        _previousBlockValue = _blockController.text;
        _cccController.text = _blockController.text;
        _ccc = _blockController.text;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      backgroundColor: DTRColors.getBackgroundColor(isDarkMode),
      extendBodyBehindAppBar: true,
      appBar: _buildModernAppBar(context, isDarkMode, colorScheme),
      body: _showSuccessAnimation
          ? Container(
              color: DTRColors.getBackgroundColor(isDarkMode),
              child: Center(
                child: SuccessAnimation(
                  message: widget.dtr != null ? 'DTR Updated!' : 'DTR Created!',
                  onCompleted: () {
                    Navigator.pop(context, true);
                  },
                ),
              ),
            )
          : Form(
              key: _formKey,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // Top spacing for app bar
                  SliverToBoxAdapter(
                    child: SizedBox(height: isDarkMode ? 100 : 110),
                  ),
                  
                  // Hero Header Section
                  SliverToBoxAdapter(
                    child: FadeInDown(
                      duration: const Duration(milliseconds: 600),
                      child: _buildModernHeader(context, isDarkMode, colorScheme),
                    ),
                  ),
                  
                  SliverToBoxAdapter(
                    child: SizedBox(height: isDarkMode ? 24 : 28),
                  ),
                  
                  // Quick Actions / Recent DTRs
                  if (_recentDTRCodes.isNotEmpty && widget.dtr == null)
                    SliverToBoxAdapter(
                      child: FadeInUp(
                        delay: const Duration(milliseconds: 200),
                        duration: const Duration(milliseconds: 600),
                        child: _buildRecentDTRsSection(context, isDarkMode, colorScheme),
                      ),
                    ),
                  
                  if (_recentDTRCodes.isNotEmpty && widget.dtr == null)
                    SliverToBoxAdapter(
                      child: SizedBox(height: isDarkMode ? 24 : 28),
                    ),
                  
                  // Primary Information Section
                  SliverToBoxAdapter(
                    child: FadeInUp(
                      delay: const Duration(milliseconds: 300),
                      duration: const Duration(milliseconds: 600),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _buildPrimaryInfoSection(context, isDarkMode, colorScheme),
                      ),
                    ),
                  ),
                  
                  SliverToBoxAdapter(
                    child: SizedBox(height: isDarkMode ? 20 : 24),
                  ),
                  
                  // Location Section
                  SliverToBoxAdapter(
                    child: FadeInUp(
                      delay: const Duration(milliseconds: 400),
                      duration: const Duration(milliseconds: 600),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _buildLocationSection(context, isDarkMode, colorScheme),
                      ),
                    ),
                  ),
                  
                  SliverToBoxAdapter(
                    child: SizedBox(height: isDarkMode ? 20 : 24),
                  ),
                  
                  // Documentation Section
                  SliverToBoxAdapter(
                    child: FadeInUp(
                      delay: const Duration(milliseconds: 500),
                      duration: const Duration(milliseconds: 600),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _buildDocumentationSection(context, isDarkMode, colorScheme),
                      ),
                    ),
                  ),
                  
                  SliverToBoxAdapter(
                    child: SizedBox(height: isDarkMode ? 20 : 24),
                  ),
                  
                  // Technical Details Section
                  SliverToBoxAdapter(
                    child: FadeInUp(
                      delay: const Duration(milliseconds: 600),
                      duration: const Duration(milliseconds: 600),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _buildTechnicalSection(context, isDarkMode, colorScheme),
                      ),
                    ),
                  ),
                  
                  SliverToBoxAdapter(
                    child: SizedBox(height: isDarkMode ? 28 : 36),
                  ),
                  
                  // Save Button
                  SliverToBoxAdapter(
                    child: FadeInUp(
                      delay: const Duration(milliseconds: 700),
                      duration: const Duration(milliseconds: 600),
                      child: _buildModernSaveButton(context, isDarkMode, colorScheme),
                    ),
                  ),
                  
                  // Bottom spacing
                  SliverToBoxAdapter(
                    child: SizedBox(height: isDarkMode ? 48 : 60),
                  ),
                ],
              ),
            ),
    );
  }
}

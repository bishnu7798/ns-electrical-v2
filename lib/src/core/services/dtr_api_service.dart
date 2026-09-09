import 'dart:convert';
import 'package:http/http.dart' as http;

class DTRAPIService {
 
    // Google Apps Script URL for DTR data
    static const String _apiUrl = 'https://script.google.com/macros/s/AKfycbzS8QDrdTu7JnOvFNuxNn5jt3vQy_AXCjM1j5X348MRwUrAy_Ng9pVTsFIbqRST68Vz/exec';
  
  // Cache for DTR data to avoid repeated API calls
  static final Map<String, Map<String, dynamic>> _dtrCache = {};
  static final Map<String, DateTime> _cacheTimestamps = {};
  
  // Cache timeout (5 minutes)
  static const Duration _cacheTimeout = Duration(minutes: 5);
  
  // Public method to check if API is properly configured
  static bool isConfigured() {
    // Check if the URL is still the placeholder
    return _apiUrl != 'https://script.google.com/macros/s/YOUR_DEPLOYED_SCRIPT_URL/exec';
  }
  
  /// Check if cached data is still valid
  static bool _isCacheValid(String dtrCode) {
    final timestamp = _cacheTimestamps[dtrCode];
    if (timestamp == null) return false;
    
    return DateTime.now().difference(timestamp) < _cacheTimeout;
  }
  
  /// Fetch DTR data by DTR code from Google Apps Script Web API
  static Future<Map<String, dynamic>?> fetchDTRData(String dtrCode) async {
    print('=== DTR SEARCH DEBUG INFO ===');
    print('Searching for DTR code: $dtrCode');
    print('API URL: $_apiUrl');
    print('Current time: ${DateTime.now()}');
    // Check if we have valid cached data
    if (_isCacheValid(dtrCode)) {
      print('Returning cached data for DTR code: $dtrCode');
      return _dtrCache[dtrCode];
    }
    
    try {
      // The API should accept a GET request with action=getDTR and dtrCode parameter
      final encodedDtrCode = Uri.encodeComponent(dtrCode);
      final uri = Uri.parse('$_apiUrl?action=getDTR&dtrCode=$encodedDtrCode');
      print('Making API request to: $uri');
      print('Original DTR code: $dtrCode');
      print('Encoded DTR code: $encodedDtrCode');
      
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 15)); // Increase timeout for slower connections
      
      print('API Response Status: ${response.statusCode}');
      print('API Response Body: ${response.body}');
      
      if (response.statusCode == 200) {
        print('Received successful HTTP response');
        print('Response body length: ${response.body.length}');
        print('Response body: ${response.body}');
        
        // Check if response body is empty
        if (response.body.isEmpty) {
          print('Response body is empty');
          return null;
        }
        
        final jsonData = jsonDecode(response.body);
        print('Parsed JSON data: $jsonData');
        print('Parsed JSON data type: ${jsonData.runtimeType}');
        
        // Check if data was found
        if (jsonData != null && jsonData is Map<String, dynamic> && jsonData.isNotEmpty) {
          // Check if this is an error response
          if (jsonData.containsKey('error')) {
            print('API Error: ${jsonData['error']}');
            return null;
          }
          
          // Check if this is a success response with data
          if (jsonData.containsKey('success') && jsonData['success'] == true && jsonData.containsKey('data')) {
            final actualData = jsonData['data'] as Map<String, dynamic>;
            print('DTR data found in nested format: $actualData');
            // Cache the actual data, not the wrapper
            _dtrCache[dtrCode] = actualData;
            _cacheTimestamps[dtrCode] = DateTime.now();
            return actualData;
          }
          
          // Check if this is a failure response (success: false)
          if (jsonData.containsKey('success') && jsonData['success'] == false) {
            print('API returned failure: ${jsonData['errors']}');
            return null;
          }
          
          print('DTR data found: $jsonData');
          // Cache the data
          _dtrCache[dtrCode] = jsonData;
          _cacheTimestamps[dtrCode] = DateTime.now();
          return jsonData;
        } else if (jsonData is List && jsonData.isNotEmpty) {
          print('Received list data, converting to map');
          // Convert list to map if it contains maps
          if (jsonData.first is Map<String, dynamic>) {
            final firstItem = jsonData.first as Map<String, dynamic>;
            print('Using first item from list: $firstItem');
            // Cache the data
            _dtrCache[dtrCode] = firstItem;
            _cacheTimestamps[dtrCode] = DateTime.now();
            return firstItem;
          } else {
            print('List does not contain map objects');
            return null;
          }
        } else {
          print('No DTR data found for code: $dtrCode');
          print('JSON data is null, empty, or not a map');
          print('JSON data type: ${jsonData.runtimeType}');
          print('This might be because the DTR code doesn\'t exist in the Google Sheet, or the Google Apps Script is not properly configured');
        }
      } else {
        print('HTTP request failed with status: ${response.statusCode}');
        print('Response body: ${response.body}');
        
        // Additional debugging for common issues
        if (response.statusCode == 404) {
          print('API endpoint not found - check if the Google Apps Script URL is correct');
        } else if (response.statusCode == 403) {
          print('Access forbidden - check API permissions');
        } else if (response.statusCode == 500) {
          print('Server error - the API might be temporarily unavailable');
        }
      }
      
      return null;
    } catch (e, stackTrace) {
      print('Error fetching DTR data: $e');
      print('Stack trace: $stackTrace');
      // Also show error to user
      // We can't directly show a snackbar here, but we can log more details
      print('This error occurred while trying to fetch DTR code: $dtrCode');
      
      // Provide more specific error messages
      if (e.toString().contains('Timeout')) {
        print('Request timed out - the API might be slow or unavailable');
      } else if (e.toString().contains('SocketException') || e.toString().contains('Connection')) {
        print('Network error - check your internet connection');
      }
      
      return null;
    }
  }
  
  /// Fetch all DTR data from Google Apps Script Web API
  static Future<List<Map<String, dynamic>>?> fetchAllDTRData() async {
    try {
      final uri = Uri.parse('$_apiUrl?action=getAllDTRs');
      print('Making API request to fetch all DTRs: $uri');
      
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 30)); // Longer timeout for fetching all data
      
      print('API Response Status for getAllDTRs: ${response.statusCode}');
      print('API Response Body length: ${response.body.length}');
      
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        print('Parsed JSON type: ${jsonData.runtimeType}');
        
        if (jsonData != null && jsonData is Map<String, dynamic> && jsonData.isNotEmpty) {
          // Check if this is an error response
          if (jsonData.containsKey('error')) {
            print('API Error: ${jsonData['error']}');
            return null;
          }
          
          // Check if this is a success response with data
          if (jsonData.containsKey('success') && jsonData['success'] == true && jsonData.containsKey('data')) {
            final actualData = jsonData['data'] as List<dynamic>;
            print('Fetched ${actualData.length} DTR records');
            
            // Convert List<dynamic> to List<Map<String, dynamic>>
            final result = actualData
                .map((item) => item as Map<String, dynamic>)
                .toList();
            return result;
          }
        }
      } else {
        print('HTTP request failed with status: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
      
      return null;
    } catch (e, stackTrace) {
      print('Error fetching all DTR data: $e');
      print('Stack trace: $stackTrace');
      return null;
    }
  }
  
  /// Save or update DTR data via Google Apps Script Web API
  static Future<bool> saveDTRData(Map<String, dynamic> dtrData) async {
    try {
      final uri = Uri.parse('$_apiUrl?action=saveDTR');
      print('Sending data to API: $uri with body: $dtrData');
      
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(dtrData),
      ).timeout(const Duration(seconds: 15)); // Add timeout for save operation
      
      print('API Response Status: ${response.statusCode}');
      print('API Response Body: ${response.body}');
      
      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        // Check if this is a success response
        if (result is Map<String, dynamic> && result.containsKey('success')) {
          // Clear cache for this DTR code since we've updated it
          final dtrCode = dtrData['dtrCode'] as String?;
          if (dtrCode != null) {
            _dtrCache.remove(dtrCode);
            _cacheTimestamps.remove(dtrCode);
          }
          return result['success'] == true;
        }
        // If response is not in expected format, assume success
        return true;
      } else {
        print('HTTP request failed with status: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
      
      return false;
    } catch (e, stackTrace) {
      print('Error saving DTR data: $e');
      print('Stack trace: $stackTrace');
      // Log more details about the error
      print('This error occurred while trying to save DTR data: $dtrData');
      return false;
    }
  }
}
import 'dart:convert';
import 'package:http/http.dart' as http;

class GoogleSheetsService {
  // Google Sheet ID from the URL
  static const String _sheetId = '1bU4aToTaxpgRaY9au-arLXB7ZwjwBI9v8NKchMkpKxo';
  
  // API endpoint to fetch data from Google Sheets
  static const String _baseUrl = 'https://docs.google.com/spreadsheets/d';
  
  // Fetch data from the Google Sheet
  static Future<List<Map<String, dynamic>>> fetchSheetData() async {
    try {
      // Using the CSV export endpoint for easier parsing
      const url = '$_baseUrl/$_sheetId/export?format=csv';
      
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final String csvData = response.body;
        return _parseCsvData(csvData);
      } else {
        throw Exception('Failed to load data from Google Sheets: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching Google Sheets data: $e');
      rethrow;
    }
  }
  
  // Parse CSV data into a list of maps
  static List<Map<String, dynamic>> _parseCsvData(String csvData) {
    final List<String> lines = LineSplitter.split(csvData).toList();
    if (lines.isEmpty) return [];
    
    // Get headers from the first line
    final List<String> headers = _parseCsvRow(lines[0]);
    
    // Parse data rows
    final List<Map<String, dynamic>> result = [];
    for (int i = 1; i < lines.length; i++) {
      final List<String> values = _parseCsvRow(lines[i]);
      if (values.length == headers.length) {
        final Map<String, dynamic> row = {};
        for (int j = 0; j < headers.length; j++) {
          row[headers[j]] = values[j];
        }
        result.add(row);
      }
    }
    
    return result;
  }
  
  // Parse a single CSV row, handling quoted values
  static List<String> _parseCsvRow(String row) {
    final List<String> result = [];
    final StringBuffer buffer = StringBuffer();
    bool inQuotes = false;
    
    for (int i = 0; i < row.length; i++) {
      final String char = row[i];
      
      if (char == '"' && !inQuotes) {
        inQuotes = true;
      } else if (char == '"' && inQuotes) {
        if (i + 1 < row.length && row[i + 1] == '"') {
          // Double quote inside quoted string
          buffer.write('"');
          i++; // Skip next quote
        } else {
          // End of quoted string
          inQuotes = false;
        }
      } else if (char == ',' && !inQuotes) {
        // End of field
        result.add(buffer.toString().trim());
        buffer.clear();
      } else {
        buffer.write(char);
      }
    }
    
    // Add the last field
    result.add(buffer.toString().trim());
    
    return result;
  }
}
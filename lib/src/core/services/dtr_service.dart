import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/dtr_model.dart';
import 'local_storage_service.dart';

class DTRService {
  static const String _dtrListKey = 'dtr_list';
  static const String _dtrDataFile = 'dtr_data.json';

  // Get all DTRs
  Future<List<DTR>> getAllDTRs() async {
    try {
      // Try to get DTRs from local storage file first
      final localStorageService = LocalStorageService();
      if (await localStorageService.fileExists(_dtrDataFile)) {
        final jsonString = await localStorageService.readFile(_dtrDataFile);
        final List<dynamic> dtrListJson = jsonDecode(jsonString);
        
        return dtrListJson.map((item) {
          return DTR.fromMap(item as Map<String, dynamic>);
        }).toList()
        ..sort((a, b) => b.id.compareTo(a.id)); // Sort by ID (timestamp) in descending order to show newest first
      }
    } catch (e) {
      print('Error reading DTR data from local storage: $e');
    }
    
    // Fallback to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final dtrListJson = prefs.getStringList(_dtrListKey) ?? [];
    
    return dtrListJson.map((jsonString) {
      final map = jsonDecode(jsonString);
      return DTR.fromMap(map);
    }).toList()
    ..sort((a, b) => b.id.compareTo(a.id)); // Sort by ID (timestamp) in descending order to show newest first
  }
  
  // Get a specific DTR by ID
  Future<DTR?> getDTRById(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final dtrListJson = prefs.getStringList(_dtrListKey) ?? [];
    
    for (final jsonString in dtrListJson) {
      final map = jsonDecode(jsonString);
      final dtr = DTR.fromMap(map);
      if (dtr.id == id) {
        return dtr;
      }
    }
    
    return null;
  }

  // Save a new DTR or update an existing one
  Future<void> saveDTR(DTR dtr) async {
    // Save to local storage file
    try {
      final localStorageService = LocalStorageService();
      final dtrs = await getAllDTRs();
      
      // Remove existing DTR with same ID if it exists
      dtrs.removeWhere((existingDtr) => existingDtr.id == dtr.id);
      
      // Add the DTR (either new or updated)
      dtrs.add(dtr);
      
      // Save to local storage file
      final jsonString = jsonEncode(dtrs.map((d) => d.toMap()).toList());
      await localStorageService.writeFile(_dtrDataFile, jsonString);
    } catch (e) {
      print('Error saving DTR data to local storage: $e');
      // Fallback to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final dtrListJson = prefs.getStringList(_dtrListKey) ?? [];
      
      // Remove existing DTR with same ID if it exists
      dtrListJson.removeWhere((jsonString) {
        final map = jsonDecode(jsonString);
        return map['id'] == dtr.id;
      });
      
      // Add the DTR (either new or updated)
      dtrListJson.add(jsonEncode(dtr.toMap()));
      
      await prefs.setStringList(_dtrListKey, dtrListJson);
    }
  }

  // Delete a DTR
  Future<void> deleteDTR(String id) async {
    // Delete from local storage file
    try {
      final localStorageService = LocalStorageService();
      if (await localStorageService.fileExists(_dtrDataFile)) {
        final dtrs = await getAllDTRs();
        
        // Remove the DTR with matching ID
        dtrs.removeWhere((dtr) => dtr.id == id);
        
        // Save updated list to local storage file
        final jsonString = jsonEncode(dtrs.map((d) => d.toMap()).toList());
        await localStorageService.writeFile(_dtrDataFile, jsonString);
        return;
      }
    } catch (e) {
      print('Error deleting DTR from local storage: $e');
    }
    
    // Fallback to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final dtrListJson = prefs.getStringList(_dtrListKey) ?? [];
    
    // Remove the DTR with matching ID
    dtrListJson.removeWhere((jsonString) {
      final map = jsonDecode(jsonString);
      return map['id'] == id;
    });
    
    await prefs.setStringList(_dtrListKey, dtrListJson);
  }
}
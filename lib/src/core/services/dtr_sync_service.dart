import 'package:flutter/material.dart';
import 'offline_dtr_service.dart';
import 'dtr_api_service.dart';

class DTRSyncService {
  // Sync all DTR data from Google Sheets to offline storage
  static Future<bool> syncAllDTRData(BuildContext context) async {
    if (!DTRAPIService.isConfigured()) {
      // Show error message if API is not configured
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('API not configured. Please contact admin to set up Google Sheets integration.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return false;
    }

    try {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Syncing all DTR data...'),
            backgroundColor: Colors.blue,
          ),
        );
      }

      // Sync all DTR data to offline storage
      final success = await OfflineDTRService.syncAllDTRData();

      if (success) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Successfully synced all DTR data for offline use!'),
              backgroundColor: Colors.green,
            ),
          );
        }
        return true;
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to sync DTR data. Please check your connection.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return false;
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error syncing DTR data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return false;
    }
  }

  // Check if offline data is available
  static Future<bool> hasOfflineData() async {
    return await OfflineDTRService.hasOfflineData();
  }

  // Get the last sync time
  static Future<DateTime?> getLastSyncTime() async {
    return await OfflineDTRService.getLastSyncTime();
  }

  // Clear offline data
  static Future<void> clearOfflineData() async {
    await OfflineDTRService.clearOfflineData();
  }
}
import 'dart:convert';
import 'package:http/http.dart' as http;

/// Example of how to send a DTR payload to the Google Apps Script Web App
Future<void> sendDTRToSheets() async {
  // The URL of your Google Apps Script Web App
  const url = 'https://script.google.com/macros/s/YOUR_SCRIPT_ID/exec';
  
  // Your API key
  const apiKey = 'your-secret-api-key';
  
  // Example DTR payload (this would come from your DTR and Pole models)
  final payload = {
    "dtrCode": "DTR001",
    "dtrName": "Main Street DTR",
    "createdAt": "2023-05-15T10:30:00Z",
    "createdBy": "user@example.com",
    "meta": {
      "capacity": "100kVA",
      "village": "Green Valley",
      "location": "Main Street",
      "landMarks": "Near School",
      "ccc": "CCC001",
      "feeder": "Feeder A",
      "substation": "Substation 1",
      "drgNo": "DRG001",
      "docDate": "2023-05-01",
      "jmcNo": "JMC001",
      "gp": "GP001",
      "censusCode": "CENSUS001",
      "block": "Block A",
      "division": "Division 1",
      "user": "john.doe@example.com"
    },
    "poles": [
      {
        "poleNo": "P001",
        "poleType": "Concrete",
        "routeLength": 100.5,
        "newPccPoleCount": 1,
        "quantity": 1,
        "remarks": "New installation"
      },
      {
        "poleNo": "P002",
        "poleType": "Steel",
        "routeLength": 150.0,
        "newPccPoleCount": 2,
        "quantity": 1,
        "remarks": "Replacement"
      }
    ]
  };
  
  try {
    // Send the POST request
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'X-API-KEY': apiKey,
      },
      body: jsonEncode(payload),
    );
    
    // Parse the response
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      print('Success: ${jsonResponse['success']}');
      print('ID: ${jsonResponse['id']}');
      print('Updated: ${jsonResponse['updated']}');
      print('Errors: ${jsonResponse['errors']}');
    } else {
      print('HTTP Error: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  } catch (e) {
    print('Exception occurred: $e');
  }
}
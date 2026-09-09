import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  const String apiUrl = 'https://script.google.com/macros/s/AKfycbwP_8RN8ikv-F59s4A_SQTXXfL6USkEHnlteahrFGrdyDTP4rU3mY7m341aMzD4uThp/exec';
  
  try {
    // Test the API with the specific DTR code
    const dtrCode = 'A3024';
    final encodedDtrCode = Uri.encodeComponent(dtrCode);
    final uri = Uri.parse('$apiUrl?action=getDTR&dtrCode=$encodedDtrCode');
    
    print('Testing API with DTR code: $dtrCode');
    print('Encoded DTR code: $encodedDtrCode');
    print('Full URI: $uri');
    
    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
    ).timeout(const Duration(seconds: 30));
    
    print('Response Status: ${response.statusCode}');
    print('Response Headers: ${response.headers}');
    print('Response Body: ${response.body}');
    
    if (response.statusCode == 200) {
      try {
        final jsonData = jsonDecode(response.body);
        print('Parsed JSON Data: $jsonData');
        print('JSON Data Type: ${jsonData.runtimeType}');
        
        if (jsonData is Map<String, dynamic>) {
          print('Keys in response: ${jsonData.keys.toList()}');
          
          // Check for common response structures
          if (jsonData.containsKey('data') && jsonData['data'] is Map) {
            final dataObj = jsonData['data'] as Map;
            print('Keys in data object: ${dataObj.keys.toList()}');
          }
          
          if (jsonData.containsKey('meta') && jsonData['meta'] is Map) {
            final metaObj = jsonData['meta'] as Map;
            print('Keys in meta object: ${metaObj.keys.toList()}');
          }
        }
      } catch (parseError) {
        print('Error parsing JSON: $parseError');
        print('Raw response body: ${response.body}');
      }
    } else {
      print('HTTP Error: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  } catch (e, stackTrace) {
    print('Error: $e');
    print('Stack trace: $stackTrace');
  }
}
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  const String apiUrl = 'https://script.google.com/macros/s/AKfycby3CviUX37lLQsqjXJ_Gkd9gGV3OVPiOoD4YlrHYrzhhdeqHuofr_yjsx3OidMXyslb/exec';
  
  try {
    // Test the API with the specific DTR code
    const dtrCode = 'A3024';
    final encodedDtrCode = Uri.encodeComponent(dtrCode);
    final uri = Uri.parse('$apiUrl?action=getDTR&dtrCode=$encodedDtrCode');
    
    print('Testing new API with DTR code: $dtrCode');
    print('Full URI: $uri');
    
    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
    ).timeout(const Duration(seconds: 30));
    
    print('Response Status: ${response.statusCode}');
    print('Response Body: ${response.body}');
    
    if (response.statusCode == 200) {
      try {
        final jsonData = jsonDecode(response.body);
        print('Parsed JSON Data: $jsonData');
      } catch (parseError) {
        print('Error parsing JSON: $parseError');
      }
    } else {
      print('HTTP Error: ${response.statusCode}');
    }
  } catch (e) {
    print('Error: $e');
  }
}
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  const String apiUrl = 'https://script.google.com/macros/s/AKfycbwP_8RN8ikv-F59s4A_SQTXXfL6USkEHnlteahrFGrdyDTP4rU3mY7m341aMzD4uThp/exec';
  
  try {
    final uri = Uri.parse('$apiUrl?action=getDTR&dtrCode=A3024');
    print('Making API request to: $uri');
    
    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
    ).timeout(const Duration(seconds: 10));
    
    print('API Response Status: ${response.statusCode}');
    print('API Response Body: ${response.body}');
    
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      print('Parsed JSON Data: $jsonData');
    }
  } catch (e, stackTrace) {
    print('Error: $e');
    print('Stack trace: $stackTrace');
  }
}
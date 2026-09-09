import 'dart:convert';
import 'dart:io';

void main() async {
  const url = 'https://script.google.com/macros/s/AKfycbwP_8RN8ikv-F59s4A_SQTXXfL6USkEHnlteahrFGrdyDTP4rU3mY7m341aMzD4uThp/exec?action=getDTR&dtrCode=A3024';
  
  print('Testing DTR API...');
  print('URL: $url');
  
  try {
    final request = await HttpClient().getUrl(Uri.parse(url));
    request.headers.add('Content-Type', 'application/json');
    
    final response = await request.close();
    print('Status code: ${response.statusCode}');
    
    final responseBody = await response.transform(utf8.decoder).join();
    print('Response body: $responseBody');
    
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(responseBody);
      print('Parsed JSON: $jsonData');
    }
  } catch (e, stackTrace) {
    print('Error: $e');
    print('Stack trace: $stackTrace');
  }
}
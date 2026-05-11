import 'dart:convert';
import 'dart:io';

void main() {
  final file = File('c:/Users/Umar/Desktop/Booking-app/frontend/assets/icons/logo.svg');
  final content = file.readAsStringSync();
  
  final regex = RegExp(r'data:image/png;base64,([^"]+)');
  final match = regex.firstMatch(content);
  
  if (match != null) {
    final base64String = match.group(1)!;
    final bytes = base64Decode(base64String);
    File('c:/Users/Umar/Desktop/Booking-app/frontend/assets/icons/logo.png').writeAsBytesSync(bytes);
    print("Successfully extracted logo.png");
  } else {
    print("Could not find base64 PNG data.");
  }
}

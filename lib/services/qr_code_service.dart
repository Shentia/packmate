import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/packing_list.dart';
import '../models/packing_item.dart';

class QRCodeService {
  // Convert a packing list to a compressed string for QR code
  static String packingListToQRData(PackingList list) {
    // Convert the list to JSON
    final Map<String, dynamic> jsonMap = list.toJson();

    // Convert to JSON string
    final jsonString = jsonEncode(jsonMap);

    // Encode to base64 for more compact representation
    final bytes = utf8.encode(jsonString);
    final base64String = base64Encode(bytes);

    return base64String;
  }

  // Convert QR code data back to a packing list
  static PackingList qrDataToPackingList(String qrData) {
    try {
      // Decode the base64 string
      final bytes = base64Decode(qrData);
      final jsonString = utf8.decode(bytes);

      // Convert from JSON
      final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;

      // Create packing list object
      return PackingList.fromJson(jsonMap);
    } catch (e) {
      if (kDebugMode) {
        print('Error decoding QR data: $e');
      }
      throw FormatException('Invalid QR code format');
    }
  }
}

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/packing_list.dart';
import '../services/qr_code_service.dart';

class QRCodeDialog extends StatelessWidget {
  final PackingList packingList;

  const QRCodeDialog({
    super.key,
    required this.packingList,
  });

  @override
  Widget build(BuildContext context) {
    final qrData = QRCodeService.packingListToQRData(packingList);

    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'QR Code for ${packingList.name}',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            QrImageView(
              data: qrData,
              version: QrVersions.auto,
              size: 250,
              backgroundColor: Colors.white,
            ),
            const SizedBox(height: 20),
            Text(
              '${packingList.items.length} items',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }
}

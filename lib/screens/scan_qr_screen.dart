import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:polivent_app/models/ui_colors.dart';
import 'package:polivent_app/screens/home.dart';

class QRScanScreen extends StatefulWidget {
  final String eventId;

  const QRScanScreen({Key? key, required this.eventId}) : super(key: key);

  @override
  State<QRScanScreen> createState() => _QRScanScreenState();
}

class _QRScanScreenState extends State<QRScanScreen> {
  bool isScanned = false;
  bool isFlashOn = false;
  final MobileScannerController cameraController = MobileScannerController();

  void _onQRViewCreated(BarcodeCapture barcodeCapture) {
    if (!isScanned && barcodeCapture.barcodes.isNotEmpty) {
      final String? qrCode = barcodeCapture.barcodes.first.rawValue;

      if (qrCode != null) {
        setState(() => isScanned = true);

        // Aksi setelah QR berhasil discan
        if (qrCode == widget.eventId) {
          Navigator.pop(context, 'QR Code successfully scanned!');
        } else {
          setState(() => isScanned = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid QR Code for this event.')),
          );
        }
      }
    }
  }

  void _toggleFlash() {
    setState(() {
      isFlashOn = !isFlashOn;
      cameraController.toggleTorch();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code for Attendance'),
        backgroundColor: UIColor.solidWhite,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const Home(), // Ganti ke screen berikutnya
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: cameraController,
            onDetect: (barcodeCapture) {
              _onQRViewCreated(barcodeCapture);
            },
          ),
          Align(
            alignment: Alignment.center,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blueAccent, width: 4),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Align the QR code within the frame to scan',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const Home(), // Ganti ke screen berikutnya
                          ),
                        ),
                        icon: const Icon(Icons.close),
                        label: const Text('Cancel'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _toggleFlash,
                        icon: Icon(
                          isFlashOn ? Icons.flash_off : Icons.flash_on,
                        ),
                        label: Text(
                            isFlashOn ? 'Turn Off Flash' : 'Turn On Flash'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

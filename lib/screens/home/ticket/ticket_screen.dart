import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:polivent_app/models/ui_colors.dart';
import 'package:polivent_app/services/data/registration_model.dart';
import 'package:uicons_pro/uicons_pro.dart';

class TicketDetailPage extends StatelessWidget {
  final Registration registration;

  const TicketDetailPage({super.key, required this.registration});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar Sliding
          SliverAppBar(
            expandedHeight: 300.0,
            floating: false,
            pinned: true,
            backgroundColor: UIColor.primaryColor,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                registration.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    registration.poster,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: UIColor.primaryColor.withOpacity(0.5),
                        child: const Icon(Icons.image_not_supported,
                            size: 50, color: Colors.white),
                      );
                    },
                  ),
                  // Gradient overlay
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.3),
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Konten Detail
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Informasi Event Card
                _buildEventInfoCard(),

                const SizedBox(height: 20),

                // QR Code Section
                _buildQRCodeSection(),

                const SizedBox(height: 20),

                // Deskripsi Event
                _buildDescriptionSection(),
              ]),
            ),
          ),
        ],
      ),
      // Floating Action Button
      floatingActionButton: FloatingActionButton(
        backgroundColor: UIColor.primaryColor,
        onPressed: () {
          // Aksi tambahan, misalnya download tiket
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tiket sedang diunduh'),
              backgroundColor: UIColor.primaryColor,
            ),
          );
        },
        child: const Icon(Icons.download, color: Colors.white),
      ),
    );
  }

  Widget _buildEventInfoCard() {
    return Card(
      elevation: 4,
      color: UIColor.solidWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildDetailRow(
              icon: UIconsPro.regularRounded.category,
              label: 'Kategori',
              value: registration.categoryName,
            ),
            const Divider(color: UIColor.typoGray, height: 1),
            _buildDetailRow(
              icon: UIconsPro.regularRounded.calendar,
              label: 'Tanggal',
              value: _formatEventDate(registration),
            ),
            const Divider(color: UIColor.typoGray, height: 1),
            _buildDetailRow(
              icon: UIconsPro.regularRounded.marker,
              label: 'Lokasi',
              value: '${registration.place}, ${registration.location}',
            ),
            const Divider(color: UIColor.typoGray, height: 1),
            _buildDetailRow(
              icon: UIconsPro.regularRounded.user_time,
              label: 'Kuota',
              value: '${registration.quota} peserta',
            ),
            const Divider(color: UIColor.typoGray, height: 1),
            _buildDetailRow(
              icon: UIconsPro.regularRounded.clock,
              label: 'Waktu Registrasi',
              value: _formatRegistrationTime(registration.registrationTime),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQRCodeSection() {
    return Card(
      elevation: 4,
      color: UIColor.solidWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'Tiket Masuk',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: UIColor.typoBlack,
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: QrImageView(
                data: registration.registId.toString(),
                version: QrVersions.auto,
                size: 200.0,
                backgroundColor: Colors.white,
                errorStateBuilder: (cxt, err) {
                  return const Text(
                    'Tidak dapat membuat QR Code',
                    style: TextStyle(color: Colors.red),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'ID Registrasi: ${registration.registId}',
              style: const TextStyle(
                color: UIColor.typoGray,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionSection() {
    return Card(
      elevation: 4,
      color: UIColor.solidWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Deskripsi Event',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: UIColor.typoBlack,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              registration.description,
              style: const TextStyle(
                fontSize: 14,
                color: UIColor.typoGray,
                height: 1.5,
              ),
              textAlign: TextAlign.justify,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: UIColor.primaryColor, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: UIColor.typoBlack,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    color: UIColor.typoGray,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatEventDate(Registration registration) {
    final startDate = DateTime.parse(registration.dateStart);
    final endDate = DateTime.parse(registration.dateEnd);

    final formatter = DateFormat('dd MMM yyyy');
    return '${formatter.format(startDate)} - ${formatter.format(endDate)}';
  }

  String _formatRegistrationTime(String registrationTime) {
    final dateTime = DateTime.parse(registrationTime);
    final formatter = DateFormat('dd MMM yyyy HH:mm');
    return formatter.format(dateTime);
  }
}

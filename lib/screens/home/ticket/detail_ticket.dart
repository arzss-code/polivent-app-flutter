import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:polivent_app/screens/home/event/detail_events.dart';
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
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: UIColor.solidWhite,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: UIColor.typoBlack),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          registration.title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: UIColor.typoBlack,
            overflow: TextOverflow.ellipsis,
          ),
          maxLines: 1,
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: CustomScrollView(
        slivers: [
          // Poster Event
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: double.infinity,
                height: 250, // Sesuaikan tinggi sesuai kebutuhan
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(15), // Tambahkan border radius
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(1),
                      spreadRadius: 1,
                      // blurRadius: 10,
                      // offset: const Offset(0, 4),
                    ),
                  ],
                ),

                margin: const EdgeInsets.all(
                    20), // Tambahkan margin di sekitar poster

                child: GestureDetector(
                  onTap: () {
                    // Navigasi ke halaman detail events
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            DetailEvents(eventId: registration.eventId),
                      ),
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.network(
                      registration.poster,
                      width: double.infinity,
                      height: 250,
                      fit: BoxFit
                          .cover, // Gunakan contain untuk mempertahankan aspek rasio
                      alignment: Alignment.topCenter,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: double.infinity,
                          height: 250,
                          color: UIColor.primaryColor.withOpacity(0.5),
                          child: const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.image_not_supported,
                                    size: 100, color: Colors.white),
                                SizedBox(height: 16),
                                Text(
                                  'Poster Tidak Tersedia',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Konten Detail
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Informasi Event Card
                _buildEventInfoCard(),

                const SizedBox(height: 10),

                // // QR Code Section
                // _buildQRCodeSection(),

                const SizedBox(height: 10),

                // Deskripsi Event
                _buildDescriptionSection(),
              ]),
            ),
          ),
        ],
      ),
      // // Floating Action Button
      // floatingActionButton: FloatingActionButton(
      //   backgroundColor: UIColor.primaryColor,
      //   onPressed: () {
      //     // Aksi tambahan, misalnya download tiket
      //     ScaffoldMessenger.of(context).showSnackBar(
      //       const SnackBar(
      //         content: Text('Tiket sedang diunduh'),
      //         backgroundColor: UIColor.primaryColor,
      //       ),
      //     );
      //   },
      //   child: const Icon(Icons.download, color: Colors.white),
      // ),
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
            const Divider(color: UIColor.typoGray2, height: 1),
            _buildDetailRow(
              icon: UIconsPro.regularRounded.calendar,
              label: 'Tanggal',
              value: _formatEventDate(registration),
            ),
            const Divider(color: UIColor.typoGray2, height: 1),
            _buildDetailRow(
              icon: UIconsPro.regularRounded.marker,
              label: 'Lokasi',
              value: '${registration.place}, ${registration.location}',
            ),
            const Divider(color: UIColor.typoGray2, height: 1),
            _buildDetailRow(
              icon: UIconsPro.regularRounded.user_time,
              label: 'Kuota',
              value: '${registration.quota} peserta',
            ),
            const Divider(color: UIColor.typoGray2, height: 1),
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
                height: 1.5, // Tambahkan jarak antar baris
              ),
              textAlign: TextAlign.justify, // Rata kanan-kiri
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

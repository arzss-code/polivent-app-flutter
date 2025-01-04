// import 'package:flutter/material.dart';
// import 'package:polivent_app/models/ui_colors.dart';

// class HelpScreen extends StatelessWidget {
//   const HelpScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF5F5F5),
//       appBar: AppBar(
//         scrolledUnderElevation: 0,
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: Icon(
//             Icons.arrow_back_ios_new,
//             color: Colors.black87,
//             size: 24,
//           ),
//           onPressed: () => Navigator.pop(context),
//         ),
//         centerTitle: true,
//         title: Text(
//           'Pusat Bantuan',
//           style: TextStyle(
//             fontSize: 22,
//             fontWeight: FontWeight.w700,
//             color: Colors.black87,
//           ),
//         ),
//         // actions: [
//         //   Padding(
//         //     padding: const EdgeInsets.only(right: 16),
//         //     child: IconButton(
//         //       icon: Icon(
//         //         Icons.search_rounded,
//         //         color: Colors.black87,
//         //         size: 28,
//         //       ),
//         //       onPressed: () {
//         //         // Tambahkan fungsi pencarian
//         //       },
//         //     ),
//         //   ),
//         // ],
//       ),
//       body: ListView(
//         physics: const BouncingScrollPhysics(),
//         padding: const EdgeInsets.symmetric(vertical: 16),
//         children: const [
//           HelpItem(
//             icon: Icons.event_available_rounded,
//             title: 'Cara Mencari Event',
//             content: 'Temukan event yang kamu inginkan dengan mudah:\n'
//                 '1. Gunakan bilah pencarian di halaman utama\n'
//                 '2. Ketik nama event, kategori, atau lokasi\n'
//                 '3. Tekan tombol cari atau enter\n'
//                 '4. Lihat hasil pencarian yang sesuai\n'
//                 'Tips: Gunakan kata kunci spesifik untuk hasil lebih akurat',
//           ),
//           HelpItem(
//             icon: Icons.filter_alt_rounded,
//             title: 'Cara Memfilter Event',
//             content: 'Saring event sesuai preferensi Anda:\n'
//                 '1. Klik tombol "Filter" di halaman event\n'
//                 '2. Pilih kategori yang diinginkan\n'
//                 '• Akademik\n'
//                 '• Olahraga\n'
//                 '• Seni & Budaya\n'
//                 '• Seminar\n'
//                 '3. Atur rentang waktu\n'
//                 '4. Pilih lokasi\n'
//                 '5. Tekan "Terapkan Filter"',
//           ),
//           HelpItem(
//             icon: Icons.app_registration_rounded,
//             title: 'Cara Mendaftar Event',
//             content: 'Daftarkan diri Anda ke event dengan mudah:\n'
//                 '1. Pilih event yang diminati\n'
//                 '2. Klik tombol "Daftar"\n'
//                 '3. Lengkapi formulir pendaftaran\n'
//                 '4. Periksa ulang data yang dimasukkan\n'
//                 '5. Konfirmasi pendaftaran\n'
//                 '6. Tunggu konfirmasi dari panitia\n'
//                 'Catatan: Pastikan data diri akurat',
//           ),
//           HelpItem(
//             icon: Icons.qr_code_scanner_rounded,
//             title: 'Cara Absensi dengan Scan',
//             content: 'Lakukan absensi dengan cepat:\n'
//                 '1. Buka menu absensi di detail event\n'
//                 '2. Pastikan Anda sudah terdaftar\n'
//                 '3. Klik tombol "Scan QR"\n'
//                 '4. Arahkan kamera ke QR Code\n'
//                 '5. Tunggu konfirmasi sistem\n'
//                 'Tips: Pastikan QR Code terlihat jelas',
//           ),
//           HelpItem(
//             icon: Icons.confirmation_number_rounded,
//             title: 'Cara Melihat Tiket',
//             content: 'Akses tiket event dengan mudah:\n'
//                 '1. Buka menu "Tiket Saya"\n'
//                 '2. Pilih event yang diinginkan\n'
//                 '3. Lihat detail tiket\n'
//                 '• Kode tiket\n'
//                 '• Tanggal & waktu\n'
//                 '• Lokasi\n'
//                 '4. Gunakan opsi unduh/cetak jika perlu',
//           ),
//           HelpItem(
//             icon: Icons.logout_rounded,
//             title: 'Cara Logout',
//             content: 'Keluar dari akun dengan aman:\n'
//                 '1. Buka menu profil/pengaturan\n'
//                 '2. Gulir ke bagian bawah\n'
//                 '3. Klik tombol "Keluar"\n'
//                 '4. Konfirmasi logout\n'
//                 'Catatan:\n'
//                 '• Data tersimpan otomatis\n'
//                 '• Anda dapat login kembali kapan saja',
//           ),
//           HelpItem(
//             icon: Icons.password_rounded,
//             title: 'Cara Mengatur Ulang Kata Sandi',
//             content:
//                 'Jika Anda lupa kata sandi, ikuti langkah-langkah berikut:\n'
//                 '1. Buka halaman login\n'
//                 '2. Klik "Lupa Kata Sandi"\n'
//                 '3. Masukkan alamat email Anda\n'
//                 '4. Periksa email untuk tautan pengaturan ulang\n'
//                 '5. Buat kata sandi baru yang kuat dan unik',
//           ),
//           HelpItem(
//             icon: Icons.support_agent_rounded,
//             title: 'Menghubungi Tim Dukungan',
//             content: 'Kami siap membantu Anda dengan berbagai cara:\n'
//                 '• Kirim email ke support@polivent.com\n'
//                 '• Gunakan fitur "Hubungi Kami" di dalam aplikasi\n'
//                 '• Jam layanan: Senin-Jumat, 09.00-17.00 WIB\n'
//                 '• Waktu respons: Maks. 1x24 jam',
//           ),
//           HelpItem(
//             icon: Icons.person,
//             title: 'Memperbarui Profil',
//             content: 'Cara mudah memperbarui profil Anda:\n'
//                 '1. Buka menu "Pengaturan"\n'
//                 '2. Pilih "Edit Profil"\n'
//                 '3. Perbarui informasi yang diinginkan\n'
//                 '4. Pastikan data akurat\n'
//                 '5. Klik "Simpan Perubahan"',
//           ),
//           HelpItem(
//             icon: Icons.notifications_active_rounded,
//             title: 'Mengaktifkan Notifikasi',
//             content: 'Kelola notifikasi dengan mudah:\n'
//                 '1. Buka "Pengaturan Aplikasi"\n'
//                 '2. Pilih menu "Notifikasi"\n'
//                 '3. Aktifkan/nonaktifkan jenis notifikasi\n'
//                 '• Acara baru\n'
//                 '• Pengumuman\n'
//                 '• Pesan pribadi',
//           ),
//           HelpItem(
//             icon: Icons.delete_forever_rounded,
//             title: 'Menghapus Akun',
//             content: 'Proses penghapusan akun:\n'
//                 '• Hubungi tim dukungan via email\n'
//                 '• Sertakan alasan penghapusan akun\n'
//                 '• Konfirmasi identitas Anda\n'
//                 '• Tunggu proses verifikasi (maks. 3x24 jam)\n'
//                 '• Akun akan dihapus permanen',
//           ),
//         ],
//       ),
//     );
//   }
// }

// class HelpItem extends StatelessWidget {
//   final String title;
//   final String content;
//   final IconData icon;

//   const HelpItem({
//     super.key,
//     required this.title,
//     required this.content,
//     required this.icon,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black12,
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//         border: Border.all(color: Colors.grey.shade200, width: 1),
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(16),
//         child: Material(
//           color: Colors.transparent,
//           child: Theme(
//             data: ThemeData(
//               dividerColor: Colors.transparent,
//             ),
//             child: ExpansionTile(
//               backgroundColor: Colors.white,
//               collapsedBackgroundColor: Colors.white,
//               tilePadding:
//                   const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//               leading: Icon(
//                 icon,
//                 color: UIColor.primaryColor,
//                 size: 32,
//               ),
//               title: Text(
//                 title,
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.w600,
//                   color: UIColor.primaryColor,
//                 ),
//               ),
//               trailing: Icon(
//                 Icons.expand_more_rounded,
//                 color: UIColor.primaryColor,
//                 size: 28,
//               ),
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
//                   child: Text(
//                     content,
//                     style: TextStyle(
//                       fontSize: 15,
//                       color: Colors.black87,
//                       height: 1.6,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:polivent_app/models/ui_colors.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  _HelpScreenState createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<HelpItem> _allHelpItems = [];
  List<HelpItem> _filteredHelpItems = [];
  String _selectedCategory = 'Semua';

  final List<String> _categories = [
    'Semua',
    'Pendaftaran',
    'Tiket',
    'Akun',
    'Event',
    'Lainnya'
  ];

  @override
  void initState() {
    super.initState();
    _initializeHelpItems();
    _filteredHelpItems = _allHelpItems;
  }

  void _initializeHelpItems() {
    _allHelpItems = [
      const HelpItem(
        category: 'Pendaftaran',
        icon: Icons.app_registration_rounded,
        title: 'Cara Mendaftar Event',
        content: 'Panduan lengkap mendaftar event:\n'
            '1. Pastikan sudah login dengan data yang benar\n'
            '2. Cari event yang diminati\n'
            '3. Pilih dan masuk ke detail event\n'
            '4. Klik tombol "Daftar Event"\n'
            '5. Event akan masuk ke tiket Anda\n',
      ),
      const HelpItem(
          category: 'Tiket',
          icon: Icons.confirmation_number_rounded,
          title: 'Cara Melihat Tiket',
          content: 'Akses tiket dengan mudah:\n'
              '1. Buka menu "Tiket Saya"\n'
              '2. Pilih event yang diinginkan\n'
              '3. Lihat detail tiket\n'
              '4. Berikan ulasan atau komentar\n'),
      const HelpItem(
        category: 'Event',
        icon: Icons.event_available_rounded,
        title: 'Cara Mencari Event',
        content: 'Temukan event tepat:\n'
            '1. Gunakan bilah pencarian\n'
            '1. Ketik event yang ingin dicari\n'
            '2. Filter berdasarkan kategori\n'
            '3. Pilih tanggal\n'
            // '4. Urutkan berdasarkan preferensi\n'
            '4. Jelajahi event rekomendasi',
      ),
      // Tambahkan item help lainnya
      const HelpItem(
        category: 'Event',
        icon: Icons.filter_list_rounded,
        title: 'Filter Event',
        content: 'Cara memfilter event:\n'
            '1. Klik tombol filter\n'
            '2. Pilih kategori\n'
            '3. Tentukan rentang waktu\n'
            // '4. Pilih lokasi\n'
            '4. Terapkan filter',
      ),
      const HelpItem(
        category: 'Event',
        icon: Icons.qr_code_scanner_rounded,
        title: 'Cara Absensi dengan Scan QR',
        content: 'Panduan Absensi Event:\n'
            '1. Pastikan terdaftar di event\n'
            '2. Buka halaman home\n'
            '3. Pilih menu "Scan Absensi"\n'
            '4. Arahkan kamera ke QR Code\n'
            '5. Tekan Tombol Scan\n'
            '6. Akan ditampilkan berhasil atau gagal\n'
            'Catatan:\n'
            '• Pastikan koneksi internet stabil',
      ),
      // Item Help untuk Like dan Komentar Event
      const HelpItem(
        category: 'Event',
        icon: Icons.favorite_rounded,
        title: 'Cara Like Event',
        content: 'Panduan Menyukai Event:\n'
            '1. Buka halaman detail event\n'
            '2. Temukan ikon hati di pojok kanan atas\n'
            '3. Klik ikon hati untuk like\n'
            '4. Ikon akan berubah warna merah\n'
            '5. Event akan ditambahkan di event favorit\n'
            'Tips:\n'
            '• Like menunjukkan minat Anda\n'
            '• Dapat membagikan event yang disukai',
      ),
      const HelpItem(
        category: 'Event',
        icon: Icons.share_rounded,
        title: 'Cara Berbagi Event',
        content: 'Panduan Membagikan Event:\n'
            '1. Buka halaman detail event\n'
            '2. Klik ikon share di pojok kanan atas\n'
            '3. Pilih platform berbagi:\n'
            '   • WhatsApp\n'
            '   • Instagram\n'
            '   • Facebook\n'
            '   • Salin tautan\n'
            '4. Tambahkan pesan pribadi (opsional)\n'
            '5. Kirim atau bagikan\n'
            'Manfaat Berbagi Event:\n'
            '• Ajak teman bergabung\n'
            '• Sebarkan informasi event\n'
            '• Tingkatkan partisipasi',
      ),
      const HelpItem(
        category: 'Event',
        icon: Icons.comment_rounded,
        title: 'Cara Memberikan Komentar',
        content: 'Panduan Menulis Komentar:\n'
            '1. Buka halaman detail event\n'
            '2. Gulir ke bagian komentar\n'
            '3. Ketik komentar di kolom input\n'
            '4. Tekan tombol kirim\n'
            '5. Komentar akan tampil segera\n'
            'Etika Berkomentar:\n'
            '• Gunakan bahasa sopan\n'
            '• Berikan komentar konstruktif\n'
            '• Hindari komentar negatif',
      ),

      const HelpItem(
        category: 'Event',
        icon: Icons.reply_rounded,
        title: 'Cara Membalas Komentar',
        content: 'Panduan Membalas Komentar:\n'
            '1. Buka halaman detail event\n'
            '2. Temukan komentar yang ingin dibalas\n'
            '3. Klik tombol "Balas" di bawah komentar\n'
            '4. Ketik balasan di kolom input\n'
            '5. Tekan tombol kirim\n'
            '6. Balasan akan tampil di bawah komentar\n'
            'Tips:\n'
            '• Gunakan bahasa yang sopan\n'
            '• Berikan balasan yang relevan\n'
            '• Hindari balasan yang bersifat negatif',
      ),

      const HelpItem(
        category: 'Event',
        icon: Icons.rate_review_rounded,
        title: 'Cara Memberikan Ulasan',
        content: 'Panduan Memberikan Ulasan:\n'
            '1. Buka halaman tiket yang telah dihadiri\n'
            '2. Gulir ke bagian ulasan\n'
            '3. Klik tombol "Beri Ulasan"\n'
            '4. Isi komentar\n'
            '5. Tekan tombol kirim\n'
            'Tips:\n'
            '• Sertakan pengalaman Anda\n'
            '• Hindari ulasan yang tidak relevan',
      ),

      const HelpItem(
        category: 'Lainnya',
        icon: Icons.notifications_active_rounded,
        title: 'Mengelola Notifikasi',
        content: 'Panduan Mengelola Notifikasi:\n'
            '1. Buka halaman Pengaturan\n'
            '2. Tekan tombol "Aktifkan Notifikasi" untuk menyalakan\n'
            '3. Tekan tombol kembali untuk mematikan\n'
            'Tips:\n'
            '• Pastikan aplikasi memiliki izin notifikasi\n'
            '• Sesuaikan jenis notifikasi sesuai kebutuhan',
      ),

      // Kategori Akun
      const HelpItem(
        category: 'Akun',
        icon: Icons.person_add_rounded,
        title: 'Membuat Akun Baru',
        content: 'Langkah pendaftaran akun:\n'
            '1. Hubungi administrator\n'
            '2. Kirimkan data diri lengkap\n'
            '3. Tunggu verifikasi\n'
            '4. Administrator akan membuatkan akun\n'
            '5. Akun siap digunakan',
      ),
      const HelpItem(
        category: 'Akun',
        icon: Icons.manage_accounts_rounded,
        title: 'Mengubah Profil',
        content: 'Perbarui informasi profil:\n'
            '1. Buka pengaturan\n'
            '2. Pilih "Edit Profil"\n'
            '3. Ubah informasi\n'
            '4. Simpan perubahan\n'
            '5. Konfirmasi perubahan',
      ),
      const HelpItem(
        category: 'Akun',
        icon: Icons.logout_rounded,
        title: 'Cara Logout dari Akun',
        content: 'Panduan Keluar dari Akun:\n'
            '1. Buka halaman Pengaturan\n'
            '2. Gulir ke bagian bawah layar\n'
            '3. Temukan tombol "Keluar" atau "Logout"\n'
            '4. Klik tombol logout\n'
            '5. Konfirmasi proses logout\n'
            '\nHal yang Perlu Diperhatikan:\n'
            '• Data tersimpan otomatis\n'
            '• Akun dapat diakses kembali\n'
            '• Keamanan data terjamin\n'
            '\nTips Keamanan:\n'
            '• Selalu logout di perangkat umum\n'
            '• Gunakan logout di akhir sesi\n'
            '• Hindari logout di tempat tidak aman',
      ),

      // Kategori Lainnya
      const HelpItem(
        category: 'Lainnya',
        icon: Icons.support_agent_rounded,
        title: 'Kontak Dukungan',
        content: 'Hubungi tim dukungan:\n'
            '• Email: poliventapp@gmail.com\n'
            '• Telepon: +62 858-7622-1718\n'
            '• Jam layanan: 09.00-17.00 WIB',
      ),
      const HelpItem(
        category: 'Lainnya',
        icon: Icons.privacy_tip_rounded,
        title: 'Kebijakan Privasi',
        content: 'Informasi privasi:\n'
            '• Data pribadi dilindungi\n'
            '• Tidak menjual data\n'
            '• Enkripsi keamanan tinggi\n'
            '• Transparansi penggunaan data',
      ),
      const HelpItem(
        category: 'Lainnya',
        icon: Icons.info_rounded,
        title: 'Tentang Aplikasi',
        content: 'Informasi aplikasi:\n'
            '• Versi aplikasi: 1.0.0\n'
            '• Fitur terbaru: Scan absensi QR\n'
            '• Tim pengembang: Kelompok 2 PBL TI-2B\n'
            '• Sumber daya aplikasi',
      ),
    ];
  }

  void _filterHelpItems(String query) {
    setState(() {
      _filteredHelpItems = _allHelpItems.where((item) {
        final titleMatch =
            item.title.toLowerCase().contains(query.toLowerCase());
        final contentMatch =
            item.content.toLowerCase().contains(query.toLowerCase());
        final categoryMatch =
            _selectedCategory == 'Semua' || item.category == _selectedCategory;

        return (titleMatch || contentMatch) && categoryMatch;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: UIColor.solidWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black87,
            size: 24,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Pusat Bantuan',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
      ),
      body: Column(
        children: [
          // Bilah Pencarian
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari bantuan...',
                prefixIcon:
                    const Icon(Icons.search, color: UIColor.primaryColor),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear,
                            color: UIColor.primaryColor),
                        onPressed: () {
                          _searchController.clear();
                          _filterHelpItems('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: _filterHelpItems,
            ),
          ),

          // Kategori Scroll Horizontal
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: _categories.map((category) {
                  return HelpCategoryChip(
                    label: category,
                    isSelected: _selectedCategory == category,
                    onSelected: () {
                      setState(() {
                        _selectedCategory = category;
                        _filterHelpItems(_searchController.text);
                      });
                    },
                  );
                }).toList(),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // // Pertanyaan Populer
          // const PopularQuestionsSection(),

          // Daftar Bantuan
          Expanded(
            child: _filteredHelpItems.isNotEmpty
                ? ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: _filteredHelpItems.length,
                    itemBuilder: (context, index) {
                      return _filteredHelpItems[index];
                    },
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.help_outline_rounded,
                          size: 100,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Tidak ada hasil ditemukan',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),

          // Kontak Dukungan
          // SupportContactSection(),
        ],
      ),
    );
  }
}

class HelpItem extends StatelessWidget {
  final String category;
  final IconData icon;
  final String title;
  final String content;

  const HelpItem({
    super.key,
    required this.category,
    required this.icon,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Theme(
          data: ThemeData(dividerColor: Colors.transparent),
          child: ExpansionTile(
            leading: Icon(icon, color: UIColor.primaryColor),
            title: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  content,
                  style: const TextStyle(color: Colors.black54),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HelpCategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onSelected;

  const HelpCategoryChip({
    super.key,
    required this.label,
    this.isSelected = false,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSelected,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? UIColor.primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          // boxShadow: const [
          //   BoxShadow(
          //     color: Colors.black12,
          //     blurRadius: 4,
          //     // offset: Offset(0, 2),
          //   ),
          // ],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class PopularQuestionsSection extends StatelessWidget {
  const PopularQuestionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              'Pertanyaan Populer',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: UIColor.primaryColor,
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                PopularQuestionChip(
                  question: 'Cara Daftar Event',
                  onTap: () {
                    // Navigasi atau fokus ke item bantuan tertentu
                  },
                ),
                PopularQuestionChip(
                  question: 'Pembatalan Tiket',
                  onTap: () {},
                ),
                // Tambahkan pertanyaan populer lainnya
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PopularQuestionChip extends StatelessWidget {
  final String question;
  final VoidCallback onTap;

  const PopularQuestionChip({
    super.key,
    required this.question,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          question,
          style: const TextStyle(
            color: UIColor.primaryColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

// class SupportContactSection extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.all(16),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black12,
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Butuh Bantuan Lebih Lanjut?',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: UIColor.primaryColor,
//             ),
//           ),
//           const SizedBox(height: 12),
//           Row(
//             children: [
//               Icon(Icons.support_agent, color: UIColor.primaryColor),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Text(
//                   'Tim Dukungan Kami Siap Membantu',
//                   style: TextStyle(
//                     color: Colors.black87,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ),
//               ElevatedButton(
//                 onPressed: () {
//                   // Implementasi kontak langsung (chat/telepon)
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: UIColor.primaryColor,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                 ),
//                 child: const Text('Hubungi Sekarang'),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

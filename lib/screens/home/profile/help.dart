import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Bantuan',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Tambahkan fungsi pencarian
            },
          ),
        ],
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: const [
          HelpItem(
            title: 'Bagaimana cara mengatur ulang kata sandi saya?',
            content:
                'Jika Anda lupa kata sandi, klik tautan "Lupa Kata Sandi" di layar login. '
                'Masukkan alamat email Anda dan ikuti petunjuk untuk mengatur ulang kata sandi Anda.',
          ),
          HelpItem(
            title: 'Bagaimana cara menghubungi dukungan?',
            content:
                'Jika Anda memerlukan bantuan, Anda dapat menghubungi tim dukungan kami dengan mengklik tombol "Hubungi Kami" '
                'di aplikasi. Anda juga dapat mengirim email ke support@polivent.com.',
          ),
          HelpItem(
            title: 'Bagaimana cara memperbarui profil saya?',
            content:
                'Untuk memperbarui profil Anda, buka layar "Pengaturan" dan klik "Edit Profil". '
                'Lakukan perubahan yang diperlukan dan simpan pembaruan Anda.',
          ),
          HelpItem(
            title: 'Bagaimana cara mengaktifkan notifikasi?',
            content:
                'Untuk mengaktifkan notifikasi, buka layar "Pengaturan" dan klik "Notifikasi". '
                'Alihkan sakelar untuk mengaktifkan atau menonaktifkan notifikasi sesuai preferensi Anda.',
          ),
          HelpItem(
            title: 'Bagaimana cara menghapus akun saya?',
            content:
                'Jika Anda ingin menghapus akun Anda, silakan hubungi tim dukungan kami di support@polivent.com. '
                'Mereka akan membantu Anda dengan proses penghapusan akun.',
          ),
        ],
      ),
      
    );
  }
}

class HelpItem extends StatelessWidget {
  final String title;
  final String content;

  const HelpItem({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ExpansionTile(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Divider(
                  height: 2,
                  thickness: 2,
                  color: Colors.black26,
                ),
              ],
            ),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Text(
                  content,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

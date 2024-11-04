import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

class BagianKomentar extends StatefulWidget {
  const BagianKomentar({Key? key}) : super(key: key);

  @override
  BagianKomentarState createState() => BagianKomentarState();
}

class BagianKomentarState extends State<BagianKomentar> {
  final List<Map<String, dynamic>> komentar = [
    {
      "id": "1",
      "pengguna": "John Doe",
      "urlFotoProfil": "https://i.pravatar.cc/150?img=1",
      "teks": "Postingan ini sangat menarik! Kontennya sangat membantu.",
      "suka": 24,
      "disukai": false,
      "waktu": DateTime.now().subtract(const Duration(hours: 2)),
      "balasan": [
        {
          "id": "1.1",
          "pengguna": "Jane Smith",
          "urlFotoProfil": "https://i.pravatar.cc/150?img=2",
          "teks": "Saya sangat setuju dengan Anda!",
          "suka": 12,
          "disukai": false,
          "waktu": DateTime.now().subtract(const Duration(hours: 1)),
        },
        // Tambahkan lebih banyak balasan di sini untuk pengujian
      ]
    },
    // Tambahkan lebih banyak komentar di sini
  ];

  final TextEditingController _kontrolerKomentar = TextEditingController();
  final ScrollController _kontrolerScroll = ScrollController();
  bool _sedangMembalas = false;
  String _membalasKe = "";
  String _idYangDibalas = "";

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Kolom input komentar di bagian atas
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(25),
            ),
            child: Row(
              children: [
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    backgroundImage:
                        NetworkImage("https://i.pravatar.cc/150?img=3"),
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: _kontrolerKomentar,
                    decoration: InputDecoration(
                      hintText: _sedangMembalas
                          ? 'Balas ke ${_membalasKe}...'
                          : 'Tulis komentar...',
                      border: InputBorder.none,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 15),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send_rounded),
                  color: Colors.blue,
                  onPressed: _kirimKomentar,
                ),
              ],
            ),
          ),
        ),

        // Daftar komentar
        ListView.builder(
          shrinkWrap: true,
          controller: _kontrolerScroll,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: komentar.length,
          itemBuilder: (context, index) {
            final komen = komentar[index];
            return Column(
              children: [
                _buatTileKomentar(komen),
                if (komen['balasan'] != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 50.0),
                    child: _buatDaftarBalasan(komen['balasan'], komen['id']),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buatDaftarBalasan(List<dynamic> balasan, String idInduk) {
    if (balasan.length <= 2) {
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: balasan.length,
        itemBuilder: (context, index) {
          return _buatTileKomentar(balasan[index],
              adalahBalasan: true, idInduk: idInduk);
        },
      );
    } else {
      return Column(
        children: [
          _buatTileKomentar(balasan[0], adalahBalasan: true, idInduk: idInduk),
          _buatTileKomentar(balasan[1], adalahBalasan: true, idInduk: idInduk),
          ExpansionTile(
            title: Text('Lihat ${balasan.length - 2} balasan lainnya'),
            children: balasan.sublist(2).map((balasan) {
              return _buatTileKomentar(balasan,
                  adalahBalasan: true, idInduk: idInduk);
            }).toList(),
          ),
        ],
      );
    }
  }

  void _kirimKomentar() {
    if (_kontrolerKomentar.text.isNotEmpty) {
      setState(() {
        if (_sedangMembalas) {
          _tambahBalasan();
        } else {
          _tambahKomentarBaru();
        }
        _kontrolerKomentar.clear();
        _sedangMembalas = false;
      });
    }
  }

  void _tambahKomentarBaru() {
    komentar.insert(0, {
      "id": DateTime.now().toString(),
      "pengguna": "Pengguna Saat Ini",
      "urlFotoProfil": "https://i.pravatar.cc/150?img=3",
      "teks": _kontrolerKomentar.text,
      "suka": 0,
      "disukai": false,
      "waktu": DateTime.now(),
      "balasan": [],
    });
  }

  void _tambahBalasan() {
    final balasanBaru = {
      "id": "${_idYangDibalas}.${DateTime.now().millisecondsSinceEpoch}",
      "pengguna": "Pengguna Saat Ini",
      "urlFotoProfil": "https://i.pravatar.cc/150?img=3",
      "teks": _kontrolerKomentar.text,
      "suka": 0,
      "disukai": false,
      "waktu": DateTime.now(),
    };

    for (var komen in komentar) {
      if (komen['id'] == _idYangDibalas) {
        komen['balasan'].add(balasanBaru);
        return;
      }
      for (var balasan in komen['balasan']) {
        if (balasan['id'] == _idYangDibalas) {
          komen['balasan'].add(balasanBaru);
          return;
        }
      }
    }
  }

  Widget _buatTileKomentar(Map<String, dynamic> komen,
      {bool adalahBalasan = false, String? idInduk}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: InkWell(
        onTap: () {
          _kontrolerScroll.animateTo(
            _kontrolerScroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
          FocusScope.of(context).requestFocus(FocusNode());
          setState(() {
            _sedangMembalas = true;
            _membalasKe = komen['pengguna'];
            _idYangDibalas = komen['id'];
          });
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(komen['urlFotoProfil']),
              radius: adalahBalasan ? 15 : 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        komen['pengguna'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        timeago.format(komen['waktu']),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(komen['teks']),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      InkWell(
                        onTap: () {
                          setState(() {
                            komen['disukai'] = !komen['disukai'];
                            if (komen['disukai']) {
                              komen['suka']++;
                            } else {
                              komen['suka']--;
                            }
                          });
                        },
                        child: Icon(
                          komen['disukai']
                              ? Icons.favorite
                              : Icons.favorite_border,
                          size: 16,
                          color: komen['disukai'] ? Colors.red : Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${komen['suka']}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 16),
                      InkWell(
                        onTap: () {
                          setState(() {
                            _sedangMembalas = true;
                            _membalasKe = komen['pengguna'];
                            _idYangDibalas = komen['id'];
                            // Focus the text field
                            FocusScope.of(context).requestFocus(FocusNode());
                          });
                        },
                        child: Text(
                          'Balas',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

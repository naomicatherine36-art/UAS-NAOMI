import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'login.dart'; 

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late Future<List<dynamic>> _futureCatatan;

  @override
  void initState() {
    super.initState();
    _futureCatatan = getCatatanMusik(); 
  }

  void refreshData() {
    setState(() {
      _futureCatatan = getCatatanMusik();
    });
  }

  // ==================== AMBIL DATA (GET) ====================
  Future<List<dynamic>> getCatatanMusik() async {
    // Menggunakan IP 10.0.2.2 untuk Android Emulator
    final url = Uri.parse('http://10.0.2.2/catatan_musik/catatan_musik.php');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data;
      } else {
        throw Exception('Gagal memuat data (Kode: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Gagal terhubung ke server: $e');
    }
  }

  // ==================== SIMPAN DATA BARU (POST) ====================
  Future<void> simpanCatatanMusik(String namaLagu, String durasi) async {
    final url = Uri.parse('http://10.0.2.2/catatan_musik/catatan_musik.php');
    try {
      final response = await http.post(url, body: {
        'nama_lagu': namaLagu,
        'durasi': durasi,
      });

      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        if (result['status'] == 'success') {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Catatan Musik Berhasil Disimpan!'), backgroundColor: Colors.green),
          );
          refreshData(); 
        } else {
          throw Exception(result['message'] ?? 'Gagal menyimpan');
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal Menyimpan: $e'), backgroundColor: Colors.red),
      );
    }
  }

  // ==================== EDIT DATA (POST dengan Action) ====================
  Future<void> editCatatanMusik(String id, String namaLagu, String durasi) async {
    final url = Uri.parse('http://10.0.2.2/catatan_musik/catatan_musik.php?action=edit');
    try {
      final response = await http.post(url, body: {
        'id': id,
        'nama_lagu': namaLagu,
        'durasi': durasi,
      });

      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        if (result['status'] == 'success') {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Catatan Musik Berhasil Diubah!'), backgroundColor: Colors.blue),
          );
          refreshData(); 
        } else {
          throw Exception(result['message'] ?? 'Gagal mengubah data');
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal Mengubah Catatan: $e'), backgroundColor: Colors.red),
      );
    }
  }

  // ==================== HAPUS DATA (POST dengan Action) ====================
  Future<void> hapusCatatanMusik(String id) async {
    final url = Uri.parse('http://10.0.2.2/catatan_musik/catatan_musik.php?action=delete');
    try {
      final response = await http.post(url, body: {
        'id': id,
      });

      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        if (result['status'] == 'success') {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Catatan Musik Berhasil Dihapus!'), backgroundColor: Colors.red),
          );
          refreshData(); 
        } else {
          throw Exception(result['message'] ?? 'Gagal menghapus data');
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal Menhapus Catatan: $e'), backgroundColor: Colors.red),
      );
    }
  }
  
  // ==================== FORM POP-UP (TAMBAH / EDIT) ====================
  void tampilkanForm(BuildContext context, {Map<String, dynamic>? dataLama}) {
    final TextEditingController _namaLaguController = TextEditingController();
    final TextEditingController _durasiController = TextEditingController();
    bool isEdit = dataLama != null;

    if (isEdit) {
      _namaLaguController.text = dataLama['nama_lagu'] ?? '';
      _durasiController.text = dataLama['durasi']?.toString() ?? '';
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFF4EAE1), 
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 20, left: 20, right: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEdit ? 'Edit Catatan Latihan' : 'Tambah Catatan Latihan', 
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF5C4033))
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _namaLaguController,
                decoration: const InputDecoration(
                  labelText: 'Nama Lagu / Materi',
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF5C4033))),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _durasiController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Durasi (Menit)',
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF5C4033))),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5C4033), 
                  foregroundColor: const Color(0xFFF4EAE1),
                  minimumSize: const Size(double.infinity, 45),
                ),
                onPressed: () {
                  if (_namaLaguController.text.isNotEmpty && _durasiController.text.isNotEmpty) {
                    if (isEdit) {
                      editCatatanMusik(dataLama['id'].toString(), _namaLaguController.text, _durasiController.text);
                    } else {
                      simpanCatatanMusik(_namaLaguController.text, _durasiController.text);
                    }
                    Navigator.pop(context); 
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Data tidak boleh kosong!')));
                  }
                },
                child: Text(isEdit ? 'PERBARUI CATATAN' : 'SIMPAN CATATAN', style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  // ==================== DIALOG KONFIRMASI HAPUS ====================
  void konfirmasiHapus(String id, String namaLagu) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Catatan?'),
        content: Text('Apakah Anda yakin ingin menghapus catatan lagu "$namaLagu"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              hapusCatatanMusik(id);
            }, 
            child: const Text('Hapus', style: TextStyle(color: Colors.red))
          ),
        ],
      ),
    );
  }

  // ==================== TAMPILAN HALAMAN UTAMA ====================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4EAE1),
      appBar: AppBar(
        title: const Text('Catatan Latihan Musik', style: TextStyle(color: Color(0xFFF4EAE1), fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF5C4033),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFFF4EAE1)),
            onPressed: () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Login()));
            },
          )
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _futureCatatan,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF5C4033)));
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('${snapshot.error}', textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Belum ada catatan musik.', style: TextStyle(fontStyle: FontStyle.italic)));
          }

          List<dynamic> listData = snapshot.data!;
          return ListView.builder(
            itemCount: listData.length,
            itemBuilder: (context, index) {
              var catatan = listData[index];
              return Card(
                color: const Color(0xFFFFFDF9),
                margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                child: ListTile(
                  leading: const Icon(Icons.library_music, color: Color(0xFF5C4033)),
                  title: Text(catatan['nama_lagu'] ?? '-', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF5C4033))),
                  subtitle: Text('Durasi: ${catatan['durasi'] ?? '0'} Menit | Tanggal: ${catatan['tanggal'] ?? '-'}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => tampilkanForm(context, dataLama: catatan),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => konfirmasiHapus(catatan['id'].toString(), catatan['nama_lagu'] ?? ''),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => tampilkanForm(context),
        backgroundColor: const Color(0xFF5C4033),
        child: const Icon(Icons.add, color: Color(0xFFF4EAE1)),
      ),
    );
  }
}
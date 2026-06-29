import 'dart:convert';
import 'package:http/http.dart' as http;

class DbHelper {
  // ==================== FUNGSI REGISTER BARU ====================
  // Hanya menambahkan fungsi ini untuk mendaftarkan akun baru via PHP
  Future<void> tambahUser(String username, String password) async {
    final url = Uri.parse('http://10.0.2.2/catatan_musik/catatan_musik.php?action=register');
    try {
      final response = await http.post(url, body: {
        'username': username,
        'password': password,
      });

      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        if (result['status'] != 'success') {
          throw Exception(result['message'] ?? 'Gagal mendaftarkan akun');
        }
      } else {
        throw Exception('Server error dengan kode: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Gagal terhubung ke server: $e');
    }
  }

  // ==================== FUNGSI CEK LOGIN ====================
  // Menambahkan fungsi cekLogin agar menyambung ke fungsi prosesLogin di file login.dart
  Future<bool> cekLogin(String username, String password) async {
    final url = Uri.parse('http://10.0.2.2/catatan_musik/catatan_musik.php?action=login');
    try {
      final response = await http.post(url, body: {
        'username': username,
        'password': password,
      });

      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        return result['status'] == 'success';
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
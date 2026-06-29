import 'package:flutter/material.dart';
import 'db_helper.dart'; 
import 'mainPage.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final DbHelper _dbHelper = DbHelper(); 
  bool _isLoading = false;

  // ==================== FUNGSI PROSES LOGIN ====================
  Future<void> prosesLogin() async {
    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username dan Password wajib diisi!'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Memanggil fungsi cekLogin asli dari db_helper kamu
      bool loginSukses = await _dbHelper.cekLogin(username, password); 

      if (loginSukses) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login Berhasil! Welcome!'), backgroundColor: Colors.green),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainPage()),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Username atau Password salah!'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal Login: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ==================== POP-UP DIALOG REGISTER (TERHUBUNG KE XAMPP) ====================
  void tampilkanDialogRegister() {
    final TextEditingController _regUsernameController = TextEditingController();
    final TextEditingController _regPasswordController = TextEditingController();
    bool _isRegistering = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: const Color(0xFFF4EAE1),
            title: const Text(
              'Daftar Akun Baru', 
              style: TextStyle(color: Color(0xFF5C4033), fontWeight: FontWeight.bold)
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _regUsernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username Baru',
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF5C4033))),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _regPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password Baru',
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF5C4033))),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: _isRegistering ? null : () => Navigator.pop(context),
                child: const Text('Batal', style: TextStyle(color: Colors.grey)),
              ),
              _isRegistering
                  ? const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Color(0xFF5C4033), strokeWidth: 2),
                      ),
                    )
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF5C4033)),
                      onPressed: () async {
                        String user = _regUsernameController.text.trim();
                        String pass = _regPasswordController.text.trim();

                        if (user.isEmpty || pass.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Semua kolom wajib diisi!'), backgroundColor: Colors.orange),
                          );
                          return;
                        }

                        setDialogState(() {
                          _isRegistering = true;
                        });

                        try {
                          // Memanggil fungsi tambahUser asli dari db_helper kamu ke XAMPP
                          await _dbHelper.tambahUser(user, pass); 
                          
                          if (!mounted) return;
                          Navigator.pop(context); // Tutup pop-up jika sukses
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Akun berhasil terdaftar! Silakan Login.'), backgroundColor: Colors.green),
                          );
                        } catch (e) {
                          // Menampilkan error jika XAMPP menolak atau tidak merespons
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Gagal: ${e.toString().replaceAll('Exception: ', '')}'), backgroundColor: Colors.red),
                          );
                        } finally {
                          setDialogState(() {
                            _isRegistering = false;
                          });
                        }
                      },
                      child: const Text('Daftar', style: TextStyle(color: Color(0xFFF4EAE1), fontWeight: FontWeight.bold)),
                    ),
            ],
          );
        }
      ),
    );
  }

  // ==================== TAMPILAN HALAMAN LOGIN ====================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4EAE1), 
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Gambar Musik Vinyl
              SizedBox(
                width: 350,  
                height: 300, 
                child: Image.asset(
                  'assets/vinyl.png',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.album, 
                      size: 100, 
                      color: Color(0xFF5C4033)
                    );
                  },
                ),
              ),
              const SizedBox(height: 25),
              
              const Text(
                'SIGN IN',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5C4033),
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 30),

              // Input Username
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  prefixIcon: Icon(Icons.person, color: Color(0xFF5C4033)),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF5C4033), width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Input Password
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock, color: Color(0xFF5C4033)),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF5C4033), width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 35),

              // Tombol Login
              _isLoading
                  ? const CircularProgressIndicator(color: Color(0xFF5C4033))
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5C4033),
                        foregroundColor: const Color(0xFFF4EAE1),
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: prosesLogin,
                      child: const Text(
                        'LOGIN',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
              const SizedBox(height: 25),

              // ✨ TOMBOL REGISTER PILIHAN DAFTAR AKUN ✨
              TextButton(
                onPressed: tampilkanDialogRegister, // Membuka kotak pop-up register
                child: const Text(
                  'Belum punya akun? Daftar di sini',
                  style: TextStyle(
                    color: Color(0xFF5C4033), 
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
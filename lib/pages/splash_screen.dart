import 'dart:async';
import 'package:flutter/material.dart';
import 'login_page.dart';
import '../database/db_helper.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _startApp();
  }

  // Fungsi untuk menjalankan logika sebelum pindah halaman
  void _startApp() async {
    // === OPTIONAL: Preload data atau cek status login di sini ===
    // Contoh: menunggu inisialisasi database
    await DBHelper.instance.database; // Pastikan database siap
    // await Future.delayed(const Duration(seconds: 1)); // Tambahan delay jika perlu

    // Cek status login (jika ada logika shared preferences)
    // final prefs = await SharedPreferences.getInstance();
    // final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    // Jika ingin langsung ke UserPage jika sudah login
    // if (isLoggedIn) {
    //   final userId = prefs.getInt('userId');
    //   final user = await DBHelper.instance.getUserById(userId);
    //   if (user != null) {
    //     Navigator.pushReplacement(
    //       context,
    //       MaterialPageRoute(builder: (context) => UserPage(user: user)),
    //     );
    //     return;
    //   }
    // }
    // =============================================================

    // Setelah 3 detik (atau setelah preload data selesai), pindah ke halaman login
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Background putih bersih
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon Buku Terbuka yang modern untuk E-book
            Image.asset(
              'assets/book_icon.png', // Ganti dengan path gambar ikon bukumu
              width: 120,
              height: 120,
            ),
            // Jika tidak ada gambar, bisa pakai Icon dari Flutter:
            // const Icon(
            //   Icons.auto_stories, // Atau Icons.book_open_sharp, Icons.library_books
            //   size: 100,
            //   color: Colors.blueAccent,
            // ),
            const SizedBox(height: 20),
            // Nama Aplikasi
            const Text(
              "Perpustakaan Digital",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey, // Warna teks modern
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Baca, Belajar, Berkembang.",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 40),
            // Indikator Loading
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                Colors.blueAccent,
              ), // Warna loading
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login_page.dart';
import '../database/db_helper.dart';
import '../models/item.dart';
import '../models/user.dart';

// ====================== HALAMAN USER ======================
class UserPage extends StatefulWidget {
  final User user;

  const UserPage({Key? key, required this.user}) : super(key: key);

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  int _currentIndex = 0;

  List<Item> books = [];
  List<Item> history = [];
  List<Item> bookmarks = [];

  @override
  void initState() {
    super.initState();
    loadBooks();
  }

  Future<void> loadBooks() async {
    books = await DBHelper.instance.getItems();
    setState(() {});
  }

  // ================== TAB DASHBOARD ==================
  Widget dashboardTab() {
    if (books.isEmpty) {
      return const Center(child: Text('Belum ada buku tersedia'));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.7,
      ),
      itemCount: books.length,
      itemBuilder: (_, i) {
        final book = books[i];
        return GestureDetector(
          onTap: () => navigateToBookDetail(book),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: book.coverPath != null
                      ? Image.file(
                          File(book.coverPath!),
                          height: 140,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        )
                      : const Icon(Icons.book, size: 100),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    children: [
                      Text(
                        book.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        book.author ?? 'Tidak Diketahui',
                        style: const TextStyle(fontSize: 12),
                      ),
                      Text(
                        book.year?.toString() ?? '-',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ================== TAB HISTORY ==================
  Widget historyTab() {
    if (history.isEmpty) {
      return const Center(child: Text('Belum ada history membaca'));
    }

    return ListView.builder(
      itemCount: history.length,
      itemBuilder: (_, i) {
        final book = history[i];
        return ListTile(
          leading: book.coverPath != null
              ? Image.file(File(book.coverPath!), width: 50, fit: BoxFit.cover)
              : const Icon(Icons.book),
          title: Text(book.title),
          subtitle: Text(book.author ?? 'Tidak Diketahui'),
          trailing: IconButton(
            icon: const Icon(Icons.delete, color: Colors.redAccent),
            onPressed: () {
              // MODEL POP UP KONFIRMASI KONSISTEN
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Hapus History?'),
                  content: Text(
                    'Apakah Anda yakin ingin menghapus "${book.title}" dari riwayat membaca?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Batal'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          // Menghapus dari history
                          history.removeAt(i);
                        });

                        Navigator.pop(context); // Tutup dialog

                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('History "${book.title}" dihapus'),
                            backgroundColor: Colors.redAccent,
                            duration: const Duration(seconds: 1),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      child: const Text('Ya, Hapus'),
                    ),
                  ],
                ),
              );
            },
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ReadBookPage(book: book)),
            );
          },
        );
      },
    );
  }

  // ================== TAB BOOKMARK ==================
  Widget bookmarkTab() {
    if (bookmarks.isEmpty) {
      return const Center(child: Text('Belum ada bookmark'));
    }
    return ListView.builder(
      itemCount: bookmarks.length,
      itemBuilder: (_, i) {
        final book = bookmarks[i];
        return ListTile(
          leading: book.coverPath != null
              ? Image.file(File(book.coverPath!), width: 50, fit: BoxFit.cover)
              : const Icon(Icons.bookmark),
          title: Text(book.title),
          subtitle: Text(book.author ?? 'Tidak Diketahui'),
          trailing: IconButton(
            icon: const Icon(Icons.bookmark_remove, color: Colors.redAccent),
            onPressed: () {
              // MODEL POP UP KONFIRMASI KONSISTEN
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Hapus Bookmark?'),
                  content: Text(
                    'Apakah Anda yakin ingin menghapus "${book.title}" dari daftar bookmark?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Batal'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          bookmarks.remove(book);
                        });

                        Navigator.pop(context); // Tutup dialog

                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '${book.title} dihapus dari bookmark',
                            ),
                            backgroundColor: Colors.redAccent,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      child: const Text('Ya, Hapus'),
                    ),
                  ],
                ),
              );
            },
          ),
          onTap: () => navigateToBookDetail(book),
        );
      },
    );
  }

  // ================== NAVIGASI DETAIL ==================
  void navigateToBookDetail(Item book) {
    setState(() {
      if (!history.contains(book)) {
        history.add(book);
      }
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BookDetailPage(book: book, bookmarks: bookmarks),
      ),
    );
  }

  // ================= TAB PROFIL USER =================
  Widget profilTab() {
    return FutureBuilder(
      future: DBHelper.instance.database,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        return FutureBuilder<List<Map<String, dynamic>>>(
          future: snapshot.data!.query(
            'users',
            where: 'id = ?',
            whereArgs: [widget.user.id], // ID dari user yang sedang login
          ),
          builder: (context, snap) {
            if (!snap.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final user = snap.data!.isNotEmpty ? snap.data!.first : null;
            if (user == null) {
              return const Center(child: Text('Profil tidak tersedia'));
            }

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Avatar
                    const CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.blueAccent,
                      child: Icon(Icons.person, size: 60, color: Colors.white),
                    ),
                    const SizedBox(height: 24),

                    // Card Profil
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user['nama'] ?? 'Nama Tidak Diketahui',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Divider(height: 30),

                            // NPM
                            _buildInfoRow(Icons.badge, 'NPM', user['npm']),
                            const SizedBox(height: 16),

                            // Program Studi
                            _buildInfoRow(Icons.school, 'Prodi', user['prodi']),
                            const SizedBox(height: 16),

                            // Email
                            _buildInfoRow(Icons.email, 'Email', user['email']),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Tombol Logout
                    // Tombol Logout
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // MODEL POP UP KONFIRMASI KONSISTEN
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Konfirmasi Logout'),
                              content: const Text(
                                'Apakah Anda yakin ingin keluar dari akun ini?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Batal'),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.redAccent,
                                    foregroundColor: Colors.white,
                                  ),
                                  onPressed: () {
                                    Navigator.pop(context); // Tutup dialog

                                    // Pindah ke halaman Login dan hapus semua history navigasi
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const LoginPage(),
                                      ),
                                    );
                                  },
                                  child: const Text('Ya, Logout'),
                                ),
                              ],
                            ),
                          );
                        },
                        icon: const Icon(Icons.logout, color: Colors.white),
                        label: const Text(
                          'Logout',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.redAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Helper widget agar kode lebih bersih
  Widget _buildInfoRow(IconData icon, String label, dynamic value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            Text(
              (value == null || value.toString().isEmpty)
                  ? '-'
                  : value.toString(),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [dashboardTab(), historyTab(), bookmarkTab(), profilTab()];

    final titles = ['Dashboard', 'History', 'Bookmark', 'Profil'];

    return Scaffold(
      appBar: AppBar(title: Text(titles[_currentIndex])),
      body: IndexedStack(index: _currentIndex, children: pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        // --- TAMBAHKAN BARIS DI BAWAH INI ---
        type: BottomNavigationBarType
            .fixed, // Mencegah perubahan warna otomatis jika > 3 item
        selectedItemColor: Colors.blue, // Warna saat dipilih
        unselectedItemColor: Colors.grey, // Warna saat tidak dipilih
        backgroundColor: Colors.white, // Pastikan background kontras
        // ------------------------------------
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),
            label: 'Bookmark',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}

// ====================== DETAIL BUKU ======================
class BookDetailPage extends StatefulWidget {
  final Item book;
  final List<Item> bookmarks;

  const BookDetailPage({
    super.key,
    required this.book,
    required this.bookmarks,
  });

  @override
  State<BookDetailPage> createState() => _BookDetailPageState();
}

class _BookDetailPageState extends State<BookDetailPage> {
  late bool isBookmarked;

  @override
  void initState() {
    super.initState();
    isBookmarked = widget.bookmarks.contains(widget.book);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.book.title)),
      body: SingleChildScrollView(
        // Menambahkan padding atas agar tidak "nyundul" AppBar
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
        child: Column(
          children: [
            // Bagian Sampul Buku
            widget.book.coverPath != null
                ? Image.file(
                    File(widget.book.coverPath!),
                    height: 250,
                    fit: BoxFit.contain, // Agar gambar tidak terpotong
                  )
                : const Icon(Icons.book, size: 120),

            const SizedBox(height: 24), // Jarak yang lebih pas

            Text(
              widget.book.title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              widget.book.author ?? 'Tidak Diketahui',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),

            const SizedBox(height: 20),

            Text(
              widget.book.description ?? 'Tidak ada deskripsi',
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 40), // Jarak sebelum masuk ke barisan tombol
            // MENYUSUN TOMBOL SECARA VERTIKAL
            Column(
              children: [
                // Tombol Baca Buku
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.menu_book),
                    label: const Text(
                      'Baca Buku',
                      style: TextStyle(fontSize: 16),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ReadBookPage(book: widget.book),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 12),

                // Tombol Bookmark
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      side: BorderSide(
                        color: isBookmarked ? Colors.redAccent : Colors.blue,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: Icon(
                      isBookmarked ? Icons.bookmark_remove : Icons.bookmark_add,
                      color: isBookmarked ? Colors.redAccent : Colors.blue,
                    ),
                    label: Text(
                      isBookmarked ? 'Hapus Bookmark' : 'Tambah Bookmark',
                      style: TextStyle(
                        fontSize: 16,
                        color: isBookmarked ? Colors.redAccent : Colors.blue,
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        if (isBookmarked) {
                          widget.bookmarks.remove(widget.book);
                          isBookmarked = false;
                        } else {
                          widget.bookmarks.add(widget.book);
                          isBookmarked = true;
                        }
                      });

                      // SnackBar tetap tampil konsisten
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isBookmarked
                                ? "Ditambahkan ke Bookmark"
                                : "${widget.book.title} dihapus dari bookmark",
                          ),
                          duration: const Duration(seconds: 1),
                          backgroundColor: isBookmarked
                              ? Colors.blue
                              : Colors.redAccent,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ====================== HALAMAN BACA PDF ======================
class ReadBookPage extends StatefulWidget {
  final Item book;

  const ReadBookPage({super.key, required this.book});

  @override
  State<ReadBookPage> createState() => _ReadBookPageState();
}

class _ReadBookPageState extends State<ReadBookPage> {
  // Controller untuk mengontrol PDF (lompat halaman, dll)
  final PdfViewerController _pdfViewerController = PdfViewerController();
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();

  @override
  void initState() {
    super.initState();
  }

  // Fungsi untuk menyimpan halaman ke memori HP
  Future<void> _saveLastPage(int pageNumber) async {
    final prefs = await SharedPreferences.getInstance();
    // Gunakan ID buku sebagai kunci agar halaman tidak tertukar dengan buku lain
    await prefs.setInt('last_page_${widget.book.id}', pageNumber);
  }

  // Fungsi untuk mengambil halaman terakhir yang disimpan
  Future<void> _loadLastPage() async {
    final prefs = await SharedPreferences.getInstance();
    // Jika data sudah dihapus, defaultnya adalah null
    int? lastPage = prefs.getInt('last_page_${widget.book.id}');

    if (lastPage != null && lastPage > 1) {
      // Hanya melompat jika data ada dan bukan halaman pertama
      _pdfViewerController.jumpToPage(lastPage);
    } else {
      // Jika data null (setelah di-delete dari history), tetap di halaman 1
      _pdfViewerController.jumpToPage(1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.book.title),
        actions: [
          // Tombol opsional untuk cek status halaman
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 15),
              child: Text("Hal: ${_pdfViewerController.pageNumber}"),
            ),
          ),
        ],
      ),
      body: widget.book.pdfPath != null
          ? SfPdfViewer.file(
              File(widget.book.pdfPath!),
              controller: _pdfViewerController,
              key: _pdfViewerKey,
              // Event ketika dokumen berhasil dimuat
              onDocumentLoaded: (PdfDocumentLoadedDetails details) {
                _loadLastPage(); // Panggil fungsi lompat halaman
              },
              // Event setiap kali halaman berubah
              onPageChanged: (PdfPageChangedDetails details) {
                _saveLastPage(details.newPageNumber); // Simpan halaman baru
              },
            )
          : const Center(child: Text('File PDF tidak tersedia')),
    );
  }
}

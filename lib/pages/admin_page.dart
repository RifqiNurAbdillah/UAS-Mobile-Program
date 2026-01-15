import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/item.dart';
import 'login_page.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _HomePageState();
}

class _HomePageState extends State<AdminPage> {
  int _currentIndex = 0;

  List<Item> items = [];
  final titleController = TextEditingController();
  final authorController = TextEditingController();
  final yearController = TextEditingController();
  final descController = TextEditingController();
  PlatformFile? pickedPDF;
  File? pickedCover;

  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    items = await DBHelper.instance.getItems();
    setState(() {});
  }

  void showForm({Item? item}) {
    // ===== SET DATA AWAL =====
    if (item != null) {
      titleController.text = item.title;
      authorController.text = item.author ?? '';
      yearController.text = item.year?.toString() ?? '';
      descController.text = item.description;

      pickedPDF = item.pdfPath != null
          ? PlatformFile(
              name: item.pdfPath!.split('/').last,
              path: item.pdfPath!,
              size: File(item.pdfPath!).lengthSync(),
            )
          : null;

      pickedCover = item.coverPath != null ? File(item.coverPath!) : null;
    } else {
      titleController.clear();
      authorController.clear();
      yearController.clear();
      descController.clear();
      pickedPDF = null;
      pickedCover = null;
    }

    // ===== DIALOG =====
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(item == null ? 'Tambah Buku' : 'Edit Buku'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Judul Buku',
                      ),
                    ),
                    TextField(
                      controller: authorController,
                      decoration: const InputDecoration(labelText: 'Pengarang'),
                    ),
                    TextField(
                      controller: yearController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Tahun Terbit',
                      ),
                    ),
                    TextField(
                      controller: descController,
                      decoration: const InputDecoration(labelText: 'Deskripsi'),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 12),

                    // ===== UPLOAD PDF =====
                    ElevatedButton.icon(
                      onPressed: () async {
                        final result = await FilePicker.platform.pickFiles(
                          type: FileType.custom,
                          allowedExtensions: ['pdf'],
                        );
                        if (result != null) {
                          setDialogState(() {
                            pickedPDF = result.files.first;
                          });
                        }
                      },
                      icon: const Icon(Icons.upload_file),
                      label: Text(
                        pickedPDF == null ? 'Upload PDF' : pickedPDF!.name,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    const SizedBox(height: 10),

                    // ===== UPLOAD COVER =====
                    ElevatedButton.icon(
                      onPressed: () async {
                        final XFile? image = await _imagePicker.pickImage(
                          source: ImageSource.gallery,
                        );
                        if (image != null) {
                          setDialogState(() {
                            pickedCover = File(image.path);
                          });
                        }
                      },
                      icon: const Icon(Icons.image),
                      label: Text(
                        pickedCover == null
                            ? 'Upload Cover'
                            : pickedCover!.path.split('/').last,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    if (pickedCover != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Image.file(
                          pickedCover!,
                          height: 140,
                          fit: BoxFit.cover,
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final title = titleController.text.trim();
                    final author = authorController.text.trim();
                    final year = int.tryParse(yearController.text);
                    final desc = descController.text.trim();

                    // 1. Validasi Judul Buku
                    if (title.isEmpty) {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Data Belum Lengkap'),
                          content: const Text(
                            'Judul Buku wajib diisi, silahkan isi Kolom Judul atau Batal Jika Tidak Mengisi Buku.',
                          ),
                          actions: [
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              style: ElevatedButton.styleFrom(
                                shape: const StadiumBorder(),
                              ),
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                      return; // Berhenti
                    }

                    // 2. Validasi PDF (E-Book)
                    if (pickedPDF == null) {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('File Belum Ada'),
                          content: const Text(
                            'Silakan upload file PDF (E-Book) terlebih dahulu.',
                          ),
                          actions: [
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              style: ElevatedButton.styleFrom(
                                shape: const StadiumBorder(),
                              ),
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                      return; // Berhenti
                    }

                    // 3. Validasi Cover
                    if (pickedCover == null) {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Cover Kosong'),
                          content: const Text(
                            'Silakan pilih gambar cover untuk buku ini.',
                          ),
                          actions: [
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              style: ElevatedButton.styleFrom(
                                shape: const StadiumBorder(),
                              ),
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                      return; // Berhenti
                    }

                    // Jika semua sudah terisi, baru jalankan simpan ke database
                    if (item == null) {
                      await DBHelper.instance.insertItem(
                        Item(
                          title: title,
                          author: author,
                          year: year,
                          description: desc,
                          pdfPath: pickedPDF?.path,
                          coverPath: pickedCover?.path,
                        ),
                      );
                    } else {
                      await DBHelper.instance.updateItem(
                        Item(
                          id: item.id,
                          title: title,
                          author: author,
                          year: year,
                          description: desc,
                          pdfPath: pickedPDF?.path,
                          coverPath: pickedCover?.path,
                        ),
                      );
                    }

                    Navigator.pop(context); // Tutup form
                    loadData(); // Refresh list
                  },
                  child: const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> pickPDFFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null) {
      setState(() {
        pickedPDF = result.files.first;
      });
    }
  }

  Future<void> pickCoverImage() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
    );
    if (image != null) {
      setState(() {
        pickedCover = File(image.path);
      });
    }
  }

  // ================= TAB HOME UI =================
  Widget homeTab() {
    return Stack(
      children: [
        GridView.builder(
          padding: const EdgeInsets.all(10),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Menampilkan dua kolom
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.7, // Rasio aspek antara lebar dan tinggi item
          ),
          itemCount: items.length,
          itemBuilder: (_, i) {
            final item = items[i];
            return GestureDetector(
              onTap: () {
                // Navigasi ke halaman Detail Buku
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => BookDetailPage(item: item)),
                );
              },
              child: Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    // Sampul Buku dengan padding dan ukuran
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: item.coverPath != null
                          ? Image.file(
                              File(item.coverPath!),
                              height: 160,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            )
                          : Icon(Icons.book, size: 100, color: Colors.grey),
                    ),
                    // Bagian bawah untuk informasi buku
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.author ?? "Tidak Diketahui",
                            style: TextStyle(fontSize: 12),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.year?.toString() ?? "Tidak Diketahui",
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            onPressed: () => showForm(),
            child: Icon(Icons.add, size: 24),
          ),
        ),
      ],
    );
  }

  // ================= TAB ANGGOTA =================
  Widget anggotaTab() {
    return FutureBuilder(
      future: DBHelper.instance.database,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        return FutureBuilder<List<Map<String, dynamic>>>(
          future: snapshot.data!.query('users'),
          builder: (context, snap) {
            if (!snap.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final users = snap.data!;
            if (users.isEmpty) {
              return const Center(child: Text('Belum ada anggota'));
            }
            return ListView.builder(
              itemCount: users.length,
              itemBuilder: (_, i) {
                final u = users[i];
                return ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(u['nama'] ?? '-'),
                  subtitle: Text('${u['npm']} • ${u['prodi']}'),
                  trailing: Text(u['kelas'] ?? '-'),
                );
              },
            );
          },
        );
      },
    );
  }

  // ================= TAB PROFIL ADMIN =================
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
            // Karena cuma 1 akun, kita ambil semua data atau pakai ID tetap
            where: 'role = ?',
            whereArgs: ['admin'],
          ),
          builder: (context, snap) {
            if (!snap.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            // Ambil data pertama dari hasil query
            final user = snap.data!.isNotEmpty ? snap.data!.first : null;

            if (user == null) {
              return const Center(child: Text('Profil Admin tidak ditemukan'));
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
                    // Avatar Admin
                    const CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.amber, // Warna beda untuk Admin
                      child: Icon(
                        Icons.admin_panel_settings,
                        size: 60,
                        color: Colors.white,
                      ),
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
                              user['nama'] ?? 'Administrator',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Divider(height: 30),

                            // Info Admin
                            _buildInfoRow(
                              Icons.person,
                              'Username',
                              user['username'] ?? 'admin',
                            ),
                            const SizedBox(height: 16),
                            _buildInfoRow(
                              Icons.email,
                              'Email',
                              user['email'] ?? 'admin@mail.com',
                            ),
                            const SizedBox(height: 16),
                            _buildInfoRow(
                              Icons.verified_user,
                              'Role',
                              user['role']?.toUpperCase() ?? 'ADMIN',
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Tombol Logout
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _showLogoutDialog(context);
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

  // Fungsi Dialog Logout yang Aman
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin keluar dari panel Admin?'),
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
              if (!mounted) return; // Cek mounted
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            },
            child: const Text('Ya, Logout'),
          ),
        ],
      ),
    );
  }

  // Helper Row
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.blueGrey),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [homeTab(), anggotaTab(), profilTab()];

    final titles = ['Dashboard Admin', 'Manajemen Anggota', 'Profil'];

    return Scaffold(
      appBar: AppBar(title: Text(titles[_currentIndex])),

      body: IndexedStack(index: _currentIndex, children: pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),

        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        showUnselectedLabels: true,

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, size: 24),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people, size: 24),
            label: 'Anggota',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, size: 24),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

class BookDetailPage extends StatelessWidget {
  final Item item; // Menyimpan data buku yang akan ditampilkan

  const BookDetailPage({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(item.title),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              // Navigasi ke halaman edit buku
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => EditBookPage(item: item)),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Menampilkan cover buku yang terpusat
              Center(
                child: item.coverPath != null
                    ? Image.file(
                        File(item.coverPath!),
                        height: 200,
                        fit: BoxFit.cover,
                      )
                    : Icon(Icons.book, size: 100, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              // Menampilkan detail buku
              Text(
                'Judul: ${item.title}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text('Pengarang: ${item.author ?? "Tidak Diketahui"}'),
              const SizedBox(height: 8),
              Text('Tahun Terbit: ${item.year ?? "Tidak Diketahui"}'),
              const SizedBox(height: 8),
              Text('Deskripsi:'),
              Text(item.description),
            ],
          ),
        ),
      ),
    );
  }
}

// ... (bagian awal AdminPage dan BookDetailPage tetap sama)

class EditBookPage extends StatefulWidget {
  final Item item;

  const EditBookPage({Key? key, required this.item}) : super(key: key);

  @override
  _EditBookPageState createState() => _EditBookPageState();
}

class _EditBookPageState extends State<EditBookPage> {
  final titleController = TextEditingController();
  final authorController = TextEditingController();
  final yearController = TextEditingController();
  final descController = TextEditingController();
  File? pickedCover;
  PlatformFile? pickedPDF;

  @override
  void initState() {
    super.initState();
    titleController.text = widget.item.title;
    authorController.text = widget.item.author ?? '';
    yearController.text = widget.item.year?.toString() ?? '';
    descController.text = widget.item.description;
    pickedCover = widget.item.coverPath != null
        ? File(widget.item.coverPath!)
        : null;
    pickedPDF = widget.item.pdfPath != null
        ? PlatformFile(
            name: widget.item.pdfPath!.split('/').last,
            path: widget.item.pdfPath!,
            size: File(widget.item.pdfPath!).lengthSync(),
          )
        : null;
  }

  // === FUNGSI DETEKSI PERUBAHAN ===
  bool _isChanged() {
    return titleController.text != widget.item.title ||
        authorController.text != (widget.item.author ?? '') ||
        yearController.text != (widget.item.year?.toString() ?? '') ||
        descController.text != widget.item.description ||
        pickedCover?.path != widget.item.coverPath ||
        pickedPDF?.path != widget.item.pdfPath;
  }

  Future<void> pickCoverImage() async {
    final ImagePicker _imagePicker = ImagePicker();
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
    );
    if (image != null) {
      setState(() {
        pickedCover = File(image.path);
      });
    }
  }

  Future<void> pickPDFFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null) {
      setState(() {
        pickedPDF = result.files.first;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Membungkus dengan PopScope untuk deteksi tombol 'Back'
    return PopScope(
      canPop: false, // Jangan langsung keluar
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        // Jika ada perubahan, minta konfirmasi batal
        if (_isChanged()) {
          final shouldPop = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Batal Edit?'),
              content: const Text(
                'Ada perubahan yang belum disimpan. Yakin ingin keluar?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Tidak'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Ya, Keluar'),
                ),
              ],
            ),
          );
          if (shouldPop ?? false) Navigator.pop(context);
        } else {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Edit Buku')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Sampul Buku
                Column(
                  children: [
                    pickedCover != null
                        ? Image.file(
                            pickedCover!,
                            height: 200,
                            fit: BoxFit.cover,
                          )
                        : const Icon(
                            Icons.image,
                            size: 100,
                            color: Colors.grey,
                          ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: pickCoverImage,
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit Cover'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Judul Buku'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: authorController,
                  decoration: const InputDecoration(labelText: 'Pengarang'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: yearController,
                  decoration: const InputDecoration(labelText: 'Tahun Terbit'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: 'Deskripsi'),
                  maxLines: 4,
                ),
                const SizedBox(height: 16),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: pickPDFFile,
                    icon: const Icon(Icons.upload_file),
                    label: Text(
                      pickedPDF == null ? 'Upload PDF' : pickedPDF!.name,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Tombol Simpan Perubahan dengan Dialog Konfirmasi
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () async {
                      // 1. Cek jika tidak ada perubahan
                      if (!_isChanged()) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Tidak ada perubahan data.'),
                          ),
                        );
                        return;
                      }

                      // 2. Munculkan Dialog Konfirmasi Simpan
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Simpan Perubahan?'),
                          content: const Text(
                            'Apakah Anda yakin data yang dimasukkan sudah benar?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Batal'),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                final updatedBook = Item(
                                  id: widget.item.id,
                                  title: titleController.text,
                                  author: authorController.text,
                                  year: int.tryParse(yearController.text),
                                  description: descController.text,
                                  coverPath: pickedCover?.path,
                                  pdfPath: pickedPDF?.path,
                                );

                                await DBHelper.instance.updateItem(updatedBook);
                                Navigator.pop(context); // Tutup dialog
                                Navigator.pop(
                                  context,
                                  true,
                                ); // Kembali ke halaman detail/admin

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Buku berhasil diperbarui'),
                                  ),
                                );
                              },
                              child: const Text('Ya, Simpan'),
                            ),
                          ],
                        ),
                      );
                    },
                    child: const Text(
                      'SIMPAN PERUBAHAN',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

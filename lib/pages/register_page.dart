import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/user.dart';
import 'package:flutter/services.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final username = TextEditingController();
  final password = TextEditingController();
  final nama = TextEditingController();
  final alamat = TextEditingController();
  final npm = TextEditingController();
  final email = TextEditingController();
  final telepon = TextEditingController();

  final prodiList = ['Informatika', 'Mesin', 'Sipil', 'Arsitek'];
  final kelasList = ['A', 'B', 'C', 'D', 'E'];

  String? selectedProdi;
  String? selectedKelas;
  String jk = 'Pria';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: username,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: password,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            TextField(
              controller: nama,
              decoration: const InputDecoration(labelText: 'Nama'),
            ),
            TextField(
              controller: alamat,
              decoration: const InputDecoration(labelText: 'Alamat'),
            ),
            TextField(
              controller: npm,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(labelText: 'NPM'),
            ),
            TextField(
              controller: email,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: telepon,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(labelText: 'Nomor HP'),
            ),
            const SizedBox(height: 12),

            DropdownButtonFormField(
              decoration: const InputDecoration(labelText: 'Prodi'),
              items: prodiList
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => selectedProdi = v,
            ),
            const SizedBox(height: 12),

            DropdownButtonFormField(
              decoration: const InputDecoration(labelText: 'Kelas'),
              items: kelasList
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => selectedKelas = v,
            ),

            Row(
              children: [
                Radio(
                  value: 'Pria',
                  groupValue: jk,
                  onChanged: (v) => setState(() => jk = v!),
                ),
                const Text('Pria'),
                Radio(
                  value: 'Perempuan',
                  groupValue: jk,
                  onChanged: (v) => setState(() => jk = v!),
                ),
                const Text('Perempuan'),
              ],
            ),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await DBHelper.instance.registerUser(
                  User(
                    username: username.text,
                    password: password.text,
                    nama: nama.text,
                    alamat: alamat.text,
                    npm: npm.text,
                    email: email.text,
                    telepon: telepon.text,
                    prodi: selectedProdi ?? '-',
                    kelas: selectedKelas ?? '-',
                    jk: jk,
                    role: 'user', // tambahkan ini
                  ),
                );

                Navigator.pop(context);
              },
              child: const Text('Daftar'),
            ),
          ],
        ),
      ),
    );
  }
}

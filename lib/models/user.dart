class User {
  int? id;
  String username;
  String password;
  String? nama;
  String? alamat;
  String? npm;
  String? email;
  String? telepon;
  String? prodi;
  String? kelas;
  String? jk;
  String role; // tambahkan ini

  User({
    this.id,
    required this.username,
    required this.password,
    this.nama,
    this.alamat,
    this.npm,
    this.email,
    this.telepon,
    this.prodi,
    this.kelas,
    this.jk,
    required this.role, // tambahkan
  });

  factory User.fromMap(Map<String, dynamic> json) => User(
    id: json['id'],
    username: json['username'],
    password: json['password'],
    nama: json['nama'],
    alamat: json['alamat'],
    npm: json['npm'],
    email: json['email'],
    telepon: json['telepon'],
    prodi: json['prodi'],
    kelas: json['kelas'],
    jk: json['jk'],
    role: json['role'], // tambahkan
  );

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'nama': nama,
      'alamat': alamat,
      'npm': npm,
      'email': email,
      'telepon': telepon,
      'prodi': prodi,
      'kelas': kelas,
      'jk': jk,
      'role': role, // tambahkan
    };
  }
}

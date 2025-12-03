import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:intl/intl.dart';
  
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with SingleTickerProviderStateMixin {
  String fullName = '';
  String email = '';
  String role = '';
  String laundryName = 'Nama toko Laundry';
  String laundryAddress = 'Alamat Laundry';
  double omzetToday = 0;
  int masuk = 20;
  int Selesai = 20;
  int terlambat = 9;

  String currentTime = '';
  String currentDate = '';
  late Timer _timer;
  late AnimationController _controller;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  final String _laundryDataDocId = 'default';

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadLaundryData();
    _updateTime();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateTime());
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userSnapshot.exists) {
        final userData = userSnapshot.data()!;
        setState(() {
          fullName = userData['name'] ?? 'users';
          email = userData['email'] ?? user.email ?? '';
          role = userData['role'] ?? '';
        });
      }
    }
  }

  Future<void> _loadLaundryData() async {
    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('laundryData')
          .doc(_laundryDataDocId)
          .get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data()!;
        setState(() {
          laundryName = data['name'] ?? 'Nama Toko Default';
          laundryAddress = data['address'] ?? 'Alamat Toko Default';
        });
      } else {
        await FirebaseFirestore.instance
            .collection('laundryData')
            .doc(_laundryDataDocId)
            .set({'name': laundryName, 'address': laundryAddress});
      }
    } catch (e) {
      print("Error loading laundry data: $e");
    }
  }

  void _updateTime() {
    final now = DateTime.now();
    setState(() {
      currentTime =
          "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
      currentDate =
          "${_getDayName(now.weekday)}, ${now.day} ${_getMonthName(now.month)} ${now.year}";
    });
  }

  Future<void> _updateLaundryData() async {
    if (_nameController.text.isEmpty || _addressController.text.isEmpty) {
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('laundryData')
          .doc(_laundryDataDocId)
          .update({
            'name': _nameController.text,
            'address': _addressController.text,
          });

      setState(() {
        laundryName = _nameController.text;
        laundryAddress = _addressController.text;
      });

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data toko berhasil diperbarui!')),
        );
      }
    } catch (e) {
      print("Error updating laundry data: $e");
    }
  }

  Future<void> _showEditDialog() async {
    _nameController.text = laundryName;
    _addressController.text = laundryAddress;

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Ubah Data Toko'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Nama Toko'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _addressController,
                  decoration: const InputDecoration(labelText: 'Alamat Toko'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text(
                'Simpan',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onPressed: _updateLaundryData,
            ),
          ],
        );
      },
    );
  }

  String _getDayName(int day) {
    const days = [
      "Senin",
      "Selasa",
      "Rabu",
      "Kamis",
      "Jumat",
      "Sabtu",
      "Minggu",
    ];
    return days[day - 1];
  }

  String _getMonthName(int month) {
    const months = [
      "Januari",
      "Februari",
      "Maret",
      "April",
      "Mei",
      "Juni",
      "Juli",
      "Agustus",
      "September",
      "Oktober",
      "November",
      "Desember",
    ];
    return months[month - 1];
  }

  final List<Map<String, dynamic>> menuItems = [
    {
      'title': 'Layanan',
      'icon': Icons.local_laundry_service,
      'route': '/services',
    },
    {'title': 'Riwayat', 'icon': Icons.history, 'route': '/history'},
    {'title': 'Laporan', 'icon': Icons.bar_chart, 'route': '/reports'},
    {'title': 'Pengeluaran', 'icon': Icons.trending_up, 'route': '/money_out'},
    {'title': 'Pelanggan', 'icon': Icons.people, 'route': '/customers'},
    {'title': 'Kasir', 'icon': Icons.person_pin, 'route': '/cashier'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F2027),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔹 HEADER ATAS
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    fullName.isEmpty ? 'Welcome' : fullName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        color: Colors.white70,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        currentDate,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 🔹 KOTAK INFORMASI LAUNDRY
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E2A33),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          backgroundImage: AssetImage('assets/images/profile.jpg'),
                          radius: 26,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                laundryName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                laundryAddress == 'Alamat Laundry'
                                ? laundryAddress
                                : '📍 $laundryAddress',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: _showEditDialog,
                          icon: const Icon(Icons.edit, color: Colors.white70),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.tealAccent.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            role.isEmpty ? 'Owner/Kasir' : role,
                            style: TextStyle(color: Colors.tealAccent),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _statBox(
                          Icons.login,
                          'Masuk',
                          masuk.toString(),
                          Colors.tealAccent,
                        ),
                        _statBox(
                          Icons.schedule,
                          'Selesai',
                          Selesai.toString(),
                          Colors.amberAccent,
                        ),
                        _statBox(
                          Icons.warning_amber,
                          'Terlambat',
                          terlambat.toString(),
                          Colors.redAccent,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 🔹 MENU GRID
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: menuItems.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                ),
                itemBuilder: (context, index) {
                  final item = menuItems[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, item['route']);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF203A43),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            item['icon'],
                            color: Colors.tealAccent,
                            size: 36,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            item['title'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: SizedBox(
          height: 60, // 🔹 tinggi tombol, jangan biarkan auto
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/transactions');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.tealAccent,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 8,
              shadowColor: Colors.tealAccent.withOpacity(0.4),
            ),
            child: const Text(
              "Transaksi",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  Widget _statBox(IconData icon, String label, String value, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFF2C5364),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer.cancel();
    _nameController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'dart:ui';
import 'finish_page.dart';

class TransactionDetailPage extends StatefulWidget {
  final DocumentSnapshot transaction;
  const TransactionDetailPage({super.key, required this.transaction});

  @override
  State<TransactionDetailPage> createState() => _TransactionDetailPageState();
}

class _TransactionDetailPageState extends State<TransactionDetailPage> {
  double bayar = 0;
  double kembalian = 0;
  final TextEditingController _bayarController = TextEditingController();

  late Future<Map<String, dynamic>?> _serviceFuture;

  Future<Map<String, dynamic>?> _fetchServiceData(String? process) async {
    if (process == null || process.isEmpty) return null;
    final snapshot = await FirebaseFirestore.instance
        .collection('services')
        .where('name', isEqualTo: process)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.first.data();
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    final data = (widget.transaction.data() as Map<String, dynamic>?) ?? {};
    final String? process = data['process'];
    _serviceFuture = _fetchServiceData(process);
  }

  @override
  Widget build(BuildContext context) {
    final data = (widget.transaction.data() as Map<String, dynamic>?) ?? {};
    final Timestamp? timestamp = data['timestamp'];
    final DateTime masuk = timestamp?.toDate() ?? DateTime.now();
    final double berat =
        double.tryParse(data['weight']?.toString() ?? '0') ?? 0.0;

    return FutureBuilder<Map<String, dynamic>?>(
      future: _serviceFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFF0F2027),
            body: Center(
              child: CircularProgressIndicator(color: Colors.tealAccent),
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: const Color(0xFF0F2027),
            body: Center(
              child: Text(
                'Terjadi kesalahan: ${snapshot.error}',
                style: const TextStyle(color: Colors.redAccent),
              ),
            ),
          );
        }

        final service = snapshot.data;
        if (service == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Detail Transaksi'),
              backgroundColor: Colors.teal,
            ),
            backgroundColor: const Color(0xFF0F2027),
            body: const Center(
              child: Text(
                'Data layanan tidak ditemukan atau field process kosong.',
                style: TextStyle(color: Colors.white70),
              ),
            ),
          );
        }

        // Aman untuk semua tipe data (string/number)
        final int durasiJam =
            int.tryParse(service['time']?.toString() ?? '') ?? 10;
        final double hargaPerKg =
            double.tryParse(service['price']?.toString() ?? '') ?? 7000.0;

        final DateTime selesai = masuk.add(Duration(hours: durasiJam));
        final double total = berat * hargaPerKg;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Detail Transaksi'),
            backgroundColor: Colors.teal,
          ),
          backgroundColor: const Color(0xFF0F2027),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF0F2027),
                    Color(0xFF203A43),
                    Color(0xFF2C5364),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white12),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nama Pelanggan: ${data['name'] ?? '-'}',
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  Text(
                    'No. Telp: ${data['phone'] ?? '-'}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Proses: ${data['process'] ?? '-'}',
                    style: const TextStyle(color: Colors.white),
                  ),
                  Text(
                    'Berat: ${berat.toStringAsFixed(1)} kg',
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Tanggal Masuk: ${DateFormat("dd MMM yyyy, HH:mm").format(masuk)}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  Text(
                    'Estimasi Selesai: ${DateFormat("dd MMM yyyy, HH:mm").format(selesai)}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Total Bayar:',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _bayarController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white12,
                      hintText: 'Masukkan nominal bayar',
                      hintStyle: const TextStyle(color: Colors.white54),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.white24),
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                    onChanged: (value) {
                      setState(() {
                        bayar = double.tryParse(value) ?? 0;
                        kembalian =
                            bayar - total; // total dari perhitungan kamu tadi
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Kembalian: Rp ${NumberFormat('#,###', 'id_ID').format(kembalian < 0 ? 0 : kembalian)}',
                    style: const TextStyle(color: Colors.white70),
                  ),

                  const SizedBox(height: 20),
                  const Text(
                    'Status Pembayaran:',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () => _updateStatus(context, 'Bayar nanti'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orangeAccent,
                        ),
                        child: const Text('Bayar nanti'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: BottomAppBar(
            color: Colors.black,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total: Rp ${NumberFormat('#,###', 'id_ID').format(total)}',
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.tealAccent,
                    ),
                    onPressed: () {
                      if (bayar < total) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Nominal bayar kurang')),
                        );
                        return;
                      }
                      _showKonfirmasiDialog(total);
                    },
                    child: const Text(
                      'Bayar',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Move methods to class level
  void _updateStatus(BuildContext context, String status) async {
    if (status == 'Bayar nanti') {
      await FirebaseFirestore.instance
          .collection('transactions')
          .doc(widget.transaction.id)
          .update({'status': 'Antrian', 'bayar': null, 'kembalian': null});
    } else {
      // Lunas
      await FirebaseFirestore.instance
          .collection('transactions')
          .doc(widget.transaction.id)
          .update({
            'status': 'Antrian',
            'bayar': bayar,
            'kembalian': kembalian < 0 ? 0 : kembalian,
          });
    }

    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Status diubah menjadi $status')));
    }
  }

  void _showKonfirmasiDialog(double total) {
    final data = widget.transaction.data() as Map<String, dynamic>?;
    if (data == null) return;

    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.35),
      transitionDuration: const Duration(milliseconds: 260),
      pageBuilder: (_, __, ___) => const SizedBox.shrink(),
      transitionBuilder: (context, anim, _, child) {
        return Transform.scale(
          scale: anim.value,
          child: Opacity(
            opacity: anim.value,
            child: Dialog(
              insetPadding: const EdgeInsets.symmetric(horizontal: 26),
              backgroundColor: Colors.transparent,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.15),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // -------------------------------------------------------
                        // HEADER GRADIENT PREMIUM
                        // -------------------------------------------------------
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFF00E28A),
                                Color(0xFF00A86B),
                                Color(0xFF007F4E),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Konfirmasi Transaksi",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  letterSpacing: 0.4,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              InkWell(
                                onTap: () => Navigator.pop(context),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // -------------------------------------------------------
                        // BODY GLASS
                        // -------------------------------------------------------
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Nama: ${data['name']}",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 14),

                              Text(
                                "Total Harga",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.75),
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "Rp ${NumberFormat('#,###', 'id_ID').format(total)}",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 14),

                              Text(
                                "Dibayar",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.75),
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "Rp ${NumberFormat('#,###', 'id_ID').format(bayar)}",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // -------------------------------------------------------
                        // TOMBOL FULL WIDTH GLASS-GREEN
                        // -------------------------------------------------------
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00C27A),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.zero,
                              ),
                            ),
                            onPressed: () async {
                              await FirebaseFirestore.instance
                                  .collection('transactions')
                                  .doc(widget.transaction.id)
                                  .update({
                                    'status': 'Antrian',
                                    'bayar': bayar,
                                    'kembalian': kembalian < 0 ? 0 : kembalian,
                                  });

                              if (!context.mounted) return;

                              Navigator.pop(context); // tutup dialog konfirmasi

                              // navigasi ke halaman finish
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      FinishPage(total: total, dp: bayar),
                                ),
                              );
                            },

                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                  onPressed: () =>
                                      _updateStatus(context, 'Antrian'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    elevation: 0,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 40,
                                      vertical: 15,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadiusGeometry.circular(10),
                                    ),
                                  ),
                                  child: const Text(
                                    "Simpan",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:intl/intl.dart';

String generateNota({
  required String namaToko,
  required String alamat,
  required String telepon,
  required double total,
  required double bayar,
  required String tanggal,
  required String kodeTransaksi,
}) {
  final format = NumberFormat('#,###', 'id_ID');
  final kembalian = bayar - total;
  // Struk gaya kasir (monospace), cocok untuk thermal printer.
  return '''
================================
         $namaToko
    $alamat
   Telp: $telepon
================================
Tanggal   : $tanggal
No. Struk : $kodeTransaksi
--------------------------------
Total      : Rp ${format.format(total)}
Dibayar    : Rp ${format.format(bayar)}
Kembalian  : Rp ${format.format(kembalian < 0 ? 0 : kembalian)}
--------------------------------
        TERIMA KASIH
  SEMOGA HARI ANDA MENYENANGKAN
================================
''';
}

class FinishPage extends StatelessWidget {
  final double total;
  final double dp;

  const FinishPage({super.key, required this.total, required this.dp});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F2027),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Lottie animasi sukses di tengah layar
              Lottie.asset(
                'assets/lottie/success.json',
                width: 350,
                height: 350,
                repeat: true,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 10),
              const Text(
                'Transaksi Berhasil Disimpan',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Total: Rp ${NumberFormat('#,###', 'id_ID').format(total)}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Dibayar: Rp ${NumberFormat('#,###', 'id_ID').format(dp)}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.black,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _bottomButton(
                icon: Icons.check_circle,
                label: 'Selesai',
                onTap: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
              ),
              _bottomButton(
                icon: Icons.print,
                label: 'Cetak',
                onTap: () {
                  final nota = generateNota(
                    namaToko: "ASSYIFA TECH",
                    alamat: "Jl. Pendidikan No. 12",
                    telepon: "0895-xxxx-xxxx",
                    total: total,
                    bayar: dp,
                    tanggal: DateFormat(
                      'dd/MM/yyyy HH:mm',
                    ).format(DateTime.now()),
                    kodeTransaksi:
                        "TRX-${DateTime.now().millisecondsSinceEpoch}",
                  );
                  _showNotaSiapCetak(context, nota);
                },
              ),
              _bottomButton(
                icon: Icons.share,
                label: 'Bagikan',
                onTap: () {
                  _showBagikanDialog(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bottomButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.tealAccent, size: 28),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  void _showNotaSiapCetak(BuildContext context, String nota) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1B2730),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          'Preview Nota (Siap Cetak)',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: SelectableText(
            nota,
            style: const TextStyle(
              color: Colors.white70,
              fontFamily: 'monospace',
              fontSize: 13,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Tutup',
              style: TextStyle(color: Colors.tealAccent),
            ),
          ),
          TextButton(
            onPressed: () {
              // Di sini taruh logika cetak/print atau kirim ke plugin printing
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Perintah cetak dikirim (mock).')),
              );
            },
            child: const Text(
              'Cetak',
              style: TextStyle(color: Colors.tealAccent),
            ),
          ),
        ],
      ),
    );
  }

  void _showNotaDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1B2730),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          'Nota Transaksi',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total: Rp ${NumberFormat('#,###', 'id_ID').format(total)}',
              style: const TextStyle(color: Colors.white70),
            ),
            Text(
              'Dibayar: Rp ${NumberFormat('#,###', 'id_ID').format(dp)}',
              style: const TextStyle(color: Colors.white70),
            ),
            Text(
              'Kembalian: Rp ${NumberFormat('#,###', 'id_ID').format(dp - total)}',
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Tutup',
              style: TextStyle(color: Colors.tealAccent),
            ),
          ),
        ],
      ),
    );
  }

  void _showBagikanDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1B2730),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          'Bagikan Struk',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Fitur bagikan struk akan segera hadir!',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: Colors.tealAccent)),
          ),
        ],
      ),
    );
  }
}

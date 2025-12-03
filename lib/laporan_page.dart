import 'package:flutter/material.dart';
import 'laporan_transaksi_page.dart';
import 'laporan_pengeluaran_page.dart';

class LaporanPage extends StatelessWidget {
  const LaporanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F2027),
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text("Laporan"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _menuItem(
              context,
              title: "Laporan Transaksi",
              icon: Icons.receipt_long,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const LaporanTransaksiPage(),
                ),
              ),
            ),

            const SizedBox(height: 16),

            _menuItem(
              context,
              title: "Laporan Pengeluaran",
              icon: Icons.money_off,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const LaporanPengeluaranPage(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuItem(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.greenAccent, size: 32),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 20),
          ],
        ),
      ),
    );
  }
}

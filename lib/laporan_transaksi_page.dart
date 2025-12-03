import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class LaporanTransaksiPage extends StatefulWidget {
  const LaporanTransaksiPage({super.key});

  @override
  State<LaporanTransaksiPage> createState() => _LaporanTransaksiPageState();
}

class _LaporanTransaksiPageState extends State<LaporanTransaksiPage> {
  DateTime? startDate;
  DateTime? endDate;

  Future<void> pickDate(bool isStart) async {
    DateTime initial = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        if (isStart) startDate = picked;
        if (!isStart) endDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F2027),
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text("Laporan Transaksi"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.sort))],
      ),

      body: Column(
        children: [
          // ================== FILTER BAR ==================
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF203A43), Color(0xFF2C5364)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _dateBox(
                  label: startDate == null
                      ? "Tanggal Awal"
                      : DateFormat("dd/MM/yyyy").format(startDate!),
                  onTap: () => pickDate(true),
                ),

                const Text(
                  ">",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                _dateBox(
                  label: endDate == null
                      ? "Tanggal Akhir"
                      : DateFormat("dd/MM/yyyy").format(endDate!),
                  onTap: () => pickDate(false),
                ),
              ],
            ),
          ),

          // ================= LIST =================
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("transactions")
                  .orderBy("timestamp", descending: true)
                  .snapshots(),
              builder: (context, snap) {
                if (!snap.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.tealAccent),
                  );
                }

                final data = snap.data!.docs;

                if (data.isEmpty) {
                  return const Center(
                    child: Text(
                      "Tidak ada transaksi.",
                      style: TextStyle(color: Colors.white70),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: data.length,
                  itemBuilder: (context, i) {
                    final d = data[i].data() as Map<String, dynamic>;
                    final name = d["name"]?.toString() ?? "-";
                    final phone = d["phone"]?.toString() ?? "-";
                    final process = d["process"]?.toString() ?? "-";
                    final status = d["status"]?.toString() ?? "-";

                    final masuk = (d["timestamp"] as Timestamp).toDate();

                    final weight = d["weight"] ?? 0;
                    final bayar = d["bayar"] ?? 0;
                    final kembalian = d["kembalian"] ?? 0;

                    // Filter berdasarkan tanggal
                    bool isAfterStart =
                        startDate == null || masuk.isAfter(startDate!);
                    bool isBeforeEnd =
                        endDate == null ||
                        masuk.isBefore(endDate!.add(const Duration(days: 1)));

                    if (!isAfterStart || !isBeforeEnd) {
                      return const SizedBox.shrink();
                    }

                    return _item(
                      name: name,
                      weight: weight,
                      process: process,
                      status: status,
                      masuk: masuk,
                      bayar: bayar,
                      kembalian: kembalian,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ==================================================================
  // DATE BOX
  // ==================================================================
  Widget _dateBox({required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white24),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // ==================================================================
  // ITEM TRANSAKSI — MIRIP HISTORY PAGE, GAYA SAMA
  // ==================================================================
  Widget _item({
    required String name,
    required dynamic weight,
    required String process,
    required String status,
    required DateTime masuk,
    required int bayar,
    required int kembalian,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nama
          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Berat: $weight Kg",
                style: const TextStyle(color: Colors.white70),
              ),
              Text(process, style: const TextStyle(color: Colors.white70)),
            ],
          ),

          const SizedBox(height: 6),

          Text(
            DateFormat("dd/MM/yyyy  HH:mm").format(masuk),
            style: const TextStyle(color: Colors.white54),
          ),

          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Bayar: Rp ${NumberFormat('#,###', 'id_ID').format(bayar)}",
                style: const TextStyle(color: Colors.greenAccent),
              ),
              Text(
                "Kembalian: Rp ${NumberFormat('#,###', 'id_ID').format(kembalian)}",
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // STATUS
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: status == "Selesai" ? Colors.green : Colors.orange,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              status,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================================================================
  // ICON ROW (dipakai juga di HistoryPage)
  // ==================================================================
  Widget _iconRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, color: Colors.white54, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              "$title: $value",
              style: const TextStyle(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }
}

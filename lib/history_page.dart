import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  String searchQuery = "";
  String selectedType = "Antrian";

  final List<String> types = [
    "Antrian",
    "Proses",
    "Siap Ambil",
    "Selesai",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F2027),
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text("Riwayat Transaksi"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // =================== SEARCH BAR ===================
            TextField(
              onChanged: (value) {
                setState(() => searchQuery = value.toLowerCase());
              },
              decoration: InputDecoration(
                hintText: "Cari nama pelanggan...",
                hintStyle: const TextStyle(color: Colors.white54),
                prefixIcon: const Icon(Icons.search, color: Colors.white70),
                filled: true,
                fillColor: Colors.white10,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),

            const SizedBox(height: 14),

            // =================== FILTER TYPE ===================
            SizedBox(
              height: 42,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: types.map((e) {
                  final bool active = selectedType == e;

                  return GestureDetector(
                    onTap: () => setState(() => selectedType = e),
                    child: Container(
                      margin: const EdgeInsets.only(right: 10),
                      padding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: active ? Colors.tealAccent : Colors.white10,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: active ? Colors.tealAccent : Colors.white24,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          e.toUpperCase(),
                          style: TextStyle(
                            color: active ? Colors.black : Colors.white70,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 12),

            // =================== LIST DATA ===================
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('transactions')
                    .where('status', isEqualTo: selectedType)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.tealAccent),
                    );
                  }

                  final docs = snapshot.data!.docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final name = data['name']?.toString().toLowerCase() ?? '';
                    return name.contains(searchQuery);
                  }).toList();

                  if (docs.isEmpty) {
                    return const Center(
                      child: Text(
                        "Tidak ada data.",
                        style: TextStyle(color: Colors.white70),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;
                      final Timestamp? masukTs = data['timestamp'];
                      final DateTime masuk =
                          masukTs != null ? masukTs.toDate() : DateTime.now();

                      final int durasiJam =
                          int.tryParse(data['time']?.toString() ?? '10') ?? 10;

                      final DateTime selesai =
                          masuk.add(Duration(hours: durasiJam));

                      final double berat =
                          double.tryParse(data['weight']?.toString() ?? '0') ??
                              0;

                      final double price =
                          double.tryParse(data['price']?.toString() ?? '0') ?? 0;

                      final double total = berat * price;

                      return _buildItem(
                        data: data,
                        total: total,
                        masuk: masuk,
                        selesai: selesai,
                        docId: docs[index].id,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ====================================================================
  // CUSTOM WIDGET LIST ITEM
  // ====================================================================
  Widget _buildItem({
    required Map<String, dynamic> data,
    required double total,
    required DateTime masuk,
    required DateTime selesai,
    required String docId,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF203A43),
            Color(0xFF2C5364),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ================= LEFT DATA =================
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // NAMA + TOTAL
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      data['name'] ?? '-',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    Row(
                      children: [
                        const Icon(Icons.payments, color: Colors.tealAccent),
                        const SizedBox(width: 4),
                        Text(
                          "Rp ${NumberFormat('#,###', 'id_ID').format(total)}",
                          style: const TextStyle(
                            color: Colors.tealAccent,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // MASUK
                _iconRow(Icons.calendar_month, "Masuk",
                    DateFormat("dd MMM yyyy, HH:mm").format(masuk)),

                // ESTIMASI
                _iconRow(Icons.timer, "Estimasi",
                    DateFormat("dd MMM yyyy, HH:mm").format(selesai)),

                // DISKON
                _iconRow(Icons.discount, "Diskon",
                    "${data['diskon'] ?? 0}%"),

                // STATUS TRANSAKSI
                _statusBadge(
                  icon: Icons.flag,
                  title: "Status",
                  value: data['status'],
                  color: _statusColor(data['status']),
                ),

                // STATUS BAYAR
                _statusBadge(
                  icon: Icons.check_circle,
                  title: "Pembayaran",
                  value: data['bayar'] != null && data['bayar'] >= total
                      ? "Lunas"
                      : "Bayar nanti",
                  color: data['bayar'] != null && data['bayar'] >= total
                      ? Colors.green
                      : Colors.orange,
                ),
              ],
            ),
          ),

          // ================= DELETE BUTTON =================
          IconButton(
            onPressed: () {
              FirebaseFirestore.instance
                  .collection('transactions')
                  .doc(docId)
                  .delete();
            },
            icon: const Icon(Icons.delete, color: Colors.redAccent, size: 28),
          ),
        ],
      ),
    );
  }

  // ====================================================================
  // REUSABLE ROW WITH ICON (TEXT DETAILS)
  // ====================================================================
  Widget _iconRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, color: Colors.white54, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              "$label: $value",
              style: const TextStyle(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }

  // ====================================================================
  // STATUS BADGE
  // ====================================================================
  Widget _statusBadge({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.22),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 6),
          Text(
            "$title: $value",
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ====================================================================
  // STATUS COLOR PICKER
  // ====================================================================
  Color _statusColor(String? status) {
    switch (status) {
      case "Antrian":
        return Colors.orangeAccent;
      case "Proses":
        return Colors.blueAccent;
      case "Siap Ambil":
        return Colors.purpleAccent;
      case "Selesai":
        return Colors.greenAccent;
      default:
        return Colors.white70;
    }
  }
}

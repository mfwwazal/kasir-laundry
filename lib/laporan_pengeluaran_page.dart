import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class LaporanPengeluaranPage extends StatefulWidget {
  const LaporanPengeluaranPage({super.key});

  @override
  State<LaporanPengeluaranPage> createState() => _LaporanPengeluaranPageState();
}

class _LaporanPengeluaranPageState extends State<LaporanPengeluaranPage> {
  DateTime? startDate;
  DateTime? endDate;

  Future<void> pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        isStart ? startDate = picked : endDate = picked;
      });
    }
  }

  // =========================
  //   FORM TAMBAH PENGELUARAN
  // =========================
  void showEditForm(String docId, Map<String, dynamic> data) {
    final namaC = TextEditingController(text: data["nama"]);
    final nominalC = TextEditingController(text: data["nominal"].toString());
    final catatanC = TextEditingController(text: data["catatan"] ?? "");
    DateTime tanggal = (data["tanggal"] as Timestamp).toDate();

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F2027),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModal) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Edit Pengeluaran",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  const SizedBox(height: 20),

                  TextField(
                    controller: namaC,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputStyle("Nama Pengeluaran"),
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: nominalC,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputStyle("Nominal"),
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: catatanC,
                    maxLines: 2,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputStyle("Catatan"),
                  ),
                  const SizedBox(height: 12),

                  // Tanggal
                  GestureDetector(
                    onTap: () async {
                      final pick = await showDatePicker(
                        context: context,
                        initialDate: tanggal,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (pick != null) {
                        setModal(() => tanggal = pick);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.shade800,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_month,
                            color: Colors.white70,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            DateFormat("dd/MM/yyyy").format(tanggal),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      minimumSize: const Size(double.infinity, 45),
                    ),
                    onPressed: () async {
                      await FirebaseFirestore.instance
                          .collection("pengeluaran")
                          .doc(docId)
                          .update({
                            "nama": namaC.text,
                            "nominal": int.parse(nominalC.text),
                            "catatan": catatanC.text,
                            "tanggal": Timestamp.fromDate(tanggal),
                          });

                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Simpan Perubahan",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void showAddForm() {
    final namaC = TextEditingController();
    final nominalC = TextEditingController();
    final catatanC = TextEditingController();
    DateTime? tanggal;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F2027),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModal) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Tambah Pengeluaran",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  const SizedBox(height: 20),

                  // NAMA
                  TextField(
                    controller: namaC,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputStyle("Nama Pengeluaran"),
                  ),

                  const SizedBox(height: 12),

                  // CATATAN
                  TextField(
                    controller: catatanC,
                    maxLines: 2,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputStyle("Catatan (opsional)"),
                  ),
                  const SizedBox(height: 12),

                  // NOMINAL
                  TextField(
                    controller: nominalC,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputStyle("Nominal"),
                  ),

                  const SizedBox(height: 12),

                  // TANGGAL
                  GestureDetector(
                    onTap: () async {
                      final pick = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (pick != null) {
                        setModal(() => tanggal = pick);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.shade800,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_month,
                            color: Colors.white70,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            tanggal == null
                                ? "Pilih Tanggal"
                                : DateFormat("dd/MM/yyyy").format(tanggal!),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // BUTTON SIMPAN
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      minimumSize: const Size(double.infinity, 45),
                    ),
                    onPressed: () async {
                      if (namaC.text.isEmpty ||
                          nominalC.text.isEmpty ||
                          tanggal == null)
                        return;

                      await FirebaseFirestore.instance
                          .collection("pengeluaran")
                          .add({
                            "nama": namaC.text,
                            "nominal": int.parse(nominalC.text),
                            "tanggal": Timestamp.fromDate(tanggal!),
                            "catatan": catatanC.text,
                          });

                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Simpan",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  static InputDecoration _inputStyle(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white54),
      filled: true,
      fillColor: Color(0xFF1A2A33),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
    );
  }

  // =========================
  //         UI BUILD
  // =========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F2027),

      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text("Laporan Pengeluaran"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      // NAVBAR
      bottomNavigationBar: BottomAppBar(
        color: Colors.green.shade800,
        shape: const CircularNotchedRectangle(),
        child: SizedBox(height: 55),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, size: 28),
        onPressed: showAddForm,
      ),

      body: Column(
        children: [
          // FILTER TANGGAL lebih rapi
          Container(
            margin: const EdgeInsets.all(14),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade800,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _dateBox(
                    label: startDate == null
                        ? "Tanggal Awal"
                        : DateFormat("dd/MM/yyyy").format(startDate!),
                    onTap: () => pickDate(true),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Icon(
                    Icons.arrow_forward,
                    color: Colors.white70,
                    size: 20,
                  ),
                ),
                Expanded(
                  child: _dateBox(
                    label: endDate == null
                        ? "Tanggal Akhir"
                        : DateFormat("dd/MM/yyyy").format(endDate!),
                    onTap: () => pickDate(false),
                  ),
                ),
              ],
            ),
          ),

          // LIST DATA
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("pengeluaran")
                  .orderBy("tanggal", descending: true)
                  .snapshots(),
              builder: (context, snap) {
                if (!snap.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.greenAccent),
                  );
                }

                final data = snap.data!.docs;

                // Filter berdasarkan tanggal
                final filtered = data.where((e) {
                  final d = e.data() as Map<String, dynamic>;
                  final tgl = (d["tanggal"] as Timestamp).toDate();

                  bool isAfterStart =
                      startDate == null || tgl.isAfter(startDate!);
                  bool isBeforeEnd =
                      endDate == null ||
                      tgl.isBefore(endDate!.add(const Duration(days: 1)));

                  return isAfterStart && isBeforeEnd;
                }).toList();

                return ListView(
                  children: [
                    ...filtered.map((e) {
                      final d = e.data() as Map<String, dynamic>;
                      final tgl = (d["tanggal"] as Timestamp).toDate();
                      final catatan = d["catatan"] ?? "";

                      final nominal = NumberFormat(
                        '#,###',
                        'id_ID',
                      ).format(d["nominal"]);

                      return Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF112027),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    DateFormat("dd/MM/yyyy").format(tgl),
                                    style: const TextStyle(
                                      color: Colors.white70,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    d["nama"],
                                    style: const TextStyle(
                                      color: Colors.white70,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    "Rp $nominal",
                                    style: const TextStyle(
                                      color: Colors.greenAccent,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.greenAccent,
                                    size: 20,
                                  ),
                                  onPressed: () => showEditForm(e.id, d),
                                ),
                              ],
                            ),

                            // Catatan ditaruh di bawah, agak kecil, tidak mengganggu
                            if (catatan.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  "Catatan: $catatan",
                                  style: const TextStyle(
                                    color: Colors.white38,
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    }),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _dateBox({required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.green.shade700,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

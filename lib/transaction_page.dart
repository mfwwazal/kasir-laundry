import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'transaction_detail_page.dart';

class TransactionPage extends StatefulWidget {
  const TransactionPage({super.key});

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  List<String> _services = [];
  String? _selectedProcess;

  @override
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.forward();
    _fetchServices();
  }

  Future<void> _fetchServices() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('services')
          .get();

      setState(() {
        _services = snapshot.docs.map((doc) => doc['name'] as String).toList();

        if (_services.isNotEmpty) {
          _selectedProcess = _services[0];
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat layanan: $e'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  // 🔹 Fungsi tambah transaksi ke Firestore
  Future<void> _addTransaction(
    String name,
    String phone,
    String process,
    double weight,
  ) async {
    await FirebaseFirestore.instance.collection('transactions').add({
      'name': name,
      'phone': phone,
      'process': process,
      'weight': weight,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _updateTransaction(
    String docId,
    String name,
    String phone,
    String process,
    double weight,
  ) async {
    await FirebaseFirestore.instance
        .collection('transactions')
        .doc(docId)
        .update({
          'name': name,
          'phone': phone,
          'process': process,
          'weight': weight,
        });
  }

  // delete
  Future<void> _deleteTransaction(String docId) async {
    await FirebaseFirestore.instance
        .collection('transactions')
        .doc(docId)
        .delete();
  }

  void _showDeleteConfirmationDialog(String docId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1B262C),
          title: const Text(
            'Hapus Transaksi',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Apakah Anda yakin ingin menghapus transaksi ini?',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Batal',
                style: TextStyle(color: Colors.white70),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
              onPressed: () async {
                Navigator.pop(context);
                await _deleteTransaction(docId);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Transaksi berhasil dihapus'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  // 🔹 Dialog tambah / edit transaksi
  void _showTransactionDialog({
    String? docId,
    String? currentName,
    String? currentPhone,
    String? currentProcess,
    double? currentWeight,
  }) {
    final TextEditingController nameController = TextEditingController(
      text: currentName,
    );
    final TextEditingController phoneController = TextEditingController(
      text: currentPhone,
    );
    final TextEditingController weightController = TextEditingController(
      text: currentWeight?.toString() ?? '',
    );
    String? tempSelectedProcess = currentProcess ?? _selectedProcess;

    if (_services.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Layanan belum tersedia. Silakan tambahkan layanan terlebih dahulu.',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStateDialog) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1B262C),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                docId == null ? 'Tambah Layanan' : 'Edit Layanan',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Nama Pelanggan',
                      labelStyle: TextStyle(color: Colors.white70),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white38),
                      ),
                    ),
                  ),
                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'No. Telepon',
                      labelStyle: TextStyle(color: Colors.white70),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white38),
                      ),
                    ),
                  ),
                  TextField(
                    controller: weightController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Berat Cucian (kg)',
                      labelStyle: TextStyle(color: Colors.white70),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white38),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Proses Layanan',
                      labelStyle: TextStyle(color: Colors.white70),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white38),
                      ),
                    ),
                    value: tempSelectedProcess,
                    dropdownColor: const Color(0xFF1B262C),
                    style: const TextStyle(color: Colors.white),
                    items: _services.map((String service) {
                      return DropdownMenuItem<String>(
                        value: service,
                        child: Text(service),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setStateDialog(() {
                        tempSelectedProcess = newValue;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Batal',
                    style: TextStyle(color: Colors.redAccent),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.tealAccent.withOpacity(0.8),
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () async {
                    if (nameController.text.isEmpty ||
                        phoneController.text.isEmpty ||
                        weightController.text.isEmpty ||
                        tempSelectedProcess == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Semua kolom harus diisi'),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                      return;
                    }

                    final double weight =
                        double.tryParse(weightController.text.trim()) ?? 0;

                    if (docId == null) {
                      final inputName = nameController.text.trim();

                      // 🔍 Cek nama sudah ada atau belum
                      final existing = await FirebaseFirestore.instance
                          .collection('transactions')
                          .where('name', isEqualTo: inputName)
                          .get();

                      if (existing.docs.isNotEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Nama pelanggan sudah ada, gunakan nama lain.',
                            ),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                        return;
                      }

                      // ⬇ Kalau aman, baru simpan
                      await _addTransaction(
                        inputName,
                        phoneController.text.trim(),
                        tempSelectedProcess!,
                        weight,
                      );
                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                    } else {
                      await _updateTransaction(
                        docId,
                        nameController.text.trim(),
                        phoneController.text.trim(),
                        tempSelectedProcess!,
                        weight,
                      );
                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                    }
                  },
                  child: Text(docId == null ? 'Tambah' : 'Update'),
                ),
              ],
            );
          },
        );
      },
    ).whenComplete(() {
      nameController.dispose();
      phoneController.dispose();
      weightController.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: const Text(
          'Daftar Transaksi',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.tealAccent,
        onPressed: () => _showTransactionDialog(),
        child: const Icon(Icons.add, color: Colors.black),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,

            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value.trim().toLowerCase();
                      });
                    },
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Cari nama pelanggan...",
                      hintStyle: const TextStyle(color: Colors.white54),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Colors.tealAccent,
                      ),
                      filled: true,
                      fillColor: Colors.white12,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('transactions')
                        .orderBy('timestamp', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Colors.tealAccent,
                          ),
                        );
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(
                          child: Text(
                            'Belum ada transaksi',
                            style: TextStyle(color: Colors.white70),
                          ),
                        );
                      }

                      final transactions = snapshot.data!.docs;
                      final filtered = transactions.where((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final name = (data['name'] ?? '')
                            .toString()
                            .toLowerCase();
                        return name.contains(_searchQuery);
                      }).toList();

                      if (filtered.isEmpty) {
                        return const Center(
                          child: Text(
                            'Transaksi tidak ditemukan',
                            style: TextStyle(color: Colors.white70),
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final DocumentSnapshot doc = filtered[index];
                          final data = doc.data() as Map<String, dynamic>;
                          final docId = doc.id;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withOpacity(0.05),
                                  Colors.white.withOpacity(0.02),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ListTile(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        TransactionDetailPage(transaction: doc),
                                  ),
                                );
                              },
                              leading: const Icon(
                                Icons.local_laundry_service,
                                color: Colors.tealAccent,
                                size: 32,
                              ),
                              title: Text(
                                data['name'] ?? '-',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Text(
                                'Proses: ${data['process']} • Berat: ${data['weight']} kg',
                                style: const TextStyle(color: Colors.white70),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Colors.lightBlueAccent,
                                    ),
                                    onPressed: () => _showTransactionDialog(
                                      docId: docId,
                                      currentName: data['name'],
                                      currentPhone: data['phone'],
                                      currentProcess: data['process'],
                                      currentWeight: (data['weight'] as num)
                                          .toDouble(),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.redAccent,
                                    ),
                                    onPressed: () =>
                                        _showDeleteConfirmationDialog(docId),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ServicePage extends StatefulWidget {
  const ServicePage({super.key});

  @override
  State<ServicePage> createState() => _ServicePageState();
}

class _ServicePageState extends State<ServicePage> {
  final _formKey = GlobalKey<FormState>();
  // formatter for Indonesian number formatting
  final NumberFormat formatter = NumberFormat.decimalPattern('id');

  // Safely format price coming from Firestore (could be int, double, or String)
  String _formatPrice(dynamic price) {
    if (price == null) return '0';
    if (price is num) return formatter.format(price);
    if (price is String) {
      // Remove any non-digit characters then parse
      final cleaned = price.replaceAll(RegExp(r'[^0-9]'), '');
      final parsed = int.tryParse(cleaned);
      if (parsed != null) return formatter.format(parsed);
      return price;
    }
    return price.toString();
  }

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();

  // 🔹 Fungsi tambah layanan ke Firestore
  Future<void> _addService() async {
    await FirebaseFirestore.instance.collection('services').add({
      'name': _nameController.text.trim(),
      'price': int.parse(_priceController.text.trim()),
      'time': _timeController.text.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // 🔹 Fungsi update layanan
  Future<void> _updateService(String id) async {
    await FirebaseFirestore.instance.collection('services').doc(id).update({
      'name': _nameController.text.trim(),
      'price': int.parse(_priceController.text.trim()),
      'time': _timeController.text.trim(),
    });
  }

  // 🔹 Fungsi hapus layanan
  Future<void> _deleteService(String id) async {
    await FirebaseFirestore.instance.collection('services').doc(id).delete();
  }

  // 🔹 Dialog tambah / edit
  void _showServiceDialog({String? id, Map<String, dynamic>? existingData}) {
    final isEdit = id != null;
    _nameController.text = existingData?['name'] ?? '';
    _priceController.text = existingData?['price']?.toString() ?? '';
    _timeController.text = existingData?['time'] ?? '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E2A36),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          isEdit ? 'Edit Layanan' : 'Tambah Layanan',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Nama Layanan',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white54),
                  ),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Masukkan nama layanan' : null,
              ),
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Harga (Rp)',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white54),
                  ),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Masukkan harga layanan' : null,
              ),
              TextFormField(
                controller: _timeController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Waktu Lama',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white54),
                  ),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Masukkan waktu layanan' : null,
              ),
            ],
          ),
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
              backgroundColor: Colors.tealAccent.withOpacity(0.3),
              foregroundColor: Colors.black,
            ),
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                if (isEdit) {
                  await _updateService(id!);
                } else {
                  await _addService();
                }

                // _nameController.clear();
                // _priceController.clear();
                // _timeController.clear();
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: Text(isEdit ? 'Simpan' : 'Tambah'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F2027),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: const Text(
          'Layanan Laundry',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('services')
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.tealAccent),
              );
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text(
                  'Belum ada layanan',
                  style: TextStyle(color: Colors.white70),
                ),
              );
            }

            final services = snapshot.data!.docs;

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: services.length,
              itemBuilder: (context, index) {
                final doc = services[index];
                final data = doc.data() as Map<String, dynamic>;

                return Card(
                  color: Colors.white.withOpacity(0.08),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: ListTile(
                    leading: const Icon(
                      Icons.local_laundry_service,
                      color: Colors.tealAccent,
                    ),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data['name'] ?? '-',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    subtitle: Text(
                      'Rp ${_formatPrice(data['price'])} • ${data['time'] ?? '-'} jam',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.edit,
                            color: Colors.amberAccent,
                          ),
                          onPressed: () => _showServiceDialog(
                            id: doc.id,
                            existingData: data,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.redAccent,
                          ),
                          onPressed: () => _deleteService(doc.id),
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.tealAccent,
        onPressed: () => _showServiceDialog(),
        child: const Icon(Icons.add, color: Colors.black87),
      ),
    );
  }
}

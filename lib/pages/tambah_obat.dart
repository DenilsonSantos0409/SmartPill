import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'riwayat_obat.dart';

class TambahObatPage extends StatefulWidget {
  final DateTime? initialDate;
  final Map<String, dynamic>? dataObat;

  const TambahObatPage({super.key, this.initialDate, this.dataObat});

  @override
  State<TambahObatPage> createState() => _TambahObatPageState();
}

class _TambahObatPageState extends State<TambahObatPage> {
  final _namaController = TextEditingController();
  final _dosisController = TextEditingController();
  final _catatanController = TextEditingController();

  String _frekuensi = 'sehari sekali';
  final List<TimeOfDay> _listWaktu = [const TimeOfDay(hour: 8, minute: 0)];
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.initialDate != null) {
      _selectedDate = widget.initialDate!;
    }
    if (widget.dataObat != null) {
      _namaController.text = widget.dataObat!['nama'];
      _dosisController.text = widget.dataObat!['dosis'];
      _frekuensi = widget.dataObat!['frekuensi'];
      _selectedDate = DateTime.parse(widget.dataObat!['tanggal']);
      _catatanController.text = widget.dataObat!['catatan'];
      _listWaktu.clear();
      for (var waktuString in widget.dataObat!['waktu']) {
        final parts = waktuString.split(":");
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        _listWaktu.add(TimeOfDay(hour: hour, minute: minute));
      }
    }
  }

  Future<void> _pilihTanggal() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _simpanObat() async {
    final dataObat = {
      'nama': _namaController.text,
      'dosis': _dosisController.text,
      'frekuensi': _frekuensi,
      'tanggal': _selectedDate.toIso8601String(),
      'waktu': _listWaktu
          .map((e) =>
              '${e.hour.toString().padLeft(2, '0')}:${e.minute.toString().padLeft(2, '0')}')
          .toList(),
      'catatan': _catatanController.text,
      'aktif': true,
    };

    final prefs = await SharedPreferences.getInstance();
    List<String> riwayat = prefs.getStringList('riwayat') ?? [];
    riwayat.add(jsonEncode(dataObat));
    await prefs.setStringList('riwayat', riwayat);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Data obat berhasil disimpan!")),
    );

    Navigator.pop(context, dataObat);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
        title: Text(
          "Tambah Obat",
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
          ),
        ),
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? const Color.fromARGB(255, 1, 37, 72)
            : Colors.lightBlueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Nama", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _namaController,
              decoration: _inputDecoration("Nama Obat"),
            ),
            const SizedBox(height: 16),
            const Text("Dosis", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _dosisController,
              decoration: _inputDecoration("tambahkan dosis"),
            ),
            const SizedBox(height: 16),
            const Text("Frekuensi",
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _frekuensi,
              items: [
                'sehari sekali',
                'dua kali sehari',
                'tiga kali sehari',
                'empat kali sehari',
                'mingguan',
                'sesuai kebutuhan'
              ]
                  .map((value) => DropdownMenuItem(
                        value: value,
                        child: Text(value),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _frekuensi = value!;
                });
              },
              decoration: _inputDecoration(""),
            ),
            const SizedBox(height: 16),
            const Text("Tanggal",
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6EEFF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    DateFormat('EEEE, dd MMMM yyyy', 'id_ID')
                        .format(_selectedDate),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                TextButton.icon(
                  onPressed: _pilihTanggal,
                  icon: const Icon(Icons.calendar_today,
                      color: Color(0xFF3866C6)),
                  label: const Text(
                    "Pilih Tanggal",
                    style: TextStyle(color: Color(0xFF3866C6)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text("Waktu", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (int i = 0; i < _listWaktu.length; i++)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6EEFF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _listWaktu[i].format(context),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _listWaktu.removeAt(i);
                            });
                          },
                          child: const Icon(Icons.close,
                              size: 18, color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                GestureDetector(
                  onTap: () async {
                    final TimeOfDay? picked = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (picked != null) {
                      setState(() {
                        _listWaktu.add(picked);
                      });
                    }
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F6FA),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, size: 18, color: Color(0xFF3866C6)),
                        SizedBox(width: 4),
                        Text("Tambah Waktu",
                            style: TextStyle(color: Color(0xFF3866C6))),
                      ],
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(height: 16),
            const Text("Catatan",
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _catatanController,
              maxLines: 3,
              decoration: _inputDecoration("Contoh: setelah makan"),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _simpanObat,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Theme.of(context).brightness == Brightness.dark
                          ? const Color.fromARGB(255, 1, 37, 72)
                          : Colors.lightBlueAccent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Simpan",
                  style: TextStyle(
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.grey),
      ),
    );
  }
}

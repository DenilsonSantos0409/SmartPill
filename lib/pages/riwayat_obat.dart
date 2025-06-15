import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import 'tambah_obat.dart';
import 'home_page.dart'; // pastikan path sesuai struktur proyek kamu
import '../providers/obat_provider.dart';

class RiwayatObatPage extends StatefulWidget {
  const RiwayatObatPage({super.key});

  @override
  State<RiwayatObatPage> createState() => _RiwayatObatPageState();
}

class _RiwayatObatPageState extends State<RiwayatObatPage> {
  List<Map<String, dynamic>> _dataObat = [];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final obatProvider = Provider.of<ObatProvider>(context, listen: false);
    final prefs = await SharedPreferences.getInstance();
    final obatList = prefs.getStringList('riwayat') ?? [];
    final parsedObat =
        obatList.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();
    obatProvider.loadObat(parsedObat);
  }

  Future<void> _simpanData() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> data = _dataObat.map((e) => jsonEncode(e)).toList();
    await prefs.setStringList('riwayat', data);
  }

  String _konversiWaktu(dynamic waktuList, BuildContext context) {
    try {
      if (waktuList == null || waktuList.isEmpty) return "-";
      if (waktuList.first is Map) {
        return waktuList.map((waktu) {
          final jam = waktu['hour'];
          final menit = waktu['minute'];
          final time = TimeOfDay(hour: jam, minute: menit);
          return time.format(context);
        }).join(', ');
      } else if (waktuList.first is String) {
        return waktuList.join(', ');
      }
      return "-";
    } catch (e) {
      return "-";
    }
  }

  @override
  Widget build(BuildContext context) {
    final obatProvider = Provider.of<ObatProvider>(context);
    final _dataObat = obatProvider.obatList;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Riwayat Obat",
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
      body: _dataObat.isEmpty
          ? const Center(child: Text("Belum ada data obat."))
          : ListView.builder(
              itemCount: _dataObat.length,
              itemBuilder: (context, index) {
                final data = _dataObat[index];
                final tanggal = DateFormat('dd MMM yyyy')
                    .format(DateTime.parse(data['tanggal']));
                final bool aktif = data['aktif'] ?? true;

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                  child: ListTile(
                    title: Text(
                      data['nama'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        decoration: aktif ? null : TextDecoration.lineThrough,
                        color: aktif ? Colors.black : Colors.grey,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Dosis: ${data['dosis']}", style: const TextStyle(fontSize: 12)),
                        Text("Frekuensi: ${data['frekuensi']}", style: const TextStyle(fontSize: 12)),
                        Text("Tanggal: $tanggal", style: const TextStyle(fontSize: 12)),
                        Text("Waktu: ${_konversiWaktu(data['waktu'], context)}",
                            style: const TextStyle(fontSize: 12)),
                        if (data['catatan'] != null && data['catatan'].toString().isNotEmpty)
                          Text("Catatan: ${data['catatan']}", style: const TextStyle(fontSize: 12)),
                        const SizedBox(height: 4),
                        Text("Status: ${aktif ? 'Aktif' : 'Nonaktif'}",
                            style: TextStyle(
                              fontSize: 12,
                              color: aktif ? Colors.green : Colors.red,
                            )),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Switch(
                          value: aktif,
                          onChanged: (value) async {
                            final updated = {..._dataObat[index], 'aktif': value};
                            await obatProvider.updateObat(index, updated);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.orange),
                          onPressed: () async {
                            final hasil = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    TambahObatPage(dataObat: _dataObat[index]),
                              ),
                            );
                            if (hasil != null) {
                              await obatProvider.updateObat(index, hasil);
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text("Hapus Obat"),
                                content: const Text(
                                    "Apakah kamu yakin ingin menghapus data ini?"),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text("Batal"),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      await obatProvider.deleteObat(index);
                                      Navigator.pop(context);
                                    },
                                    child: const Text("Hapus"),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TambahObatPage()),
          );

          if (result != null && result is Map<String, dynamic>) {
            try {
              final obatProvider = Provider.of<ObatProvider>(context, listen: false);
              await obatProvider.addObat(result);
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Gagal menambah obat: ${e.toString()}')),
              );
            }
          }
        },
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? const Color.fromARGB(255, 1, 37, 72)
            : Colors.lightBlueAccent,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const HomePage()),
                );
              },
              icon: const Icon(Icons.home),
            ),
            const SizedBox(width: 20),
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RiwayatObatPage()),
                );
              },
              icon: const Icon(Icons.history),
            ),
          ],
        ),
      ),
    );
  }
}

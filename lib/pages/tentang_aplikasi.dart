import 'package:flutter/material.dart';

class TentangAplikasiPage extends StatelessWidget {
  const TentangAplikasiPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor =
        isDark ? const Color.fromARGB(255, 1, 37, 72) : Colors.lightBlueAccent;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tentang Aplikasi'),
        backgroundColor: primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.asset(
                'assets/Logo.png',
                width: 80,
                height: 80,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'SmartPill',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 10),
            Text(
              'Versi 1.0.0',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),
            const Text(
              'Aplikasi ini membantu Anda mengatur dan mengingat jadwal konsumsi obat secara efisien. '
              'Fitur termasuk tambah obat, jadwal pengingat, serta riwayat konsumsi.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            const Text(
              'Dikembangkan oleh:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 6),
            const Text('TEAM SMARTPILL'),
            const SizedBox(height: 20),
            const Text(
              'Hubungi:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 6),
            const Text('SmartPill2025@gmail.com'),
          ],
        ),
      ),
    );
  }
}

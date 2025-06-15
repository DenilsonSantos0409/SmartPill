import 'package:flutter/material.dart';

class NotifikasiPage extends StatelessWidget {
  const NotifikasiPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> notifikasiList = [
      {'judul': 'Waktunya minum Paracetamol', 'waktu': '13 Juni 2025 - 08:00'},
      {
        'judul': 'Minum Amoxicillin setelah makan',
        'waktu': '13 Juni 2025 - 12:00'
      },
      {'judul': 'Jangan lupa minum Vitamin C', 'waktu': '13 Juni 2025 - 18:00'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Notification",
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
      body: ListView.builder(
        itemCount: notifikasiList.length,
        itemBuilder: (context, index) {
          final notif = notifikasiList[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[850] // Dark background for dark mode
                : Colors.white, // Light background for light mode
            child: ListTile(
              leading: const Icon(Icons.notifications_active),
              title: Text(
                notif['judul'] ?? '',
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white // White text for dark mode
                      : Colors.black, // Black text for light mode
                ),
              ),
              subtitle: Text(
                notif['waktu'] ?? '',
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[300] // Light grey for dark mode
                      : Colors.black54, // Grey for light mode
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

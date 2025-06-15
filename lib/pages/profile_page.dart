import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String name = 'Ilan Ewos';
  String email = 'user@email.com';
  String password = '********';
  String phone = '0812-3456-7890';
  String? photoPath;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString('name') ?? name;
      email = prefs.getString('email') ?? email;
      password = prefs.getString('password') != null ? '********' : password;
      phone = prefs.getString('phone') ?? phone;
      photoPath = prefs.getString('photo');
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor =
        isDark ? const Color.fromARGB(255, 1, 37, 72) : Colors.lightBlueAccent;
    final secondaryTextColor = isDark ? Colors.grey[300] : Colors.grey[700];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Pengguna'),
        backgroundColor: primaryColor,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 60,
                backgroundImage: photoPath != null &&
                        File(photoPath!).existsSync()
                    ? FileImage(File(photoPath!))
                    : const AssetImage('assets/test_foto.png') as ImageProvider,
              ),
              const SizedBox(height: 20),
              Text(
                name,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                email,
                style: TextStyle(fontSize: 16, color: secondaryTextColor),
              ),
              const SizedBox(height: 30),
              const Divider(thickness: 1),
              const SizedBox(height: 16),
              Text(
                'Informasi Pengguna',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              infoTile(Icons.person, 'Nama Lengkap', name, primaryColor),
              const Divider(),
              infoTile(Icons.email, 'Email', email, primaryColor),
              const Divider(),
              infoTile(Icons.lock, 'Password', '********', primaryColor),
              const Divider(),
              infoTile(Icons.phone, 'No. HP', phone, primaryColor),
              const Divider(),
              const SizedBox(height: 40),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await Navigator.pushNamed(context, '/edit-profile');
                    await _loadProfileData();
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget infoTile(
      IconData icon, String title, String value, Color iconColor) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: iconColor),
      title: Text(title),
      subtitle: Text(value),
    );
  }
}

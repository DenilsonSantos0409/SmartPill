// lib/widgets/custom_drawer.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  String _name = 'Nama Pengguna';

  @override
  void initState() {
    super.initState();
    _loadName();
  }

  Future<void> _loadName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _name = prefs.getString('name') ?? 'Nama Pengguna';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) => Column(
          children: [
            Stack(
              children: [
                UserAccountsDrawerHeader(
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? const Color.fromARGB(255, 1, 37, 72)
                        : Colors.lightBlueAccent,
                  ),
                  accountName: Text(_name),
                  accountEmail: null,
                  currentAccountPicture: const CircleAvatar(
                    backgroundImage: AssetImage('assets/test_foto.png'),
                  ),
                ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: IconButton(
                    icon: Icon(
                      themeProvider.isDarkMode
                          ? Icons.dark_mode
                          : Icons.light_mode,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      themeProvider.toggleTheme(!themeProvider.isDarkMode);
                    },
                  ),
                ),
              ],
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile Saya'),
              onTap: () async {
                Navigator.pop(context);
                await Navigator.pushNamed(context, '/profile');
                _loadName(); // refresh nama
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Tentang Aplikasi'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/tentang-aplikasi');
              },
            ),
            const Spacer(),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.exit_to_app, color: Colors.red),
              title: const Text(
                'Logout',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (Route<dynamic> route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

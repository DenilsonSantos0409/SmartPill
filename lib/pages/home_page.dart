import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../providers/theme_provider.dart';
import 'tambah_obat.dart';
import 'riwayat_obat.dart';
import '../providers/obat_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/browser.dart';
import 'package:timezone/data/latest_all.dart';
import 'package:timezone/timezone.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _showCalendar = false;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  late List<DateTime> next30Days;


  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();


 @override
void initState() {
  super.initState();
  next30Days = _getDatesFromYesterday();
  _loadObatData();
  _loadUserName(); // Tambahkan ini di akhir
}

  Future<void> init() async {
    initializeTimeZones();

    //! https://en.wikipedia.org/wiki/List_of_tz_database_time_zones
    setLocalLocation(
      getLocation('America/Toronto'),
    );

    const androidSettings =
        AndroidInitializationSettings('@mipmap/launcher_icon');
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings();

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await notificationsPlugin.initialize(initializationSettings);

    await notificationsPlugin
      .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
      ?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
  }






  Future<void> _loadObatData() async {
    final obatProvider = Provider.of<ObatProvider>(context, listen: false);
    final prefs = await SharedPreferences.getInstance();
    final obatList = prefs.getStringList('riwayat') ?? [];
    final parsedObat =
        obatList.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();
    obatProvider.loadObat(parsedObat);
  }

  List<Map<String, dynamic>> get _filteredObatList {
    final obatList = Provider.of<ObatProvider>(context).obatList;
    return obatList.where((obat) {
      return DateFormat('yyyy-MM-dd').format(DateTime.parse(obat['tanggal'])) ==
          DateFormat('yyyy-MM-dd').format(_selectedDay);
    }).toList();
  }

  // Check if a date has medicines
  bool _hasObatOnDate(DateTime date) {
    final obatList = Provider.of<ObatProvider>(context, listen: false).obatList;
    return obatList.any((obat) {
      return DateFormat('yyyy-MM-dd').format(DateTime.parse(obat['tanggal'])) ==
          DateFormat('yyyy-MM-dd').format(date);
    });
  }

  // Generate a list of dates starting from yesterday for the next 30 days
  List<DateTime> _getDatesFromYesterday() {
    DateTime yesterday = DateTime.now().subtract(Duration(days: 1));
    return List.generate(30, (index) => yesterday.add(Duration(days: index)));
  }
  
  String _userName = 'Memuat nama...';

@override
Future<void> _loadUserName() async {
  final prefs = await SharedPreferences.getInstance();
  setState(() {
    _userName = prefs.getString('name') ?? 'Ilan Ewos';
  });
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      drawer: Drawer(
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
                    accountName: Text(_userName),
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
  onTap: () {
    Navigator.pop(context);
    Navigator.pushNamed(context, '/profile').then((_) {
      _loadUserName(); // <- Tambahkan ini
    });
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
      ),
      appBar: AppBar(
        title: const Text('SmartPill'),
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? const Color.fromARGB(255, 1, 37, 72)
            : Colors.lightBlueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.pushNamed(context, '/notifications');
            },
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // Top Image Section
          SliverToBoxAdapter(
            child: Container(
              height: MediaQuery.of(context).size.height * 0.3,
              color: Colors.white,
              child: Center(
                child: Image.asset(
                  'assets/smartpill_homepage.png', // Add your image here
                  height: MediaQuery.of(context).size.height * 0.3,
                  width: MediaQuery.of(context).size.width,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    // Fallback if image doesn't exist
                    return Container(
                      height: MediaQuery.of(context).size.height * 0.3,
                      width: MediaQuery.of(context).size.width,
                      color: Colors.white,
                      child: const Icon(
                        Icons.medical_services,
                        size: 80,
                        color: Colors.grey,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          // Reminders Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Reminders',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context)
                                  .textTheme
                                  .headlineLarge
                                  ?.color ??
                              Colors.black87,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _showCalendar = !_showCalendar;
                          });
                        },
                        child: Icon(
                          _showCalendar
                              ? Icons.keyboard_arrow_up
                              : Icons.calendar_today,
                          color: Colors.grey[600],
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Date Calendar
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    height: 100, // Set a fixed height for the scrolling area
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(30, (index) {
                          final date = next30Days[index];
                          final isToday = DateFormat('yyyy-MM-dd')
                                  .format(date) ==
                              DateFormat('yyyy-MM-dd').format(DateTime.now());
                          final hasObat = _hasObatOnDate(date);
                          final isSelected =
                              DateFormat('yyyy-MM-dd').format(date) ==
                                  DateFormat('yyyy-MM-dd').format(_selectedDay);

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedDay = date;
                                _focusedDay = date;
                              });
                            },
                            child: Container(
                              width: 70, // Adjust width as needed
                              height: 70,
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 8), // Add margin for spacing
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors
                                        .blue // Highlight selected date in blue
                                    : isToday
                                        ? Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? const Color.fromARGB(
                                                255, 1, 37, 72)
                                            : Colors.lightBlueAccent
                                        : Colors.transparent,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    DateFormat('EEE')
                                        .format(date), // Display day name
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isSelected || isToday
                                          ? Colors.white
                                          : (Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? Colors.grey[400]
                                              : Colors.grey[600]),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${date.day}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected || isToday
                                          ? Colors.white
                                          : (Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? Colors.white
                                              : Colors.black87),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  if (hasObat)
                                    Container(
                                      width: 4,
                                      height: 4,
                                      decoration: BoxDecoration(
                                        color: isSelected || isToday
                                            ? Colors.white
                                            : Colors.black87,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),

                  // Display the selected date in the body
                  // Check if a date is selected
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      'Selected Date: ${DateFormat('dd MMMM yyyy').format(_selectedDay)}', // Format the date as needed
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // Full Calendar (when expanded)
                  if (_showCalendar)
                    Container(
                      margin: const EdgeInsets.only(top: 16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[800]
                            : Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TableCalendar(
                        locale: 'id_ID',
                        firstDay: DateTime.utc(2020, 1, 1),
                        lastDay: DateTime.utc(2100, 12, 31),
                        focusedDay: _focusedDay,
                        calendarFormat: CalendarFormat.month,
                        selectedDayPredicate: (day) =>
                            isSameDay(day, _selectedDay),
                        onDaySelected: (selectedDay, focusedDay) {
                          setState(() {
                            _selectedDay = selectedDay;
                            _focusedDay = focusedDay;
                            _showCalendar = false; // Hide calendar on selection
                          });
                        },
                        calendarStyle: const CalendarStyle(
                          todayDecoration: BoxDecoration(
                            color: Colors.lightBlueAccent,
                            shape: BoxShape.circle,
                          ),
                          selectedDecoration: BoxDecoration(
                            color: Colors.lightBlueAccent,
                            shape: BoxShape.circle,
                          ),
                        ),
                        calendarBuilders: CalendarBuilders(
                          defaultBuilder: (context, day, focusedDay) {
                            if (_hasObatOnDate(day)) {
                              return Container(
                                margin: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '${day.day}',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    Container(
                                      width: 4,
                                      height: 4,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.white
                                            : Colors.black87,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                            return null;
                          },
                        ),
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Today Activities Section
                  const Text(
                    'Today Activities',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // Medicine List
          _filteredObatList.isEmpty
              ? SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Container(
                      height: 100,
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[800]
                            : Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.grey[600]!
                                    : Colors.grey[300]!),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.medication,
                              size: 32,
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.grey[300]
                                  : Colors.grey[400],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'No activities for today',
                              style: TextStyle(
                                fontSize: 16,
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final obat = _filteredObatList[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 6.0),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? (index % 2 == 0
                                        ? Colors.blue[900]!.withOpacity(0.3)
                                        : Colors.red[900]!.withOpacity(0.3))
                                    : (index % 2 == 0
                                        ? const Color(0xFFE8F4FD)
                                        : const Color(0xFFFFE8E8)),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? (index % 2 == 0
                                      ? Colors.blue[700]!
                                      : Colors.red[700]!)
                                  : (index % 2 == 0
                                      ? Colors.blue[200]!
                                      : Colors.red[200]!),
                            ),
                          ),
                          child: Row(
                            children: [
                              // Medicine Icon
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? (index % 2 == 0
                                          ? Colors.blue[800]
                                          : Colors.red[800])
                                      : (index % 2 == 0
                                          ? Colors.blue[100]
                                          : Colors.red[100]),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.medication,
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? (index % 2 == 0
                                          ? Colors.blue[300]
                                          : Colors.red[300])
                                      : (index % 2 == 0
                                          ? Colors.blue[600]
                                          : Colors.red[600]),
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),

                              // Medicine Info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      obat['nama'],
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context)
                                                .textTheme
                                                .bodyLarge
                                                ?.color ??
                                            Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.grey[400]
                                            : Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Dosage
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${obat['dosis']}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.color ??
                                        Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    childCount: _filteredObatList.length,
                  ),
                ),

          // Bottom spacing for FAB
          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => TambahObatPage(initialDate: null)),
          );
          if (result != null && result is Map<String, dynamic>) {
            Provider.of<ObatProvider>(context, listen: false).addObat(result);
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
              onPressed: () {},
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
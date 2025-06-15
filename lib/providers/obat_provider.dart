import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ObatProvider with ChangeNotifier {
  List<Map<String, dynamic>> _obatList = [];

  List<Map<String, dynamic>> get obatList => _obatList;

  Future<void> addObat(Map<String, dynamic> obat) async {
    _obatList.add(obat);
    await _saveToPrefs();
    notifyListeners();
  }

  Future<void> loadObat(List<Map<String, dynamic>> obat) async {
    _obatList = obat;
    notifyListeners();
  }

  Future<void> updateObat(int index, Map<String, dynamic> newData) async {
    _obatList[index] = newData;
    await _saveToPrefs();
    notifyListeners();
  }

  Future<void> deleteObat(int index) async {
    _obatList.removeAt(index);
    await _saveToPrefs();
    notifyListeners();
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final data = _obatList.map((e) => jsonEncode(e)).toList();
    await prefs.setStringList('riwayat', data);
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesService = ChangeNotifierProvider((ref) => SharedPreferencesService());

class SharedPreferencesService extends ChangeNotifier {
  SharedPreferences? _prefs;

  Future<void> add(String key, String value) async {
    final prefs = await _getSharedPreferencesInstance();
    await prefs.setString(key, value);
  }

  Future<String?> get(String key) async {
    final prefs = await _getSharedPreferencesInstance();
    return prefs.getString(key);
  }

  Future<void> removeKey(String key) async {
    final prefs = await _getSharedPreferencesInstance();
    await prefs.remove(key);
  }

  Future<String> getToken(String key) async {
    final prefs = await _getSharedPreferencesInstance();
    return prefs.getString(key)!;
  }

  Future<SharedPreferences> _getSharedPreferencesInstance() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }
}

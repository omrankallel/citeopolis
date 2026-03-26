import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

class LocalStorageListService<T extends HiveObject> {
  Box<String>? _box; // Changer de Box<List<T>> à Box<String>
  final String boxName;
  final T Function(Map<String, dynamic>) fromJsonFactory;
  final Map<String, dynamic> Function(T) toJsonFactory;
  bool _isInitialized = false;

  LocalStorageListService({
    required this.boxName,
    required this.fromJsonFactory,
    required this.toJsonFactory,
  });

  Box<String> get box {
    if (!_isInitialized || _box == null) {
      throw StateError('LocalStorageListService for $boxName not initialized. Call initialize() first.');
    }
    return _box!;
  }

  bool get isInitialized => _isInitialized && _box != null;

  Future<void> initialize() async {
    try {
      if (kDebugMode) {
        print('🔧 Initialisation de la box list: $boxName');
      }
      _box = await Hive.openBox<String>(boxName); // Box<String> au lieu de Box<List<T>>
      _isInitialized = true;
      if (kDebugMode) {
        print('✅ Box list $boxName initialisée avec ${_box!.length} collections');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erreur initialisation box list $boxName: $e');
      }
      _isInitialized = false;
      rethrow;
    }
  }

  Future<void> save(String key, List<T> items) async {
    if (!isInitialized) {
      throw StateError('Service $boxName non initialisé');
    }

    try {
      // Convertir chaque objet en Map puis sérialiser en JSON
      final List<Map<String, dynamic>> jsonList = items.map((item) => toJsonFactory(item)).toList();
      final String jsonString = jsonEncode(jsonList);

      await box.put(key, jsonString);
      if (kDebugMode) {
        print('💾 Sauvé: liste de ${items.length} items pour $key dans $boxName');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erreur sauvegarde liste $key dans $boxName: $e');
      }
      rethrow;
    }
  }

  List<T>? get(String key) {
    if (!isInitialized) {
      if (kDebugMode) {
        print('⚠️ Service $boxName non initialisé pour get($key)');
      }
      return null;
    }

    try {
      final String? jsonString = box.get(key);
      if (jsonString == null || jsonString.isEmpty) {
        if (kDebugMode) {
          print('🔍 Get liste $key: aucun item dans $boxName');
        }
        return null;
      }

      // Désérialiser depuis JSON
      final List<dynamic> jsonList = jsonDecode(jsonString);
      final List<T> items = jsonList
          .map((json) => fromJsonFactory(json as Map<String, dynamic>))
          .toList();

      if (kDebugMode) {
        print('🔍 Get liste $key: ${items.length} items dans $boxName');
      }
      return items;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erreur get liste $key dans $boxName: $e');
      }
      return null;
    }
  }

  Future<void> delete(String key) async {
    if (!isInitialized) {
      throw StateError('Service $boxName non initialisé');
    }

    try {
      await box.delete(key);
      if (kDebugMode) {
        print('🗑️ Supprimé: liste $key de $boxName');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erreur suppression liste $key dans $boxName: $e');
      }
      rethrow;
    }
  }

  Future<void> clear() async {
    if (!isInitialized) {
      throw StateError('Service $boxName non initialisé');
    }

    try {
      await box.clear();
      if (kDebugMode) {
        print('🧹 Box list $boxName vidée');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erreur clear list $boxName: $e');
      }
      rethrow;
    }
  }

  bool contains(String key) {
    if (!isInitialized) return false;
    try {
      return box.containsKey(key);
    } catch (e) {
      return false;
    }
  }

  Future<void> close() async {
    if (_box != null) {
      await _box!.close();
      _box = null;
      _isInitialized = false;
      if (kDebugMode) {
        print('🔒 Box list $boxName fermée');
      }
    }
  }
}
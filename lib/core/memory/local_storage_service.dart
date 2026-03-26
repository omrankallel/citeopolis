import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

class LocalStorageService<T extends HiveObject> {
  Box<T>? _box;
  final String boxName;
  bool _isInitialized = false;

  LocalStorageService(this.boxName);

  Box<T> get box {
    if (!_isInitialized || _box == null) {
      throw StateError('LocalStorageService for $boxName not initialized. Call initialize() first.');
    }
    return _box!;
  }

  bool get isInitialized => _isInitialized && _box != null;

  Future<void> initialize() async {
    try {
      if (kDebugMode) {
        print('🔧 Initialisation de la box: $boxName');
      }
      _box = await Hive.openBox<T>(boxName);
      _isInitialized = true;
      if (kDebugMode) {
        print('✅ Box $boxName initialisée avec ${_box!.length} éléments');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erreur initialisation box $boxName: $e');
      }
      _isInitialized = false;
      rethrow;
    }
  }

  Future<void> save(String key, T item) async {
    if (!isInitialized) {
      throw StateError('Service $boxName non initialisé');
    }

    try {
      await box.put(key, item);
      if (kDebugMode) {
        print('💾 Sauvé: $key dans $boxName (Total: ${box.length})');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erreur sauvegarde $key dans $boxName: $e');
      }
      rethrow;
    }
  }

  T? get(String key) {
    if (!isInitialized) {
      if (kDebugMode) {
        print('⚠️ Service $boxName non initialisé pour get($key)');
      }
      return null;
    }

    try {
      final item = box.get(key);
      if (kDebugMode) {
        print('🔍 Get $key: ${item != null ? "trouvé" : "non trouvé"} dans $boxName');
      }
      return item;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erreur get $key dans $boxName: $e');
      }
      return null;
    }
  }

  List<T> getAll() {
    if (!isInitialized) {
      if (kDebugMode) {
        print('⚠️ Service $boxName non initialisé pour getAll()');
      }
      return [];
    }

    try {
      final items = box.values.toList();
      if (kDebugMode) {
        print('📖 GetAll: ${items.length} items dans $boxName');
      }
      return items;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erreur getAll dans $boxName: $e');
      }
      return [];
    }
  }

  Future<void> delete(String key) async {
    if (!isInitialized) {
      throw StateError('Service $boxName non initialisé');
    }

    try {
      await box.delete(key);
      if (kDebugMode) {
        print('🗑️ Supprimé: $key de $boxName');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erreur suppression $key dans $boxName: $e');
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
        print('🧹 Box $boxName vidée');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erreur clear $boxName: $e');
      }
      rethrow;
    }
  }

  bool contains(String key) {
    if (!isInitialized) {
      if (kDebugMode) {
        print('⚠️ Service $boxName non initialisé pour contains($key)');
      }
      return false;
    }

    try {
      return box.containsKey(key);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erreur contains $key dans $boxName: $e');
      }
      return false;
    }
  }

  int get length {
    if (!isInitialized) {
      if (kDebugMode) {
        print('⚠️ Service $boxName non initialisé pour length');
      }
      return 0;
    }

    try {
      return box.length;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erreur length $boxName: $e');
      }
      return 0;
    }
  }

  Future<void> close() async {
    if (_box != null) {
      await _box!.close();
      _box = null;
      _isInitialized = false;
      if (kDebugMode) {
        print('🔒 Box $boxName fermée');
      }
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final favoritesProvider = ChangeNotifierProvider((ref) => FavoritesProvider());

class FavoritesProvider extends ChangeNotifier {}

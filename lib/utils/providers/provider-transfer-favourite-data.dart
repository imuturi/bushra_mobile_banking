import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../dto/dto-favourites-click.dart';

class FavoriteTransferDataProvider with ChangeNotifier {
  Favorite? _selectedFavorite;

  Favorite? get selectedFavorite => _selectedFavorite;

  void setFavorite(Favorite? favorite) {
    _selectedFavorite = favorite;
    notifyListeners();
  }

  // Clear after use to avoid stale data
  void clearFavorite() {
    _selectedFavorite = null;
    notifyListeners();
  }
}
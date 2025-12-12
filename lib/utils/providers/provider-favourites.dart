import 'package:flutter/cupertino.dart';

import '../../models/dto/favourites-get-response.dart';

class FavouritesProvider with ChangeNotifier {

  GetFavoritesResponse? _favorites;
  GetFavoritesResponse? get favorites => _favorites;

  void setFavorites(GetFavoritesResponse favoritesResponse) {
    _favorites = favoritesResponse;
    notifyListeners();
  }

  void clearFavorites() {
    _favorites = null;
    notifyListeners();
  }
}

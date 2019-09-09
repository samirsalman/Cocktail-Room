import 'cocktail/cocktail.dart';

class Cache {
  static Map<String, Cocktail> cache = Map();
  static Map<String, List> qty = Map();

  static void putInCache(cocktail) {
    cache[cocktail.name] = cocktail;
  }

  static bool isInCache(cocktail) {
    if (cache[cocktail.name] != null) {
      return true;
    } else
      return false;
  }
}

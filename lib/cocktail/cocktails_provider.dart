import 'dart:io';
import 'package:facebook_audience_network/ad/ad_banner.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../cocktail_api.dart';
import '../favorites.dart';
import '../home.dart';
import '../home_stfll.dart';
import 'cocktail.dart';
import 'package:connectivity/connectivity.dart';

class CocktailsProvider with ChangeNotifier {
  var cocktailsList = [];
  bool load = true;
  String lastSearch = "55555xxxx78s9e78";
  List<Cocktail> favorites = List();
  List<String> favoritesName = List();
  Widget currPage = HomeS();
  int currentIndex = 0;
  bool connection = true;
  Cocktail random;
  CocktailAPI api;
  List<String> types = List();
  List<String> filter = List();
  List<Cocktail> allCocktail = List();
  List<Cocktail> temp = List();
  Map<String, int> typePosition = Map();

  CocktailsProvider(context) {
    api = CocktailAPI(context);
  }

  void removeFromFilter(element) {
    filter.remove(element);
    types.insert(typePosition[element], element);
    notifyListeners();

    if (filter.length == 0) {
      print("IS 0");
      cocktailsList = api.allCocktails.sublist(0, 50);
      notifyListeners();
    } else {
      for (int j = 0; j < removedByFilter.length; j++) {
        if (removedByFilter[j].type == element) {
          cocktailsList.add(removedByFilter[j]);
          removedByFilter.removeAt(j);
          print(removedByFilter[j]);
        }
      }
      notifyListeners();
    }
  }

  void addToFilter(element) {
    filter.add(element);
    int where = types.indexOf(element);
    typePosition[element] = where;
    types.remove(element);
    notifyListeners();
    cocktailsList.clear();
    for (int j = 0; j < api.allCocktails.length; j++) {
      if (filter.contains(api.allCocktails[j].type.toString())) {
        cocktailsList.add(api.allCocktails[j]);
      }
    }
    cocktailsList = cocktailsList.length > 50
        ? cocktailsList.sublist(0, 50)
        : cocktailsList;
    print(cocktailsList);

    notifyListeners();
  }

  Future<List<String>> getAllTypes(context) async {
    if (types.length == 0) {
      String typeList =
          await DefaultAssetBundle.of(context).loadString("assets/types.json");
      print(typeList);
      var jsonResult = json.decode(typeList);
      for (int i = 0; i < jsonResult['types'].length; i++) {
        types.add(jsonResult['types'][i]['type']);
        print(jsonResult['types'][i]['type']);
      }
      notifyListeners();
    }

    return types;
  }

  void searchCocktail(query) {
    if (api.first) {
      api.searchDrink(query, filter: []).then((value) {
        loadFavorites();
        notifyListeners();
      });
    } else if (query != lastSearch) {
      api.searchDrink(query, filter: filter).then((value) {
        cocktailsList = value.length > 50 ? value.sublist(0, 50) : value;
        lastSearch = query;
        load = false;
        notifyListeners();
      });
    }
  }
/*
  Future getForType(type) {
    api.getForType(type).then((value) {
      cocktailsList = value;
      notifyListeners();
    });
  }
  */

  void setConnection(bool value) {
    connection = value;
  }

  Widget banner = Padding(
    padding: const EdgeInsets.only(bottom: 16.0),
    child: FacebookBannerAd(
      placementId: "422662708456327_422676801788251",
      bannerSize: BannerSize.STANDARD,
      keepAlive: false,
    ),
  );

  Future<dynamic> translate(quote) async {
    return quote;
  }

  void changePage(int index) {
    switch (index) {
      case 0:
        if (currentIndex != 0) {
          currPage = HomeS();
          currentIndex = 0;
          notifyListeners();
        }
        break;

      case 1:
        if (currentIndex != 1) {
          currPage = Favorites();
          currentIndex = 1;
          notifyListeners();
        }
    }
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future loadFavorites() async {
    int value = await isFirst();
    if (value == 1) {
      readCounter().then((value) {
        List<Cocktail> temp = List();
        favoritesName.clear();
        var jsonFile = json.decode(value);
        for (int i = 0; i < jsonFile['list'].length; i++) {
          temp.add(Cocktail.fromJsonFile(jsonFile['list'][i]));
          favoritesName.add(jsonFile['list'][i]["strDrink"]);
        }
        favorites = temp;
        print(favorites);
        notifyListeners();
      });
    } else {
      Map<String, dynamic> map = Map();
      map['list'] = [];
      writeCounter(json.encode(map));
      SharedPreferences.getInstance().then((value) {
        value.setInt('first', 1);
      });
      notifyListeners();
    }
  }

  Future<Cocktail> randomCocktail() async =>
      api.randomCocktail().then((result) async {
        return result[0];
      });

  Future<int> isFirst() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('first');
  }

  Future putFav(Cocktail cocktail) async {
    var translated = await translate(cocktail.instructions);
    cocktail.instructions = translated;
    String jsonFile = await readCounter();
    var result = json.decode(jsonFile);
    result['list'].add(cocktail.toJson());
    print("ID PRIMA DI SCRIVERE " + cocktail.id.toString());
    writeCounter(json.encode(result));
    favorites.add(cocktail);
    favoritesName.add(cocktail.name);
    notifyListeners();
  }

  Future removeFav(Cocktail cocktail) async {
    String jsonFile = await readCounter();
    var result = json.decode(jsonFile);
    for (int i = 0; i < result['list'].length; i++) {
      if (result['list'][i]['idDrink'] == cocktail.id) {
        print(result['list'][i]['strDrink']);
        result['list'].removeAt(i);
        print("ID PRIMA DI SCRIVERE " + favorites[i].id);

        favorites.removeAt(i);
        favoritesName.removeAt(i);

        notifyListeners();
      }
    }
    writeCounter(json.encode(result));

    print(result);
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/fav.json');
  }

  Future<File> writeCounter(String counter) async {
    final file = await _localFile;

    // Write the file.
    file.writeAsStringSync('$counter');
  }

  Future<String> readCounter() async {
    try {
      final file = await _localFile;

      // Read the file.
      String contents = file.readAsStringSync();

      return contents;
    } catch (e) {
      // If encountering an error, return 0.
      return null;
    }
  }
}

List<Cocktail> removedByFilter = List();

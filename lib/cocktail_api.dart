import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'cocktail/cocktail.dart';
import 'package:flutter/material.dart';

class CocktailAPI {
  BuildContext full;
  CocktailAPI(this.full);
  List<Cocktail> allCocktails = List();
  bool first = true;

  //String currentType = "Tutti";

  Future<List<Cocktail>> searchDrink(String query,
      {List<String> filter}) async {
    query = query.trim();
    List<Cocktail> all;
    if (query.length == 0 && filter.length == 0) {
      first = false;
      List<Cocktail> x = await getRequest("", 1);
      return x;
    } else if (query.length == 0 && filter.length > 0) {
      return all = allCocktails.where((el) {
        return filter.contains(el.type);
      }).toList();
    } else {
      if (filter != null && filter.length > 0) {
        all = allCocktails.where((el) {
          return el.name.toLowerCase().contains(query.toLowerCase()) &&
              filter.contains(el.type);
        }).toList();
      } else {
        all = allCocktails.where((el) {
          return el.name.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
      return all;
    }
  }

  Future<List<Cocktail>> getRequest(query, code, {filter}) async {
    List<Cocktail> results = List();
/*
    if (currentType == "Tutti") {
    */
    String cocktailsList =
        await DefaultAssetBundle.of(full).loadString("assets/drinks.json");
    var jsonFile = json.decode(cocktailsList);
    for (int i = 0; i < jsonFile['drinks'].length; i++) {
      results.add(Cocktail.fromJsonFile(jsonFile['drinks'][i]));
    }
    print(results.length.toString());
    allCocktails = results;
    return results;
    /*
    } else {
      for (int i = 0; i < list.length; i++) {
        if (list[i]
            .name
            .toString()
            .toLowerCase()
            .contains(query.toString().toLowerCase())) {
          results.add(list[i]);
        }
      }
      return results;
    }
    */
  }

  /*
  Future<List<Cocktail>> getForType(type) async {
    if (type == "Tutti") {
      currentType = type;
      return getRequest("", 1);
    }

    currentType = type;
    String cocktailsList =
        await DefaultAssetBundle.of(full).loadString("assets/drinks.json");
    print(full);
    List<Cocktail> results = List();
    var jsonFile = json.decode(cocktailsList);

    for (int i = 0; i < jsonFile['drinks'].length; i++) {
      if (jsonFile['drinks'][i]['strCategory']
          .toString()
          .toLowerCase()
          .contains(type.toString().toLowerCase())) {
        results.add(Cocktail(jsonFile['drinks'][i], 1));
      }
    }

    print(results);
    if (results.length >= 60) {
      return results.sublist(0, 60);
    } else {
      return results;
    }
  }
  */

  Future<List<Cocktail>> randomCocktail() async {
    List<Cocktail> results = List();
    String cocktailsList =
        await DefaultAssetBundle.of(full).loadString("assets/drinks.json");
    var jsonFile = json.decode(cocktailsList);
    int i = Random().nextInt(jsonFile['drinks'].length);
    results.add(Cocktail.fromJsonFile(jsonFile['drinks'][i]));
    return results;
  }

  Future<List<String>> getIngredients() async {
    List<String> types = List();
    String cocktailsList =
        await DefaultAssetBundle.of(full).loadString("assets/drinks.json");
    var jsonFile = json.decode(cocktailsList);
    for (int i = 0; i < jsonFile['drinks'].length; i++) {
      Cocktail c = Cocktail.fromJsonFile(jsonFile['drinks'][i]);
      var x = c.ingredients;
      for (int j = 0; j < x.length; j++) {
        if (x[j] != null && x[j] != "") {
          if (!types.contains(x[j])) {
            types.add(x[j]);
          }
        }
      }
    }
    return types;
  }
}

//66015dea6f9baeaa04b076610a903b351398d25c

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'cocktail/cocktail.dart';
import 'cocktail/cocktails_provider.dart';

class FavoriteComponent extends StatefulWidget {
  Cocktail cName;
  FavoriteComponent(this.cName);
  @override
  _FavoriteComponentState createState() => _FavoriteComponentState();
}

class _FavoriteComponentState extends State<FavoriteComponent> {
  bool fav = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var cocktailProvider = Provider.of<CocktailsProvider>(context);
    List<String> favorites = cocktailProvider.favoritesName;

    if (favorites.contains(widget.cName.name.toString())) {
      setState(() {
        fav = true;
      });
    } else {
      setState(() {
        fav = false;
      });
    }

    return IconButton(
        icon: Icon(
          !fav ? Icons.favorite_border : Icons.favorite,
          color: Theme.of(context).primaryColor,
        ),
        onPressed: () {
          if (!fav) {
            cocktailProvider.putFav(widget.cName);
          } else {
            cocktailProvider.removeFav(widget.cName);
          }
          setState(() {
            fav = !fav;
          });
        });
  }
}

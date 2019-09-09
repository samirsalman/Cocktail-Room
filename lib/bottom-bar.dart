import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'cocktail/cocktails_provider.dart';

class BottomBar extends StatefulWidget {
  @override
  _BottomBarState createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  var current = 0;

  @override
  Widget build(BuildContext context) {
    var cocktailsProvider = Provider.of<CocktailsProvider>(context);

    return BottomNavyBar(
        onItemSelected: (value) {
          cocktailsProvider.changePage(value);
          setState(() {
            current = value;
          });
        },
        selectedIndex: current,
        items: [
          BottomNavyBarItem(
              icon: Icon(
                Icons.home,
              ),
              title: Text("Home"),
              activeColor: Color(0xFF82A2FF)),
          BottomNavyBarItem(
              icon: Icon(
                Icons.favorite,
              ),
              title: Text("Preferiti"),
              activeColor: Colors.red),
        ]);
  }
}

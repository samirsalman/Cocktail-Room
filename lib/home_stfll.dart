import 'dart:io';
import 'dart:math';
import 'package:connectivity/connectivity.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:facebook_audience_network/facebook_audience_network.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'cocktail/cocktails_provider.dart';
import 'cocktail_item.dart';
import 'favorite_component.dart';
import 'fonts/fonts_settings.dart';

class HomeS extends StatefulWidget {
  @override
  _HomeSState createState() => _HomeSState();
}

class _HomeSState extends State<HomeS> {
  TextEditingController textEditingController = TextEditingController();
  var connectionStatus;

  bool connection = true;
  bool load = true;
  bool connectionTimeout = false;

  void checkConnection() async {
    connectionStatus = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) async {
      try {
        final result = await InternetAddress.lookup('google.com');

        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          print('connected');
          setState(() {
            connection = true;
            load = false;
            connectionTimeout = false;
          });
          return;
        }
      } on SocketException catch (_) {
        print('not connected');
        setState(() {
          load = false;
          connection = false;
          connectionTimeout = false;
        });
        return;
      }
    });
  }

  List<Color> colors = [
    Colors.redAccent,
    Colors.yellow,
    Colors.orange,
    Colors.blue,
    Colors.purple
  ];

  @override
  void initState() {
    checkConnection();
    super.initState();
  }

  @override
  void dispose() {
    connectionStatus.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var cocktailsProvider = Provider.of<CocktailsProvider>(context);
    List cocktails = cocktailsProvider.cocktailsList;
    cocktailsProvider.getAllTypes(context);

    if (cocktailsProvider.lastSearch == "55555xxxx78s9e78") {
      textEditingController.text = "";
    } else {
      textEditingController.text = cocktailsProvider.lastSearch;
    }

    if (connection == false) {
      cocktailsProvider.setConnection(connection);

      return Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.error_outline,
            size: 80,
            color: Theme.of(context).primaryColor,
          ),
          Text(
            "Nessuna connessione",
            style: Fonts.hB,
          ),
        ],
      ));
    }

    if (cocktailsProvider.load && connection) {
      cocktailsProvider.setConnection(connection);

      if (cocktailsProvider.lastSearch != "55555xxxx78s9e78") {
        cocktailsProvider.searchCocktail(cocktailsProvider.lastSearch);
      } else {
        cocktailsProvider.searchCocktail("");
        cocktailsProvider.loadFavorites();
      }
      return Center(child: CircularProgressIndicator());
    }

    if (cocktails.length == 0) {
      return ListView(
        children: <Widget>[
          Container(
              width: MediaQuery.of(context).size.width * 0.7,
              margin: EdgeInsets.all(24),
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20))),
                child: TextField(
                  controller: textEditingController,
                  onEditingComplete: () {
                    cocktailsProvider
                        .searchCocktail(textEditingController.text);
                    FocusScope.of(context).requestFocus(new FocusNode());
                  },
                  style: Fonts.hB,
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      suffixIcon: IconButton(
                        icon: Icon(Icons.search),
                        onPressed: () {
                          cocktailsProvider
                              .searchCocktail(textEditingController.text);
                          FocusScope.of(context).requestFocus(new FocusNode());
                        },
                      ),
                      prefixIcon: IconButton(
                          icon: Icon(Icons.clear),
                          onPressed: () {
                            textEditingController.clear();
                            FocusScope.of(context)
                                .requestFocus(new FocusNode());
                            cocktailsProvider.searchCocktail("");
                          })),
                ),
              )),
          buildFilterRow(
              context, cocktailsProvider, MediaQuery.of(context).size),
          cocktailsProvider.banner,
          Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.not_interested,
                size: 80,
                color: Theme.of(context).primaryColor,
              ),
              Text(
                "Nessun drink trovato",
                style: Fonts.hB,
              ),
            ],
          ))
        ],
      );
    }
    var size = MediaQuery.of(context).size;
    return ListView(
      children: <Widget>[
        Container(
            width: MediaQuery.of(context).size.width * 0.7,
            margin: EdgeInsets.only(top: 24, left: 24, right: 24, bottom: 0),
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20))),
              child: TextField(
                controller: textEditingController,
                onEditingComplete: () {
                  cocktailsProvider.searchCocktail(textEditingController.text);
                  FocusScope.of(context).requestFocus(new FocusNode());
                },
                style: Fonts.hB,
                decoration: InputDecoration(
                    border: InputBorder.none,
                    suffixIcon: IconButton(
                      icon: Icon(Icons.search),
                      onPressed: () {
                        cocktailsProvider
                            .searchCocktail(textEditingController.text);
                        FocusScope.of(context).requestFocus(new FocusNode());
                      },
                    ),
                    prefixIcon: IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          textEditingController.clear();
                          FocusScope.of(context).requestFocus(new FocusNode());
                          cocktailsProvider.searchCocktail("");
                        })),
              ),
            )),
        buildFilterRow(context, cocktailsProvider, size),
        cocktailsProvider.banner,
        GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: (size.width / 150).toInt(),
                childAspectRatio: 1 / 1.25),
            physics: ScrollPhysics(),
            shrinkWrap: true,
            itemCount: cocktails.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  cocktailsProvider.decreaseClickBeforeAds();
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => CocktailItem(cocktails[index])));
                },
                child: Container(
                  child: Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                              bottomRight: Radius.circular(150),
                              bottomLeft: Radius.circular(24),
                              topLeft: Radius.circular(24),
                              topRight: Radius.circular(24))),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Container(
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      cocktails[index].name,
                                      style: Theme.of(context).textTheme.title,
                                      textAlign: TextAlign.left,
                                    ),
                                  ),
                                  width: size.width * 0.30,
                                ),
                                Align(
                                  child: FavoriteComponent(cocktails[index]),
                                ),
                              ],
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            ),
                            Text(
                              cocktails[index].type,
                              style: Theme.of(context).textTheme.display1,
                            ),
                            Hero(
                              tag: cocktails[index].name,
                              child: Container(
                                  margin: EdgeInsets.only(top: 14),
                                  width: 100,
                                  height: 100,
                                  decoration:
                                      BoxDecoration(shape: BoxShape.circle),
                                  child: ClipRRect(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(35)),
                                    child: FadeInImage(
                                      placeholder: AssetImage("assets/ph.png"),
                                      image: NetworkImage(
                                        cocktails[index].image,
                                      ),
                                    ),
                                  )),
                            ),
                          ],
                        ),
                      )),
                ),
              );
            }),
      ],
    );
  }

  Column buildFilterRow(
      BuildContext context, CocktailsProvider cocktailsProvider, Size size) {
    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              FlatButton(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Icon(
                        Icons.find_replace,
                        color: Theme.of(context).brightness == Brightness.light
                            ? Colors.black
                            : Colors.white,
                      ),
                      Text("Filtra", style: Theme.of(context).textTheme.body1)
                    ],
                  ),
                ),
                onPressed: () {
                  var type = cocktailsProvider.types;

                  showDialog(
                      context: context,
                      builder: (context) {
                        return Container(
                          child: AlertDialog(
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(24))),
                            title: Container(
                              child: Text(
                                "Seleziona il tipo di cocktail che vuoi cercare",
                                style: Theme.of(context).textTheme.body2,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            content: Container(
                                height: 300,
                                width: 300,
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: type.length,
                                  itemBuilder: (context, i) {
                                    return Column(
                                      children: <Widget>[
                                        ListTile(
                                          onTap: () {
                                            cocktailsProvider
                                                .addToFilter(type[i]);
                                            Navigator.pop(context);
                                          },
                                          title: Text(
                                            type[i],
                                            style: Theme.of(context)
                                                .textTheme
                                                .body2,
                                          ),
                                          leading: Icon(Icons.local_drink),
                                        ),
                                        Divider(
                                          color: Theme.of(context).primaryColor,
                                        )
                                      ],
                                    );
                                  },
                                )),
                          ),
                        );
                      });
                },
              ),
            ],
            crossAxisAlignment: CrossAxisAlignment.center,
          ),
        ),
        Container(
            width: size.width * 0.95,
            child: Wrap(
              children: cocktailsProvider.filter
                  .map((e) => Container(
                      margin: EdgeInsets.all(4),
                      child: Chip(
                        onDeleted: () {
                          cocktailsProvider.removeFromFilter(e);
                        },
                        label: Text(
                          e,
                          style: Fonts.p,
                        ),
                        deleteIcon: Icon(
                          Icons.remove,
                          size: 15,
                        ),
                        deleteIconColor: Colors.black,
                        backgroundColor:
                            colors[cocktailsProvider.filter.indexOf(e) % 5],
                      )))
                  .toList(),
            )),
      ],
    );
  }
}

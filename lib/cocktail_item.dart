import 'dart:convert';
import 'dart:io';
import 'package:facebook_audience_network/ad/ad_banner.dart';
import 'package:facebook_audience_network/facebook_audience_network.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'ads_page.dart';
import 'cache.dart';
import 'cocktail/cocktail.dart';
import 'cocktail/cocktails_provider.dart';
import 'favorite_component.dart';
import 'fonts/fonts_settings.dart';
import 'package:http/http.dart' as http;

class CocktailItem extends StatefulWidget {
  Cocktail cocktail;
  CocktailItem(this.cocktail);

  @override
  _CocktailItemState createState() => _CocktailItemState();
}

class _CocktailItemState extends State<CocktailItem> {
  Cocktail item;
  bool load = true;
  List<Widget> ingredients = List();
  List<Widget> qty = List();

  String getBannerAdUnitId() {
    if (Platform.isIOS) {
      return 'ca-app-pub-3570890638885974/1602530592';
    } else if (Platform.isAndroid) {
      return 'ca-app-pub-3570890638885974/1602530592';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    var cp = Provider.of<CocktailsProvider>(context);

    if (cp.clickBeforeAds == 0) {
      FacebookInterstitialAd.loadInterstitialAd(
        placementId: "422662708456327_426271244762140",
        listener: (result, value) {
          if (result == InterstitialAdResult.LOADED)
            FacebookInterstitialAd.showInterstitialAd(delay: 0);
          if (result == InterstitialAdResult.DISPLAYED) {
            cp.resetClickBeforeAds();
          }
          if (result == InterstitialAdResult.ERROR) {
            print(result);
          }
        },
      );
    }
    if (load) {
      return Scaffold(
          appBar: AppBar(
            iconTheme: IconThemeData(
              color: Colors.white, //change your color here
            ),
            centerTitle: true,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(25),
                    bottomLeft: Radius.circular(25))),
            title: Text(
              'CocktailRoom',
              style: TextStyle(color: Colors.white, fontFamily: "PaytoneOne"),
            ),
          ),
          body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white, //change your color here
        ),
        centerTitle: true,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(25),
                bottomLeft: Radius.circular(25))),
        title: Text(
          'CocktailRoom',
          style: TextStyle(color: Colors.white, fontFamily: "PaytoneOne"),
        ),
      ),
      body: Center(
          child: Container(
              margin: EdgeInsets.all(14),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Hero(
                            tag: item.name,
                            child: Container(
                                margin: EdgeInsets.all(8),
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(35)),
                                    image: DecorationImage(
                                        image: NetworkImage(
                                      item.image,
                                    ))))),
                        Container(
                          width: size.width * 0.3,
                          child: Text(
                            item.name,
                            style: Theme.of(context).textTheme.body2,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          child: Align(
                            child: FavoriteComponent(item),
                            alignment: Alignment.centerRight,
                          ),
                        ),
                      ],
                    ),
                    SingleChildScrollView(
                      child: Column(
                        children: <Widget>[
                          Container(
                            alignment: Alignment(0.5, 1),
                            child: FacebookBannerAd(
                              placementId: "422662708456327_422663381789593",
                              bannerSize: BannerSize.STANDARD,
                              listener: (result, value) {
                                switch (result) {
                                  case BannerAdResult.ERROR:
                                    print("Error: $value");
                                    break;
                                  case BannerAdResult.LOADED:
                                    print("Loaded: $value");
                                    break;
                                  case BannerAdResult.CLICKED:
                                    print("Clicked: $value");
                                    break;
                                  case BannerAdResult.LOGGING_IMPRESSION:
                                    print("Logging Impression: $value");
                                    break;
                                }
                              },
                            ),
                          ),
                          _getDetails("Tipo", item.type, Icons.info_outline),
                          _getDetails(
                              "Bicchiere", item.glass, Icons.local_drink),
                          Container(
                              width: size.width,
                              child: Card(
                                  margin: EdgeInsets.all(14),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: <Widget>[
                                      Container(
                                        color: Theme.of(context)
                                            .primaryColor
                                            .withOpacity(0.2),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            Icon(
                                              Icons.list,
                                              size: 30,
                                            ),
                                            Text(
                                              "Ingredients : ",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .body1,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        children: ingredients,
                                      )
                                    ],
                                  ))),
                          _getIstructions(
                              "Istruzioni", item.instructions, Icons.details),
                        ],
                      ),
                    ),
                  ],
                ),
              ))),
    );
  }

  Future<dynamic> translate(quote) async {
    return quote;
  }

  @override
  void initState() {
    item = widget.cocktail;
    createItem(item);

    super.initState();
  }

  createItem(item) {
    translate(item.instructions).then((value) {
      setState(() {
        item.instructions = value;
      });
      List<String> convertedQty = List();
      for (String qt in item.qty) {
        if (qt != null && qt != "") {
          qt = ozConverter(qt);
          convertedQty.add(qt);
        } else {
          qt = "A piacere";
          convertedQty.add(qt);
        }
      }
      int i = 0;
      for (var e in item.ingredients) {
        createIngredient(e, convertedQty, i);
        i++;
      }
      setState(() {
        load = false;
      });
    });
  }

  void createIngredient(e, convertedQty, i) {
    print(e);
    if (e != null && e != "") {
      ingredients.add(Container(
        margin: EdgeInsets.all(14),
        child: Container(
          margin: EdgeInsets.all(8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                e,
                style: Theme.of(context).textTheme.body1,
              ),
              Text(
                convertedQty[i],
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.body1,
              ),
            ],
          ),
        ),
      ));
    }
  }

  String ozConverter(qt) {
    bool isMultiple = false;
    var tot;
    var otherTot;

    if (qt.contains("oz")) {
      try {
        var quantita = qt.split("oz")[0];
        print(quantita);
        if (quantita.contains("/")) {
          List<String> splitting = quantita.split(" ");

          if (splitting.length > 2) {
            int size = splitting.length - 1;
            otherTot = List();
            for (int i = 0; i < size; i++) {
              if (splitting[i].contains("/")) {
                otherTot.add(double.parse(splitting[i].split("/")[0]) /
                    double.parse(splitting[i].split("/")[1]));
              } else {
                otherTot.add(double.parse(splitting[i]));
              }
            }
          } else {
            var fraz = quantita.split("/");
            var n1 = double.parse(fraz[0]);
            var n2 = double.parse(fraz[1]);
            tot = n1 / n2;
          }
        } else if (qt.contains("-")) {
          var fraz = quantita.split("-");
          var n1 = double.parse(fraz[0]);
          var n2 = double.parse(fraz[1]);
          n1 = n1 * 2.8413;
          n2 = n2 * 2.8413;
          qt = n1.round().toString() + "-" + n2.round().toString() + " cl";
          isMultiple = true;
        } else {
          tot = double.parse(quantita);
        }
        if (!isMultiple) {
          qt = "";

          if (otherTot != null) {
            qt = "";
            double total = 0;
            for (int i = 0; i < otherTot.length; i++) {
              total += otherTot[i];
            }
            total = total * 2.8413;
            qt += total.round().toString() + " cl";
          } else {
            tot = tot * 2.8413;
            qt += tot.round().toString() + " cl";
          }
        }
      } catch (_) {
        return qt;
      }
    } else if (qt.contains("dashes")) {
      qt = qt.split("dashes")[0] + " spruzzi";
    } else if (qt.contains("cub")) {
      qt = qt.split("cub")[0] + " cubo";
    }
    return qt;
  }

  Widget _getDetails(var name, var data, var icon) {
    return Container(
      height: 100,
      child: Card(
        margin: EdgeInsets.all(14),
        child: Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Icon(
                icon,
                size: 30,
              ),
              Text(
                name + " : ",
                style: Theme.of(context).textTheme.body1,
              ),
              Text(
                data,
                style: Theme.of(context).textTheme.body1,
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _getIstructions(var name, var data, var icon) {
    return Container(
      child: Card(
        margin: EdgeInsets.all(14),
        child: Column(
          children: <Widget>[
            Container(
              color: Theme.of(context).primaryColor.withOpacity(0.2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    icon,
                    size: 30,
                  ),
                  Text(
                    name + " : ",
                    style: Theme.of(context).textTheme.body1,
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                      child: Text(
                    data,
                    style: Theme.of(context).textTheme.body1,
                  ))
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

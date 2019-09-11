import 'package:facebook_audience_network/ad/ad_banner.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'cocktail/cocktails_provider.dart';
import 'cocktail_item.dart';
import 'favorite_component.dart';
import 'fonts/fonts_settings.dart';

class Favorites extends StatelessWidget {
  TextEditingController textEditingController = TextEditingController();
  List<Color> colors = [
    Colors.redAccent,
    Colors.yellow,
    Colors.orange,
    Colors.blue,
    Colors.purple
  ];
  @override
  Widget build(BuildContext context) {
    var cocktailsProvider = Provider.of<CocktailsProvider>(context);
    List cocktails = cocktailsProvider.favorites;

    if (!cocktailsProvider.connection) {
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

    if (cocktails == null || cocktails.length == 0) {
      return Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: FacebookBannerAd(
              placementId: "422662708456327_422676801788251",
              bannerSize: BannerSize.STANDARD,
              keepAlive: true,
            ),
          ),
          Expanded(
            child: Center(
                child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.insert_emoticon,
                  size: 80,
                  color: Theme.of(context).primaryColor,
                ),
                Text(
                  "Nessun Preferito",
                  style: Fonts.hB,
                ),
              ],
            )),
          ),
        ],
      );
    }
    return ListView(
      children: <Widget>[
        Container(
          width: MediaQuery.of(context).size.width * 0.7,
          margin: EdgeInsets.all(24),
        ),
        Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: FacebookBannerAd(
                placementId: "422662708456327_422663381789593",
                bannerSize: BannerSize.STANDARD,
                keepAlive: true,
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
                })),
        GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, childAspectRatio: 1 / 1.25),
            physics: ScrollPhysics(),
            shrinkWrap: true,
            itemCount: cocktails.length,
            itemBuilder: (context, index) {
              var size = MediaQuery.of(context).size;
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
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(35),
                                      image: DecorationImage(
                                          image: NetworkImage(
                                        cocktails[index].image,
                                      )))),
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
}

import 'package:facebook_audience_network/facebook_audience_network.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'bottom-bar.dart';
import 'cocktail/cocktails_provider.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'cocktail_item.dart';
import 'fonts/fonts_settings.dart';

void main() {
  FacebookAudienceNetwork.init(
          testingId: "ae537705-3919-4f54-864d-8334cc778ed8")
      .then((value) {
    runApp(MyApp());
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: <ChangeNotifierProvider>[
          ChangeNotifierProvider<CocktailsProvider>(
            builder: (_) => CocktailsProvider(context),
          ),
        ],
        child: DynamicTheme(
          defaultBrightness: Brightness.light,
          data: (brightness) => ThemeData(
              primaryColor: Color(0xFF82A2FF),
              brightness: brightness,
              appBarTheme: AppBarTheme(
                  brightness: brightness,
                  color: brightness == Brightness.light
                      ? Color(0xFF82A2FF)
                      : Colors.black),
              bottomAppBarColor:
                  brightness == Brightness.light ? Colors.white : Colors.black,
              buttonColor: Color(0xFF82A2FF),
              textTheme: TextTheme(
                  title: brightness == Brightness.light ? Fonts.h2 : Fonts.h2W,
                  body2: brightness == Brightness.light ? Fonts.h1 : Fonts.h1W,
                  body1: brightness == Brightness.light ? Fonts.h3 : Fonts.h3W,
                  display1:
                      brightness == Brightness.light ? Fonts.p : Fonts.pW)),
          themedWidgetBuilder: (context, theme) {
            return MaterialApp(
                color: Color(0xFF82A2FF),
                theme: theme,
                debugShowCheckedModeBanner: false,
                title: 'CocktailRoom',
                home: CurrentPage());
          },
        ));
  }
}

class CurrentPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var cocktailProvider = Provider.of<CocktailsProvider>(context);
    //List<String> type = Provider.of<CocktailsProvider>(context).types;

    return Scaffold(
      bottomNavigationBar: BottomBar(),
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
              icon: Icon(
                Icons.format_paint,
                color: Colors.white,
              ),
              onPressed: () {
                /*
          FlatButton(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.find_replace,
                    color: Colors.white,
                  ),
                  Text("Filtra", style: Fonts.h2W)
                ],
              ),
            ),
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (context) {
                    cocktailProvider.getAllTypes();

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
                                        Navigator.pop(context);
                                        cocktailProvider.getForType(type[i]);
                                      },
                                      title: Text(
                                        type[i],
                                        style:
                                            Theme.of(context).textTheme.body2,
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
          */
                DynamicTheme.of(context).setBrightness(
                    Theme.of(context).brightness == Brightness.dark
                        ? Brightness.light
                        : Brightness.dark);
              })
        ],
        centerTitle: false,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(25),
                bottomLeft: Radius.circular(25))),
        title: Text(
          'CocktailRoom',
          style: TextStyle(color: Colors.white, fontFamily: "PaytoneOne"),
        ),
      ),
      body: cocktailProvider.currPage,
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).buttonColor,
        onPressed: () {
          cocktailProvider.decreaseClickBeforeAds();
          cocktailProvider.randomCocktail().then((value) {
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => CocktailItem(value)));
          });
        },
        child: Icon(Icons.shuffle),
      ),
    );
  }
}

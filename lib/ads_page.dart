import 'package:facebook_audience_network/facebook_audience_network.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'cocktail/cocktails_provider.dart';

class AdsPage extends StatefulWidget {
  @override
  _AdsPageState createState() => _AdsPageState();
}

class _AdsPageState extends State<AdsPage> {
  bool _isRewardedAdLoaded = false;
  bool _isRewardedVideoComplete = false;
  CocktailsProvider cp;

  void _loadRewardedVideoAd() {
    FacebookRewardedVideoAd.loadRewardedVideoAd(
      placementId: "422662708456327_426271244762140",
      listener: (result, value) {
        print("Rewarded Ad: $result --> $value");
        if (result == RewardedVideoAdResult.LOADED) {
          setState(() {
            _isRewardedAdLoaded = true;
          });
        }
        if (result == RewardedVideoAdResult.VIDEO_COMPLETE) {
          setState(() {
            _isRewardedVideoComplete = true;
          });
          cp.resetClickBeforeAds();
        }


        /// Once a Rewarded Ad has been closed and becomes invalidated,
        /// load a fresh Ad by calling this function.
        if (result == RewardedVideoAdResult.VIDEO_CLOSED) {
          setState(() {
            _isRewardedAdLoaded = false;
          });
          _loadRewardedVideoAd();
        }
      },
    );
  }

  _showRewardedAd() {
    if (_isRewardedAdLoaded == true)
      FacebookRewardedVideoAd.showRewardedVideoAd();
    else
      print("Rewarded Ad not yet loaded!");
  }

  @override
  Widget build(BuildContext context) {
    cp = Provider.of<CocktailsProvider>(context);
    return SingleChildScrollView(
      child: _showRewardedAd(),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadRewardedVideoAd();
  }
}
